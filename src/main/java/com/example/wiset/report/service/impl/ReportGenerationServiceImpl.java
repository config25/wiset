package com.example.wiset.report.service.impl;

import com.example.wiset.client.WisetAiClient;
import com.example.wiset.dto.ai.GenerateRequest;
import com.example.wiset.dto.ai.GenerateResponse;
import com.example.wiset.dto.ai.GenerationInputs;
import com.example.wiset.support.CurrentUser;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.function.Supplier;

/**
 * AI 리포트 생성 오케스트레이션.
 *   /api/generate 를 type0(컨설팅)·type1(역량평가) 두 번 병렬 호출 → 결과를 delete-rewrite 로 적재.
 *   - type0 → 코칭 본문(장문 텍스트)        → sys_ai_report(COACHING).content
 *   - type1 → 역량 점수 JSON(공통/직무/리더십) → sys_report_competency(CRITERIA) + 강점/보완 TOP3
 *   AI 호출(느린 HTTP)은 트랜잭션 밖, 적재만 ReportPersistServiceImpl 에서 트랜잭션 처리.
 */
@Service
public class ReportGenerationServiceImpl {

    private static final Logger log = LoggerFactory.getLogger(ReportGenerationServiceImpl.class);

    /**
     * [디버그] consulting_log 오염(타 사용자 상담 누적, ISSUE-2) 격리용.
     *   true → 컨설팅 호출 직전 consulting_log 를 강제로 비워 보냄. AI 응답이 달라지면 오염이 원인임이 확정.
     *   원인 확정·DB 정리 후엔 false 로 되돌리거나 블록 제거.
     */
    private static final boolean DEBUG_CLEAR_CONSULTING_LOG = true;

    private final WisetAiClient ai;
    private final ExecutorService exec;
    private final ReportPersistServiceImpl persistService;
    private final ReportInputAssembler assembler;
    private final ObjectMapper om = new ObjectMapper();

    public ReportGenerationServiceImpl(WisetAiClient ai,
                                   @Qualifier("aiExecutor") ExecutorService exec,
                                   ReportPersistServiceImpl persistService,
                                   ReportInputAssembler assembler) {
        this.ai = ai;
        this.exec = exec;
        this.persistService = persistService;
        this.assembler = assembler;
    }

    /** type0 + type1 병렬 호출 → 적재 → 요약 반환. 한쪽 실패해도 나머지는 진행/적재. */
    public Map<String, Object> generate(GenerationInputs in) throws Exception {
        long userSn = CurrentUser.userSn();
        log.info("[리포트생성] ===== 시작 user={} =====", userSn);

        // 입력이 비어 있으면(분석 시작 플로우) 저장된 사용자 데이터에서 자동 조립
        if (isEmpty(in)) {
            in = assembler.assemble();
            log.info("[리포트생성] 입력 자동 조립(저장 데이터 기반)");
        } else {
            log.info("[리포트생성] 입력 본문 직접 전달");
        }
        log.info("[리포트생성] AI 입력 — targetRole={}, resume={}자, profile={}자, unstructured={}자, consultingLog={}자",
                in.getTargetRole(), len(in.getResumeText()), len(in.getUserProfile()),
                len(in.getUnstructuredData()), len(in.getConsultingLog()));

        // [디버그] 호출 전 consulting_log 강제 클리어(오염 격리). "" 로 바꿔 완전 빈값 실험도 가능.
        if (DEBUG_CLEAR_CONSULTING_LOG) {
            log.warn("[디버그] consulting_log 강제 클리어 — 기존 {}자 → '과거 로그 없음' (오염 격리 실험)",
                    len(in.getConsultingLog()));
            in.setConsultingLog("과거 로그 없음");
        }

        GenerateRequest consultingReq =
                GenerateRequest.consulting(in.getUserProfile(), in.getUnstructuredData(), in.getConsultingLog());
        GenerateRequest evalReq =
                GenerateRequest.competencyEval(in.getTargetRole(), in.getResumeText());

        log.info("[리포트생성] AI 병렬 호출 시작 (type0 컨설팅 + type1 역량평가)");
        long t0 = System.currentTimeMillis();
        CompletableFuture<GenerateResponse> coachingF =
                CompletableFuture.supplyAsync(safe(() -> ai.generate("/api/consulting", consultingReq), "consulting"), exec);
        CompletableFuture<GenerateResponse> evalF =
                CompletableFuture.supplyAsync(safe(() -> ai.generate("/api/competency-eval", evalReq), "competency-eval"), exec);
        CompletableFuture.allOf(coachingF, evalF).join();
        long elapsedMs = System.currentTimeMillis() - t0;

        GenerateResponse coaching = coachingF.join();
        GenerateResponse eval = evalF.join();
        String coachingText = coaching == null ? null : coaching.getResponse();
        Map<String, Map<String, Double>> groups = parseCompetency(eval == null ? null : eval.getResponse());
        log.info("[리포트생성] AI 응답 수신 — 병렬 {}ms, 코칭 {}자, 기준역량 {}그룹", elapsedMs,
                len(coachingText), groups == null ? 0 : groups.size());

        String[] banner = composeBanner(in.getTargetRole(), in.getExperienceLevel());
        log.info("[리포트생성] DB 적재 시작 — persist 호출 (코칭 {}자, 역량그룹 {}개)",
                len(coachingText), groups == null ? 0 : groups.size());
        Map<String, Object> persisted;
        try {
            persisted = persistService.persist(userSn, coachingText, banner[0], banner[1], banner[2], groups);
            log.info("[리포트생성] ✅ DB 적재 성공 → {}", persisted);
        } catch (Exception e) {
            log.error("[리포트생성] ❌ DB 적재 실패 — 트랜잭션 롤백됨: {}", e.toString(), e);
            throw e;
        }
        log.info("[리포트생성] ===== 완료 — {} =====", persisted);

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("ok", true);
        out.put("elapsedMs", elapsedMs);
        out.put("coachingGenerated", coachingText != null && !coachingText.trim().isEmpty());
        out.put("competencyGroups", groups == null ? 0 : groups.size());
        out.put("sentToAi", in); // AI 로 보낸 입력(조립 결과) 그대로 — 투명성/디버깅용
        out.putAll(persisted);
        return out;
    }

    /** 입력 묶음이 사실상 비었는지(자동 조립 필요 여부). */
    private static boolean isEmpty(GenerationInputs in) {
        if (in == null) return true;
        return blank(in.getUserProfile()) && blank(in.getUnstructuredData()) && blank(in.getConsultingLog())
                && blank(in.getTargetRole()) && blank(in.getResumeText());
    }

    private static boolean blank(String s) { return s == null || s.trim().isEmpty(); }

    private static int len(String s) { return s == null ? 0 : s.length(); }

    /**
     * 코칭 배너(제목/부제목/키워드) 조립 — 프로필 기반(AI 아님). targetRole="[업종 - 직무]", expLevel=신입/경력.
     * 반환 [title, subtitle, keywords(줄바꿈 아이콘|라벨)]. 정보 없으면 해당 값 null.
     */
    private static String[] composeBanner(String targetRole, String expLevel) {
        String industry = "", job = "";
        if (targetRole != null) {
            String s = targetRole.replaceAll("^\\[|\\]$", "").trim(); // "IT·SW - 공정개발"
            int dash = s.indexOf(" - ");
            if (dash >= 0) { industry = s.substring(0, dash).trim(); job = s.substring(dash + 3).trim(); }
            else industry = s;
        }
        if (industry.isEmpty() && job.isEmpty()) return new String[]{null, null, null};

        String goal = "경력".equals(expLevel) ? "이직" : "신규 취업"; // 신입/미상 → 신규 취업
        String indPart = industry.isEmpty() ? "" : industry + " 산업 ";
        String jobPart = job.isEmpty() ? "" : job + " 직무로 ";
        String title = indPart + jobPart + goal + "을 준비하시는 회원님, 환영합니다.";
        String subtitle = (industry.isEmpty() ? "" : industry + " ") + (job.isEmpty() ? "" : job + " ") + goal + " 전략";
        StringBuilder kw = new StringBuilder();
        if (!industry.isEmpty()) kw.append("trending|").append(industry).append(" 산업");
        if (!job.isEmpty()) kw.append(kw.length() > 0 ? "\n" : "").append("layers|").append(job);
        kw.append(kw.length() > 0 ? "\n" : "").append("refresh|").append(goal);
        return new String[]{title, subtitle.trim(), kw.toString()};
    }

    /**
     * type1 응답 텍스트(JSON) → {그룹명:{역량명:0~3점}}. 점수 못 뽑으면 null(적재 생략).
     *   역량값은 두 형식을 모두 허용한다(서버 응답이 점수만 → 객체로 진화):
     *     2겹: {"공통활동":{"문제해결":2.0}}                       — 점수를 숫자로 직접
     *     3겹: {"공통활동":{"문제해결":{"score":2.0,"reason":..,"sources":[]}}} — 객체에서 score 추출
     *   ※ reason·sources 는 현재 적재 스키마(점수만)에 자리가 없어 보존하지 않는다(별도 과제).
     */
    private Map<String, Map<String, Double>> parseCompetency(String responseText) {
        if (responseText == null || responseText.trim().isEmpty()) {
            log.warn("[역량파싱] type1 응답이 비어 있음 → 역량 적재 생략(에러 아님)");
            return null;
        }
        try {
            JsonNode root = om.readTree(responseText);
            Map<String, Map<String, Double>> groups = new LinkedHashMap<>();
            int totalComp = 0, scored = 0;
            for (Iterator<Map.Entry<String, JsonNode>> git = root.fields(); git.hasNext(); ) {
                Map.Entry<String, JsonNode> group = git.next();
                if (!group.getValue().isObject()) {
                    log.warn("[역량파싱] 그룹 '{}' 값이 오브젝트가 아님(type={}) → 그룹 통째 스킵",
                            group.getKey(), group.getValue().getNodeType());
                    continue;
                }
                Map<String, Double> scores = new LinkedHashMap<>();
                for (Iterator<Map.Entry<String, JsonNode>> cit = group.getValue().fields(); cit.hasNext(); ) {
                    Map.Entry<String, JsonNode> comp = cit.next();
                    totalComp++;
                    Double score = extractScore(comp.getValue());
                    if (score != null) {
                        scores.put(comp.getKey(), score);
                        scored++;
                    } else {
                        log.warn("[역량파싱] 역량 '{}.{}' 에서 점수 추출 실패 — 값={} (점수 키명/형식 확인)",
                                group.getKey(), comp.getKey(), comp.getValue());
                    }
                }
                if (!scores.isEmpty()) groups.put(group.getKey(), scores);
            }
            // 최종 파싱 결과를 항상 찍어, '에러 없이 적재 생략'되는 지점을 눈에 보이게 한다.
            log.info("[역량파싱] 최종 결과 — 그룹 {}개, 점수 추출 {}/{}개, groups={}",
                    groups.size(), scored, totalComp, groups);
            if (groups.isEmpty()) {
                log.warn("[역량파싱] ⚠ 추출 점수 0개 → 역량 적재가 '에러 없이' 생략됩니다. "
                        + "AI 점수 키명(score/Score/value 등)·구조를 확인하세요.");
                return null;
            }
            return groups;
        } catch (Exception e) {
            log.warn("역량 JSON 파싱 실패 — 역량 적재 생략. 응답: {}", responseText, e);
            return null;
        }
    }

    /** 점수로 인정하는 키(대소문자 무시): score / value / 점수. */
    private static final String[] SCORE_KEYS = {"score", "value", "점수"};

    /**
     * 역량값 노드에서 점수 추출. 못 뽑으면 null(→ 호출부에서 로그 후 스킵).
     *   - 숫자 노드(2.0) → 그대로
     *   - 문자열 숫자("2.0") → 파싱
     *   - 오브젝트({score|Score|value|점수: ...}) → 해당 키에서 추출(대소문자 무시, 문자열 숫자도 허용)
     */
    private static Double extractScore(JsonNode v) {
        if (v == null || v.isNull()) return null;
        if (v.isNumber()) return v.asDouble();
        if (v.isTextual()) return parseNum(v.asText());
        if (v.isObject()) {
            for (Iterator<String> it = v.fieldNames(); it.hasNext(); ) {
                String key = it.next();
                for (String want : SCORE_KEYS) {
                    if (key.equalsIgnoreCase(want)) {
                        JsonNode sv = v.get(key);
                        if (sv != null && sv.isNumber()) return sv.asDouble();
                        if (sv != null && sv.isTextual()) return parseNum(sv.asText());
                    }
                }
            }
        }
        return null;
    }

    private static Double parseNum(String s) {
        if (s == null) return null;
        try {
            return Double.parseDouble(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    /** 호출 실패 시 예외로 전체를 죽이지 않고 null 반환(로그만). */
    private Supplier<GenerateResponse> safe(Supplier<GenerateResponse> call, String label) {
        return () -> {
            try {
                return call.get();
            } catch (Exception e) {
                log.error("AI 호출 실패: {}", label, e);
                return null;
            }
        };
    }
}

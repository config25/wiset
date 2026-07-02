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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
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
     *   ISSUE-2 원인이던 seed-cnsl-real.sql(운영 덤프 9건) 제거 완료 → 격리 불필요하여 off.
     *   (정상 시드 seed-cnsl-user1.sql 의 익명화 데이터만 AI 입력으로 흐름)
     */
    private static final boolean DEBUG_CLEAR_CONSULTING_LOG = false;

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

        // 시장정합도/JD 매칭 — 스크랩 공고별 market-fit. experience_level 은 필수라 미지정 시 '신입'.
        String expLevel = blank(in.getExperienceLevel()) ? "신입" : in.getExperienceLevel();
        List<Map<String, Object>> jobScraps = in.getJobScraps();
        int jdCount = jobScraps == null ? 0 : jobScraps.size();

        log.info("[리포트생성] AI 호출 시작 — 동시 2개씩 처리 (컨설팅 + 역량평가 + 시장정합도 {}건)", jdCount);
        long t0 = System.currentTimeMillis();
        CompletableFuture<GenerateResponse> coachingF =
                CompletableFuture.supplyAsync(safe(() -> ai.generate("/api/consulting", consultingReq), "consulting"), exec);
        CompletableFuture<GenerateResponse> evalF =
                CompletableFuture.supplyAsync(safe(() -> ai.generate("/api/competency-eval", evalReq), "competency-eval"), exec);
        List<CompletableFuture<Map<String, Object>>> marketFs = new ArrayList<>();
        if (jobScraps != null) {
            for (Map<String, Object> jd : jobScraps) {
                String jobText = str(jd.get("jobPostingText"));
                if (jobText == null || jobText.trim().isEmpty()) continue;
                final Map<String, Object> jdf = jd;
                GenerateRequest mfReq = GenerateRequest.marketFit(jobText, in.getResumeText(), expLevel);
                marketFs.add(CompletableFuture
                        .supplyAsync(safe(() -> ai.generate("/api/market-fit", mfReq), "market-fit"), exec)
                        .thenApply(resp -> parseMarketFit(jdf, resp == null ? null : resp.getResponse())));
            }
        }
        List<CompletableFuture<?>> all = new ArrayList<>();
        all.add(coachingF);
        all.add(evalF);
        all.addAll(marketFs);

        // 진행률 로그 — 각 호출 완료 시 (n/전체)·경과초를 한 줄로. 거대한 프롬프트/응답 덤프와 분리해 흐름 추적용("[진행]" grep).
        final int totalCalls = all.size();
        final java.util.concurrent.atomic.AtomicInteger doneCalls = new java.util.concurrent.atomic.AtomicInteger();
        log.info("[진행] ▶ AI 호출 {}개 시작 (컨설팅 + 역량평가 + 시장정합도 {}건) — 이 서버는 호출당 수십초~수분 걸립니다", totalCalls, marketFs.size());
        coachingF.whenComplete((r, e) -> log.info("[진행] ✔ {}/{} 컨설팅(코칭) {} · 경과 {}초",
                doneCalls.incrementAndGet(), totalCalls, r != null && r.getResponse() != null ? "완료" : "응답없음", (System.currentTimeMillis() - t0) / 1000));
        evalF.whenComplete((r, e) -> log.info("[진행] ✔ {}/{} 역량평가 {} · 경과 {}초",
                doneCalls.incrementAndGet(), totalCalls, r != null && r.getResponse() != null ? "완료" : "응답없음", (System.currentTimeMillis() - t0) / 1000));
        for (int mi = 0; mi < marketFs.size(); mi++) {
            final int idx = mi + 1;
            marketFs.get(mi).whenComplete((r, e) -> log.info("[진행] ✔ {}/{} 시장정합도#{} {} · 경과 {}초",
                    doneCalls.incrementAndGet(), totalCalls, idx, r != null ? "완료" : "스킵/실패", (System.currentTimeMillis() - t0) / 1000));
        }

        CompletableFuture.allOf(all.toArray(new CompletableFuture[0])).join();
        long elapsedMs = System.currentTimeMillis() - t0;
        log.info("[진행] ▣ AI 전체 완료 ({}/{}) · 총 {}초 → DB 적재 시작", doneCalls.get(), totalCalls, elapsedMs / 1000);

        GenerateResponse coaching = coachingF.join();
        GenerateResponse eval = evalF.join();
        String coachingText = coaching == null ? null : coaching.getResponse();
        Map<String, Map<String, CompetencyEval>> groups = parseCompetency(eval == null ? null : eval.getResponse());
        List<Map<String, Object>> marketResults = new ArrayList<>();
        for (CompletableFuture<Map<String, Object>> f : marketFs) {
            Map<String, Object> r = f.join();
            if (r != null) marketResults.add(r);
        }
        log.info("[리포트생성] AI 응답 수신 — 병렬 {}ms, 코칭 {}자, 기준역량 {}그룹, 시장정합도 {}건", elapsedMs,
                len(coachingText), groups == null ? 0 : groups.size(), marketResults.size());

        String[] banner = composeBanner(in.getTargetRole(), in.getExperienceLevel());
        log.info("[리포트생성] DB 적재 시작 — persist 호출 (코칭 {}자, 역량그룹 {}개)",
                len(coachingText), groups == null ? 0 : groups.size());
        Map<String, Object> persisted;
        try {
            persisted = persistService.persist(userSn, coachingText, banner[0], banner[1], banner[2], groups, marketResults);
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

    private static String str(Object o) { return o == null ? null : String.valueOf(o); }

    /**
     * market-fit 응답(JSON) → JD 매칭·시장정합도 적재용 Map. 실패 시 null(해당 공고만 스킵).
     *   반환: {jobPostingId, company, role, meta, fitRate(int), areas:{Knowledge|Skill|Attitude:[{name,score100,scoreRaw,reason,sources[]}]}}
     */
    private Map<String, Object> parseMarketFit(Map<String, Object> jd, String responseText) {
        if (responseText == null || responseText.trim().isEmpty()) {
            log.warn("[시장정합도] 응답 비어 있음 → 이 공고 스킵 (jobPostingId={})", jd.get("jobPostingId"));
            return null;
        }
        try {
            JsonNode root = om.readTree(responseText);
            JsonNode ev = root.path("evaluation");
            Map<String, List<Map<String, Object>>> areas = new LinkedHashMap<>();
            areas.put("Knowledge", parseReqs(ev.path("knowledge")));
            areas.put("Skill", parseReqs(ev.path("skill")));
            areas.put("Attitude", parseReqs(ev.path("attitude")));
            int reqTotal = areas.get("Knowledge").size() + areas.get("Skill").size() + areas.get("Attitude").size();
            if (reqTotal == 0) {
                log.warn("[시장정합도] 요구역량 0건 파싱 → 스킵 (jobPostingId={}, 응답={})", jd.get("jobPostingId"), responseText);
                return null;
            }
            double mfs = root.path("market_fit_score").asDouble(Double.NaN);
            int fitRate = Double.isNaN(mfs) ? avgScore100(areas) : (int) Math.round(mfs);
            Map<String, Object> out = new LinkedHashMap<>();
            out.put("jobPostingId", jd.get("jobPostingId"));
            out.put("company", jd.get("company"));
            out.put("role", jd.get("role"));
            out.put("meta", jd.get("meta"));
            out.put("fitRate", fitRate);
            out.put("areas", areas);
            return out;
        } catch (Exception e) {
            log.warn("[시장정합도] JSON 파싱 실패 → 스킵 (jobPostingId={}). 응답: {}", jd.get("jobPostingId"), responseText, e);
            return null;
        }
    }

    /** evaluation.&lt;area&gt; 배열 → [{name, scoreRaw(0~3), score100, reason, sources[]}]. */
    private static List<Map<String, Object>> parseReqs(JsonNode arr) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (arr != null && arr.isArray()) {
            for (JsonNode n : arr) {
                String name = n.path("requirement").asText(null);
                if (name == null || name.trim().isEmpty()) continue;
                double raw = n.path("score").asDouble(0);   // 0~3
                List<String> sources = new ArrayList<>();
                JsonNode src = n.path("sources");
                if (src.isArray()) for (JsonNode s : src) { String v = s.asText(null); if (v != null && !v.trim().isEmpty()) sources.add(v.trim()); }
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("name", name.trim());
                m.put("scoreRaw", raw);
                m.put("score100", (int) Math.round(raw / 3.0 * 100));
                m.put("reason", n.path("reason").asText(null));
                m.put("sources", sources);
                list.add(m);
            }
        }
        return list;
    }

    /** 요구역량 평균 score100 (market_fit_score 누락 시 폴백). */
    private static int avgScore100(Map<String, List<Map<String, Object>>> areas) {
        int sum = 0, n = 0;
        for (List<Map<String, Object>> l : areas.values()) for (Map<String, Object> q : l) { sum += (Integer) q.get("score100"); n++; }
        return n == 0 ? 0 : Math.round((float) sum / n);
    }

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
        // 희망 업종(14개 관련직) → 배너 대분류(4개: AI 정보보안/화학바이오/반도체/일반산업)로 묶어 표시.
        String[] sector = sectorOf(industry);           // {대분류명, 아이콘}
        String secName = industry.isEmpty() ? "" : sector[0];
        String indPart = secName.isEmpty() ? "" : withIndustrySuffix(secName) + " ";
        String jobPart = job.isEmpty() ? "" : job + " 직무로 ";
        String title = indPart + jobPart + goal + "을 준비하시는 회원님, 환영합니다.";
        String subtitle = (secName.isEmpty() ? "" : secName + " ") + (job.isEmpty() ? "" : job + " ") + goal + " 전략";
        StringBuilder kw = new StringBuilder();
        if (!secName.isEmpty()) kw.append(sector[1]).append("|").append(withIndustrySuffix(secName));
        if (!job.isEmpty()) kw.append(kw.length() > 0 ? "\n" : "").append(iconFor(job, JOB_ICONS)).append("|").append(job);
        kw.append(kw.length() > 0 ? "\n" : "").append(goalIcon(goal)).append("|").append(goal);
        return new String[]{title, subtitle.trim(), kw.toString()};
    }

    /**
     * 희망 업종(career-goal.jsp 14개 "관련직") → 배너 대분류(4개) 매핑.
     *   실장님 지정 구분: AI 정보보안 / 화학바이오 / 반도체 / 일반산업(그 외 전부).
     *   각 행 = {대분류명, 아이콘, 관련직 부분문자열...}, 위에서부터 첫 부분일치 승. 미매칭은 일반산업.
     * ※ 아이콘명은 ai-coaching.jsp 의 JS ICONS 맵에 등록돼 있어야 렌더됨(미등록 시 빈 SVG).
     */
    private static final String[][] SECTORS = {
            // 키워드는 career-goal 원본 라벨(정보통신 관련직 등) + buildTargetRole 이 미리 바꾼 코드(AI_정보보안 등) 둘 다 잡는다.
            {"AI 정보보안", "shield", "정보통신", "정보보안"},                    // 정보통신 관련직 · "AI_정보보안"
            {"화학바이오",  "flask",  "생명", "자연과학", "화학", "식품", "바이오"}, // 생명·자연과학 / 화학·식품가공 관련직 · "화학바이오"
            {"반도체",      "zap",    "전기", "전자", "반도체"},                  // 전기/전자 관련직 · "반도체"
    };
    // 그 외(교육·보건의료·디자인/방송·운전/운송·건축/토목·기계·재료·환경/에너지/안전·기술영업/판매·기타) → 일반산업
    private static final String[] DEFAULT_SECTOR = {"일반산업", "doc"};

    /** 관련직 라벨 → {대분류명, 아이콘}. 표의 부분문자열 중 첫 매칭, 없으면 일반산업. */
    private static String[] sectorOf(String industry) {
        if (industry != null) {
            for (String[] row : SECTORS) {
                for (int i = 2; i < row.length; i++) {
                    if (industry.contains(row[i])) return new String[]{row[0], row[1]};
                }
            }
        }
        return DEFAULT_SECTOR;
    }

    /** 대분류명에 " 산업" 접미사 부여(이미 '산업'으로 끝나면 그대로 — '일반산업 산업' 방지). */
    private static String withIndustrySuffix(String sector) {
        return sector.endsWith("산업") ? sector : sector + " 산업";
    }

    private static final String[][] JOB_ICONS = {
            {"bulb",      "연구개발"},   // 연구개발직 (전구)
            {"clipboard", "연구지원"},   // 연구지원직 (클립보드)
            {"layers",    "기술"},       // 기술직 (레이어)
    };

    /** 텍스트에 표의 키워드가 포함되면 해당 아이콘 반환(위에서부터 첫 매칭). 없으면 기본 briefcase. */
    private static String iconFor(String text, String[][] table) {
        if (text != null) {
            for (String[] row : table) {
                for (int i = 1; i < row.length; i++) {
                    if (text.contains(row[i])) return row[0];
                }
            }
        }
        return "briefcase";
    }

    /**
     * 경력목표 → 강조 칩 아이콘(09 배너 아이콘 매핑 기준).
     *   경력성장→trending, 재취업→compass, 이직→refresh, 그 외(신규 취업 등)→rocket.
     */
    private static String goalIcon(String goal) {
        if (goal != null) {
            if (goal.contains("성장"))   return "trending";
            if (goal.contains("재취업")) return "compass";
            if (goal.contains("이직"))   return "refresh";
        }
        return "rocket";
    }

    /**
     * type1 응답 텍스트(JSON) → {그룹명:{역량명:CompetencyEval}}. 점수 못 뽑으면 null(적재 생략).
     *   역량값은 두 형식을 모두 허용한다(서버 응답이 점수만 → 객체로 진화):
     *     2겹: {"공통활동":{"문제해결":2.0}}                       — 점수를 숫자로 직접(근거·출처 없음)
     *     3겹: {"공통활동":{"문제해결":{"score":2.0,"reason":..,"sources":[..]}}} — 점수+근거(reason)+출처(sources) 보존
     *   근거(reason)→comment, 출처(sources)→sys_report_competency_source 로 적재된다(ISSUE-1 잔여분 반영).
     */
    private Map<String, Map<String, CompetencyEval>> parseCompetency(String responseText) {
        if (responseText == null || responseText.trim().isEmpty()) {
            log.warn("[역량파싱] type1 응답이 비어 있음 → 역량 적재 생략(에러 아님)");
            return null;
        }
        try {
            JsonNode root = om.readTree(responseText);
            Map<String, Map<String, CompetencyEval>> groups = new LinkedHashMap<>();
            int totalComp = 0, scored = 0;
            for (Iterator<Map.Entry<String, JsonNode>> git = root.fields(); git.hasNext(); ) {
                Map.Entry<String, JsonNode> group = git.next();
                if (!group.getValue().isObject()) {
                    log.warn("[역량파싱] 그룹 '{}' 값이 오브젝트가 아님(type={}) → 그룹 통째 스킵",
                            group.getKey(), group.getValue().getNodeType());
                    continue;
                }
                Map<String, CompetencyEval> scores = new LinkedHashMap<>();
                for (Iterator<Map.Entry<String, JsonNode>> cit = group.getValue().fields(); cit.hasNext(); ) {
                    Map.Entry<String, JsonNode> comp = cit.next();
                    totalComp++;
                    JsonNode node = comp.getValue();
                    Double score = extractScore(node);
                    if (score != null) {
                        scores.put(comp.getKey(), new CompetencyEval(score, extractReason(node), extractSources(node)));
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

    /** 근거(해설)로 인정하는 키(대소문자 무시). 3겹 객체일 때만 존재. */
    private static final String[] REASON_KEYS = {"reason", "근거", "comment", "평어", "explanation", "desc"};
    /** 출처 배열 키 / 출처 원소의 구분·상세 키. */
    private static final String[] SOURCE_ARRAY_KEYS = {"sources", "source", "출처", "근거출처", "evidence"};
    private static final String[] SRC_TYPE_KEYS   = {"type", "source_type", "sourceType", "t", "구분", "출처"};
    private static final String[] SRC_DETAIL_KEYS = {"detail", "d", "text", "내용", "근거", "desc", "value"};

    /** 역량값 노드에서 근거(reason) 추출. 오브젝트가 아니거나 없으면 null. */
    private static String extractReason(JsonNode v) {
        if (v == null || !v.isObject()) return null;
        return firstTextByKeys(v, REASON_KEYS);
    }

    /**
     * 역량값 노드에서 근거 출처(sources) 추출 → 각 [sourceType(nullable), detail].
     *   원소가 문자열이면 detail 로, 오브젝트면 구분/상세 키에서 추출. 없으면 빈 리스트.
     */
    private static List<String[]> extractSources(JsonNode v) {
        List<String[]> out = new ArrayList<>();
        if (v == null || !v.isObject()) return out;
        JsonNode arr = firstNodeByKeys(v, SOURCE_ARRAY_KEYS);
        if (arr == null || !arr.isArray()) return out;
        for (JsonNode el : arr) {
            if (el == null || el.isNull()) continue;
            if (el.isTextual()) {
                String d = el.asText().trim();
                if (!d.isEmpty()) out.add(new String[]{null, d});
            } else if (el.isObject()) {
                String type = firstTextByKeys(el, SRC_TYPE_KEYS);
                String detail = firstTextByKeys(el, SRC_DETAIL_KEYS);
                if (detail == null && type != null) { detail = type; type = null; } // 값이 하나뿐이면 detail 로
                if (detail != null) out.add(new String[]{type, detail});
            }
        }
        return out;
    }

    /** 오브젝트에서 keys 중 하나에 해당하는(대소문자 무시) 첫 노드. 없으면 null. */
    private static JsonNode firstNodeByKeys(JsonNode obj, String[] keys) {
        for (String k : keys) {
            for (Iterator<Map.Entry<String, JsonNode>> it = obj.fields(); it.hasNext(); ) {
                Map.Entry<String, JsonNode> e = it.next();
                if (e.getKey().equalsIgnoreCase(k)) return e.getValue();
            }
        }
        return null;
    }

    /** firstNodeByKeys 결과를 텍스트로. 숫자면 문자열화, 그 외/빈값이면 null. */
    private static String firstTextByKeys(JsonNode obj, String[] keys) {
        JsonNode n = firstNodeByKeys(obj, keys);
        if (n == null) return null;
        if (n.isTextual()) { String s = n.asText().trim(); return s.isEmpty() ? null : s; }
        if (n.isNumber()) return n.asText();
        return null;
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

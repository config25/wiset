package com.example.wiset.report.service.impl;

import com.example.wiset.client.WisetAiClient;
import com.example.wiset.dto.ai.GenerateRequest;
import com.example.wiset.dto.ai.GenerateResponse;
import com.example.wiset.dto.ai.GenerationInputs;
import com.example.wiset.support.CurrentUser;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

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
        Map<String, Object> persisted = persistService.persist(userSn, coachingText, banner[0], banner[1], banner[2], groups);
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

    /** type1 응답 텍스트(JSON) → {그룹명:{역량명:0~3점}}. 파싱 실패 시 null(적재 생략). */
    private Map<String, Map<String, Double>> parseCompetency(String responseText) {
        if (responseText == null || responseText.trim().isEmpty()) return null;
        try {
            return om.readValue(responseText, new TypeReference<Map<String, Map<String, Double>>>() {});
        } catch (Exception e) {
            log.warn("역량 JSON 파싱 실패 — 역량 적재 생략. 응답: {}", responseText, e);
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

package com.example.wiset.report.service.impl;

import com.example.wiset.support.CommonDAO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * AI 생성 결과를 리포트 테이블에 delete-rewrite 로 적재(트랜잭션).
 *   - 코칭 본문(type0)        → sys_ai_report(COACHING).content 덮어쓰기
 *   - 기준정합도 점수(type1)  → sys_report_competency(CRITERIA) 삭제 후 재삽입 + 강점/보완 TOP3(HIGHLIGHT) 파생
 *   시장정합도/CFI/JD/해설·근거는 손대지 않음(시드 유지). 점수 0~3 → 0~100(×100/3).
 *
 * // [wbridge] @Mapper 제거 → CommonDAO(report.write.*) 이식. DTO 유지.
 */
@Service
public class ReportPersistServiceImpl {

    private static final Logger log = LoggerFactory.getLogger(ReportPersistServiceImpl.class);

    /** AI 가 새로 쓰는 fit_type (삭제 대상). 시장정합도(MARKET)는 보존. */
    private static final List<String> AI_TYPES = Arrays.asList("CRITERIA", "HIGHLIGHT");
    private static final String[] STRENGTH_ICONS = {"flask", "chart", "lightbulb"};
    private static final String[] GAP_ICONS = {"code", "shield", "users"};

    private final CommonDAO commonDAO;

    public ReportPersistServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    /**
     * @param coachingText type0 응답(코칭 본문). null/blank 면 코칭 미적재.
     * @param groups       type1 파싱 결과 {그룹명:{역량명:0~3점}}. null/empty 면 역량 미적재.
     * @return 적재 요약(diagnosisId, reportId 들, 건수)
     */
    @Transactional
    public Map<String, Object> persist(long userSn, String coachingText,
                                       String bannerTitle, String bannerSubtitle, String bannerKeywords,
                                       Map<String, Map<String, Double>> groups) throws Exception {
        log.info("[적재] ===== 시작 user={}, 코칭={}자, 역량그룹={}개 =====",
                userSn, coachingText == null ? 0 : coachingText.length(), groups == null ? 0 : groups.size());
        Map<String, Object> dp = new HashMap<>();
        dp.put("userSn", userSn);
        Long diagnosisId = commonDAO.selectOne("report.write.findLatestDiagnosisId", dp);
        if (diagnosisId == null) {
            Map<String, Object> h = new HashMap<>();
            h.put("userSn", userSn);
            commonDAO.insert("report.write.insertDiagnosis", h);
            diagnosisId = ((Number) h.get("diagnosisId")).longValue();
            log.info("[적재] 진단 신규 생성 → diagnosisId={}", diagnosisId);
        } else {
            log.info("[적재] 기존 diagnosisId={} 사용", diagnosisId);
        }
        //이런 식이면 최신 이력 하나만 볼 수 있는 상황인데 괜찮을까욥

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("diagnosisId", diagnosisId);

        // 코칭 본문 + 배너(프로필 기반 조립값)
        if (coachingText != null && !coachingText.trim().isEmpty()) {
            long coachingReportId = ensureReport(userSn, diagnosisId, "COACHING");
            Map<String, Object> cp = new HashMap<>();
            cp.put("reportId", coachingReportId);
            cp.put("content", coachingText);
            int contentRows = commonDAO.update("report.write.updateReportContent", cp);
            log.info("[적재] 코칭 본문 UPDATE 실행 → reportId={} ({}자), 적용 {}행{}", coachingReportId,
                    coachingText.length(), contentRows, contentRows == 0 ? "  ⚠ 0행(대상 리포트 매칭 실패)" : "");
            if (bannerTitle != null && !bannerTitle.trim().isEmpty()) {
                Map<String, Object> bp = new HashMap<>();
                bp.put("reportId", coachingReportId);
                bp.put("bannerTitle", bannerTitle);
                bp.put("subtitle", bannerSubtitle);
                bp.put("keywords", bannerKeywords);
                commonDAO.update("report.write.updateReportBanner", bp);
                log.info("[적재] 코칭 배너 갱신 → reportId={} title='{}'", coachingReportId, bannerTitle);
            }
            out.put("coachingReportId", coachingReportId);
            out.put("coachingChars", coachingText.length());
        } else {
            log.info("[적재] 코칭 본문 없음 — 건너뜀");
        }

        // 기준정합도(CRITERIA) + 강점/보완 TOP3 + CFI 파생. 시장정합도(MARKET)는 시드 유지(손 안 댐).
        if (groups != null && !groups.isEmpty()) {
            long activityReportId = ensureReport(userSn, diagnosisId, "ACTIVITY_ANALYSIS");
            int n = saveCriteria(activityReportId, groups);
            log.info("[적재] 기준정합도 delete-rewrite → reportId={}, 역량 {}개 (시장정합도/JD 보존)", activityReportId, n);
            out.put("activityReportId", activityReportId);
            out.put("criteriaCount", n);
        } else {
            log.info("[적재] 역량 데이터 없음 — 건너뜀");
        }
        log.info("[적재] ===== 완료 user={} → {} =====", userSn, out);
        return out;
    }

    private long ensureReport(long userSn, long diagnosisId, String reportType) throws Exception {
        Map<String, Object> fp = new HashMap<>();
        fp.put("userSn", userSn);
        fp.put("reportType", reportType);
        Long id = commonDAO.selectOne("report.write.findReportId", fp); // 기존 시드 리포트 재사용(진단 무관)
        if (id != null) {
            log.info("[적재] reportType={} → 기존 reportId={} 재사용", reportType, id);
            return id;
        }
        Map<String, Object> h = new HashMap<>();
        h.put("userSn", userSn);
        h.put("diagnosisId", diagnosisId);
        h.put("reportType", reportType);
        commonDAO.insert("report.write.insertReport", h);
        long newId = ((Number) h.get("reportId")).longValue();
        log.info("[적재] reportType={} → 신규 reportId={} 생성", reportType, newId);
        return newId;
    }

    /** CRITERIA + HIGHLIGHT 만 비우고 새로 적재(MARKET 보존). 반환=기준역량 건수. */
    private int saveCriteria(long reportId, Map<String, Map<String, Double>> groups) throws Exception {
        Map<String, Object> dp = new HashMap<>();
        dp.put("reportId", reportId);
        dp.put("types", AI_TYPES);
        int delSrc = commonDAO.delete("report.write.deleteCompetencySourcesByTypes", dp);
        int delComp = commonDAO.delete("report.write.deleteCompetenciesByTypes", dp);
        log.info("[적재] 기존 CRITERIA/HIGHLIGHT 삭제 → sources {}행, competency {}행 (reportId={})",
                delSrc, delComp, reportId);

        int order = 10, count = 0;
        List<String[]> ranked = new ArrayList<>(); // [name, score100]
        for (Map.Entry<String, Map<String, Double>> g : groups.entrySet()) {
            String groupCode = stripActivity(g.getKey());
            if (g.getValue() == null) continue;
            for (Map.Entry<String, Double> e : g.getValue().entrySet()) {
                if (e.getValue() == null) continue;
                int s100 = toHundred(e.getValue());
                Map<String, Object> r = new HashMap<>();
                r.put("fitType", "CRITERIA");
                r.put("groupCode", groupCode);
                r.put("name", e.getKey());
                r.put("myScore", s100);
                r.put("sortOrder", order++);
                Map<String, Object> ip = new HashMap<>();
                ip.put("reportId", reportId);
                ip.put("c", r);
                commonDAO.insert("report.write.insertCompetency", ip);
                ranked.add(new String[]{e.getKey(), String.valueOf(s100)});
                count++;
            }
        }
        log.info("[적재] CRITERIA 역량 INSERT {}건 (reportId={})", count, reportId);

        // 강점 TOP3(높은 점수) / 보완 TOP3(낮은 점수) — required/comment/근거는 비움
        ranked.sort((a, b) -> Integer.compare(Integer.parseInt(b[1]), Integer.parseInt(a[1])));
        List<String> strengthNames = new ArrayList<>();
        List<String> gapNames = new ArrayList<>();
        Set<String> strongSet = new LinkedHashSet<>();
        int n = ranked.size();
        for (int i = 0; i < Math.min(3, n); i++) {
            String[] it = ranked.get(i);
            strongSet.add(it[0]);
            strengthNames.add(it[0]);
            insertHighlight(reportId, "STRENGTH", STRENGTH_ICONS[i], it[0], Integer.parseInt(it[1]), 30 + i);
        }
        int placed = 0;
        for (int i = n - 1; i >= 0 && placed < 3; i--) {
            String[] it = ranked.get(i);
            if (strongSet.contains(it[0])) continue; // 강점과 중복 방지(역량 6개 미만일 때)
            gapNames.add(it[0]);
            insertHighlight(reportId, "GAP", GAP_ICONS[placed], it[0], Integer.parseInt(it[1]), 40 + placed);
            placed++;
        }

        // CFI — AI 역량 점수/강점·보완에서 파생(시드 아님). 점수=평균, 배지·요약=강점/보완 TOP.
        deriveCfi(reportId, ranked, strengthNames, gapNames);
        return count;
    }

    /** CFI(점수/제목/요약/배지)를 AI 역량 결과에서 파생해 upsert. */
    private void deriveCfi(long reportId, List<String[]> ranked, List<String> strengths, List<String> gaps) throws Exception {
        if (ranked.isEmpty()) return;
        int sum = 0;
        for (String[] it : ranked) sum += Integer.parseInt(it[1]);
        int cfi = Math.round((float) sum / ranked.size());

        String s1 = strengths.size() > 0 ? strengths.get(0) : null;
        String s2 = strengths.size() > 1 ? strengths.get(1) : null;
        String g1 = gaps.size() > 0 ? gaps.get(0) : null;
        String g2 = gaps.size() > 1 ? gaps.get(1) : null;

        // 배지: 강점·보완 각 2개 (TOP3에서)
        StringBuilder badges = new StringBuilder();
        for (String s : strengths.subList(0, Math.min(2, strengths.size())))
            badges.append(badges.length() > 0 ? "\n" : "").append("blue|강점 · ").append(s);
        for (String g : gaps.subList(0, Math.min(2, gaps.size())))
            badges.append(badges.length() > 0 ? "\n" : "").append("pink|보완 · ").append(g);

        // 요약: 강점/보완 역량명을 그대로 인용(템플릿)
        String strongPart = s2 != null ? (s1 + "·" + s2) : (s1 == null ? "" : s1);
        String gapPart = g2 != null ? (g1 + "·" + g2) : (g1 == null ? "" : g1);
        String title = (s1 == null ? "핵심 역량" : s1) + " 등 강점, "
                + (g1 == null ? "일부 영역" : g1) + " 보완 필요";
        String summary = "AI 분석 결과 <b>" + strongPart + "</b> 역량이 강점으로 확인됩니다."
                + (gapPart.isEmpty() ? "" : " 다만 <b>" + gapPart + "</b> 영역은 보완이 필요합니다.");
        String criteriaSummary = "기준 정합도 분석 결과 <b>" + strongPart + "</b> 역량이 상위권 강점이며, "
                + (gapPart.isEmpty() ? "전반적으로 고른 수준입니다." : "<b>" + gapPart + "</b> 영역은 보강이 필요합니다.");

        Map<String, Object> up = new HashMap<>();
        up.put("reportId", reportId);
        up.put("cfiScore", cfi);
        up.put("summaryTitle", title);
        up.put("summaryText", summary);
        up.put("keywordBadges", badges.toString());
        up.put("criteriaSummary", criteriaSummary);
        commonDAO.update("report.write.upsertActivityCfi", up);
        log.info("[적재] CFI 파생 → reportId={}, cfi={}, 강점={}, 보완={}", reportId, cfi, strengths, gaps);
    }

    private void insertHighlight(long reportId, String status, String icon, String name, int score, int order) throws Exception {
        Map<String, Object> r = new HashMap<>();
        r.put("fitType", "HIGHLIGHT");
        r.put("status", status);
        r.put("icon", icon);
        r.put("name", name);
        r.put("myScore", score);
        r.put("sortOrder", order);
        Map<String, Object> ip = new HashMap<>();
        ip.put("reportId", reportId);
        ip.put("c", r);
        commonDAO.insert("report.write.insertCompetency", ip);
    }

    /** 0.00~3.00 → 0~100 반올림. */
    private static int toHundred(double raw) {
        return (int) Math.round(raw / 3.0 * 100.0);
    }

    /** "공통활동"→"공통", "직무활동"→"직무", "리더십활동"→"리더십". */
    private static String stripActivity(String group) {
        if (group == null) return null;
        String g = group.trim();
        return g.endsWith("활동") ? g.substring(0, g.length() - 2) : g;
    }
}

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
 * AI 생성 결과를 적재(트랜잭션). 진단할 때마다 새 진단 row + 새 리포트 row 를 만들어 이력 보존.
 *   - 코칭 본문(type0)        → sys_ai_report(COACHING).content
 *   - 기준정합도 점수(type1)  → sys_report_competency(CRITERIA) + 강점/보완 TOP3(HIGHLIGHT) + CFI 파생
 *   새 리포트라 시장정합도(MARKET)/JD/해설·근거는 아직 비어 있음(추후 AI 재생성 예정). 점수 0~3 → 0~100(×100/3).
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
                                       Map<String, Map<String, CompetencyEval>> groups,
                                       List<Map<String, Object>> marketResults) throws Exception {
        log.info("[적재] ===== 시작 user={}, 코칭={}자, 역량그룹={}개 =====",
                userSn, coachingText == null ? 0 : coachingText.length(), groups == null ? 0 : groups.size());
        // 진단할 때마다 새 진단 row 를 남겨 이력 보존. (과거엔 최신 1건을 재사용 → 이전 진단/리포트가 덮여 이력 유실)
        Map<String, Object> h = new HashMap<>();
        h.put("userSn", userSn);
        commonDAO.insert("report.write.insertDiagnosis", h);
        long diagnosisId = ((Number) h.get("diagnosisId")).longValue();
        log.info("[적재] 진단 신규 생성 → diagnosisId={}", diagnosisId);

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

        // 활동분석 리포트 — 기준정합도(CRITERIA)+강점·보완+CFI(type1) / 시장정합도(MARKET)+JD 매칭+시장요약(market-fit).
        boolean hasGroups = groups != null && !groups.isEmpty();
        boolean hasMarket = marketResults != null && !marketResults.isEmpty();
        if (hasGroups || hasMarket) {
            long activityReportId = ensureReport(userSn, diagnosisId, "ACTIVITY_ANALYSIS");
            out.put("activityReportId", activityReportId);
            if (hasGroups) {
                int n = saveCriteria(activityReportId, groups);
                log.info("[적재] 기준정합도 delete-rewrite → reportId={}, 역량 {}개", activityReportId, n);
                out.put("criteriaCount", n);
            }
            if (hasMarket) {
                int[] mc = saveMarket(activityReportId, marketResults);
                log.info("[적재] 시장정합도 delete-rewrite → reportId={}, MARKET 역량 {}개, JD 매칭 {}건", activityReportId, mc[0], mc[1]);
                out.put("marketCount", mc[0]);
                out.put("jdMatchCount", mc[1]);
            }
        } else {
            log.info("[적재] 역량/시장 데이터 없음 — 건너뜀");
        }
        log.info("[적재] ===== 완료 user={} → {} =====", userSn, out);
        return out;
    }

    private long ensureReport(long userSn, long diagnosisId, String reportType) throws Exception {
        Map<String, Object> fp = new HashMap<>();
        fp.put("userSn", userSn);
        fp.put("diagnosisId", diagnosisId);
        fp.put("reportType", reportType);
        Long id = commonDAO.selectOne("report.write.findReportId", fp); // 같은 진단 내 재적재 시에만 재사용(새 진단이면 null → 신규)
        if (id != null) {
            log.info("[적재] reportType={} → 같은 진단(diagnosisId={})의 기존 reportId={} 재사용", reportType, diagnosisId, id);
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
    private int saveCriteria(long reportId, Map<String, Map<String, CompetencyEval>> groups) throws Exception {
        Map<String, Object> dp = new HashMap<>();
        dp.put("reportId", reportId);
        dp.put("types", AI_TYPES);
        int delSrc = commonDAO.delete("report.write.deleteCompetencySourcesByTypes", dp);
        int delComp = commonDAO.delete("report.write.deleteCompetenciesByTypes", dp);
        log.info("[적재] 기존 CRITERIA/HIGHLIGHT 삭제 → sources {}행, competency {}행 (reportId={})",
                delSrc, delComp, reportId);

        int order = 10, count = 0, srcCount = 0;
        List<String[]> ranked = new ArrayList<>(); // [name, score100]
        for (Map.Entry<String, Map<String, CompetencyEval>> g : groups.entrySet()) {
            String groupCode = stripActivity(g.getKey());
            if (g.getValue() == null) continue;
            for (Map.Entry<String, CompetencyEval> e : g.getValue().entrySet()) {
                CompetencyEval ce = e.getValue();
                if (ce == null) continue;
                int s100 = toHundred(ce.getScore());
                Map<String, Object> r = new HashMap<>();
                r.put("fitType", "CRITERIA");
                r.put("groupCode", groupCode);
                r.put("name", e.getKey());
                r.put("myScore", s100);
                r.put("comment", ce.getReason());   // AI 근거(reason) → 역량별 해설(comment)
                r.put("sortOrder", order++);
                Map<String, Object> ip = new HashMap<>();
                ip.put("reportId", reportId);
                ip.put("c", r);
                commonDAO.insert("report.write.insertCompetency", ip);   // useGeneratedKeys → r.competencyId 채워짐
                srcCount += saveSources(r.get("competencyId"), ce.getSources()); // AI 출처(sources) 적재
                ranked.add(new String[]{e.getKey(), String.valueOf(s100)});
                count++;
            }
        }
        log.info("[적재] CRITERIA 역량 INSERT {}건, 근거출처 {}건 (reportId={})", count, srcCount, reportId);

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

    /**
     * 시장정합도 적재 — market-fit(스크랩 JD별) 결과를 delete-rewrite.
     *   - MARKET 역량(ksa): 적합률 최고 공고의 knowledge/skill/attitude 요구를 대표로 적재(+근거출처)
     *   - JD 매칭 카드: 공고별 1행(적합률/충족·부족역량/추천도)
     *   - 시장 요약(market_summary): 평균 적합률 + 대표 공고 강점/보완 파생
     * @return [MARKET 역량 건수, JD 매칭 건수]
     */
    @SuppressWarnings("unchecked")
    private int[] saveMarket(long reportId, List<Map<String, Object>> results) throws Exception {
        // 기존 MARKET 역량·근거 + JD 매칭 제거
        Map<String, Object> dp = new HashMap<>();
        dp.put("reportId", reportId);
        dp.put("types", Arrays.asList("MARKET"));
        commonDAO.delete("report.write.deleteCompetencySourcesByTypes", dp);
        commonDAO.delete("report.write.deleteCompetenciesByTypes", dp);
        Map<String, Object> jdel = new HashMap<>();
        jdel.put("reportId", reportId);
        commonDAO.delete("report.write.deleteJdMatch", jdel);

        // 대표 공고 = 적합률 최고(시장 정합도 KSA 기준). 동률이면 먼저 나온 것.
        Map<String, Object> rep = null;
        for (Map<String, Object> r : results) if (rep == null || asInt(r.get("fitRate")) > asInt(rep.get("fitRate"))) rep = r;

        int compCount = 0;
        if (rep != null) {
            Map<String, List<Map<String, Object>>> areas = (Map<String, List<Map<String, Object>>>) rep.get("areas");
            int order = 10;
            for (Map.Entry<String, List<Map<String, Object>>> a : areas.entrySet()) {
                if (a.getValue() == null) continue;
                for (Map<String, Object> req : a.getValue()) {
                    Map<String, Object> c = new HashMap<>();
                    c.put("fitType", "MARKET");
                    c.put("groupCode", a.getKey());          // Knowledge/Skill/Attitude
                    c.put("name", trunc(str(req.get("name")), 100));
                    c.put("myScore", req.get("score100"));
                    c.put("comment", str(req.get("reason")));
                    c.put("sortOrder", order++);
                    Map<String, Object> ip = new HashMap<>();
                    ip.put("reportId", reportId);
                    ip.put("c", c);
                    commonDAO.insert("report.write.insertCompetency", ip);
                    List<String> srcs = (List<String>) req.get("sources");
                    if (srcs != null) {
                        int si = 0;
                        for (String s : srcs) {
                            if (s == null || s.trim().isEmpty()) continue;
                            Map<String, Object> sp = new HashMap<>();
                            sp.put("competencyId", c.get("competencyId"));
                            sp.put("sourceType", "시장 요구");
                            sp.put("detail", trunc(s, 255));
                            sp.put("isPrimary", si == 0 ? 1 : 0);
                            commonDAO.insert("report.write.insertCompetencySource", sp);
                            si++;
                        }
                    }
                    compCount++;
                }
            }
        }

        // JD 매칭 카드 — 공고별 1행
        int jdCount = 0;
        for (Map<String, Object> r : results) {
            Map<String, List<Map<String, Object>>> areas = (Map<String, List<Map<String, Object>>>) r.get("areas");
            List<Map<String, Object>> reqs = new ArrayList<>();
            if (areas != null) for (List<Map<String, Object>> l : areas.values()) if (l != null) reqs.addAll(l);
            List<String> strengths = new ArrayList<>(), gaps = new ArrayList<>();
            int met = 0;
            for (Map<String, Object> req : reqs) {
                double raw = asDouble(req.get("scoreRaw"));
                if (raw >= 2.0) { strengths.add(str(req.get("name"))); met++; }   // 충족(3점 만점 중 2점↑)
                else gaps.add(str(req.get("name")));                              // 그 외 전부 부족 → 충족+부족=전체 일치
            }
            int fit = asInt(r.get("fitRate"));
            String rec = fit >= 75 ? "추천" : fit >= 60 ? "도전" : "관심";
            List<String> advices = new ArrayList<>();
            for (String g : gaps) advices.add(g + " 역량 보완 권장");
            Map<String, Object> jm = new HashMap<>();
            jm.put("reportId", reportId);
            jm.put("jobPostingId", r.get("jobPostingId"));
            jm.put("company", trunc(str(r.get("company")), 100));
            jm.put("role", trunc(str(r.get("role")), 150));
            jm.put("meta", trunc(str(r.get("meta")), 200));
            jm.put("fitRate", fit);
            jm.put("matchCount", met + " / " + reqs.size());
            jm.put("recommendation", rec);
            jm.put("gapKeywords", joinLines(gaps));
            jm.put("strengths", joinLines(strengths));
            jm.put("advices", joinLines(advices));
            commonDAO.insert("report.write.insertJdMatch", jm);
            jdCount++;
        }

        // 시장 요약 파생
        Map<String, Object> mp = new HashMap<>();
        mp.put("reportId", reportId);
        mp.put("marketSummary", deriveMarketSummary(results, rep));
        commonDAO.update("report.write.updateActivityMarket", mp);
        return new int[]{compCount, jdCount};
    }

    /** 시장 요약 — 평균 적합률 + 대표 공고 최고/최저 역량. */
    @SuppressWarnings("unchecked")
    private String deriveMarketSummary(List<Map<String, Object>> results, Map<String, Object> rep) {
        int n = results.size(), sum = 0;
        for (Map<String, Object> r : results) sum += asInt(r.get("fitRate"));
        int avg = n > 0 ? Math.round((float) sum / n) : 0;
        String strong = null, weak = null;
        if (rep != null) {
            Map<String, List<Map<String, Object>>> areas = (Map<String, List<Map<String, Object>>>) rep.get("areas");
            Map<String, Object> hi = null, lo = null;
            if (areas != null) for (List<Map<String, Object>> l : areas.values()) if (l != null) for (Map<String, Object> q : l) {
                if (hi == null || asInt(q.get("score100")) > asInt(hi.get("score100"))) hi = q;
                if (lo == null || asInt(q.get("score100")) < asInt(lo.get("score100"))) lo = q;
            }
            if (hi != null) strong = str(hi.get("name"));
            if (lo != null) weak = str(lo.get("name"));
        }
        StringBuilder sb = new StringBuilder();
        sb.append("스크랩한 채용공고 ").append(n).append("건 기준 평균 적합률은 <b>").append(avg).append("%</b>입니다.");
        if (rep != null) sb.append(" 가장 잘 맞는 <b>").append(str(rep.get("role")))
                .append("</b>(적합률 ").append(asInt(rep.get("fitRate"))).append("%)");
        if (strong != null) sb.append(" 기준 <b>").append(strong).append("</b> 역량은 충족하나");
        if (weak != null) sb.append(" <b>").append(weak).append("</b> 영역은 보강이 필요합니다.");
        else sb.append(".");
        return sb.toString();
    }

    private static int asInt(Object o) {
        if (o == null) return 0;
        if (o instanceof Number) return ((Number) o).intValue();
        try { return (int) Math.round(Double.parseDouble(o.toString().trim())); } catch (Exception e) { return 0; }
    }

    private static double asDouble(Object o) {
        if (o == null) return 0;
        if (o instanceof Number) return ((Number) o).doubleValue();
        try { return Double.parseDouble(o.toString().trim()); } catch (Exception e) { return 0; }
    }

    private static String str(Object o) { return o == null ? null : String.valueOf(o); }

    /** 목록 → 줄바꿈 구분 TEXT(빈/널 제외). 비면 null. */
    private static String joinLines(List<String> list) {
        if (list == null || list.isEmpty()) return null;
        StringBuilder sb = new StringBuilder();
        for (String s : list) { if (s == null || s.trim().isEmpty()) continue; sb.append(sb.length() > 0 ? "\n" : "").append(s.trim()); }
        return sb.length() == 0 ? null : sb.toString();
    }

    /** 역량 근거 출처(AI sources) 적재. 첫 출처를 대표(is_primary=1)로. 반환=적재 건수. */
    private int saveSources(Object competencyId, List<String[]> sources) throws Exception {
        if (competencyId == null || sources == null || sources.isEmpty()) return 0;
        long cid = ((Number) competencyId).longValue();
        int n = 0;
        for (String[] s : sources) {
            if (s == null || s.length < 2 || s[1] == null || s[1].trim().isEmpty()) continue;
            Map<String, Object> sp = new HashMap<>();
            sp.put("competencyId", cid);
            sp.put("sourceType", trunc(s[0], 50));    // VARCHAR(50)
            sp.put("detail", trunc(s[1], 255));       // VARCHAR(255)
            sp.put("isPrimary", n == 0 ? 1 : 0);
            commonDAO.insert("report.write.insertCompetencySource", sp);
            n++;
        }
        return n;
    }

    /** 컬럼 길이 초과 방지용 트림/절단. */
    private static String trunc(String s, int max) {
        if (s == null) return null;
        String t = s.trim();
        return t.length() <= max ? t : t.substring(0, max);
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

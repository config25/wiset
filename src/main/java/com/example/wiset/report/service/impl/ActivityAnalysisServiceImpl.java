package com.example.wiset.report.service.impl;

import com.example.wiset.support.CommonDAO;
import com.example.wiset.support.CurrentUser;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 12 활동 분석 리포트 (조회 전용) — 전부 관계형 테이블에서 조립(비교 가능하도록 컬럼 저장).
 *   rows/ksa/강점·보완 TOP3 → sys_report_competency (fit_type 구분)
 *   역량별 근거 소스         → sys_report_competency_source
 *   CFI·종합해설·배지        → sys_report_activity
 *   스크랩 JD 비교           → sys_report_jd_match (리스트는 줄바꿈 TEXT)
 *   차트/색 등 표현 계산은 프론트가 수행. 테이블이 비면 프론트가 목업으로 폴백.
 *   (content JSON 은 레거시 폴백용으로만 유지)
 */
// [wbridge] @Mapper 제거 → CommonDAO(report.aiReport.*, report.competency.*) 이식. DTO 유지.
@Service
public class ActivityAnalysisServiceImpl {

    private static final Logger log = LoggerFactory.getLogger(ActivityAnalysisServiceImpl.class);

    /** MARKET 그룹코드 → 화면 부제(sub) 라벨. */
    private static final Map<String, String> MARKET_SUB = new LinkedHashMap<>();
    static {
        MARKET_SUB.put("Knowledge", "지식 요건");
        MARKET_SUB.put("Skill",     "기술 요건");
        MARKET_SUB.put("Attitude",  "태도 요건");
    }

    private final CommonDAO commonDAO;                  // report.aiReport.* / report.competency.*
    private final ObjectMapper om = new ObjectMapper();

    public ActivityAnalysisServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    /**
     * {@code { content, cfi, criteriaSummary, marketSummary, jds, rows, ksa, strengthsTop, gapsTop }}.
     * diagnosisId 지정 시 그 진단, null 이면 최신. 테이블이 비면 해당 키를 내리지 않아 프론트가 목업 폴백.
     */
    public Map<String, Object> getAnalysisReport(Long diagnosisId) throws Exception {
        long u = CurrentUser.userSn();
        log.info("[활동분석조회] ===== 기준 정합도 등 읽기 시작 — user={}, reportType=ACTIVITY_ANALYSIS, diagnosisId={} =====",
                u, diagnosisId);
        Map<String, Object> out = new LinkedHashMap<>();

        // 레거시 content(JSON) — 컬럼이 비었을 때만 의미. 있으면 프론트가 컬럼값으로 덮음.
        Map<String, Object> pc = new HashMap<>();
        pc.put("userSn", u);
        pc.put("reportType", "ACTIVITY_ANALYSIS");
        pc.put("diagnosisId", diagnosisId);
        String json = commonDAO.selectOne("report.aiReport.findContent", pc);
        Object content = null;
        if (json != null && !json.trim().isEmpty()) {
            try {
                content = om.readValue(json, Object.class);
            } catch (Exception e) {
                content = null;
            }
        }
        out.put("content", content);

        Map<String, Object> pr = new HashMap<>();
        pr.put("userSn", u);
        pr.put("reportType", "ACTIVITY_ANALYSIS");
        pr.put("diagnosisId", diagnosisId);
        Long reportId = commonDAO.selectOne("report.competency.findReportId", pr);
        if (reportId == null) {
            log.warn("[활동분석조회] ⚠ ACTIVITY_ANALYSIS 리포트 행 없음(user={}) → 기준 정합도 못 받아옴(프론트 목업 폴백). "
                    + "= 리포트 생성/적재가 한 번도 안 됨", u);
            return out;
        }
        log.info("[활동분석조회] 대상 reportId={}", reportId);

        Map<String, Object> pid = new HashMap<>();
        pid.put("reportId", reportId);

        // CFI · 종합해설 · 배지
        Map<String, Object> act = commonDAO.selectOne("report.competency.findActivity", pid);
        if (act != null) {
            Map<String, Object> cfi = new LinkedHashMap<>();
            if (act.get("cfiScore") != null)     cfi.put("score", act.get("cfiScore"));
            if (act.get("cfiDelta") != null)     cfi.put("delta", act.get("cfiDelta"));
            if (act.get("summaryTitle") != null) cfi.put("title", act.get("summaryTitle"));
            if (act.get("summaryText") != null)  cfi.put("summary", act.get("summaryText"));
            List<Map<String, Object>> badges = parseBadges(str(act.get("keywordBadges")));
            if (!badges.isEmpty()) cfi.put("badges", badges);
            if (!cfi.isEmpty()) out.put("cfi", cfi);
            if (act.get("criteriaSummary") != null) out.put("criteriaSummary", act.get("criteriaSummary"));
            if (act.get("marketSummary") != null)   out.put("marketSummary", act.get("marketSummary"));
        }

        // 스크랩 JD 비교
        List<Map<String, Object>> jds = new ArrayList<>();
        for (Map<String, Object> j : commonDAO.<Map<String, Object>>selectList("report.competency.findJdMatches", pid)) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("co", j.get("company"));
            m.put("role", j.get("role"));
            m.put("meta", j.get("meta"));
            m.put("fit", j.get("fitRate"));
            m.put("match", j.get("matchCount"));
            m.put("rec", j.get("recommendation"));
            m.put("tone", toneFor(str(j.get("recommendation"))));
            m.put("gap", splitLines(str(j.get("gapKeywords"))));
            m.put("met", splitLines(str(j.get("strengths"))));
            m.put("advice", splitLines(str(j.get("advices"))));
            jds.add(m);
        }
        if (!jds.isEmpty()) out.put("jds", jds);

        // 역량 점수/근거
        List<Map<String, Object>> comps = commonDAO.selectList("report.competency.findCompetencies", pid);
        if (comps.isEmpty()) {
            log.warn("[활동분석조회] ⚠ sys_report_competency 0건(reportId={}) → 기준 정합도(rows) 못 받아옴. "
                    + "= type1(역량평가) 적재가 안 됨(파싱 null 또는 AI 호출 실패)", reportId);
            return out;
        }

        Map<Long, List<Map<String, Object>>> srcByComp = new LinkedHashMap<>();
        for (Map<String, Object> s : commonDAO.<Map<String, Object>>selectList("report.competency.findSources", pid)) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("t", s.get("sourceType"));
            m.put("d", s.get("detail"));
            srcByComp.computeIfAbsent(longOrNull(s.get("competencyId")), k -> new ArrayList<>()).add(m);
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        List<Map<String, Object>> ksa = new ArrayList<>();
        List<Map<String, Object>> strengthsTop = new ArrayList<>();
        List<Map<String, Object>> gapsTop = new ArrayList<>();

        for (Map<String, Object> c : comps) {
            String fit = c.get("fitType") == null ? "" : str(c.get("fitType"));
            String groupCode = str(c.get("groupCode"));
            List<Map<String, Object>> src = srcByComp.getOrDefault(longOrNull(c.get("competencyId")), new ArrayList<>());
            switch (fit) {
                case "CRITERIA": {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("l", c.get("name"));
                    m.put("g", groupCode);
                    m.put("v", c.get("myScore"));
                    m.put("avg", c.get("requiredScore"));
                    m.put("comment", c.get("comment"));
                    m.put("sources", src);
                    rows.add(m);
                    break;
                }
                case "MARKET": {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("area", groupCode);
                    m.put("sub", MARKET_SUB.getOrDefault(groupCode, groupCode));
                    m.put("l", c.get("name"));
                    m.put("lvl", c.get("levelCode"));
                    m.put("v", c.get("myScore"));
                    m.put("comment", c.get("comment"));
                    m.put("sources", src);
                    ksa.add(m);
                    break;
                }
                case "HIGHLIGHT": {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("ic", c.get("icon"));
                    m.put("n", c.get("name"));
                    m.put("v", c.get("myScore"));
                    if ("GAP".equals(c.get("status"))) {
                        m.put("gap", fmtGap(intOrNull(c.get("myScore")), intOrNull(c.get("requiredScore"))));
                        gapsTop.add(m);
                    } else {
                        strengthsTop.add(m);
                    }
                    break;
                }
                default: // 알 수 없는 fit_type 은 제외
            }
        }

        if (!rows.isEmpty())         out.put("rows", rows);
        if (!ksa.isEmpty())          out.put("ksa", ksa);
        if (!strengthsTop.isEmpty()) out.put("strengthsTop", strengthsTop);
        if (!gapsTop.isEmpty())      out.put("gapsTop", gapsTop);
        log.info("[활동분석조회] ===== 완료 — 역량 {}건 → 기준정합도(CRITERIA) {}건, 시장(MARKET) {}건, "
                + "강점·보완(HIGHLIGHT) {}건, criteriaSummary={} =====",
                comps.size(), rows.size(), ksa.size(), strengthsTop.size() + gapsTop.size(),
                out.get("criteriaSummary") != null);
        if (rows.isEmpty()) {
            log.warn("[활동분석조회] ⚠ CRITERIA(기준 정합도) 0건 — 역량은 있는데 fit_type=CRITERIA 행이 없음 "
                    + "(type1 적재 시 group/fit_type 불일치 가능성)");
        }
        return out;
    }

    /** 배지 TEXT(줄바꿈, 줄 = "tone|라벨") → [{tone, t}]. */
    private List<Map<String, Object>> parseBadges(String text) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (text == null || text.trim().isEmpty()) return list;
        for (String line : text.split("\\r?\\n")) {
            String s = line.trim();
            if (s.isEmpty()) continue;
            String tone = "brand", t = s;
            int bar = s.indexOf('|');
            if (bar >= 0) {
                String l = s.substring(0, bar).trim();
                String r = s.substring(bar + 1).trim();
                if (!l.isEmpty()) tone = l;
                t = r;
            }
            if (t.isEmpty()) continue;
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("tone", tone);
            m.put("t", t);
            list.add(m);
        }
        return list;
    }

    /** 줄바꿈 구분 TEXT → 비어있지 않은 줄 목록. */
    private static List<String> splitLines(String text) {
        List<String> list = new ArrayList<>();
        if (text == null) return list;
        for (String line : text.split("\\r?\\n")) {
            String s = line.trim();
            if (!s.isEmpty()) list.add(s);
        }
        return list;
    }

    /** 추천 등급 → 칩 톤. */
    private static String toneFor(String rec) {
        if ("도전".equals(rec)) return "pink";
        return "brand"; // 추천/관심/기타
    }

    private static String str(Object o) { return o == null ? null : o.toString(); }

    private static Integer intOrNull(Object o) {
        if (o == null) return null;
        if (o instanceof Number) return ((Number) o).intValue();
        String s = o.toString().trim();
        return s.isEmpty() ? null : Integer.valueOf(s);
    }

    private static Long longOrNull(Object o) {
        if (o == null) return null;
        if (o instanceof Number) return ((Number) o).longValue();
        String s = o.toString().trim();
        return s.isEmpty() ? null : Long.valueOf(s);
    }

    /** 보완 격차 표기: 내 점수 - 목표(음수). 예: 60,85 → "-25". */
    private static String fmtGap(Integer my, Integer req) {
        if (my == null || req == null) return null;
        int diff = my - req;
        return diff >= 0 ? ("+" + diff) : String.valueOf(diff);
    }
}

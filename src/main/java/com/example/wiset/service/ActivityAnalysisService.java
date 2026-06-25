package com.example.wiset.service;

import com.example.wiset.dto.ReportActivityRow;
import com.example.wiset.dto.ReportCompetencyRow;
import com.example.wiset.dto.ReportCompetencySource;
import com.example.wiset.dto.ReportJdMatchRow;
import com.example.wiset.mapper.AiReportMapper;
import com.example.wiset.mapper.ReportCompetencyMapper;
import com.example.wiset.support.CurrentUser;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
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
@Service
public class ActivityAnalysisService {

    /** MARKET 그룹코드 → 화면 부제(sub) 라벨. */
    private static final Map<String, String> MARKET_SUB = new LinkedHashMap<>();
    static {
        MARKET_SUB.put("Knowledge", "지식 요건");
        MARKET_SUB.put("Skill",     "기술 요건");
        MARKET_SUB.put("Attitude",  "태도 요건");
    }

    private final AiReportMapper aiReportMapper;       // content(JSON) — 레거시 폴백
    private final ReportCompetencyMapper competencyMapper;
    private final ObjectMapper om = new ObjectMapper();

    public ActivityAnalysisService(AiReportMapper aiReportMapper, ReportCompetencyMapper competencyMapper) {
        this.aiReportMapper = aiReportMapper;
        this.competencyMapper = competencyMapper;
    }

    /**
     * {@code { content, cfi, criteriaSummary, marketSummary, jds, rows, ksa, strengthsTop, gapsTop }}.
     * diagnosisId 지정 시 그 진단, null 이면 최신. 테이블이 비면 해당 키를 내리지 않아 프론트가 목업 폴백.
     */
    public Map<String, Object> getAnalysisReport(Long diagnosisId) {
        long u = CurrentUser.userSn();
        Map<String, Object> out = new LinkedHashMap<>();

        // 레거시 content(JSON) — 컬럼이 비었을 때만 의미. 있으면 프론트가 컬럼값으로 덮음.
        String json = aiReportMapper.findContent(u, "ACTIVITY_ANALYSIS", diagnosisId);
        Object content = null;
        if (json != null && !json.trim().isEmpty()) {
            try {
                content = om.readValue(json, Object.class);
            } catch (Exception e) {
                content = null;
            }
        }
        out.put("content", content);

        Long reportId = competencyMapper.findReportId(u, "ACTIVITY_ANALYSIS", diagnosisId);
        if (reportId == null) return out;

        // CFI · 종합해설 · 배지
        ReportActivityRow act = competencyMapper.findActivity(reportId);
        if (act != null) {
            Map<String, Object> cfi = new LinkedHashMap<>();
            if (act.getCfiScore() != null)     cfi.put("score", act.getCfiScore());
            if (act.getCfiDelta() != null)     cfi.put("delta", act.getCfiDelta());
            if (act.getSummaryTitle() != null) cfi.put("title", act.getSummaryTitle());
            if (act.getSummaryText() != null)  cfi.put("summary", act.getSummaryText());
            List<Map<String, Object>> badges = parseBadges(act.getKeywordBadges());
            if (!badges.isEmpty()) cfi.put("badges", badges);
            if (!cfi.isEmpty()) out.put("cfi", cfi);
            if (act.getCriteriaSummary() != null) out.put("criteriaSummary", act.getCriteriaSummary());
            if (act.getMarketSummary() != null)   out.put("marketSummary", act.getMarketSummary());
        }

        // 스크랩 JD 비교
        List<Map<String, Object>> jds = new ArrayList<>();
        for (ReportJdMatchRow j : competencyMapper.findJdMatches(reportId)) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("co", j.getCompany());
            m.put("role", j.getRole());
            m.put("meta", j.getMeta());
            m.put("fit", j.getFitRate());
            m.put("match", j.getMatchCount());
            m.put("rec", j.getRecommendation());
            m.put("tone", toneFor(j.getRecommendation()));
            m.put("gap", splitLines(j.getGapKeywords()));
            m.put("met", splitLines(j.getStrengths()));
            m.put("advice", splitLines(j.getAdvices()));
            jds.add(m);
        }
        if (!jds.isEmpty()) out.put("jds", jds);

        // 역량 점수/근거
        List<ReportCompetencyRow> comps = competencyMapper.findCompetencies(reportId);
        if (comps.isEmpty()) return out;

        Map<Long, List<Map<String, Object>>> srcByComp = new LinkedHashMap<>();
        for (ReportCompetencySource s : competencyMapper.findSources(reportId)) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("t", s.getSourceType());
            m.put("d", s.getDetail());
            srcByComp.computeIfAbsent(s.getCompetencyId(), k -> new ArrayList<>()).add(m);
        }

        List<Map<String, Object>> rows = new ArrayList<>();
        List<Map<String, Object>> ksa = new ArrayList<>();
        List<Map<String, Object>> strengthsTop = new ArrayList<>();
        List<Map<String, Object>> gapsTop = new ArrayList<>();

        for (ReportCompetencyRow c : comps) {
            String fit = c.getFitType() == null ? "" : c.getFitType();
            List<Map<String, Object>> src = srcByComp.getOrDefault(c.getCompetencyId(), new ArrayList<>());
            switch (fit) {
                case "CRITERIA": {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("l", c.getName());
                    m.put("g", c.getGroupCode());
                    m.put("v", c.getMyScore());
                    m.put("avg", c.getRequiredScore());
                    m.put("comment", c.getComment());
                    m.put("sources", src);
                    rows.add(m);
                    break;
                }
                case "MARKET": {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("area", c.getGroupCode());
                    m.put("sub", MARKET_SUB.getOrDefault(c.getGroupCode(), c.getGroupCode()));
                    m.put("l", c.getName());
                    m.put("lvl", c.getLevelCode());
                    m.put("v", c.getMyScore());
                    m.put("comment", c.getComment());
                    m.put("sources", src);
                    ksa.add(m);
                    break;
                }
                case "HIGHLIGHT": {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("ic", c.getIcon());
                    m.put("n", c.getName());
                    m.put("v", c.getMyScore());
                    if ("GAP".equals(c.getStatus())) {
                        m.put("gap", fmtGap(c.getMyScore(), c.getRequiredScore()));
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

    /** 보완 격차 표기: 내 점수 - 목표(음수). 예: 60,85 → "-25". */
    private static String fmtGap(Integer my, Integer req) {
        if (my == null || req == null) return null;
        int diff = my - req;
        return diff >= 0 ? ("+" + diff) : String.valueOf(diff);
    }
}

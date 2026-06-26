package com.example.wiset.admin.service.impl;

import org.springframework.stereotype.Service;

import com.example.wiset.support.CommonDAO;

import java.util.*;

/**
 * 18_관리자 만족도 관리 조립 (조회 전용) — 레거시 wbridge commonDAO idiom 이식판(로컬 실행).
 *   summary(평균·전월대비) / sentiment(감성분포) / trend(만족도·액션실행률 주별 + 상관계수)
 *   / complaints(불만 TOP5) / recentFeedback / evalHistory / activityLog.
 *   파생값(델타·비율·상관계수)은 여기서 계산하고 화면은 표현만 담당.
 *   SQL 은 sqlmap/mngr/adminSatisfaction_mapper.xml (namespace mngr.adminSatisfaction) 참조.
 *
 *   [wbridge 포팅 델타] @Service("adminSatisfactionService") extends DefaultServiceImpl (패키지 wbridge.mngr...),
 *     CommonDAO 주입 제거(상속 commonDAO 사용), 각 메서드 throws Exception.
 */
@Service
public class AdminSatisfactionServiceImpl {

    private final CommonDAO commonDAO;

    public AdminSatisfactionServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    private static final Map<Integer, String> PERSONA = new HashMap<>();
    static {
        PERSONA.put(1, "신규 취업");
        PERSONA.put(2, "이직 준비");
        PERSONA.put(3, "재취업");
        PERSONA.put(4, "승진·보직");
    }
    private static final Map<String, String> SENTIMENT_LABEL = new LinkedHashMap<>();
    static {
        SENTIMENT_LABEL.put("POSITIVE", "긍정");
        SENTIMENT_LABEL.put("NEUTRAL", "중립");
        SENTIMENT_LABEL.put("NEGATIVE", "부정");
    }

    public Map<String, Object> get() throws Exception {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("summary", buildSummary());
        out.put("sentiment", buildSentiment());
        out.put("trend", buildTrend());
        out.put("complaints", buildComplaints());
        out.put("recentFeedback", buildRecentFeedback());
        out.put("evalHistory", buildEvalHistory());
        out.put("activityLog", buildActivityLog());
        return out;
    }

    // ----------------------------------------------------------------- summary
    private Map<String, Object> buildSummary() throws Exception {
        Map<String, Object> s = commonDAO.selectOne("mngr.adminSatisfaction.summary");
        double cur = s.get("curAvg") == null ? 0 : num(s.get("curAvg")).doubleValue();
        double prev = s.get("prevAvg") == null ? 0 : num(s.get("prevAvg")).doubleValue();
        Map<String, Object> m = new LinkedHashMap<>();
        double avg = s.get("avgAll") == null ? 0 : num(s.get("avgAll")).doubleValue();
        m.put("avg", round2(avg));
        m.put("totalRatings", num(s.get("totalRatings")).longValue());
        m.put("totalFeedback", num(s.get("totalFeedback")).longValue());
        m.put("delta", (s.get("prevAvg") == null) ? null : round2(cur - prev));
        return m;
    }

    // --------------------------------------------------------------- sentiment
    private List<Map<String, Object>> buildSentiment() throws Exception {
        long total = 0;
        Map<String, Long> counts = new LinkedHashMap<>();
        for (Map<String, Object> row : commonDAO.<Map<String, Object>>selectList("mngr.adminSatisfaction.sentimentCounts")) {
            long c = num(row.get("cnt")).longValue();
            counts.put(String.valueOf(row.get("sentiment")), c);
            total += c;
        }
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map.Entry<String, String> e : SENTIMENT_LABEL.entrySet()) {
            long c = counts.getOrDefault(e.getKey(), 0L);
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("code", e.getKey());
            m.put("label", e.getValue());
            m.put("count", c);
            m.put("percent", total > 0 ? Math.round(100.0 * c / total) : 0);
            list.add(m);
        }
        return list;
    }

    // ------------------------------------------------------------------- trend
    private Map<String, Object> buildTrend() throws Exception {
        // 주(wk) 기준 병합: 만족도% = avg/5*100, 액션실행률% = clicks/views*100
        Map<Long, String> labels = new TreeMap<>();
        Map<Long, Double> satByWk = new HashMap<>();
        for (Map<String, Object> r : commonDAO.<Map<String, Object>>selectList("mngr.adminSatisfaction.weeklySatisfaction")) {
            long wk = num(r.get("wk")).longValue();
            labels.put(wk, String.valueOf(r.get("lbl")));
            satByWk.put(wk, num(r.get("avgRating")).doubleValue() / 5.0 * 100.0);
        }
        Map<Long, Double> actByWk = new HashMap<>();
        for (Map<String, Object> r : commonDAO.<Map<String, Object>>selectList("mngr.adminSatisfaction.weeklyAction")) {
            long wk = num(r.get("wk")).longValue();
            labels.putIfAbsent(wk, String.valueOf(r.get("lbl")));
            double clicks = num(r.get("clicks")).doubleValue();
            double views = num(r.get("views")).doubleValue();
            actByWk.put(wk, views > 0 ? Math.min(100.0, clicks / views * 100.0) : 0.0);
        }
        // 최근 7주만
        List<Long> weeks = new ArrayList<>(labels.keySet());
        if (weeks.size() > 7) weeks = weeks.subList(weeks.size() - 7, weeks.size());

        List<Map<String, Object>> points = new ArrayList<>();
        List<Double> satSeries = new ArrayList<>();
        List<Double> actSeries = new ArrayList<>();
        for (Long wk : weeks) {
            double sat = satByWk.getOrDefault(wk, 0.0);
            double act = actByWk.getOrDefault(wk, 0.0);
            Map<String, Object> p = new LinkedHashMap<>();
            p.put("label", labels.get(wk));
            p.put("satisfaction", (int) Math.round(sat));
            p.put("actionRate", (int) Math.round(act));
            points.add(p);
            satSeries.add(sat);
            actSeries.add(act);
        }
        Map<String, Object> trend = new LinkedHashMap<>();
        trend.put("points", points);
        trend.put("correlation", round2(pearson(satSeries, actSeries)));
        return trend;
    }

    // -------------------------------------------------------------- complaints
    private List<Map<String, Object>> buildComplaints() throws Exception {
        List<Map<String, Object>> rows = commonDAO.selectList("mngr.adminSatisfaction.complaintsTop5");
        long total = 0;
        for (Map<String, Object> r : rows) total += num(r.get("cnt")).longValue();
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> r : rows) {
            long c = num(r.get("cnt")).longValue();
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("category", r.get("category"));
            m.put("count", c);
            m.put("percent", total > 0 ? Math.round(100.0 * c / total) : 0);
            list.add(m);
        }
        return list;
    }

    // ---------------------------------------------------------- recentFeedback
    private List<Map<String, Object>> buildRecentFeedback() throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> r : commonDAO.<Map<String, Object>>selectList("mngr.adminSatisfaction.recentFeedback")) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("time", r.get("t"));
            m.put("persona", PERSONA.getOrDefault(num(r.get("personaCode")).intValue(), "기타"));
            m.put("rating", num(r.get("rating")).intValue());
            m.put("opinion", r.get("opinion"));
            m.put("sentiment", SENTIMENT_LABEL.getOrDefault(String.valueOf(r.get("sentiment")), "중립"));
            list.add(m);
        }
        return list;
    }

    // ------------------------------------------------------------ evalHistory
    private List<Map<String, Object>> buildEvalHistory() throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> r : commonDAO.<Map<String, Object>>selectList("mngr.adminSatisfaction.evalHistory")) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("time", r.get("t"));
            m.put("reportId", r.get("reportId"));
            m.put("star", r.get("star") == null ? null : num(r.get("star")).intValue());
            m.put("avg4", r.get("avg4") == null ? null : round2(num(r.get("avg4")).doubleValue()));
            m.put("hasOpinion", num(r.get("hasOpinion")).intValue() == 1);
            list.add(m);
        }
        return list;
    }

    // ------------------------------------------------------------- activityLog
    private List<Map<String, Object>> buildActivityLog() throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> r : commonDAO.<Map<String, Object>>selectList("mngr.adminSatisfaction.activityLog")) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("time", r.get("tm"));
            m.put("user", r.get("usr"));
            m.put("action", r.get("actionType"));
            m.put("detail", r.get("detail"));
            list.add(m);
        }
        return list;
    }

    // ----------------------------------------------------------------- helpers
    private static Number num(Object o) {
        if (o == null) return 0;
        if (o instanceof Number) return (Number) o;
        return Double.parseDouble(o.toString());
    }

    /** 피어슨 상관계수 (표본 부족/분산 0 이면 0) */
    private static double pearson(List<Double> xs, List<Double> ys) {
        int n = Math.min(xs.size(), ys.size());
        if (n < 2) return 0;
        double sx = 0, sy = 0, sxx = 0, syy = 0, sxy = 0;
        for (int i = 0; i < n; i++) {
            double x = xs.get(i), y = ys.get(i);
            sx += x; sy += y; sxx += x * x; syy += y * y; sxy += x * y;
        }
        double cov = n * sxy - sx * sy;
        double dx = n * sxx - sx * sx, dy = n * syy - sy * sy;
        if (dx <= 0 || dy <= 0) return 0;
        return cov / Math.sqrt(dx * dy);
    }

    private static double round2(double v) { return Math.round(v * 100.0) / 100.0; }
}

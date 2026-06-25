package com.example.wiset.service;

import com.example.wiset.mapper.AdminDashboardMapper;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 17_관리자 통합 대시보드 조립 (조회 전용).
 *   [DB 연결] 누적 진단 / 오늘 진단 시작 / 단계별 이탈률(퍼널) / 페르소나 유입
 *            / 좋아요·싫어요(만족도 별점 ≥4·≤2) / 평균 만족도(별점) / 답변 품질지표(자동평가) / 최근 데이터 배치.
 *   [DB 미연동·정적값] MAU·실시간 동시접속·평균 응답속도·시스템 활용량·성능 지표
 *            — AI/시스템 성능 측정 영역이라 추후 모니터링 연동.
 *            (레이아웃/CSV 유지 위해 동일 JSON 구조로 디자인 샘플값 제공)
 */
@Service
public class AdminDashboardService {

    private final AdminDashboardMapper mapper;

    public AdminDashboardService(AdminDashboardMapper mapper) {
        this.mapper = mapper;
    }

    private static final Map<Integer, String> PERSONA = new LinkedHashMap<>();
    static {
        PERSONA.put(1, "신규 취업");
        PERSONA.put(2, "이직 준비");
        PERSONA.put(3, "재취업");
        PERSONA.put(4, "승진·보직 희망");
    }
    private static final String[] FUNNEL_LABELS = {
            "STEP 1 페르소나", "STEP 2 현황 입력", "STEP 3 목표 입력",
            "STEP 4 세부 고민", "STEP 5 검토", "리포트 도달"
    };
    private static final Map<String, String> BATCH_STATUS = new HashMap<>();
    static {
        BATCH_STATUS.put("SUCCESS", "성공");
        BATCH_STATUS.put("WARNING", "경고");
        BATCH_STATUS.put("FAILED", "실패");
    }

    /** 대시보드 전체 데이터 */
    public Map<String, Object> getDashboard() {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("realtime", buildRealtime());   // 일부 DB
        out.put("persona", buildPersona());      // 정적
        out.put("funnel", buildFunnel());        // DB
        out.put("answer", buildAnswer());        // 일부 DB
        out.put("quality", buildQuality());      // 정적
        out.put("system", buildSystem());        // 일부 DB
        return out;
    }

    // ---------------------------------------------------------------- realtime
    private Map<String, Object> buildRealtime() {
        Map<String, Object> r = mapper.realtimeKpi();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("cumulative", num(r.get("cumulative")).longValue());     // [DB] 누적 진단
        m.put("todayStarted", num(r.get("todayStarted")).longValue()); // [DB] 오늘 진단 시작
        m.put("mau", 4219L);   // [미연동] 운영 지표 — 디자인 샘플값
        m.put("live", 127L);   // [미연동] 실시간 동시접속 — 샘플값
        return m;
    }

    // ----------------------------------------------------------------- persona (DB)
    private List<Map<String, Object>> buildPersona() {
        List<Map<String, Object>> rows = mapper.personaInflow();
        long total = 0;
        for (Map<String, Object> row : rows) total += num(row.get("cnt")).longValue();
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            int code = num(row.get("personaCode")).intValue();
            long cnt = num(row.get("cnt")).longValue();
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("code", code);
            m.put("label", PERSONA.getOrDefault(code, "기타"));
            m.put("count", cnt);
            m.put("percent", total > 0 ? Math.round(100.0 * cnt / total) : 0);
            list.add(m);
        }
        list.sort((a, b) -> Long.compare(num(b.get("count")).longValue(), num(a.get("count")).longValue()));
        return list;
    }

    // ------------------------------------------------------------------ funnel (DB)
    private Map<String, Object> buildFunnel() {
        Map<String, Object> c = mapper.funnelCounts();
        long[] counts = new long[6];
        for (int i = 0; i < 6; i++) counts[i] = num(c.get("s" + (i + 1))).longValue();
        long base = counts[0];

        List<Map<String, Object>> steps = new ArrayList<>();
        int maxDrop = 0;
        String maxDropStep = null;
        for (int i = 0; i < 6; i++) {
            int pct = base > 0 ? (int) Math.round(100.0 * counts[i] / base) : 0;
            int drop = 0;
            if (i > 0 && counts[i - 1] > 0) {
                drop = (int) Math.round(100.0 * (counts[i - 1] - counts[i]) / counts[i - 1]);
            }
            if (drop > maxDrop) { maxDrop = drop; maxDropStep = FUNNEL_LABELS[i]; }
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("step", FUNNEL_LABELS[i]);
            m.put("count", counts[i]);
            m.put("pct", pct);
            m.put("drop", drop);
            steps.add(m);
        }
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("steps", steps);
        out.put("maxDrop", maxDrop);
        out.put("maxDropStep", maxDropStep);
        return out;
    }

    // ------------------------------------------------------------------ answer
    private Map<String, Object> buildAnswer() {
        Map<String, Object> out = new LinkedHashMap<>();

        // [DB] 좋아요/싫어요 = 만족도 별점 ≥4.0 / ≤2.0
        Map<String, Object> th = mapper.thumbs();
        long up = num(th.get("up")).longValue();
        long down = num(th.get("down")).longValue();
        long total = up + down;
        Map<String, Object> sat = new LinkedHashMap<>();
        sat.put("up", up);
        sat.put("down", down);
        sat.put("total", total);
        sat.put("upPercent", total > 0 ? Math.round(100.0 * up / total) : 0);
        sat.put("downPercent", total > 0 ? Math.round(100.0 * down / total) : 0);
        out.put("satisfaction", sat);

        // [미연동] 평균 응답 속도 = AI 답변속도(AI 성능) — 디자인 샘플값
        Map<String, Object> speed = new LinkedHashMap<>();
        speed.put("avgSec", 34.2);
        speed.put("p95Sec", 51.0);
        speed.put("p99Sec", 72.0);
        speed.put("maxSec", 89.0);
        speed.put("count", total);
        out.put("speed", speed);

        // [DB] 평균 만족도 (별점 분포)
        long[] dist = new long[6]; // index 1..5
        for (Map<String, Object> row : mapper.ratingDist()) {
            int r = num(row.get("rating")).intValue();
            if (r >= 1 && r <= 5) dist[r] = num(row.get("cnt")).longValue();
        }
        long rTotal = 0, rSum = 0;
        for (int i = 1; i <= 5; i++) { rTotal += dist[i]; rSum += (long) i * dist[i]; }
        Map<String, Object> rating = new LinkedHashMap<>();
        rating.put("avg", rTotal > 0 ? round2((double) rSum / rTotal) : 0.0);
        rating.put("total", rTotal);
        List<Map<String, Object>> stars = new ArrayList<>();
        for (int i = 5; i >= 1; i--) {
            Map<String, Object> s = new LinkedHashMap<>();
            s.put("star", i);
            s.put("count", dist[i]);
            s.put("percent", rTotal > 0 ? Math.round(100.0 * dist[i] / rTotal) : 0);
            stars.add(s);
        }
        rating.put("stars", stars);
        out.put("rating", rating);
        return out;
    }

    // ----------------------------------------------------------------- quality (DB · 자동 평가)
    private List<Map<String, Object>> buildQuality() {
        Map<String, Object> q = mapper.quality();
        List<Map<String, Object>> list = new ArrayList<>();
        list.add(qItem("신뢰성 (Faithfulness)", q.get("faithfulness")));
        list.add(qItem("정확성 (Accuracy)", q.get("accuracy")));
        list.add(qItem("직무 반영도", q.get("jobReflection")));
        list.add(qItem("관련성 (Relevance)", q.get("relevance")));
        return list;
    }
    private Map<String, Object> qItem(String label, Object val) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("label", label);
        m.put("value", val == null ? 0 : Math.round(num(val).doubleValue()));
        return m;
    }

    // ------------------------------------------------------------------ system
    private Map<String, Object> buildSystem() {
        Map<String, Object> out = new LinkedHashMap<>();

        // [미연동] 일별 활용량 — 디자인 샘플값
        String[] days = {"월", "화", "수", "목", "금", "토", "일"};
        int[] vals = {42, 38, 51, 47, 56, 33, 45};
        List<Map<String, Object>> usage = new ArrayList<>();
        long usageTotal = 0;
        for (int i = 0; i < 7; i++) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("day", days[i]);
            m.put("value", (long) vals[i]);
            usage.add(m);
            usageTotal += vals[i];
        }
        Map<String, Object> usageBox = new LinkedHashMap<>();
        usageBox.put("days", usage);
        usageBox.put("total", usageTotal);
        usageBox.put("avg", round1(usageTotal / 7.0));
        out.put("usage", usageBox);

        // [미연동] 성능 지표 — 디자인 샘플값
        Map<String, Object> perf = new LinkedHashMap<>();
        perf.put("apiAvailability", 99.97);
        perf.put("gpuUsage", 64);
        perf.put("dbResponseMs", 38L);
        perf.put("errorRate", 0.12);
        perf.put("queueWaiting", 2L);
        out.put("performance", perf);

        // [DB] 최근 배치
        List<Map<String, Object>> batches = new ArrayList<>();
        for (Map<String, Object> row : mapper.recentBatches()) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", row.get("id"));
            m.put("type", row.get("type"));
            m.put("ts", row.get("ts"));
            m.put("count", num(row.get("cnt")).longValue());
            m.put("duration", fmtDuration(num(row.get("dur")).intValue()));
            m.put("status", BATCH_STATUS.getOrDefault(String.valueOf(row.get("status")), String.valueOf(row.get("status"))));
            batches.add(m);
        }
        out.put("batches", batches);
        return out;
    }

    // ------------------------------------------------------------------ helpers
    private static Number num(Object o) {
        if (o == null) return 0;
        if (o instanceof Number) return (Number) o;
        return Double.parseDouble(o.toString());
    }

    private static String fmtDuration(int sec) {
        if (sec >= 60) return (sec / 60) + "분 " + String.format("%02d", sec % 60) + "초";
        return sec + "초";
    }

    private static double round1(double v) { return Math.round(v * 10.0) / 10.0; }
    private static double round2(double v) { return Math.round(v * 100.0) / 100.0; }
}

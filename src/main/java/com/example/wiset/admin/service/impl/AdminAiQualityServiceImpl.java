package com.example.wiset.admin.service.impl;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.wiset.support.CommonDAO;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 19_관리자 AI 품질 관리 조립 (조회 + 가중치 저장) — 레거시 wbridge commonDAO idiom 이식판(로컬 실행).
 *   metrics(품질 4지표+전월대비) / lowReports / factors(품질저하 요인)
 *   / weights(직무·역량 가중치) / weightsHistory / prompts / saveWeights(쓰기).
 *   SQL 은 sqlmap/mngr/adminAiQuality_mapper.xml (namespace mngr.adminAiQuality) 참조.
 *
 *   [wbridge 포팅 델타] @Service("adminAiQualityService") extends DefaultServiceImpl (패키지 wbridge.mngr...),
 *     CommonDAO 주입 제거(상속 commonDAO 사용), 각 메서드 throws Exception.
 *     트랜잭션은 wbridge 의 dispatcher-transaction.xml AOP 포인트컷이 담당(@Transactional 제거).
 */
@Service
public class AdminAiQualityServiceImpl {

    private final CommonDAO commonDAO;

    public AdminAiQualityServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    private static final Map<Integer, String> PERSONA = new HashMap<>();
    static {
        PERSONA.put(1, "신규 취업");
        PERSONA.put(2, "이직 준비");
        PERSONA.put(3, "재취업");
        PERSONA.put(4, "승진·보직");
    }

    public Map<String, Object> get() throws Exception {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("metrics", buildMetrics());
        out.put("lowReports", buildLowReports());
        out.put("lowReportCount", ((Number) commonDAO.selectOne("mngr.adminAiQuality.lowReportCount")).longValue());
        out.put("factors", buildFactors());
        out.put("weights", buildWeights());
        out.put("weightsHistory", buildHistory());
        out.put("prompts", buildPrompts());
        return out;
    }

    // ------------------------------------------------------------------ metrics
    private List<Map<String, Object>> buildMetrics() throws Exception {
        Map<String, Object> q = commonDAO.selectOne("mngr.adminAiQuality.qualityMetrics");
        List<Map<String, Object>> list = new ArrayList<>();
        list.add(metric("신뢰성 (Faithfulness)", "소스 근거 일치도", q.get("allFaith"), q.get("curFaith"), q.get("prevFaith")));
        list.add(metric("정확성 (Accuracy)", "사실 검증 통과율", q.get("allAcc"), q.get("curAcc"), q.get("prevAcc")));
        list.add(metric("직무 반영도", "직무 키워드 매칭", q.get("allJob"), q.get("curJob"), q.get("prevJob")));
        list.add(metric("관련성 (Relevance)", "질의-응답 관련성", q.get("allRel"), q.get("curRel"), q.get("prevRel")));
        return list;
    }

    private Map<String, Object> metric(String label, String desc, Object all, Object cur, Object prev) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("label", label);
        m.put("desc", desc);
        m.put("value", all == null ? 0 : (int) Math.round(num(all).doubleValue()));
        Double delta = (cur == null || prev == null) ? null : round1(num(cur).doubleValue() - num(prev).doubleValue());
        m.put("delta", delta);
        m.put("trend", (delta == null || delta >= 0) ? "good" : "warn");
        return m;
    }

    // --------------------------------------------------------------- lowReports
    private List<Map<String, Object>> buildLowReports() throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> r : commonDAO.<Map<String, Object>>selectList("mngr.adminAiQuality.lowReports")) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("reportId", r.get("reportId"));
            m.put("persona", PERSONA.getOrDefault(num(r.get("personaCode")).intValue(), "기타"));
            m.put("star", r.get("star") == null ? null : round1(num(r.get("star")).doubleValue()));
            m.put("speed", r.get("ms") == null ? "-" : round1(num(r.get("ms")).doubleValue() / 1000.0) + "초");
            m.put("issue", r.get("issue") == null ? "원인 분석 중" : r.get("issue"));
            list.add(m);
        }
        return list;
    }

    // ------------------------------------------------------------------ factors
    private List<Map<String, Object>> buildFactors() throws Exception {
        List<Map<String, Object>> rows = commonDAO.selectList("mngr.adminAiQuality.qualityFactors");
        long total = 0;
        for (Map<String, Object> r : rows) total += num(r.get("cnt")).longValue();
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> r : rows) {
            long c = num(r.get("cnt")).longValue();
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("label", r.get("factor"));
            m.put("count", c);
            m.put("percent", total > 0 ? Math.round(100.0 * c / total) : 0);
            list.add(m);
        }
        return list;
    }

    // ------------------------------------------------------------------ weights
    private Map<String, Object> buildWeights() throws Exception {
        List<String> jobs = new ArrayList<>();
        Map<String, List<Map<String, Object>>> byJob = new LinkedHashMap<>();
        for (Map<String, Object> r : commonDAO.<Map<String, Object>>selectList("mngr.adminAiQuality.weights")) {
            String job = String.valueOf(r.get("jobName"));
            if (!byJob.containsKey(job)) { byJob.put(job, new ArrayList<>()); jobs.add(job); }
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("competency", r.get("competency"));
            m.put("weight", num(r.get("weight")).intValue());
            m.put("defaultWeight", num(r.get("defaultWeight")).intValue());
            byJob.get(job).add(m);
        }
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("jobs", jobs);
        out.put("byJob", byJob);
        return out;
    }

    // ------------------------------------------------------------------ history
    private List<Map<String, Object>> buildHistory() throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        List<Map<String, Object>> rows = commonDAO.selectList("mngr.adminAiQuality.weightsHistory");
        for (int i = 0; i < rows.size(); i++) {
            Map<String, Object> r = rows.get(i);
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("version", r.get("version"));
            m.put("date", r.get("date"));
            m.put("jobName", r.get("jobName"));
            m.put("reason", r.get("reason"));
            m.put("modifier", r.get("modifier"));
            m.put("current", i == 0); // 최신 = 현재
            list.add(m);
        }
        return list;
    }

    // ------------------------------------------------------------------ prompts
    private List<Map<String, Object>> buildPrompts() throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> r : commonDAO.<Map<String, Object>>selectList("mngr.adminAiQuality.prompts")) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("code", r.get("code"));
            m.put("title", r.get("title"));
            m.put("version", r.get("version"));
            String vars = r.get("variables") == null ? "" : r.get("variables").toString().trim();
            m.put("variables", vars.isEmpty() ? Collections.emptyList() : Arrays.asList(vars.split("\\s+")));
            m.put("content", r.get("content"));
            list.add(m);
        }
        return list;
    }

    // ------------------------------------------------------------ 가중치 저장(쓰기)
    /**
     * 직무 가중치 저장: 합계 100 검증 → 각 역량 UPDATE → 버전 채번 → 변경 이력 1건 기록.
     * @return 갱신된 전체 페이로드(get())
     */
    @Transactional
    public Map<String, Object> saveWeights(String jobName, List<Map<String, Object>> weights, String reason) throws Exception {
        if (jobName == null || jobName.trim().isEmpty()) throw new IllegalArgumentException("대상 직무가 없습니다.");
        if (weights == null || weights.isEmpty()) throw new IllegalArgumentException("가중치 항목이 없습니다.");
        int sum = 0;
        for (Map<String, Object> w : weights) sum += num(w.get("weight")).intValue();
        if (sum != 100) throw new IllegalArgumentException("가중치 합계는 100% 여야 합니다 (현재 " + sum + "%).");

        // 현재 값과 동일하면(실제 변경 없음) UPDATE·이력 기록 모두 생략 (예: '전체'에서 기본값 복원 = 무변경)
        Map<String, Integer> curMap = new HashMap<>();
        for (Map<String, Object> row : commonDAO.<Map<String, Object>>selectList("mngr.adminAiQuality.weights")) {
            if (jobName.equals(String.valueOf(row.get("jobName")))) {
                curMap.put(String.valueOf(row.get("competency")), num(row.get("weight")).intValue());
            }
        }
        boolean changed = false;
        for (Map<String, Object> w : weights) {
            Integer cur = curMap.get(String.valueOf(w.get("competency")));
            if (cur == null || cur.intValue() != num(w.get("weight")).intValue()) { changed = true; break; }
        }
        if (!changed) return get();

        for (Map<String, Object> w : weights) {
            Map<String, Object> up = new HashMap<>();
            up.put("jobName", jobName);
            up.put("competency", String.valueOf(w.get("competency")));
            up.put("weight", num(w.get("weight")).intValue());
            commonDAO.update("mngr.adminAiQuality.updateWeight", up);
        }
        String version = nextVersion(commonDAO.selectOne("mngr.adminAiQuality.latestWeightsVersion"));
        String json = toWeightsJson(weights);
        String r = (reason == null || reason.trim().isEmpty()) ? (jobName + " 가중치 조정") : reason.trim();
        Map<String, Object> hist = new HashMap<>();
        hist.put("version", version);
        hist.put("jobName", jobName);
        hist.put("reason", r);
        hist.put("modifier", "관리자");
        hist.put("weightsJson", json);
        commonDAO.insert("mngr.adminAiQuality.insertWeightsHistory", hist);
        return get();
    }

    /** v3.2 -> v3.3, 형식 안 맞으면 v1.0 */
    private static String nextVersion(String latest) {
        if (latest != null) {
            Matcher m = Pattern.compile("v(\\d+)\\.(\\d+)").matcher(latest.trim());
            if (m.matches()) return "v" + m.group(1) + "." + (Integer.parseInt(m.group(2)) + 1);
        }
        return "v1.0";
    }

    /** [{"competency":"..","weight":N},...] 스냅샷 JSON */
    private static String toWeightsJson(List<Map<String, Object>> weights) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < weights.size(); i++) {
            Map<String, Object> w = weights.get(i);
            if (i > 0) sb.append(',');
            sb.append("{\"competency\":\"")
              .append(String.valueOf(w.get("competency")).replace("\\", "\\\\").replace("\"", "\\\""))
              .append("\",\"weight\":").append(num(w.get("weight")).intValue()).append('}');
        }
        return sb.append(']').toString();
    }

    // ------------------------------------------------------------------ helpers
    private static Number num(Object o) {
        if (o == null) return 0;
        if (o instanceof Number) return (Number) o;
        return Double.parseDouble(o.toString());
    }

    private static double round1(double v) { return Math.round(v * 10.0) / 10.0; }
}

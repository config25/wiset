package com.example.wiset.service;

import com.example.wiset.mapper.AdminReportsMapper;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 20_관리자 리포트 관리 조립 (조회 전용).
 *   KPI + 리포트 목록(페이지네이션). 페르소나 그룹/속도/만족도 라벨링은 여기서.
 */
@Service
public class AdminReportsService {

    private final AdminReportsMapper mapper;

    public AdminReportsService(AdminReportsMapper mapper) {
        this.mapper = mapper;
    }

    /** 승진·보직(4)은 경력성장, 그 외(1~3)는 취업희망 그룹 */
    private static String personaGroup(int code) {
        return code == 4 ? "경력성장" : "취업희망";
    }

    public Map<String, Object> get(int page, int size) {
        return get(page, size, null, null, null, null);
    }

    /**
     * 필터 조회. search(리포트/사용자/직무 키워드) · personaGroup(취업희망/경력성장) ·
     * sat(gte4/3to4/lt3) · days(7/30, null=전체 기간). KPI는 전체 기준(필터 무관).
     */
    public Map<String, Object> get(int page, int size, String search, String personaGroup, String sat, Integer days) {
        if (page < 1) page = 1;
        if (size < 1 || size > 100) size = 20;
        search = blankToNull(search);
        personaGroup = blankToNull(personaGroup);
        sat = blankToNull(sat);
        if (days != null && days <= 0) days = null;

        long total = mapper.count(search, personaGroup, sat, days);
        int offset = (page - 1) * size;

        Map<String, Object> kpiRow = mapper.kpi();
        Map<String, Object> kpi = new LinkedHashMap<>();
        kpi.put("total", num(kpiRow.get("total")).longValue());
        kpi.put("today", num(kpiRow.get("today")).longValue());
        kpi.put("avgSatisfaction", kpiRow.get("avgSatisfaction") == null ? null
                : round2(num(kpiRow.get("avgSatisfaction")).doubleValue()));
        kpi.put("rediagnosis", num(kpiRow.get("rediagnosis")).longValue());

        List<Map<String, Object>> rows = new ArrayList<>();
        for (Map<String, Object> r : mapper.list(search, personaGroup, sat, days, offset, size)) {
            Double satVal = r.get("satisfaction") == null ? null : round1(num(r.get("satisfaction")).doubleValue());
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("reportId", r.get("reportId"));
            m.put("user", r.get("usr"));
            m.put("persona", personaGroup(num(r.get("personaCode")).intValue()));
            m.put("job", r.get("job") == null ? "-" : r.get("job"));
            m.put("score", r.get("score") == null ? null : num(r.get("score")).intValue());
            m.put("cohort", r.get("cohort") == null ? null : num(r.get("cohort")).longValue());
            m.put("satisfaction", satVal);
            m.put("speed", r.get("ms") == null ? "-" : round1(num(r.get("ms")).doubleValue() / 1000.0) + "초");
            m.put("createdAt", r.get("createdAt"));
            m.put("flag", satVal != null && satVal < 3.0); // 낮은 만족도 강조
            rows.add(m);
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("kpi", kpi);
        out.put("total", total);
        out.put("page", page);
        out.put("size", size);
        out.put("totalPages", (int) Math.ceil((double) total / size));
        out.put("rows", rows);
        return out;
    }

    private static Number num(Object o) {
        if (o == null) return 0;
        if (o instanceof Number) return (Number) o;
        return Double.parseDouble(o.toString());
    }

    private static double round1(double v) { return Math.round(v * 10.0) / 10.0; }
    private static double round2(double v) { return Math.round(v * 100.0) / 100.0; }

    private static String blankToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }
}

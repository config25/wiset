package com.example.wiset.mypage.service.impl;

import com.example.wiset.support.CommonDAO;
import com.example.wiset.support.CurrentUser;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 마이페이지 대시보드 조립 (조회 전용).
 *   summary(사용자정보+KPI) / trend(역량 성장 추이) / planner(액션) / history(진단 이력)
 *   // [wbridge] @Mapper 제거 → CommonDAO(mypage.dashboard.*, mypage.resume.*) 이식.
 *   // [wbridge] DTO→Map: 매퍼 결과를 LinkedHashMap 으로 받아 키(=SQL 별칭) 접근. 별칭이 구 DTO 필드명과 동일하여 응답 JSON 무변경.
 */
@Service
public class MyPageDashboardServiceImpl {

    private final CommonDAO commonDAO;

    public MyPageDashboardServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    private static final Map<String, String> TYPE_LABEL = new HashMap<>();
    private static final Map<String, String> TYPE_BADGE = new HashMap<>();
    private static final Map<String, String> STATUS_LABEL = new HashMap<>();
    private static final Map<String, String> TERM_LABEL = new HashMap<>();
    private static final Map<String, String> SOURCE_LABEL = new HashMap<>();
    private static final Map<Integer, String> PERSONA = new HashMap<>();
    private static final Map<String, String> TONE = new HashMap<>();
    private static final Map<String, String> DEGREE_LABEL = new HashMap<>();
    static {
        // TN_RESUME_ACDMCR.LAST_DGRI_SE_CODE → 라벨 (TN_CODE 미시드 → 로컬 매핑)
        DEGREE_LABEL.put("01", "고졸");
        DEGREE_LABEL.put("02", "전문학사");
        DEGREE_LABEL.put("03", "학사");
        DEGREE_LABEL.put("04", "석사");
        DEGREE_LABEL.put("05", "박사");
    }
    static {
        PERSONA.put(1, "신규 취업");
        PERSONA.put(2, "이직 준비");
        PERSONA.put(3, "재취업");
        PERSONA.put(4, "승진·보직 희망");
        TONE.put("AI_COACHING", "accent");
        TONE.put("COMPREHENSIVE", "primary");
        TONE.put("LIGHT", "sub");
    }
    static {
        TYPE_LABEL.put("LIGHT", "취업준비도 진단 (라이트형)");
        TYPE_LABEL.put("COMPREHENSIVE", "직무수행역량 진단 (종합형)");
        TYPE_LABEL.put("AI_COACHING", "AI 커리어 코칭");
        TYPE_BADGE.put("LIGHT", "라이트");
        TYPE_BADGE.put("COMPREHENSIVE", "종합");
        TYPE_BADGE.put("AI_COACHING", "AI");
        STATUS_LABEL.put("TODO", "대기");
        STATUS_LABEL.put("IN_PROGRESS", "진행중");
        STATUS_LABEL.put("DONE", "완료");
        TERM_LABEL.put("SHORT", "단기");
        TERM_LABEL.put("MID", "중기");
        TERM_LABEL.put("LONG", "장기");
        SOURCE_LABEL.put("WBRIDGE", "WISET 추천");
        SOURCE_LABEL.put("EXTERNAL_LINK", "외부 연계");
        SOURCE_LABEL.put("EXTERNAL_REC", "외부 추천");
        SOURCE_LABEL.put("MANUAL", "직접 입력");
        SOURCE_LABEL.put("COHORT", "코호트 추천");
        SOURCE_LABEL.put("AI", "AI 추천");
    }

    public Map<String, Object> getDashboard() throws Exception {
        long u = CurrentUser.userSn();
        Map<String, Object> pu = new HashMap<>();
        pu.put("userSn", u);
        Long profileSn = commonDAO.selectOne("mypage.resume.findUserProfile", pu);
        if (profileSn == null) {
            commonDAO.insert("mypage.resume.insertUserProfilePlaceholder", pu);
        }
        List<Map<String, Object>> diags = commonDAO.selectList("mypage.dashboard.listDiagnoses", pu);   // 오름차순
        List<Map<String, Object>> planner = commonDAO.selectList("mypage.dashboard.listPlanner", pu);
        String currentStatus = commonDAO.selectOne("mypage.dashboard.getCurrentStatus", pu);
        Map<String, Object> profile = commonDAO.selectOne("mypage.dashboard.getProfileHeader", pu);

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("summary", buildSummary(diags, planner, currentStatus, profile));
        out.put("trend", buildTrend(diags));
        out.put("planner", buildPlanner(planner));
        out.put("history", buildHistory(diags));
        return out;
    }

    private Map<String, Object> buildSummary(List<Map<String, Object>> diags, List<Map<String, Object>> planner,
                                             String currentStatus, Map<String, Object> profile) {
        Map<String, Object> s = new LinkedHashMap<>();
        // 회원 프로필 헤더 (TN 조인) — 데이터 없으면 null 유지
        if (profile != null) {
            s.put("name", profile.get("userNm"));
            s.put("email", maskEmail(str(profile.get("email"))));
            s.put("phone", maskPhone(str(profile.get("mbtlnum"))));
            s.put("persona", PERSONA.get(intOrNull(profile.get("personaCode"))));
            s.put("major", profile.get("majorNm"));
            s.put("degree", DEGREE_LABEL.get(str(profile.get("degreeCode"))));
            s.put("age", ageFrom(str(profile.get("brthdy"))));
            s.put("careerTitle", profile.get("careerTitle"));
            s.put("careerYear", careerYear(str(profile.get("careerBeginDe"))));
        }
        Map<String, Object> last = diags.isEmpty() ? null : diags.get(diags.size() - 1);
        Map<String, Object> prev = diags.size() >= 2 ? diags.get(diags.size() - 2) : null;
        s.put("careerGoal", last != null ? last.get("desiredJob") : null);
        s.put("currentStatus", currentStatus);
        s.put("cohortSize", last != null ? last.get("cohortSize") : null);
        s.put("cohortPercentile", last != null ? last.get("cohortPercentile") : null);
        s.put("recentDate", last != null ? last.get("date") : null);
        s.put("recentName", last != null ? (TYPE_LABEL.getOrDefault(str(last.get("diagnosisType")), "진단")
                + (last.get("versionCode") != null ? " " + last.get("versionCode") : "")) : null);
        s.put("totalCount", diags.size());
        s.put("recentScore", last != null ? last.get("totalScore") : null);
        s.put("scoreDelta", delta(last, prev));
        long done = planner.stream().filter(p -> "DONE".equals(p.get("status"))).count();
        s.put("actionsDone", done);
        s.put("actionsTotal", planner.size());
        return s;
    }

    private List<Map<String, Object>> buildTrend(List<Map<String, Object>> diags) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> d : diags) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("ym", d.get("ym"));
            m.put("typeLabel", TYPE_BADGE.getOrDefault(str(d.get("diagnosisType")), ""));
            m.put("professionalism", d.get("professionalism"));
            m.put("leadership", d.get("leadership"));
            m.put("communication", d.get("communication"));
            m.put("problemSolving", d.get("problemSolving"));
            m.put("digital", d.get("digital"));
            list.add(m);
        }
        return list;
    }

    private List<Map<String, Object>> buildPlanner(List<Map<String, Object>> planner) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (Map<String, Object> p : planner) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("title", p.get("title"));
            m.put("source", SOURCE_LABEL.getOrDefault(str(p.get("source")), str(p.get("source"))));
            m.put("term", TERM_LABEL.getOrDefault(str(p.get("term")), str(p.get("term"))));
            m.put("status", STATUS_LABEL.getOrDefault(str(p.get("status")), str(p.get("status"))));
            list.add(m);
        }
        return list;
    }

    private List<Map<String, Object>> buildHistory(List<Map<String, Object>> diags) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (int i = diags.size() - 1; i >= 0; i--) {           // 최신순
            Map<String, Object> d = diags.get(i);
            Map<String, Object> prev = i >= 1 ? diags.get(i - 1) : null;
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("date", d.get("date"));
            m.put("badge", TYPE_BADGE.getOrDefault(str(d.get("diagnosisType")), ""));
            m.put("name", TYPE_LABEL.getOrDefault(str(d.get("diagnosisType")), "진단"));
            m.put("totalScore", d.get("totalScore"));
            m.put("delta", delta(d, prev));
            list.add(m);
        }
        return list;
    }

    /** 진단·코칭 이력 타임라인 (최신순). mypage-history 용. */
    public List<Map<String, Object>> getHistory() throws Exception {
        long u = CurrentUser.userSn();
        Map<String, Object> pu = new HashMap<>();
        pu.put("userSn", u);
        Long profileSn = commonDAO.selectOne("mypage.resume.findUserProfile", pu);
        if (profileSn == null) {
            commonDAO.insert("mypage.resume.insertUserProfilePlaceholder", pu);
        }
        List<Map<String, Object>> rows = commonDAO.selectList("mypage.dashboard.listHistory", pu);   // 최신순
        List<Map<String, Object>> out = new ArrayList<>();
        for (int i = 0; i < rows.size(); i++) {
            Map<String, Object> r = rows.get(i);
            Map<String, Object> older = i + 1 < rows.size() ? rows.get(i + 1) : null;  // 직전(더 과거)
            Integer cur = intOrNull(r.get("totalScore"));
            Integer old = older != null ? intOrNull(older.get("totalScore")) : null;
            Integer diff = (cur != null && old != null) ? cur - old : null;
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("diagnosisId", r.get("diagnosisId"));
            m.put("d", r.get("date"));
            m.put("tm", r.get("time"));
            m.put("id", r.get("code"));
            m.put("title", TYPE_LABEL.getOrDefault(str(r.get("diagnosisType")), "진단"));
            m.put("ver", r.get("versionCode"));
            m.put("score", r.get("totalScore"));
            m.put("delta", (diff != null && diff > 0) ? ("+" + diff) : null);
            m.put("persona", PERSONA.get(intOrNull(r.get("personaCode"))));
            m.put("job", r.get("desiredJob"));
            m.put("concerns", r.get("concernSummary"));
            m.put("tagC", TONE.getOrDefault(str(r.get("diagnosisType")), "sub"));
            m.put("tag", TYPE_BADGE.getOrDefault(str(r.get("diagnosisType")), ""));
            m.put("actions", r.get("actions") != null ? r.get("actions") : 0);
            m.put("satisfaction", r.get("satisfaction"));
            out.add(m);
        }
        return out;
    }

    private Integer delta(Map<String, Object> cur, Map<String, Object> prev) {
        if (cur == null || prev == null) return null;
        Integer c = intOrNull(cur.get("totalScore"));
        Integer p = intOrNull(prev.get("totalScore"));
        if (c == null || p == null) return null;
        return c - p;
    }

    /** Map 값(Number/String/null) → Integer. */
    private static Integer intOrNull(Object o) {
        if (o == null) return null;
        if (o instanceof Number) return ((Number) o).intValue();
        String s = o.toString().trim();
        return s.isEmpty() ? null : Integer.valueOf(s);
    }

    private static String str(Object o) { return o == null ? null : o.toString(); }

    // ── 프로필 헤더 파생값 (개인정보 마스킹 / 나이·연차 계산) ──────────────────

    /** 이메일 마스킹: 로컬파트 앞 3자만 노출 → kjs****@gmail.com */
    private String maskEmail(String email) {
        if (email == null || email.indexOf('@') < 1) return email;
        int at = email.indexOf('@');
        String local = email.substring(0, at);
        String head = local.length() <= 3 ? local : local.substring(0, 3);
        return head + "****" + email.substring(at);
    }

    /** 휴대폰 마스킹: 가운데 자리 마스킹 → 010-****-1234 */
    private String maskPhone(String phone) {
        if (phone == null) return null;
        String digits = phone.replaceAll("[^0-9]", "");
        if (digits.length() < 7) return phone;
        String head = digits.substring(0, 3);
        String tail = digits.substring(digits.length() - 4);
        return head + "-****-" + tail;
    }

    /** 생년월일(YYYYMMDD) → 만 나이. */
    private Integer ageFrom(String brthdy) {
        if (brthdy == null || brthdy.length() < 8) return null;
        try {
            java.time.LocalDate birth = java.time.LocalDate.of(
                    Integer.parseInt(brthdy.substring(0, 4)),
                    Integer.parseInt(brthdy.substring(4, 6)),
                    Integer.parseInt(brthdy.substring(6, 8)));
            return java.time.Period.between(birth, java.time.LocalDate.now()).getYears();
        } catch (RuntimeException e) {
            return null;
        }
    }

    /** 입사일(YYYY-MM-DD 등) → N년차 (시작연도 기준, 올해=1년차). */
    private Integer careerYear(String beginDe) {
        if (beginDe == null || beginDe.length() < 4) return null;
        try {
            int beginYear = Integer.parseInt(beginDe.substring(0, 4));
            int cur = java.time.LocalDate.now().getYear();
            return Math.max(1, cur - beginYear + 1);
        } catch (RuntimeException e) {
            return null;
        }
    }
}

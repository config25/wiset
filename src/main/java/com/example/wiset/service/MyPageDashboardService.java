package com.example.wiset.service;

import com.example.wiset.dto.DiagnosisRow;
import com.example.wiset.dto.HistoryRow;
import com.example.wiset.dto.PlannerRow;
import com.example.wiset.dto.ProfileHeaderRow;
import com.example.wiset.mapper.DashboardMapper;
import com.example.wiset.mapper.ResumeMapper;
import com.example.wiset.support.CurrentUser;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 마이페이지 대시보드 조립 (조회 전용).
 *   summary(사용자정보+KPI) / trend(역량 성장 추이) / planner(액션) / history(진단 이력)
 */
@Service
public class MyPageDashboardService {

    private final DashboardMapper mapper;
    private final ResumeMapper resumeMapper; // 프로필 보장(FK)

    public MyPageDashboardService(DashboardMapper mapper, ResumeMapper resumeMapper) {
        this.mapper = mapper;
        this.resumeMapper = resumeMapper;
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

    public Map<String, Object> getDashboard() {
        long u = CurrentUser.userSn();
        if (resumeMapper.findUserProfile(u) == null) {
            resumeMapper.insertUserProfilePlaceholder(u);
        }
        List<DiagnosisRow> diags = mapper.listDiagnoses(u);   // 오름차순
        List<PlannerRow> planner = mapper.listPlanner(u);
        String currentStatus = mapper.getCurrentStatus(u);
        ProfileHeaderRow profile = mapper.getProfileHeader(u);

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("summary", buildSummary(diags, planner, currentStatus, profile));
        out.put("trend", buildTrend(diags));
        out.put("planner", buildPlanner(planner));
        out.put("history", buildHistory(diags));
        return out;
    }

    private Map<String, Object> buildSummary(List<DiagnosisRow> diags, List<PlannerRow> planner,
                                             String currentStatus, ProfileHeaderRow profile) {
        Map<String, Object> s = new LinkedHashMap<>();
        // 회원 프로필 헤더 (TN 조인) — 데이터 없으면 null 유지
        if (profile != null) {
            s.put("name", profile.getUserNm());
            s.put("email", maskEmail(profile.getEmail()));
            s.put("phone", maskPhone(profile.getMbtlnum()));
            s.put("persona", PERSONA.get(profile.getPersonaCode()));
            s.put("major", profile.getMajorNm());
            s.put("degree", DEGREE_LABEL.get(profile.getDegreeCode()));
            s.put("age", ageFrom(profile.getBrthdy()));
            s.put("careerTitle", profile.getCareerTitle());
            s.put("careerYear", careerYear(profile.getCareerBeginDe()));
        }
        DiagnosisRow last = diags.isEmpty() ? null : diags.get(diags.size() - 1);
        DiagnosisRow prev = diags.size() >= 2 ? diags.get(diags.size() - 2) : null;
        s.put("careerGoal", last != null ? last.getDesiredJob() : null);
        s.put("currentStatus", currentStatus);
        s.put("cohortSize", last != null ? last.getCohortSize() : null);
        s.put("cohortPercentile", last != null ? last.getCohortPercentile() : null);
        s.put("recentDate", last != null ? last.getDate() : null);
        s.put("recentName", last != null ? (TYPE_LABEL.getOrDefault(last.getDiagnosisType(), "진단")
                + (last.getVersionCode() != null ? " " + last.getVersionCode() : "")) : null);
        s.put("totalCount", diags.size());
        s.put("recentScore", last != null ? last.getTotalScore() : null);
        s.put("scoreDelta", delta(last, prev));
        long done = planner.stream().filter(p -> "DONE".equals(p.getStatus())).count();
        s.put("actionsDone", done);
        s.put("actionsTotal", planner.size());
        return s;
    }

    private List<Map<String, Object>> buildTrend(List<DiagnosisRow> diags) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (DiagnosisRow d : diags) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("ym", d.getYm());
            m.put("typeLabel", TYPE_BADGE.getOrDefault(d.getDiagnosisType(), ""));
            m.put("professionalism", d.getProfessionalism());
            m.put("leadership", d.getLeadership());
            m.put("communication", d.getCommunication());
            m.put("problemSolving", d.getProblemSolving());
            m.put("digital", d.getDigital());
            list.add(m);
        }
        return list;
    }

    private List<Map<String, Object>> buildPlanner(List<PlannerRow> planner) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (PlannerRow p : planner) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("title", p.getTitle());
            m.put("source", SOURCE_LABEL.getOrDefault(p.getSource(), p.getSource()));
            m.put("term", TERM_LABEL.getOrDefault(p.getTerm(), p.getTerm()));
            m.put("status", STATUS_LABEL.getOrDefault(p.getStatus(), p.getStatus()));
            list.add(m);
        }
        return list;
    }

    private List<Map<String, Object>> buildHistory(List<DiagnosisRow> diags) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (int i = diags.size() - 1; i >= 0; i--) {           // 최신순
            DiagnosisRow d = diags.get(i);
            DiagnosisRow prev = i >= 1 ? diags.get(i - 1) : null;
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("date", d.getDate());
            m.put("badge", TYPE_BADGE.getOrDefault(d.getDiagnosisType(), ""));
            m.put("name", TYPE_LABEL.getOrDefault(d.getDiagnosisType(), "진단"));
            m.put("totalScore", d.getTotalScore());
            m.put("delta", delta(d, prev));
            list.add(m);
        }
        return list;
    }

    /** 진단·코칭 이력 타임라인 (최신순). mypage-history 용. */
    public List<Map<String, Object>> getHistory() {
        long u = CurrentUser.userSn();
        if (resumeMapper.findUserProfile(u) == null) {
            resumeMapper.insertUserProfilePlaceholder(u);
        }
        List<HistoryRow> rows = mapper.listHistory(u);   // 최신순
        List<Map<String, Object>> out = new ArrayList<>();
        for (int i = 0; i < rows.size(); i++) {
            HistoryRow r = rows.get(i);
            HistoryRow older = i + 1 < rows.size() ? rows.get(i + 1) : null;  // 직전(더 과거)
            Integer diff = (older != null && r.getTotalScore() != null && older.getTotalScore() != null)
                    ? r.getTotalScore() - older.getTotalScore() : null;
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("diagnosisId", r.getDiagnosisId());
            m.put("d", r.getDate());
            m.put("tm", r.getTime());
            m.put("id", r.getCode());
            m.put("title", TYPE_LABEL.getOrDefault(r.getDiagnosisType(), "진단"));
            m.put("ver", r.getVersionCode());
            m.put("score", r.getTotalScore());
            m.put("delta", (diff != null && diff > 0) ? ("+" + diff) : null);
            m.put("persona", PERSONA.get(r.getPersonaCode()));
            m.put("job", r.getDesiredJob());
            m.put("concerns", r.getConcernSummary());
            m.put("tagC", TONE.getOrDefault(r.getDiagnosisType(), "sub"));
            m.put("tag", TYPE_BADGE.getOrDefault(r.getDiagnosisType(), ""));
            m.put("actions", r.getActions() != null ? r.getActions() : 0);
            m.put("satisfaction", r.getSatisfaction());
            out.add(m);
        }
        return out;
    }

    private Integer delta(DiagnosisRow cur, DiagnosisRow prev) {
        if (cur == null || prev == null || cur.getTotalScore() == null || prev.getTotalScore() == null) return null;
        return cur.getTotalScore() - prev.getTotalScore();
    }

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

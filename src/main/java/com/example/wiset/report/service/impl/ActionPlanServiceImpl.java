package com.example.wiset.report.service.impl;

import com.example.wiset.dto.SurveyDto;
import com.example.wiset.dto.SurveySubmitDto;
import com.example.wiset.support.CommonDAO;
import com.example.wiset.support.CurrentUser;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 05 액션 플랜.
 *   조회: 액션 플래너(sys_action_planner) + 추천 활동(sys_resource) — AI 출력 연결 전, 기존 테이블로 선연결.
 *   저장: 만족도 별점(1~4)+자유 의견(문항 5) → sys_ai_report_survey,
 *         추천 의향(좋아요/싫어요)            → sys_user_activity_log(thumbs).
 *   (교육 부족역량 키워드는 AI 진단 파생이라 추후 연결)
 */
// [wbridge] @Mapper 제거 → CommonDAO 이식(actionPlanner/aiReport/resume/survey). DTO 유지.
@Service
public class ActionPlanServiceImpl {

    /** 자유 서술 의견 문항 번호(별점 1~4 다음). */
    private static final int OPINION_QUESTION_NO = 5;

    /** source_type_code → 화면 라벨 (mypage 액션 플래너와 동일 규칙) */
    private static final Map<String, String> SOURCE_LABEL = new LinkedHashMap<>();
    static {
        SOURCE_LABEL.put("WBRIDGE", "W브릿지");
        SOURCE_LABEL.put("EXTERNAL", "외부연계");
        SOURCE_LABEL.put("EXTERNAL_LINK", "외부 연계");
        SOURCE_LABEL.put("EXTERNAL_REC", "외부 추천");
        SOURCE_LABEL.put("MANUAL", "직접 입력");
        SOURCE_LABEL.put("COHORT", "코호트 추천");
        SOURCE_LABEL.put("AI", "AI 추천");
    }

    private final CommonDAO commonDAO; // survey/resume/actionPlanner/aiReport 통합
    private final ObjectMapper om = new ObjectMapper();

    public ActionPlanServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    private static String str(Object o) { return o == null ? null : o.toString(); }

    /**
     * 액션 플랜 리포트 스냅샷 조회(읽기전용 재조회용).
     *   content(JSON) = 생성 시점의 planner + recommendations + gapRecs 스냅샷.
     *   diagnosisId 지정 시 그 진단의 리포트, null 이면 최신. 없으면 content=null(프론트 라이브 폴백).
     */
    public Map<String, Object> getReport(Long diagnosisId) throws Exception {
        long u = CurrentUser.userSn();
        Map<String, Object> pContent = new HashMap<>();
        pContent.put("userSn", u);
        pContent.put("reportType", "ACTION_PLAN");
        pContent.put("diagnosisId", diagnosisId);
        String json = commonDAO.selectOne("report.aiReport.findContent", pContent);
        Map<String, Object> out = new LinkedHashMap<>();
        Object content = null;
        if (json != null && !json.trim().isEmpty()) {
            try {
                content = om.readValue(json, Object.class);
            } catch (Exception e) {
                content = null;
            }
        }
        out.put("content", content);
        return out;
    }

    /**
     * /action-plan 화면 데이터 (조회 전용).
     *   planner         = 내 액션 플래너, 기간(SHORT/MID/LONG)별 묶음
     *   recommendations = 추천 활동, 카테고리(job=채용/support=지원사업/cohort=코호트)별 묶음
     * AI 출력이 채워지기 전이므로 비어 있으면 프론트가 목업으로 폴백한다.
     */
    public Map<String, Object> getData() throws Exception {
        long u = CurrentUser.userSn();
        Map<String, Object> pUser = new HashMap<>();
        pUser.put("userSn", u);
        if (commonDAO.selectOne("mypage.resume.findUserProfile", pUser) == null) {
            commonDAO.insert("mypage.resume.insertUserProfilePlaceholder", pUser);
        }

        // 1) 액션 플래너 — 기간별 그룹
        Map<String, List<Map<String, Object>>> planner = new LinkedHashMap<>();
        planner.put("SHORT", new ArrayList<>());
        planner.put("MID",   new ArrayList<>());
        planner.put("LONG",  new ArrayList<>());
        for (Map<String, Object> it : commonDAO.<Map<String, Object>>selectList("mypage.actionPlanner.listItems", pUser)) {
            List<Map<String, Object>> bucket = planner.get(str(it.get("term")));
            if (bucket == null) continue; // 알 수 없는 기간 코드는 제외
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("plannerId", it.get("plannerId"));   // 닫기(삭제)용
            m.put("title", it.get("title"));
            m.put("source", SOURCE_LABEL.getOrDefault(str(it.get("source")), str(it.get("source"))));
            m.put("status", it.get("status"));
            bucket.add(m);
        }

        // 2) 추천 활동 — 카테고리별 그룹 (COHORT 출처는 type 무관 코호트 탭으로)
        Map<String, List<Map<String, Object>>> recs = new LinkedHashMap<>();
        recs.put("job",     new ArrayList<>());
        recs.put("support", new ArrayList<>());
        recs.put("cohort",  new ArrayList<>());
        for (Map<String, Object> r : commonDAO.<Map<String, Object>>selectList("mypage.actionPlanner.listRecommendations")) {
            String sourceType = str(r.get("sourceType"));
            String type = str(r.get("type"));
            String cat;
            if ("COHORT".equals(sourceType)) cat = "cohort";
            else if ("SUPPORT".equals(type))  cat = "support";
            else if ("JOB".equals(type))      cat = "job";
            else continue; // EDUCATION 등은 이 화면의 추천 탭 3종에 없음
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("resourceId", r.get("resourceId"));                                // 담기 저장용
            m.put("title", r.get("title"));
            m.put("org", r.get("org"));
            m.put("location", r.get("location"));
            m.put("salaryMin", r.get("salaryMin"));
            m.put("salaryMax", r.get("salaryMax"));
            m.put("content", r.get("content"));
            m.put("source", SOURCE_LABEL.getOrDefault(sourceType, sourceType));      // 표시 라벨
            m.put("sourceCode", sourceType);                                         // 저장용 코드
            recs.get(cat).add(m);
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("planner", planner);
        out.put("recommendations", recs);
        return out;
    }

    @Transactional
    public void saveSurvey(SurveySubmitDto req) throws Exception {
        long userSn = CurrentUser.userSn();
        Map<String, Object> pUser = new HashMap<>();
        pUser.put("userSn", userSn);
        if (commonDAO.selectOne("mypage.resume.findUserProfile", pUser) == null) {
            commonDAO.insert("mypage.resume.insertUserProfilePlaceholder", pUser);
        }
        commonDAO.delete("report.survey.deleteDraftByUser", pUser); // 재제출 시 별점·의견 draft 교체

        // 별점 문항(1~4)
        if (req.getRatings() != null) {
            for (SurveyDto d : req.getRatings()) {
                if (d.getRating() != null && d.getRating() > 0) {
                    Map<String, Object> p = new HashMap<>();
                    p.put("userSn", userSn);
                    p.put("d", d);
                    commonDAO.insert("report.survey.insertSurvey", p);
                }
            }
        }
        // 자유 의견(문항 5) — 별점 없이 텍스트만, 입력 시에만 1행
        String opinion = req.getOpinion();
        if (opinion != null && !opinion.trim().isEmpty()) {
            SurveyDto o = new SurveyDto();
            o.setQuestionNo(OPINION_QUESTION_NO);
            o.setOpinion(opinion.trim());
            Map<String, Object> p = new HashMap<>();
            p.put("userSn", userSn);
            p.put("d", o);
            commonDAO.insert("report.survey.insertSurvey", p); // rating NULL
        }
        // 추천 의향(좋아요/싫어요) — 행동 로그(append-only)
        String rec = req.getRecommend();
        if ("up".equals(rec) || "down".equals(rec)) {
            Map<String, Object> p = new HashMap<>();
            p.put("userSn", userSn);
            p.put("value", "thumbs_" + rec);
            commonDAO.insert("report.survey.insertThumb", p);
        }
    }
}

package com.example.wiset.service;

import com.example.wiset.dto.ActionPlannerItemDto;
import com.example.wiset.dto.RecommendationDto;
import com.example.wiset.dto.SurveyDto;
import com.example.wiset.dto.SurveySubmitDto;
import com.example.wiset.mapper.ActionPlannerMapper;
import com.example.wiset.mapper.AiReportMapper;
import com.example.wiset.mapper.ResumeMapper;
import com.example.wiset.mapper.SurveyMapper;
import com.example.wiset.support.CurrentUser;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
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
@Service
public class ActionPlanService {

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

    private final SurveyMapper surveyMapper;
    private final ResumeMapper resumeMapper; // sys_user_profile 보장 재사용(survey.user_id FK)
    private final ActionPlannerMapper plannerMapper; // 액션 플래너/추천 활동 조회 재사용
    private final AiReportMapper aiReportMapper;      // 리포트 스냅샷(ACTION_PLAN) 조회
    private final ObjectMapper om = new ObjectMapper();

    public ActionPlanService(SurveyMapper surveyMapper, ResumeMapper resumeMapper,
                             ActionPlannerMapper plannerMapper, AiReportMapper aiReportMapper) {
        this.surveyMapper = surveyMapper;
        this.resumeMapper = resumeMapper;
        this.plannerMapper = plannerMapper;
        this.aiReportMapper = aiReportMapper;
    }

    /**
     * 액션 플랜 리포트 스냅샷 조회(읽기전용 재조회용).
     *   content(JSON) = 생성 시점의 planner + recommendations + gapRecs 스냅샷.
     *   diagnosisId 지정 시 그 진단의 리포트, null 이면 최신. 없으면 content=null(프론트 라이브 폴백).
     */
    public Map<String, Object> getReport(Long diagnosisId) {
        long u = CurrentUser.userSn();
        String json = aiReportMapper.findContent(u, "ACTION_PLAN", diagnosisId);
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
    public Map<String, Object> getData() {
        long u = CurrentUser.userSn();
        if (resumeMapper.findUserProfile(u) == null) {
            resumeMapper.insertUserProfilePlaceholder(u);
        }

        // 1) 액션 플래너 — 기간별 그룹
        Map<String, List<Map<String, Object>>> planner = new LinkedHashMap<>();
        planner.put("SHORT", new ArrayList<>());
        planner.put("MID",   new ArrayList<>());
        planner.put("LONG",  new ArrayList<>());
        for (ActionPlannerItemDto it : plannerMapper.listItems(u)) {
            List<Map<String, Object>> bucket = planner.get(it.getTerm());
            if (bucket == null) continue; // 알 수 없는 기간 코드는 제외
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("plannerId", it.getPlannerId());   // 닫기(삭제)용
            m.put("title", it.getTitle());
            m.put("source", SOURCE_LABEL.getOrDefault(it.getSource(), it.getSource()));
            m.put("status", it.getStatus());
            bucket.add(m);
        }

        // 2) 추천 활동 — 카테고리별 그룹 (COHORT 출처는 type 무관 코호트 탭으로)
        Map<String, List<Map<String, Object>>> recs = new LinkedHashMap<>();
        recs.put("job",     new ArrayList<>());
        recs.put("support", new ArrayList<>());
        recs.put("cohort",  new ArrayList<>());
        for (RecommendationDto r : plannerMapper.listRecommendations()) {
            String cat;
            if ("COHORT".equals(r.getSourceType())) cat = "cohort";
            else if ("SUPPORT".equals(r.getType()))  cat = "support";
            else if ("JOB".equals(r.getType()))      cat = "job";
            else continue; // EDUCATION 등은 이 화면의 추천 탭 3종에 없음
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("resourceId", r.getResourceId());                                  // 담기 저장용
            m.put("title", r.getTitle());
            m.put("org", r.getOrg());
            m.put("location", r.getLocation());
            m.put("salaryMin", r.getSalaryMin());
            m.put("salaryMax", r.getSalaryMax());
            m.put("content", r.getContent());
            m.put("source", SOURCE_LABEL.getOrDefault(r.getSourceType(), r.getSourceType())); // 표시 라벨
            m.put("sourceCode", r.getSourceType());                                  // 저장용 코드
            recs.get(cat).add(m);
        }

        Map<String, Object> out = new LinkedHashMap<>();
        out.put("planner", planner);
        out.put("recommendations", recs);
        return out;
    }

    @Transactional
    public void saveSurvey(SurveySubmitDto req) {
        long userSn = CurrentUser.userSn();
        if (resumeMapper.findUserProfile(userSn) == null) {
            resumeMapper.insertUserProfilePlaceholder(userSn);
        }
        surveyMapper.deleteDraftByUser(userSn); // 재제출 시 별점·의견 draft 교체

        // 별점 문항(1~4)
        if (req.getRatings() != null) {
            for (SurveyDto d : req.getRatings()) {
                if (d.getRating() != null && d.getRating() > 0) {
                    surveyMapper.insertSurvey(userSn, d);
                }
            }
        }
        // 자유 의견(문항 5) — 별점 없이 텍스트만, 입력 시에만 1행
        String opinion = req.getOpinion();
        if (opinion != null && !opinion.trim().isEmpty()) {
            SurveyDto o = new SurveyDto();
            o.setQuestionNo(OPINION_QUESTION_NO);
            o.setOpinion(opinion.trim());
            surveyMapper.insertSurvey(userSn, o); // rating NULL
        }
        // 추천 의향(좋아요/싫어요) — 행동 로그(append-only)
        String rec = req.getRecommend();
        if ("up".equals(rec) || "down".equals(rec)) {
            surveyMapper.insertThumb(userSn, "thumbs_" + rec);
        }
    }
}

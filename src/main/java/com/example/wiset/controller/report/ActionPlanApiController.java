package com.example.wiset.controller.report;

import com.example.wiset.dto.SurveySubmitDto;
import com.example.wiset.service.ActionPlanService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 05 액션 플랜 - 조사 API.
 *   만족도(별점 1~4 + 자유 의견) + 추천 의향(좋아요/싫어요) 저장. 액션플래너/추천은 AI라 추후.
 */
@RestController
@RequestMapping("/api/action-plan")
public class ActionPlanApiController {

    private final ActionPlanService actionPlanService;

    public ActionPlanApiController(ActionPlanService actionPlanService) {
        this.actionPlanService = actionPlanService;
    }

    /** 액션 플래너 + 추천 활동 조회 (기존 테이블 선연결, 라이브 편집용) */
    @GetMapping("/data")
    public Map<String, Object> data() {
        return actionPlanService.getData();
    }

    /** 액션 플랜 리포트 스냅샷 조회 (읽기전용 재조회용). diagnosisId 없으면 최신 1건. */
    @GetMapping("/report")
    public Map<String, Object> report(@RequestParam(required = false) Long diagnosisId) {
        return actionPlanService.getReport(diagnosisId);
    }

    @PostMapping("/survey")
    public void saveSurvey(@RequestBody SurveySubmitDto req) {
        actionPlanService.saveSurvey(req);
    }
}

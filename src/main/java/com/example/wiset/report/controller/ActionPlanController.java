package com.example.wiset.report.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 13_AI 리포트 (액션 플랜) 화면.
 * 리포트의 '액션 플랜' 탭 — 액션 플래너 + 추천 활동(채용/지원사업/코호트) + 교육·멘토링 + 만족도 조사.
 * (액션 플래너 -> sys_action_planner, 만족도 -> sys_ai_report_survey)
 */
@Controller
public class ActionPlanController {

    @GetMapping("/action-plan")
    public String actionPlan() {
        return "action-plan"; // -> /WEB-INF/views/action-plan.jsp
    }
}

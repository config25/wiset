package com.example.wiset.controller.report;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 12_AI 리포트 (활동 분석) 화면.
 * 리포트의 '활동 분석' 탭 — JD 적합률, JD 비교, 역량 오각형, 역량별 해설.
 * (역량 점수 -> sys_competency_diagnosis)
 */
@Controller
public class ActivityAnalysisController {

    @GetMapping("/activity-analysis")
    public String activityAnalysis() {
        return "activity-analysis"; // -> /WEB-INF/views/activity-analysis.jsp
    }
}

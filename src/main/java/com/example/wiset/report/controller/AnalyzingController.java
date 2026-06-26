package com.example.wiset.report.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 07_분석 진행 (로딩) / 07b_분석 완료 화면.
 * 실제로는 AI 분석 API 진행 상태를 표시해야 하나, 현재는 시각용 시뮬레이션만.
 *   진행률 100% 도달 시 analyzing.jsp 가 /analysis-complete 로 이동.
 */
@Controller
public class AnalyzingController {

    @GetMapping("/analyzing")
    public String analyzing() {
        return "analyzing"; // -> /WEB-INF/views/analyzing.jsp
    }

    @GetMapping("/analysis-complete")
    public String analysisComplete() {
        return "analysis-complete"; // -> /WEB-INF/views/analysis-complete.jsp (07b)
    }
}

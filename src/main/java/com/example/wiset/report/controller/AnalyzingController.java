package com.example.wiset.report.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 07_분석 진행 (로딩) / 07b_분석 완료 화면.
 * 실제로는 AI 분석 API 진행 상태를 표시해야 하나, 현재는 시각용 시뮬레이션만.
 *   진행률 100% 도달 시 analyzing.jsp 가 /analysis-complete 로 이동.
 */
@Controller
public class AnalyzingController {

    private static final Logger log = LoggerFactory.getLogger(AnalyzingController.class);

    @GetMapping("/analyzing")
    public String analyzing() {
        log.warn("[분석화면] ⚠ '분석 진행'은 현재 시각 시뮬레이션만 — 이 경로는 /api/report/generate(AI 호출+DB UPDATE)를 "
                + "호출하지 않습니다. → AI 최신 답변이 DB에 반영되려면 분석 시작 시 /api/report/generate 를 호출해야 함(현재 누락).");
        return "analyzing"; // -> /WEB-INF/views/analyzing.jsp
    }

    @GetMapping("/analysis-complete")
    public String analysisComplete() {
        log.info("[분석화면] 분석 완료 화면 → 리포트 본문은 /api/ai-coaching/report 로 DB에서 '조회'만 함(생성 아님)");
        return "analysis-complete"; // -> /WEB-INF/views/analysis-complete.jsp (07b)
    }
}

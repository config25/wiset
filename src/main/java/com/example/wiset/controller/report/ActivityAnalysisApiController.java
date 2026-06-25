package com.example.wiset.controller.report;

import com.example.wiset.service.ActivityAnalysisService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 12 활동 분석 리포트 - 조회 API.
 *   저장된 분석 본문(JSON)을 반환 → 화면 재조회 시 동일 디자인으로 렌더.
 */
@RestController
@RequestMapping("/api/activity-analysis")
public class ActivityAnalysisApiController {

    private final ActivityAnalysisService service;

    public ActivityAnalysisApiController(ActivityAnalysisService service) {
        this.service = service;
    }

    @GetMapping("/report")
    public Map<String, Object> report(@RequestParam(required = false) Long diagnosisId) {
        return service.getAnalysisReport(diagnosisId);
    }
}

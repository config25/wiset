package com.example.wiset.controller.report;

import com.example.wiset.service.AiCoachingService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 08 AI 코칭 리포트 - 조회 API.
 *   저장된 리포트 본문(JSON)을 반환 → 화면 재조회(리포트 보기) 시 동일 디자인으로 렌더.
 */
@RestController
@RequestMapping("/api/ai-coaching")
public class AiCoachingApiController {

    private final AiCoachingService service;

    public AiCoachingApiController(AiCoachingService service) {
        this.service = service;
    }

    @GetMapping("/report")
    public Map<String, Object> report(@RequestParam(required = false) Long diagnosisId) {
        return service.getCoachingReport(diagnosisId);
    }
}

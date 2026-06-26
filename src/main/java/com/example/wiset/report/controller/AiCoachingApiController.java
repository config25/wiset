package com.example.wiset.report.controller;

import com.example.wiset.report.service.impl.AiCoachingServiceImpl;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 08 AI 코칭 리포트 - 조회 API.
 *   저장된 리포트 본문(JSON)을 반환 → 화면 재조회(리포트 보기) 시 동일 디자인으로 렌더.
 *
 * [wbridge 포팅 델타] @Controller extends DefaultController · @Resource 주입 · @RequestMapping("/report/*.do") ·
 *   @RequestParam Map+ModelMap → return "jsonView". 조회 결과는 이미 Map.
 */
@RestController
@RequestMapping("/api/ai-coaching")
public class AiCoachingApiController {

    private final AiCoachingServiceImpl service;

    public AiCoachingApiController(AiCoachingServiceImpl service) {
        this.service = service;
    }

    @GetMapping("/report")
    public Map<String, Object> report(@RequestParam(required = false) Long diagnosisId) throws Exception {
        return service.getCoachingReport(diagnosisId);
    }
}

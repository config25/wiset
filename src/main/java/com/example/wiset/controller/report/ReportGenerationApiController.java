package com.example.wiset.controller.report;

import com.example.wiset.dto.ai.GenerationInputs;
import com.example.wiset.service.ReportGenerationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;

/**
 * AI 리포트 생성 API.
 *   현재: 3개 외부 AI API 를 병렬 호출하고 원본 응답을 그대로 반환(응답 스키마 확인용).
 *   입력은 본문(GenerationInputs)으로 직접 전달 — 추후 CurrentUser 기준 DB 자동 조립으로 대체.
 */
@Slf4j
@RestController
@RequestMapping("/api/report")
public class ReportGenerationApiController {

    private final ReportGenerationService service;

    public ReportGenerationApiController(ReportGenerationService service) {
        this.service = service;
    }

    @PostMapping("/generate")
    public ResponseEntity<?> generate(@RequestBody(required = false) GenerationInputs in) {
        try {
            return ResponseEntity.ok(service.generate(in == null ? new GenerationInputs() : in));
        } catch (Exception e) {
            log.error("AI 리포트 생성 실패", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("message", "리포트 생성에 실패했습니다."));
        }
    }
}

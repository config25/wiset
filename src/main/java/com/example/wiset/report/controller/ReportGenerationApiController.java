package com.example.wiset.report.controller;

import com.example.wiset.dto.ai.GenerationInputs;
import com.example.wiset.report.service.impl.ReportGenerationJobService;
import com.example.wiset.support.CurrentUser;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * AI 리포트 생성 API (비동기).
 *   외부 AI 추론 서버가 느려 생성이 수 분 걸리므로, 요청은 백그라운드 잡만 띄우고 즉시 반환한다.
 *   프론트(분석 진행 화면)는 {@code GET /api/report/status} 를 폴링해 완료 여부를 확인한다.
 *
 * [wbridge 포팅 델타] @Controller extends DefaultController · @Resource 주입 · @RequestMapping("/report/*.json") ·
 *   ResponseEntity → ModelMap + return "jsonView".
 */
@RestController
@RequestMapping("/api/report")
public class ReportGenerationApiController {

    private final ReportGenerationJobService jobService;

    public ReportGenerationApiController(ReportGenerationJobService jobService) {
        this.jobService = jobService;
    }

    /** 생성 시작(비동기) — 백그라운드 잡을 띄우고 즉시 202 반환. 이미 진행 중이면 중복 시작 생략. */
    @PostMapping("/generate")
    public ResponseEntity<?> generate(@RequestBody(required = false) GenerationInputs in) {
        long userSn = CurrentUser.userSn();
        return ResponseEntity.accepted()
                .body(jobService.start(userSn, in == null ? new GenerationInputs() : in));
    }

    /** 생성 진행 상태(프론트 폴링용) — status: idle|running|done|failed. */
    @GetMapping("/status")
    public ResponseEntity<?> status() {
        return ResponseEntity.ok(jobService.status(CurrentUser.userSn()));
    }
}

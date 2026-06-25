package com.example.wiset.controller.stage;

import com.example.wiset.service.AnalysisService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.Map;

/**
 * 분석 시작 - 입력 데이터 일괄 저장 API (AI 전송 제외, 저장만).
 *   sessionStorage 선택값(페르소나/현황/경력목표/고민/경력성장) → DB.
 */
@Slf4j
@RestController
@RequestMapping("/api/analysis")
public class AnalysisApiController {

    private final AnalysisService service;

    public AnalysisApiController(AnalysisService service) {
        this.service = service;
    }

    @PostMapping("/save")
    public ResponseEntity<?> save(@RequestBody Map<String, Object> body) {
        try {
            service.saveInput(body);
            return ResponseEntity.ok(Collections.singletonMap("message", "저장 완료"));
        } catch (Exception e) {
            log.error("분석 입력 저장 실패", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("message", "입력 저장에 실패했습니다."));
        }
    }
}

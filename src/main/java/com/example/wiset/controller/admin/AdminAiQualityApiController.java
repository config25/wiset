package com.example.wiset.controller.admin;

import com.example.wiset.service.AdminAiQualityService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/** 19_관리자 AI 품질 관리 - 조회 전용 API */
@Slf4j
@RestController
@RequestMapping("/api/admin/ai-quality")
public class AdminAiQualityApiController {

    private final AdminAiQualityService service;

    public AdminAiQualityApiController(AdminAiQualityService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<?> aiQuality() {
        try {
            return ResponseEntity.ok(service.get());
        } catch (Exception e) {
            log.error("관리자 AI 품질 조회 실패", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("message", "AI 품질 데이터를 불러오지 못했습니다."));
        }
    }

    /** 직무 가중치 저장 (변경 이력 기록). body: {jobName, weights:[{competency,weight}], reason} */
    @SuppressWarnings("unchecked")
    @PostMapping("/weights")
    public ResponseEntity<?> saveWeights(@RequestBody Map<String, Object> body) {
        try {
            String jobName = (String) body.get("jobName");
            List<Map<String, Object>> weights = (List<Map<String, Object>>) body.get("weights");
            String reason = (String) body.get("reason");
            return ResponseEntity.ok(service.saveWeights(jobName, weights, reason));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Collections.singletonMap("message", e.getMessage()));
        } catch (Exception e) {
            log.error("가중치 저장 실패", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("message", "가중치 저장에 실패했습니다."));
        }
    }
}

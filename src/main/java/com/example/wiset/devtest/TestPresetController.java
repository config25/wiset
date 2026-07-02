package com.example.wiset.devtest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Collections;

/**
 * [개발용] 시연 테스트 콘솔.
 *   GET  /test                  → 테스트 전용 대시보드 화면(test.jsp).
 *   POST /api/test/load/{1~4}   → 해당 페르소나를 데모 계정(user 1)에 시딩 + sessionStorage 페이로드(JSON) 반환.
 *   POST /api/test/clear        → user 1 현 상황(DB) 전량 삭제(세션은 클라이언트가 비움).
 *   GET  /api/test/state        → user 1 현 상황 요약(항목 건수 + 최종학력 식별자).
 * ※ 로그인/시큐리티가 없어 누구나 접근 가능한 개발 전용 도구. 운영 배포 시 제거/차단 필요.
 */
@Controller
public class TestPresetController {

    private static final Logger log = LoggerFactory.getLogger(TestPresetController.class);

    private final TestPresetService service;

    public TestPresetController(TestPresetService service) {
        this.service = service;
    }

    /** 테스트 콘솔 페이지 (view: /WEB-INF/jsp/wbro/test.jsp) */
    @GetMapping("/test")
    public String page() {
        return "test";
    }

    @PostMapping("/api/test/load/{persona}")
    @ResponseBody
    public ResponseEntity<?> load(@PathVariable int persona) {
        try {
            return ResponseEntity.ok(service.load(persona));
        } catch (Exception e) {
            log.error("[api/test] 프리셋 로드 실패 persona={}", persona, e);
            return ResponseEntity.status(500)
                    .body(Collections.singletonMap("message", "프리셋 로드 실패: " + e.getMessage()));
        }
    }

    @PostMapping("/api/test/clear")
    @ResponseBody
    public ResponseEntity<?> clear() {
        try {
            service.clear();
            return ResponseEntity.ok(Collections.singletonMap("message", "현 상황(user 1) 비움 완료"));
        } catch (Exception e) {
            log.error("[api/test] 세션 비우기 실패", e);
            return ResponseEntity.status(500)
                    .body(Collections.singletonMap("message", "비우기 실패: " + e.getMessage()));
        }
    }

    @GetMapping("/api/test/state")
    @ResponseBody
    public ResponseEntity<?> state() {
        try {
            return ResponseEntity.ok(service.state());
        } catch (Exception e) {
            log.error("[api/test] 상태 조회 실패", e);
            return ResponseEntity.status(500)
                    .body(Collections.singletonMap("message", "상태 조회 실패: " + e.getMessage()));
        }
    }
}

package com.example.wiset.controller.admin;

import com.example.wiset.service.AdminSatisfactionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;

/** 18_관리자 만족도 관리 - 조회 전용 API */
@Slf4j
@RestController
@RequestMapping("/api/admin/satisfaction")
public class AdminSatisfactionApiController {

    private final AdminSatisfactionService service;

    public AdminSatisfactionApiController(AdminSatisfactionService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<?> satisfaction() {
        try {
            return ResponseEntity.ok(service.get());
        } catch (Exception e) {
            log.error("관리자 만족도 조회 실패", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("message", "만족도 데이터를 불러오지 못했습니다."));
        }
    }
}

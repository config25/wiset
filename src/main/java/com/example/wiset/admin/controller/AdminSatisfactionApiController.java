package com.example.wiset.admin.controller;

import com.example.wiset.admin.service.impl.AdminSatisfactionServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;

/**
 * 18_관리자 만족도 관리 - 조회 전용 API.
 * [wbridge 포팅 델타] 지금은 Boot 그대로 실행. 포팅 시: @Controller extends DefaultController,
 *   @Resource(name="adminSatisfactionService"), @RequestMapping("/mngr/admin/...do"), @RequestParam Map+ModelMap,
 *   return "jsonView". (서비스/매퍼는 이미 wbridge idiom: CommonDAO + mngr.adminSatisfaction.*)
 */
@RestController
@RequestMapping("/api/admin/satisfaction")
public class AdminSatisfactionApiController {

    private static final Logger log = LoggerFactory.getLogger(AdminSatisfactionApiController.class);

    private final AdminSatisfactionServiceImpl service;

    public AdminSatisfactionApiController(AdminSatisfactionServiceImpl service) {
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

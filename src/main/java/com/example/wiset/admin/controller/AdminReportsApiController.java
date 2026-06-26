package com.example.wiset.admin.controller;

import com.example.wiset.admin.service.impl.AdminReportsServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;

/**
 * 20_관리자 리포트 관리 - 조회 전용 API.
 *
 * [wbridge 포팅 델타] (지금은 Boot 그대로 실행 — admin-reports.jsp 가 /api/admin/reports 호출)
 *   - 선언: @Controller public class AdminReportsController extends DefaultController (패키지 wbridge.mngr...).
 *   - 주입: @Resource(name="adminReportsService") private AdminReportsServiceImpl service.
 *   - 매핑: @RequestMapping("/mngr/admin/selectReports.do"), @RequestParam Map param, ModelMap model.
 *   - 반환: model.addAttribute(...) 후 return "jsonView"  (MappingJackson2JsonView 빈이 직렬화).
 *   서비스/매퍼 계층은 이미 wbridge idiom(CommonDAO + mngr.adminReports.* )이라 그대로 이식됨.
 */
@RestController
@RequestMapping("/api/admin/reports")
public class AdminReportsApiController {

    private static final Logger log = LoggerFactory.getLogger(AdminReportsApiController.class);

    private final AdminReportsServiceImpl service;

    public AdminReportsApiController(AdminReportsServiceImpl service) {
        this.service = service;
    }

    /**
     * KPI + 리포트 목록 (필터·페이지네이션).
     * @param search   리포트/사용자/직무 키워드
     * @param persona  '취업희망' | '경력성장' (그 외/빈값=전체)
     * @param sat      'gte4'(★4↑) | '3to4' | 'lt3'(★3↓) (그 외/빈값=전체)
     * @param period   7 | 30 (그 외/0/빈값=전체 기간)
     */
    @GetMapping
    public ResponseEntity<?> reports(@RequestParam(defaultValue = "1") int page,
                                     @RequestParam(defaultValue = "20") int size,
                                     @RequestParam(required = false) String search,
                                     @RequestParam(required = false) String persona,
                                     @RequestParam(required = false) String sat,
                                     @RequestParam(required = false) Integer period) {
        try {
            return ResponseEntity.ok(service.get(page, size, search, persona, sat, period));
        } catch (Exception e) {
            log.error("관리자 리포트 목록 조회 실패 (page={}, size={})", page, size, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("message", "리포트 목록을 불러오지 못했습니다."));
        }
    }
}

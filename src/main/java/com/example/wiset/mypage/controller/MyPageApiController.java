package com.example.wiset.mypage.controller;

import com.example.wiset.mypage.service.impl.MyPageDashboardServiceImpl;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * 마이페이지 대시보드 - 조회 전용 API
 *
 * [wbridge 포팅 델타] @Controller extends DefaultController · @Resource(name="...") 서비스 주입 ·
 *   @RequestMapping("/mypage/*.do") · @RequestParam Map param+ModelMap → return "jsonView". 조회 결과는 이미 Map.
 */
@RestController
@RequestMapping("/api/mypage")
public class MyPageApiController {

    private final MyPageDashboardServiceImpl dashboardService;

    public MyPageApiController(MyPageDashboardServiceImpl dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/dashboard")
    public Map<String, Object> dashboard() throws Exception {
        return dashboardService.getDashboard();
    }

    @GetMapping("/history")
    public java.util.List<Map<String, Object>> history() throws Exception {
        return dashboardService.getHistory();
    }
}

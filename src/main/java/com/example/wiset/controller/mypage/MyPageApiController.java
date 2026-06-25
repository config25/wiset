package com.example.wiset.controller.mypage;

import com.example.wiset.service.MyPageDashboardService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/** 마이페이지 대시보드 - 조회 전용 API */
@RestController
@RequestMapping("/api/mypage")
public class MyPageApiController {

    private final MyPageDashboardService dashboardService;

    public MyPageApiController(MyPageDashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/dashboard")
    public Map<String, Object> dashboard() {
        return dashboardService.getDashboard();
    }

    @GetMapping("/history")
    public java.util.List<Map<String, Object>> history() {
        return dashboardService.getHistory();
    }
}

package com.example.wiset.controller.admin;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 17_관리자 (통합 대시보드) 화면.
 * 실시간 지표 + 답변 통계 + 시스템 통계(품질/성능/배치).
 * (-> sys_ai_report_quality / sys_ai_report_survey / sys_system_metrics / sys_batch_history / sys_queue_metrics)
 */
@Controller
public class AdminDashboardController {

    @GetMapping("/admin-dashboard")
    public String adminDashboard() {
        return "admin-dashboard"; // -> /WEB-INF/views/admin-dashboard.jsp
    }
}

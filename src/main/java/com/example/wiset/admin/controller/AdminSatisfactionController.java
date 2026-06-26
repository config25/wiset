package com.example.wiset.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 18_관리자 (만족도 관리) 화면.
 * 만족도 지표 + 행동 연계 추이 + 불만 요소 + 피드백/행동 로그.
 * (-> sys_ai_report_survey / sys_user_activity_log)
 */
@Controller
public class AdminSatisfactionController {

    @GetMapping("/admin-satisfaction")
    public String adminSatisfaction() {
        return "admin-satisfaction"; // -> /WEB-INF/views/admin-satisfaction.jsp
    }
}

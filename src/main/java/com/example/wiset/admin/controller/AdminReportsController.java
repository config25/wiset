package com.example.wiset.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 20_관리자 (리포트 관리) 화면.
 * 생성된 리포트 검색/필터 + 목록 + 상세 조회.
 * (-> sys_ai_report / sys_competency_diagnosis / sys_ai_report_survey / sys_ai_report_quality)
 */
@Controller
public class AdminReportsController {

    @GetMapping("/admin-reports")
    public String adminReports() {
        return "admin-reports"; // -> /WEB-INF/views/admin-reports.jsp
    }
}

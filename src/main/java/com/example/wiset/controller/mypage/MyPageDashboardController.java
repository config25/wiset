package com.example.wiset.controller.mypage;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 14_마이페이지 (AI 커리어 코칭 · 대시보드) 화면.
 * 회원 프로파일 + KPI + 역량 성장 추이 + 액션 플래너 요약 + 진단 이력. (고정 디자인)
 */
@Controller
public class MyPageDashboardController {

    @GetMapping("/mypage-dashboard")
    public String mypageDashboard() {
        return "mypage-dashboard"; // -> /WEB-INF/views/mypage-dashboard.jsp
    }
}

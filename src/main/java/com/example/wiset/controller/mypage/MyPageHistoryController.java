package com.example.wiset.controller.mypage;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 16_마이페이지 (AI 커리어 코칭 · 코칭 이력) 화면.
 * 진단·코칭 이력 타임라인. (-> sys_diagnosis_session / sys_competency_diagnosis / sys_ai_report)
 */
@Controller
public class MyPageHistoryController {

    @GetMapping("/mypage-history")
    public String mypageHistory() {
        return "mypage-history"; // -> /WEB-INF/views/mypage-history.jsp
    }
}

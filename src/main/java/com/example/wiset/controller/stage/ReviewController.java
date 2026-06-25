package com.example.wiset.controller.stage;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 06_입력 데이터 확인 (AI 경력개발 진단 Step 5) 화면.
 * 1~4단계 입력 내용을 검토하고 AI 분석을 시작하는 확인 화면. (고정 디자인)
 */
@Controller
public class ReviewController {

    @GetMapping("/review")
    public String review() {
        return "review"; // -> /WEB-INF/views/review.jsp
    }
}

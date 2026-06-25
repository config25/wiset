package com.example.wiset.controller.stage;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 05_세부 고민 (AI 경력개발 진단 Step 4) 화면.
 * 키워드별 고민 예시(3카테고리 탭) + 자유 서술. (-> sys_user_concern)
 */
@Controller
public class ConcernController {

    @GetMapping("/concern")
    public String concern() {
        return "concern"; // -> /WEB-INF/views/concern.jsp
    }
}

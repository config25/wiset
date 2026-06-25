package com.example.wiset.controller.stage;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 03_현 상황 입력 (AI 경력개발 진단 Step 2) 화면.
 * 학력·경력·추가정보 입력 폼. (자동 연동된 예시 데이터를 보여주는 디자인 화면)
 */
@Controller
public class CurrentSituationController {

    @GetMapping("/current-situation")
    public String currentSituation() {
        return "current-situation"; // -> /WEB-INF/views/current-situation.jsp
    }
}

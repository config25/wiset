package com.example.wiset.stage.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 02_페르소나 선택 (AI 경력개발 진단 Step 1) 화면.
 * 페르소나 4종은 고정 디자인이라 뷰만 연결한다.
 */
@Controller
public class PersonaController {

    @GetMapping("/persona-select")
    public String personaSelect() {
        return "persona-select"; // -> /WEB-INF/views/persona-select.jsp
    }
}

package com.example.wiset.report.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 08_AI 코칭 리포트 (이직 준비자 · 바이오 R&D) 화면.
 * AI 리포트의 'AI 코칭' 탭 — 5개 섹션(종합진단평/세부고민해석/강점활용/약점보완/당장할일).
 * (-> sys_ai_report + sys_ai_coaching_comment coaching_type_code 1~5)
 */
@Controller
public class AiCoachingController {

    @GetMapping("/ai-coaching")
    public String aiCoaching() {
        return "ai-coaching"; // -> /WEB-INF/views/ai-coaching.jsp
    }
}

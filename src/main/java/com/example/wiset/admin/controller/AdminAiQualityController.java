package com.example.wiset.admin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 19_관리자 (AI 품질 관리) 화면.
 * 답변 품질 지표 + 알고리즘 가중치 조정/이력 + 프롬프트 관리.
 * (-> sys_ai_report_quality / sys_current_weights / sys_weights_history / sys_prompt_template)
 */
@Controller
public class AdminAiQualityController {

    @GetMapping("/admin-ai-quality")
    public String adminAiQuality() {
        return "admin-ai-quality"; // -> /WEB-INF/views/admin-ai-quality.jsp
    }
}

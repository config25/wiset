package com.example.wiset.controller.mypage;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 15_마이페이지 (AI 커리어 코칭 · 액션 플래너) 화면.
 * 나만의 액션 플래너(단/중/장기 · 진행상태) + 추천 활동(채용/교육멘토링/지원사업 탭).
 * (-> sys_action_planner)
 */
@Controller
public class MyPageActionPlannerController {

    @GetMapping("/mypage-action-planner")
    public String mypageActionPlanner() {
        return "mypage-action-planner"; // -> /WEB-INF/views/mypage-action-planner.jsp
    }
}

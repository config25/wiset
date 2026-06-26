package com.example.wiset.stage.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 04_경력개발 목표 (AI 경력개발 진단 Step 3) 화면.
 * 희망 업종·직무·기업규모·연봉·근무지·시기·근무유형 + 타깃 JD 선택 폼.
 *
 * 조건부 분기: 페르소나 4(승진·보직 희망 = 경력성장 트랙)를 선택한 경우
 * 04b "경력 성장 목표" 화면(career-goal-growth)을 보여준다.
 * 그 외 페르소나는 기본 04 화면(career-goal).
 */
@Controller
public class CareerGoalController {

    @GetMapping("/career-goal")
    public String careerGoal(@RequestParam(required = false) String persona) {
        if ("4".equals(persona)) {
            return "career-goal-growth"; // -> /WEB-INF/views/career-goal-growth.jsp (04b)
        }
        return "career-goal"; // -> /WEB-INF/views/career-goal.jsp (04)
    }
}

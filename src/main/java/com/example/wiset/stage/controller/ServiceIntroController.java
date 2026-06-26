package com.example.wiset.stage.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * 01_서비스 소개 (AI 커리어 코칭) 화면.
 * 고정 디자인 화면이라 별도 데이터 전달 없이 뷰만 연결한다.
 * (DB 연동 동적 데이터가 생기면 그때 Model로 전달)
 */
@Controller
public class ServiceIntroController {

    @GetMapping("/service-intro")
    public String serviceIntro() {
        return "service-intro"; // -> /WEB-INF/views/service-intro.jsp
    }
}

package com.example.wiset.report.controller;

import com.example.wiset.report.service.impl.AiCoachingServiceImpl;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.not;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * GET /api/ai-coaching/report 의 웹 계층(컨트롤러) 검증.
 *
 * <p>무엇을 보장하나 — 이번 이슈의 핵심 결론 "백엔드는 HTML 을 escape 하지 않는다" 를 API 레벨에서 못박는다.
 *   응답 JSON 의 content 에 &lt;h2&gt; 가 그대로(&amp;lt; 아님) 실려 나가야 한다.
 *   (실제 화면의 태그 노출은 프론트 JS 의 esc() 책임이며 백엔드와 무관함을 회귀로 고정)
 *
 * <p>테스트 종류 : 슬라이스 테스트(@WebMvcTest) — 컨트롤러+Jackson 직렬화만 띄우고 DB/서비스는 제외.
 *   서비스는 @MockBean 으로 가짜를 주입하므로 실제 DB(CommonDAO)·외부 AI 없이 돈다.
 * <p>핵심 도구
 * <ul>
 *   <li>MockMvc        : 실제 톰캣 없이 HTTP 요청을 흉내 내 컨트롤러를 호출</li>
 *   <li>@MockBean      : 의존 서비스(AiCoachingServiceImpl)를 가짜로 대체</li>
 *   <li>jsonPath/content: 응답 본문(JSON·문자열)을 꺼내 검증</li>
 * </ul>
 * <p>테스트 패턴 : given(서비스 반환값 스텁) → when(mvc.perform 으로 GET) → then(andExpect 로 응답 검증).
 *
 * <p>실행 방법
 * <pre>
 *   이 클래스만 : ./gradlew test --tests "com.example.wiset.report.controller.AiCoachingApiControllerTest"
 * </pre>
 */
@WebMvcTest(AiCoachingApiController.class)
class AiCoachingApiControllerTest {

    @Autowired
    MockMvc mvc; // 가짜 HTTP 클라이언트 — 컨트롤러를 직접 호출한다

    @MockBean
    AiCoachingServiceImpl service; // 실제 서비스 대신 주입되는 가짜(DB 안 탐)

    @Test
    void content_의_HTML_은_escape_없이_그대로_응답된다() throws Exception {
        // given : 서비스가 HTML 본문을 담은 Map 을 돌려주도록 스텁
        String html = "<h2>1. 전공·직무 기초 이해</h2><p>본문입니다.</p>";
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("content", html);
        body.put("bannerTitle", "환영합니다");
        when(service.getCoachingReport(any())).thenReturn(body);

        // when : GET /api/ai-coaching/report 호출
        // then : 200 OK + content 의 HTML 이 원형 그대로(escape 안 됨)
        mvc.perform(get("/api/ai-coaching/report"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").value(html))            // 원형 그대로
                .andExpect(content().string(containsString("<h2>")))     // 태그 살아있음
                .andExpect(content().string(not(containsString("&lt;"))));// escape 안 됨
    }

    @Test
    void diagnosisId_파라미터가_서비스로_전달된다() throws Exception {
        // given : 빈 응답 스텁
        when(service.getCoachingReport(any()))
                .thenReturn(Collections.singletonMap("content", null));

        // when : 쿼리파라미터 diagnosisId=42 로 호출
        mvc.perform(get("/api/ai-coaching/report").param("diagnosisId", "42"))
                .andExpect(status().isOk());

        // then : 컨트롤러가 파라미터를 Long 42 로 변환해 서비스에 넘겼는지 확인
        verify(service).getCoachingReport(42L);
    }
}

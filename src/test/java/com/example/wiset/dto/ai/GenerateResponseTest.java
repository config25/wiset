package com.example.wiset.dto.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.util.Collections;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * AI 응답 DTO(GenerateResponse) 매핑 검증.
 *
 * <p>무엇을 보장하나
 * <ul>
 *   <li>snake_case(response, elapsed_seconds) → 카멜 필드 매핑</li>
 *   <li>response 안의 HTML 이 역직렬화 과정에서 escape 없이 그대로 보존됨 (이번 이슈의 핵심)</li>
 *   <li>알 수 없는 필드 무시(@JsonIgnoreProperties(ignoreUnknown = true))</li>
 * </ul>
 *
 * <p>테스트 종류 : 순수 단위 테스트 — Spring 컨텍스트·DB·네트워크 없이 ObjectMapper 만 사용(가장 빠름).
 * <p>테스트 패턴 : given(입력 JSON 준비) → when(역직렬화) → then(필드 검증).
 *
 * <p>실행 방법
 * <pre>
 *   전체 테스트     : ./gradlew test
 *   이 클래스만     : ./gradlew test --tests "com.example.wiset.dto.ai.GenerateResponseTest"
 *   메서드 하나만   : ./gradlew test --tests "com.example.wiset.dto.ai.GenerateResponseTest.snakeCase_필드가_카멜_필드로_매핑된다"
 *   리포트(HTML)    : build/reports/tests/test/index.html
 * </pre>
 */
class GenerateResponseTest {

    private final ObjectMapper om = new ObjectMapper();

    @Test
    void snakeCase_필드가_카멜_필드로_매핑된다() throws Exception {
        // given : AI 서버가 내려주는 snake_case JSON
        String json = "{\"response\":\"hello\",\"elapsed_seconds\":1.5}";

        // when : DTO 로 역직렬화
        GenerateResponse r = om.readValue(json, GenerateResponse.class);

        // then : 카멜 필드에 값이 들어왔는지 확인
        assertThat(r.getResponse()).isEqualTo("hello");
        assertThat(r.getElapsedSeconds()).isEqualTo(1.5);
    }

    @Test
    void response_안의_HTML_은_escape_없이_그대로_보존된다() throws Exception {
        // given : 외부 AI 가 보내는 형태(JSON 문자열 안에 담긴 HTML)를 그대로 만든다
        String html = "<h2>1. 전공·직무 기초 이해</h2><p>본문입니다.</p>";
        String json = om.writeValueAsString(Collections.singletonMap("response", html));

        // when : DTO 로 역직렬화
        GenerateResponse r = om.readValue(json, GenerateResponse.class);

        // then : 태그가 살아있고 escape(&lt;) 되지 않아야 한다 → "백엔드는 HTML 을 훼손하지 않는다"의 근거
        assertThat(r.getResponse())
                .isEqualTo(html)         // 원형 유지
                .contains("<h2>")        // 태그 살아있음
                .doesNotContain("&lt;"); // escape 안 됨
    }

    @Test
    void 알수없는_필드는_무시된다() throws Exception {
        // given : 스키마에 없는 필드(unknown_field)가 섞인 응답
        String json = "{\"response\":\"x\",\"elapsed_seconds\":0,\"unknown_field\":\"y\"}";

        // when : 역직렬화 (예외가 나지 않아야 한다)
        GenerateResponse r = om.readValue(json, GenerateResponse.class);

        // then : 아는 필드만 매핑되고 모르는 필드는 조용히 무시
        assertThat(r.getResponse()).isEqualTo("x");
        assertThat(r.getElapsedSeconds()).isEqualTo(0.0);
    }
}

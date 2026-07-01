package com.example.wiset.dto.ai;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * AI 요청 DTO(GenerateRequest) 직렬화 검증.
 *
 * <p>무엇을 보장하나
 * <ul>
 *   <li>팩토리(consulting/competencyEval)별로 해당 엔드포인트 필드만 채워 보냄</li>
 *   <li>@JsonNaming(snake_case) + @JsonInclude(NON_NULL): set 안 한 필드는 JSON 에서 생략 →
 *       엔드포인트별 바디로 정확히 맞춰짐</li>
 * </ul>
 *
 * <p>테스트 종류 : 순수 단위 테스트 — ObjectMapper 로 직렬화한 뒤 JsonNode 로 결과를 들여다본다.
 * <p>테스트 패턴 : given(팩토리로 요청 생성) → when(직렬화) → then(JSON 필드 유무·값 검증).
 *
 * <p>실행 방법
 * <pre>
 *   이 클래스만 : ./gradlew test --tests "com.example.wiset.dto.ai.GenerateRequestTest"
 * </pre>
 */
class GenerateRequestTest {

    private final ObjectMapper om = new ObjectMapper();

    @Test
    void consulting_요청은_컨설팅_필드만_snake_case_로_직렬화된다() throws Exception {
        // given : /api/consulting 용 요청을 팩토리로 생성
        GenerateRequest req = GenerateRequest.consulting("프로필", "비정형", "상담로그");

        // when : JSON 으로 직렬화한 뒤 트리로 파싱
        JsonNode n = om.readTree(om.writeValueAsString(req));

        // then : 컨설팅 필드는 snake_case 로 존재하고, 다른 엔드포인트 전용 필드는 생략
        assertThat(n.get("user_profile").asText()).isEqualTo("프로필");
        assertThat(n.get("unstructured_data").asText()).isEqualTo("비정형");
        assertThat(n.get("consulting_log").asText()).isEqualTo("상담로그");
        assertThat(n.get("max_new_tokens").asInt()).isEqualTo(1536);
        assertThat(n.has("target_role")).isFalse();   // NON_NULL 로 생략
        assertThat(n.has("resume_text")).isFalse();
    }

    @Test
    void competencyEval_요청은_역량평가_필드만_직렬화된다() throws Exception {
        // given : /api/competency-eval 용 요청을 팩토리로 생성
        GenerateRequest req = GenerateRequest.competencyEval("[IT·SW - 백엔드]", "이력서");

        // when : JSON 으로 직렬화한 뒤 트리로 파싱
        JsonNode n = om.readTree(om.writeValueAsString(req));

        // then : 역량평가 필드만 존재하고, 컨설팅 전용 필드는 생략
        assertThat(n.get("target_role").asText()).isEqualTo("[IT·SW - 백엔드]");
        assertThat(n.get("resume_text").asText()).isEqualTo("이력서");
        assertThat(n.get("max_new_tokens").asInt()).isEqualTo(512);
        assertThat(n.has("user_profile")).isFalse();
        assertThat(n.has("consulting_log")).isFalse();
    }
}

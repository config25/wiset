package com.example.wiset.client;

import com.example.wiset.dto.ai.GenerateRequest;
import com.example.wiset.dto.ai.GenerateResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

/**
 * 외부 WISET AI 추론 서버(Qwen Fine-tuned) 클라이언트.
 *   단일 엔드포인트 POST /api/generate — type 으로 컨설팅(type0)/역량평가(type1) 분기.
 *
 * [wbridge 포팅 델타] @Component 런타임 빈이므로 src/main/java 유지(wbridge 도 client/util 류는 java 에 둠,
 *   예: wbridge.common.util). 포팅 시 패키지만 wbridge.* 로 이동. (resources/client 는 wbridge 에 없는 폴더)
 */
@Component
public class WisetAiClient {

    private static final Logger log = LoggerFactory.getLogger(WisetAiClient.class);
    private static final ObjectMapper OM = new ObjectMapper();

    private final RestTemplate rt;
    private final String baseUrl;

    public WisetAiClient(@Qualifier("aiRestTemplate") RestTemplate rt,
                         @Value("${wiset.ai.base-url}") String baseUrl) {
        this.rt = rt;
        // 끝 슬래시 제거(중복 슬래시 방지)
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
    }

    /**
     * 전용 엔드포인트로 POST (path = "/api/consulting" | "/api/competency-eval" | "/api/market-fit").
     */
    public GenerateResponse generate(String path, GenerateRequest req) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        log.info("[AI호출] POST {}{} (maxTokens={})", baseUrl, path, req.getMaxNewTokens());
        // 요청 프롬프트 원문 로깅(실제 전송되는 JSON 바디 — @JsonInclude(NON_NULL)·snake_case 직렬화 그대로). 길면 8000자에서 절단.
        try {
            String reqBody = OM.writeValueAsString(req);
            log.info("\n========================= [AI프롬프트원문 {}] =========================\n{}\n========================================================================",
                    path, reqBody +"//총" + reqBody.length() + "자");
            log.info("unstructured_data 길이: {}자",
                    req.getUnstructuredData() == null ? 0 : req.getUnstructuredData().length());
        } catch (Exception e) {
            log.warn("[AI프롬프트원문 {}] 직렬화 실패 — {}", path, e.toString());
        }
        long t0 = System.currentTimeMillis();
        GenerateResponse resp = rt.exchange(baseUrl + path, HttpMethod.POST,
                new HttpEntity<>(req, headers), GenerateResponse.class).getBody();
        int chars = (resp != null && resp.getResponse() != null) ? resp.getResponse().length() : 0;
        log.info("[AI호출] {} 완료 — {}자, 서버 {}s, 왕복 {}ms", path, chars,
                resp == null ? null : resp.getElapsedSeconds(), System.currentTimeMillis() - t0);
        // 응답 원문 로깅(답변 형식 확인용 — 역량 JSON·근거·시장정합도 구조 파악). 길면 8000자에서 절단.
        if (resp != null && resp.getResponse() != null) {
            String body = resp.getResponse();
            log.info("\n========================= [AI응답원문 {}] =========================\n{}\n========================================================================",
                    path, body.length() > 8000 ? body.substring(0, 8000) + "…(이하 생략, 총 " + body.length() + "자)" : body);
        }
        return resp;
    }
}

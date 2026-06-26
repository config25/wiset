package com.example.wiset.client;

import com.example.wiset.dto.ai.GenerateRequest;
import com.example.wiset.dto.ai.GenerateResponse;
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

    private final RestTemplate rt;
    private final String baseUrl;

    public WisetAiClient(@Qualifier("aiRestTemplate") RestTemplate rt,
                         @Value("${wiset.ai.base-url}") String baseUrl) {
        this.rt = rt;
        // 끝 슬래시 제거(중복 슬래시 방지)
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
    }

    public GenerateResponse generate(GenerateRequest req) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        log.info("[AI호출] type={} → POST {}/api/generate (maxTokens={})", req.getType(), baseUrl, req.getMaxNewTokens());
        long t0 = System.currentTimeMillis();
        GenerateResponse resp = rt.exchange(baseUrl + "/api/generate", HttpMethod.POST,
                new HttpEntity<>(req, headers), GenerateResponse.class).getBody();
        int chars = (resp != null && resp.getResponse() != null) ? resp.getResponse().length() : 0;
        log.info("[AI호출] type={} 완료 — {}자, 서버 {}s, 왕복 {}ms", req.getType(), chars,
                resp == null ? null : resp.getElapsedSeconds(), System.currentTimeMillis() - t0);
        return resp;
    }
}

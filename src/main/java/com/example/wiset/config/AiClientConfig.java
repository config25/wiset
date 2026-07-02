package com.example.wiset.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * 외부 WISET AI 추론 서버 호출용 인프라.
 *   - aiRestTemplate : 타임아웃 적용된 전용 RestTemplate (LLM 생성은 길어 read-timeout 넉넉히)
 *   - aiExecutor     : 리포트 생성 시 API 병렬 호출용 스레드풀
 *
 * [wbridge 호환] Boot 전용(RestTemplateBuilder) 제거 → 순수 Spring(SimpleClientHttpRequestFactory)으로 작성.
 *   @Configuration/@Bean 은 Spring 4.3 에서도 동작하므로 wbridge 컴포넌트스캔 범위에 두면 그대로 사용 가능
 *   (혹은 관례대로 resources/config/spring 의 XML <bean> 으로 옮겨도 됨).
 *   ※ .java 는 반드시 src/main/java 밑에 둔다 — resources 로 옮기면 Gradle 이 컴파일하지 않아 빌드가 깨진다.
 */
@Configuration
public class AiClientConfig {

    @Bean(name = "aiRestTemplate")
    public RestTemplate aiRestTemplate(@Value("${wiset.ai.connect-timeout-ms:5000}") int connectMs,
                                       @Value("${wiset.ai.read-timeout-ms:180000}") int readMs) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(connectMs);
        factory.setReadTimeout(readMs);
        return new RestTemplate(factory);
    }

    /**
     * API 호출용 — 코어 2(동시 2개씩).
     *   외부 AI 추론 서버가 단일 GPU라 동시 요청이 많으면(예: 5개) 서로 굶겨 read-timeout 으로 죽는다.
     *   반면 동시 2개는 원래 검증된 수준(컨설팅+역량평가 병렬)이라 안전하다 → 겹쳐 돌려 총 시간을 줄인다.
     *   (5개 호출이 2개씩 처리됨. read-timeout 600s 여유로 최악의 경우에도 타임아웃 안 남)
     */
    @Bean(name = "aiExecutor", destroyMethod = "shutdown")
    public ExecutorService aiExecutor() {
        return Executors.newFixedThreadPool(2);
    }
}

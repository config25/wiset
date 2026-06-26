package com.example.wiset.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.web.client.RestTemplateBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * 외부 WISET AI 추론 서버 호출용 인프라.
 *   - aiRestTemplate : 타임아웃 적용된 전용 RestTemplate (LLM 생성은 길어 read-timeout 넉넉히)
 *   - aiExecutor     : 리포트 생성 시 API 병렬 호출용 스레드풀
 *
 * [wbridge 포팅 델타] wbridge 는 자바 @Configuration 이 없고 설정은 전부 resources/config/spring 의 XML 빈이다.
 *   포팅 시 이 두 빈(aiRestTemplate/aiExecutor)을 resources/config/spring/context-ai.xml 의 <bean> 으로 옮긴다.
 *   ※ .java 는 반드시 src/main/java 밑에 둔다 — resources 로 옮기면 Gradle 이 컴파일하지 않아 빌드가 깨진다.
 */
@Configuration
public class AiClientConfig {

    @Bean(name = "aiRestTemplate")
    public RestTemplate aiRestTemplate(RestTemplateBuilder builder,
                                       @Value("${wiset.ai.connect-timeout-ms:5000}") long connectMs,
                                       @Value("${wiset.ai.read-timeout-ms:180000}") long readMs) {
        return builder
                .setConnectTimeout(Duration.ofMillis(connectMs))
                .setReadTimeout(Duration.ofMillis(readMs))
                .build();
    }

    /** 4종 API 동시 호출용. allOf 로 모이므로 코어 4면 충분. */
    @Bean(name = "aiExecutor", destroyMethod = "shutdown")
    public ExecutorService aiExecutor() {
        return Executors.newFixedThreadPool(4);
    }
}

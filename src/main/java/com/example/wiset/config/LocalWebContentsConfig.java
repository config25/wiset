package com.example.wiset.config;

import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.File;

/**
 * [로컬 전용 — wbridge 미복사]
 * JSP 웹루트를 wbridge 관례 이름인 {@code src/main/WebContents} 로 지정한다.
 *
 *   - Spring Boot 의 기본 JSP docBase 는 {@code src/main/webapp} 이라, 웹루트를 WebContents 로
 *     옮긴 뒤에는 bootRun 이 JSP 를 못 찾아 전 화면 404 가 된다. 이 커스터마이저로 docBase 를 보정.
 *   - 통합 시: wbridge(eGov/WAR)는 WebContents 가 정식 웹루트라 이 보정이 불필요 → 이 클래스는 복사하지 않는다.
 */
@Configuration
public class LocalWebContentsConfig {

    @Bean
    public WebServerFactoryCustomizer<TomcatServletWebServerFactory> webContentsDocRoot() {
        return factory -> {
            File docRoot = new File("src/main/WebContents").getAbsoluteFile();
            if (docRoot.isDirectory()) {
                factory.setDocumentRoot(docRoot);
            }
        };
    }
}

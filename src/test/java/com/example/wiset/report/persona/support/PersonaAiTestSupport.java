package com.example.wiset.report.persona.support;

import org.junit.jupiter.api.Assumptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.InputStream;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URI;
import java.util.Properties;

/**
 * 페르소나 통합 테스트 공용 지원 — AI 서버 연결 가능 여부 체크.
 *
 * <p>풀 파이프라인 테스트({@link AbstractPersonaReportIT})는 실제 AI 서버로 호출하므로,
 *   서버가 꺼져 있으면 {@link Assumptions#assumeTrue} 로 <b>실패가 아니라 SKIP</b> 처리한다.
 *   base-url 은 운영과 동일하게 main 의 application.properties 에서 읽는다.
 */
public final class PersonaAiTestSupport {

    private static final Logger log = LoggerFactory.getLogger("PERSONA-AI");

    /** application.properties 의 wiset.ai.base-url (없으면 기본값). */
    public static final String BASE_URL = loadProp("wiset.ai.base-url", "http://192.168.0.184:8000");

    private PersonaAiTestSupport() {}

    /** AI 서버 TCP 연결 가능 여부 확인 — 불가하면 테스트 SKIP(실패 아님). */
    public static void assumeAiReachable() {
        boolean reachable = false;
        try {
            URI uri = URI.create(BASE_URL);
            int port = uri.getPort() > 0 ? uri.getPort() : 80;
            try (Socket s = new Socket()) {
                s.connect(new InetSocketAddress(uri.getHost(), port), 1500);
                reachable = true;
            }
        } catch (Exception ignore) { /* 연결 실패 → reachable=false */ }
        if (!reachable) {
            log.warn("[페르소나IT] AI 서버({}) 연결 불가 — 테스트 SKIP", BASE_URL);
        }
        Assumptions.assumeTrue(reachable, "AI 서버(" + BASE_URL + ") 연결 불가 — 테스트 SKIP");
    }

    private static String loadProp(String key, String def) {
        try (InputStream in = PersonaAiTestSupport.class.getResourceAsStream("/application.properties")) {
            if (in == null) return def;
            Properties p = new Properties();
            p.load(in);
            String v = p.getProperty(key);
            return (v == null || v.trim().isEmpty()) ? def : v.trim();
        } catch (Exception e) {
            return def;
        }
    }
}

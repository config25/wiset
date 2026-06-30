package com.example.wiset.report.persona.support;

import com.example.wiset.client.WisetAiClient;
import com.example.wiset.dto.ai.GenerateRequest;
import com.example.wiset.dto.ai.GenerateResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Assumptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

import java.io.InputStream;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.URI;
import java.util.Properties;

/**
 * 페르소나 시나리오 "라이브 AI 호출" 테스트용 공용 지원.
 *
 * <p>목적 : IDE에서 ▶(세모)를 누르면 실제 AI 서버로 요청을 보내고 답변 원문을 콘솔 로그로 확인.
 *   (단위 테스트가 아니라 수동 탐색·검증용 — 목 없이 진짜 HTTP 를 친다.)
 *
 * <p>핵심 설계
 * <ul>
 *   <li>base-url·타임아웃은 운영과 동일하게 main 의 application.properties 에서 읽는다(하드코딩 표류 방지).</li>
 *   <li>요청 전송·프롬프트원문·응답원문 로깅은 운영 코드 {@link WisetAiClient} 를 그대로 재사용한다.</li>
 *   <li>AI 서버에 연결 안 되면 {@link Assumptions#assumeTrue}로 <b>실패가 아니라 SKIP</b> 처리 →
 *       서버가 꺼져 있어도 {@code ./gradlew test} 가 깨지지 않는다.</li>
 *
 *
 *       //필수랑 선택 나눠서 플로우 따라가며 여러가지 경우의 수 대조해보기
 * </ul>
 */
public final class PersonaAiTestSupport {

    private static final Logger log = LoggerFactory.getLogger("PERSONA-AI");
    private static final ObjectMapper JSON = new ObjectMapper();

    /** application.properties 의 wiset.ai.base-url (없으면 기본값). */
    public static final String BASE_URL = loadProp("wiset.ai.base-url", "http://192.168.0.184:8000");
    private static final int CONNECT_MS = intProp("wiset.ai.connect-timeout-ms", 5000);
    private static final int READ_MS    = intProp("wiset.ai.read-timeout-ms", 180000);

    private PersonaAiTestSupport() {}

    /** 운영과 동일한 타임아웃의 RestTemplate 으로 WisetAiClient 생성. */
    public static WisetAiClient client() {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(CONNECT_MS);
        factory.setReadTimeout(READ_MS);
        return new WisetAiClient(new RestTemplate(factory), BASE_URL);
    }

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
        Assumptions.assumeTrue(reachable, "AI 서버(" + BASE_URL + ") 연결 불가 — 테스트 SKIP");
    }

    /**
     * 페르소나 시나리오 1건을 실제 AI 서버로 보내고, 요청 필드·응답을 빠짐없이 로그로 덤프한다.
     *   ① 시나리오 헤더(페르소나·엔드포인트·서버) → ② 전송 요청 필드 전체(필드별 길이+원문)
     *   → ③ WisetAiClient 내부 로깅(프롬프트원문/응답원문) → ④ 응답 메타(소요·길이) → ⑤ 답변 원문(JSON 이면 정렬).
     *
     * @param persona 시나리오 식별 라벨(예: "A · 신규취업")
     * @return AI 응답(이후 단언에 사용)
     */
    public static GenerateResponse run(WisetAiClient client, String persona, String path, GenerateRequest req) {
        log.info("\n"
                + "================================================================================\n"
                + "  [페르소나 시나리오] {}\n"
                + "  엔드포인트 : {}\n"
                + "  AI 서버    : {}\n"
                + "================================================================================",
                persona, path, BASE_URL);

        logRequestFields(req);

        long t0 = System.currentTimeMillis();
        GenerateResponse resp = client.generate(path, req); // 내부에서 프롬프트원문/응답원문도 로깅
        long ms = System.currentTimeMillis() - t0;

        String body = (resp == null) ? null : resp.getResponse();
        log.info("\n"
                + "------------------------------ [AI 응답 메타] ----------------------------------\n"
                + "  페르소나   : {}\n"
                + "  엔드포인트 : {}\n"
                + "  서버 처리  : {} 초\n"
                + "  왕복(체감) : {} ms\n"
                + "  답변 길이  : {} 자\n"
                + "--------------------------------------------------------------------------------",
                persona, path, (resp == null ? null : resp.getElapsedSeconds()), ms,
                (body == null ? 0 : body.length()));

        log.info("\n"
                + "##################### [AI 답변 원문 — {} {}] #####################\n{}\n"
                + "################################################################################",
                persona, path, prettyMaybe(body));
        return resp;
    }

    /** 전송될 GenerateRequest 의 채워진 필드를 전부(라벨+길이+원문) 찍는다. */
    private static void logRequestFields(GenerateRequest r) {
        StringBuilder sb = new StringBuilder("\n--------------------------- [전송 요청 필드] -----------------------------------");
        appendField(sb, "system_prompt", r.getSystemPrompt());
        appendField(sb, "user_prompt", r.getUserPrompt());
        appendField(sb, "target_role", r.getTargetRole());
        appendField(sb, "resume_text", r.getResumeText());
        appendField(sb, "user_profile", r.getUserProfile());
        appendField(sb, "unstructured_data", r.getUnstructuredData());
        appendField(sb, "consulting_log", r.getConsultingLog());
        appendField(sb, "job_posting_text", r.getJobPostingText());
        appendField(sb, "experience_level", r.getExperienceLevel());
        sb.append("\n\n  · 생성 파라미터: max_new_tokens=").append(r.getMaxNewTokens())
                .append(", temperature=").append(r.getTemperature())
                .append(", top_p=").append(r.getTopP());
        sb.append("\n--------------------------------------------------------------------------------");
        log.info(sb.toString());
    }

    private static void appendField(StringBuilder sb, String name, String v) {
        if (v == null) return; // NON_NULL 직렬화처럼, 안 보낸 필드는 생략
        sb.append("\n\n[").append(name).append("] (").append(v.length()).append("자)\n").append(v);
    }

    /** 응답이 JSON(역량평가 등)이면 들여쓰기 정렬해서 가독성을 높이고, 아니면 원문 그대로. */
    private static String prettyMaybe(String body) {
        if (body == null) return "(응답 null)";
        String t = body.trim();
        if (t.startsWith("{") || t.startsWith("[")) {
            try {
                Object tree = JSON.readValue(t, Object.class);
                return JSON.writerWithDefaultPrettyPrinter().writeValueAsString(tree);
            } catch (Exception ignore) { /* JSON 아님 → 원문 */ }
        }
        return body;
    }

    // ----------------------------------------------------- properties 로더
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

    private static int intProp(String key, int def) {
        try {
            return Integer.parseInt(loadProp(key, String.valueOf(def)));
        } catch (Exception e) {
            return def;
        }
    }
}

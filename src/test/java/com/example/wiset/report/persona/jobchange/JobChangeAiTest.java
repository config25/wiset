package com.example.wiset.report.persona.jobchange;

import com.example.wiset.client.WisetAiClient;
import com.example.wiset.dto.ai.GenerateRequest;
import com.example.wiset.dto.ai.GenerateResponse;
import com.example.wiset.report.persona.support.PersonaAiTestSupport;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * [시나리오 B] 이직 준비 (이공계 재직 여성의 경력 점프업, persona_code=2, 경력).
 * 정의서: dodo/qa/personas/persona2_이직준비.md
 *
 * <p>▶(세모)를 누르면 실제 AI 서버로 호출 → 콘솔에 AI 답변 원문이 찍힌다. 연결 불가 시 SKIP.
 */
class JobChangeAiTest {

    private final WisetAiClient ai = PersonaAiTestSupport.client();

    @BeforeEach
    void requireServer() { PersonaAiTestSupport.assumeAiReachable(); }

    private static final String TARGET_ROLE =
            "[AI 및 융합 기술, 딥테크 - AI 모델 개발 연구원, MLOps 엔지니어]";

    private static final String RESUME =
            "[학력]\n- 석사 · 컴퓨터공학과\n\n"
            + "[경력]\n- 퀀텀에듀솔루션 · 솔루션개발팀 · 주니어 연구원 (3년 6개월)\n\n"
            + "[논문·연구]\n- 시계열 데이터를 활용한 이상탐지 알고리즘 연구\n\n"
            + "[자격증]\n- 정보처리기사\n- AWS Certified Solutions Architect";

    private static final String CONCERN =
            "현재 직장에서는 유지보수 및 기존 솔루션 고도화 위주의 업무를 하고 있습니다. 최신 AI 기술과 데이터 파이프라인 "
            + "구축 쪽으로 커리어를 확장해 이직하고 싶은데, 실무에서 AI를 전담했던 경험이 부족합니다. 제가 가진 기존 유지보수 "
            + "경험을 AI 딥테크 시장에서 요구하는 '클라우드 인프라 및 모델 서빙 역량'으로 어떻게 재번역하고 포트폴리오를 "
            + "재구성해야 할지 막막합니다.";

    private static final String USER_PROFILE =
            "페르소나: 이직 준비. 경력. AI 및 융합 기술, 딥테크 산업 희망. "
            + "AI 모델 개발 연구원, MLOps 엔지니어 직무 희망. 희망 근무지: 경기 성남시 (판교), 서울 강남구. "
            + "희망 고용형태: 정규직. 세부 고민: " + CONCERN;

    private static final String UNSTRUCTURED = RESUME; // 자소서·포트폴리오 없음

    private static final String CONSULTING_LOG = "[세부 고민] " + CONCERN;

    @Test
    void 컨설팅_코칭_답변_받기() {
        GenerateResponse resp = PersonaAiTestSupport.run(ai, "B · 이직 준비", "/api/consulting",
                GenerateRequest.consulting(USER_PROFILE, UNSTRUCTURED, CONSULTING_LOG));
        assertThat(resp).isNotNull();
        assertThat(resp.getResponse()).isNotBlank();
    }

    @Test
    void 역량평가_JSON_답변_받기() {
        GenerateResponse resp = PersonaAiTestSupport.run(ai, "B · 이직 준비", "/api/competency-eval",
                GenerateRequest.competencyEval(TARGET_ROLE, RESUME));
        assertThat(resp).isNotNull();
        assertThat(resp.getResponse()).isNotBlank();
    }
}

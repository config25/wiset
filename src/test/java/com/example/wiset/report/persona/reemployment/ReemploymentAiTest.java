package com.example.wiset.report.persona.reemployment;

import com.example.wiset.client.WisetAiClient;
import com.example.wiset.dto.ai.GenerateRequest;
import com.example.wiset.dto.ai.GenerateResponse;
import com.example.wiset.report.persona.support.PersonaAiTestSupport;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * [시나리오 C] 재취업 (R&D 경력단절 여성 복귀, persona_code=3, 경력 + 3년 공백기).
 * 정의서: dodo/qa/personas/persona3_재취업.md
 *
 * <p>▶(세모)를 누르면 실제 AI 서버로 호출 → 콘솔에 AI 답변 원문이 찍힌다. 연결 불가 시 SKIP.
 */
class ReemploymentAiTest {

    private final WisetAiClient ai = PersonaAiTestSupport.client();

    @BeforeEach
    void requireServer() { PersonaAiTestSupport.assumeAiReachable(); }

    private static final String TARGET_ROLE =
            "[제약·바이오, 생명 및 자연과학 연구업 - 연구개발직 (바이오/화학 R&D) 또는 연구지원직(Staff Scientist)]";

    private static final String RESUME =
            "[학력]\n- 석사 · 생명공학과 (화학·바이오)\n\n"
            + "[경력]\n- A제약사 · 신약연구센터 · 선임연구원 (2018.03~2023.05) · 총 5년 3개월, 이후 3년 공백\n\n"
            + "[논문·연구]\n- 특허 출원 1건\n- SCI급 논문 2편\n\n"
            + "[교육이수]\n- WISET 여성과학기술인 경력복귀 R&D 트렌드 교육 · WISET";

    private static final String CONCERN =
            "출산과 육아로 인해 3년간 현업을 떠나있어 최신 연구 장비 활용에 대한 감각이 떨어졌을까 봐 두렵습니다. "
            + "AI 신약 개발과 다중특이 의약품 등 패러다임이 급변하는 상황에서, 면접 시 3년의 공백기를 '단절'이 아닌 "
            + "'지식 융합 및 준비기'로 어떻게 효과적으로 방어하고 이전 5년의 규제/문서 작성 역량을 어필할 수 있을지 막막합니다.";

    private static final String USER_PROFILE =
            "페르소나: 재취업. 경력. 제약·바이오, 생명 및 자연과학 연구업 산업 희망. "
            + "연구개발직 (바이오/화학 R&D) 또는 연구지원직(Staff Scientist) 직무 희망. 희망 근무지: 서울 전체, 경기 수원시. "
            + "희망 고용형태: 정규직, 시간선택제. 세부 고민: " + CONCERN;

    private static final String UNSTRUCTURED = RESUME; // 자소서·포트폴리오 없음

    private static final String CONSULTING_LOG = "[세부 고민] " + CONCERN;

    @Test
    void 컨설팅_코칭_답변_받기() {
        GenerateResponse resp = PersonaAiTestSupport.run(ai, "C · 재취업", "/api/consulting",
                GenerateRequest.consulting(USER_PROFILE, UNSTRUCTURED, CONSULTING_LOG));
        assertThat(resp).isNotNull();
        assertThat(resp.getResponse()).isNotBlank();
    }

    @Test
    void 역량평가_JSON_답변_받기() {
        GenerateResponse resp = PersonaAiTestSupport.run(ai, "C · 재취업", "/api/competency-eval",
                GenerateRequest.competencyEval(TARGET_ROLE, RESUME));
        assertThat(resp).isNotNull();
        assertThat(resp.getResponse()).isNotBlank();
    }
}

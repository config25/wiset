package com.example.wiset.report.persona.promotion;

import com.example.wiset.client.WisetAiClient;
import com.example.wiset.dto.ai.GenerateRequest;
import com.example.wiset.dto.ai.GenerateResponse;
import com.example.wiset.report.persona.support.PersonaAiTestSupport;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * [시나리오 D] 승진/보직 희망 (이공계 여성 리더십 강화, persona_code=4, 경력).
 * 정의서: dodo/qa/personas/persona4_승진보직.md
 *
 * <p>양식 차이: 희망 업종/직무 대신 '경력성장 목표(growth)'를 입력 → target_role 은 목표 보직으로 대체.
 * <p>▶(세모)를 누르면 실제 AI 서버로 호출 → 콘솔에 AI 답변 원문이 찍힌다. 연결 불가 시 SKIP.
 */
class PromotionAiTest {

    private final WisetAiClient ai = PersonaAiTestSupport.client();

    @BeforeEach
    void requireServer() { PersonaAiTestSupport.assumeAiReachable(); }

    // 희망 업종/직무가 없어 목표 보직이 target_role 로 대체된다(persona4 fallback).
    private static final String TARGET_ROLE = "데이터랩 연구소장 / 랩장 (PL)";

    private static final String RESUME =
            "[학력]\n- 박사 · 산업공학과 (AI 최적화 전공)\n\n"
            + "[경력]\n- B테크기업 · 데이터랩 · 책임연구원 (총 8년)\n\n"
            + "[인턴·대외활동]\n- 사내 기술 세미나 리드\n- 주니어 연구원 멘토 활동";

    private static final String CONCERN =
            "지금까지는 실무 역량과 연구 성과(논문, 특허)로 인정받았으나, 이번에 랩장 승진 대상자가 되었습니다. "
            + "기술 전문가가 리더로 넘어갈 때 겪는 '역량의 덫(Competence Trap)'에 빠지지 않고, 남성 팀원이 다수인 조직에서 "
            + "부드럽지만 결단력 있는 리더십을 구축하고 싶습니다. 당장 앞둔 리더십 다면평가에서 나의 조직 관리 역량을 "
            + "어떻게 정량적 성과로 증명해야 할지 전략이 필요합니다.";

    // persona4 는 경력성장 목표(목표보직·현재담당·목표처우·평가요소·강화역량)가 프로필에 펼쳐진다.
    private static final String USER_PROFILE =
            "페르소나: 승진·보직 희망. 경력. "
            + "경력성장 목표(목표 보직: 데이터랩 연구소장 / 랩장 (PL); 연차: 8년; "
            + "현재 담당업무: AI 모델 고도화 리딩, 연구 과제 일정·예산 관리, 타 부서 기술 지원·커뮤니케이션; "
            + "목표 처우: 8,000~9,000만원; 평가요소: 리더십 다면평가, 프로젝트 성공률 및 팀 기여도; "
            + "강화역량: 다면평가 방어, 조직·인력 관리, 전략·기획, 갈등관리 및 의사소통). "
            + "세부 고민: " + CONCERN;

    private static final String UNSTRUCTURED = RESUME; // 자소서·포트폴리오 없음

    private static final String CONSULTING_LOG =
            "[컨설팅 결과] WISET 여성 리더십 및 중간관리자 멘토링 이수\n\n[세부 고민] " + CONCERN;

    @Test
    void 컨설팅_코칭_답변_받기() {
        GenerateResponse resp = PersonaAiTestSupport.run(ai, "D · 승진/보직", "/api/consulting",
                GenerateRequest.consulting(USER_PROFILE, UNSTRUCTURED, CONSULTING_LOG));
        assertThat(resp).isNotNull();
        assertThat(resp.getResponse()).isNotBlank();
    }

    @Test
    void 역량평가_JSON_답변_받기() {
        GenerateResponse resp = PersonaAiTestSupport.run(ai, "D · 승진/보직", "/api/competency-eval",
                GenerateRequest.competencyEval(TARGET_ROLE, RESUME));
        assertThat(resp).isNotNull();
        assertThat(resp.getResponse()).isNotBlank();
    }
}

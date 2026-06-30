package com.example.wiset.report.persona.newhire;

import com.example.wiset.client.WisetAiClient;
import com.example.wiset.dto.ai.GenerateRequest;
import com.example.wiset.dto.ai.GenerateResponse;
import com.example.wiset.report.persona.support.PersonaAiTestSupport;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * [시나리오 A] 신규취업 (이공계 신진 여성인재, persona_code=1, 신입).
 * 정의서: dodo/qa/personas/persona1_신규취업.md
 *
 * <p>프롬프트는 운영 수준으로 풍족하게 — 이력 전 섹션(날짜 포함) + 자기소개서 본문 + 1:1 컨설팅 다건.
 *   필수(*)/선택 입력을 블록으로 나눠 어느 조각이 프롬프트의 어디로 가는지 따라가기 쉽게 구성.
 *
 * <p>▶(세모)를 누르면 실제 AI 서버로 호출 → 콘솔에 요청 필드·AI 답변 원문이 찍힌다. 연결 불가 시 SKIP.
 */
class NewHireAiTest {

    private final WisetAiClient ai = PersonaAiTestSupport.client();

    @BeforeEach
    void requireServer() { PersonaAiTestSupport.assumeAiReachable(); }

    // ───────────────────────────── 필수(*) 입력 ─────────────────────────────
    // STEP1 페르소나=신규취업, STEP2 학력*, STEP3 희망 업종*/직무*
    private static final String TARGET_ROLE =
            "[IT·소프트웨어·데이터 서비스 (AI 딥테크) - 데이터 엔지니어, 백엔드 개발자]";

    // ───────────────────────────── 이력서 (필수 학력 + 선택 섹션들) ─────────────────────────────
    private static final String RESUME =
            "[학력]\n"
            + "- 학사 · ICT융합학부 (데이터사이언스 전공) (2027.02 졸업예정) · 학점 3.92/4.50\n\n"
            + "[경력]\n"
            + "- IT 스타트업 · 데이터분석팀 · 인턴 (2025.12~2026.06): 사용자 로그 ETL 파이프라인 구축, "
            + "Python·SQL 기반 대시보드 지표 자동화\n\n"
            + "[자격증]\n"
            + "- SQLD · 한국데이터산업진흥원 (2026.03)\n"
            + "- ADsP · 한국데이터산업진흥원 (2025.09)\n\n"
            + "[어학]\n"
            + "- 영어 · 비즈니스 · TOEIC 905\n\n"
            + "[인턴·대외활동]\n"
            + "- 인턴 · IT 스타트업 데이터분석팀 (2025.12~2026.06): 추천 로직 A/B 테스트 데이터 분석\n"
            + "- 동아리 · 교내 데이터분석학회 (2024.03~2025.12): 캐글 경진대회 팀 리드\n\n"
            + "[교육이수]\n"
            + "- 취업탐색 멘토링 · WISET\n"
            + "- AI 데이터 분석 전문인력 양성과정(수강 중) · WISET\n\n"
            + "[수상]\n"
            + "- 글로벌 여성 해커톤 우수상 (2026)";

    // ───────────────────────────── 선택 입력 — 자기소개서 본문 ─────────────────────────────
    private static final String COVER_LETTER =
            "[자기소개서] 제목: 사용자 중심의 확장성 있는 시스템을 지향하는 백엔드 개발자입니다.\n"
            + "대학에서 미디어테크놀로지와 ICT 융합을 전공하며 대용량 데이터 처리와 안정적인 서버 아키텍처 설계에 깊은 관심을 "
            + "가지게 되었습니다.\n\n"
            + "교내 프로젝트 및 산학 협력을 통해 Java 17과 Spring Boot 기반의 웹 애플리케이션 개발을 주도한 경험이 있습니다. "
            + "특히 복잡한 비즈니스 로직을 효율적인 데이터베이스 ERD 설계와 SQL 튜닝을 통해 개선하며, 시스템 쿼리 성능을 "
            + "최적화한 경험이 강점입니다. Docker를 활용한 컨테이너 기반 배포 환경 구축에도 익숙합니다.\n\n"
            + "단순히 동작하는 코드를 넘어, 동료들이 이해하기 쉬운 깔끔한 코드를 작성하고 변화하는 요구사항에 유연하게 대응할 수 "
            + "있는 확장성 있는 시스템을 만드는 것이 개발자로서의 목표입니다. 입사 후에도 지속해서 기술을 연마하여 팀과 서비스의 "
            + "성장에 기여하겠습니다.";

    // ───────────────────────────── 선택 입력 — 포트폴리오 ─────────────────────────────
    private static final String PORTFOLIO =
            "[포트폴리오]\n- parkdohyun.com\n- Github (대용량 로그 처리 토이프로젝트)";

    // ───────────────────────────── 선택 입력 — 세부 고민(STEP4) ─────────────────────────────
    private static final String CONCERN =
            "WISET 멘토링과 인턴십을 통해 데이터 분석 실무를 경험했습니다. 다만, 여성 엔지니어가 상대적으로 적은 "
            + "백엔드/인프라 직무로 전문성을 파고들지, 비교적 융합적인 서비스 기획/기술 PM으로 진로를 잡아야 할지 롤모델이 부족합니다. "
            + "섣불리 기획 직무로 진입했다가 기술적 전문성을 잃고 조직 내에서 '윤활유 업무(Glue work)'에만 매몰될까 봐 두렵습니다. "
            + "커리어 첫 단추를 어떻게 꿰어야 할지 고민입니다.";

    // ───────────────────────────── 선택 입력 — 1:1 커리어컨설팅 이력 ─────────────────────────────
    private static final String CONSULTING_HISTORY =
            "[1:1 커리어컨설팅 이력 2건]\n\n"
            + "1. (2026-05-10)\n"
            + "  Q: 데이터 분석 인턴 경험을 백엔드 개발자 지원에 어떻게 연결할 수 있을까요? 포트폴리오 구성이 고민입니다.\n"
            + "  A: 데이터 파이프라인 구축 경험은 백엔드 직무에서 큰 강점입니다. ETL 과정에서 다룬 대용량 처리·쿼리 최적화 "
            + "사례를 API 설계 관점으로 재구성해 보세요. Github README에 아키텍처 다이어그램과 성능 개선 수치(예: 쿼리 응답 40% 단축)를 "
            + "명시하면 설득력이 높아집니다.\n\n"
            + "2. (2026-05-24)\n"
            + "  Q: 데이터 엔지니어와 백엔드 개발자 중 신입으로 어디를 노리는 게 유리할까요? 기획/PM 전향도 고민됩니다.\n"
            + "  A: 두 직무는 데이터 처리·인프라에서 겹치는 영역이 많습니다. 신입 단계에서는 SQL·클라우드·컨테이너를 공통 기반으로 "
            + "쌓고 공고의 요구 스택에 맞춰 포트폴리오를 변주해 동시 지원하세요. 기획/PM은 기술 기반을 1~2년 다진 뒤 전환해도 늦지 "
            + "않으며, 오히려 기술 이해도가 강력한 차별점이 됩니다.";

    // ───────────────────────────── 조립된 AI 요청 필드 ─────────────────────────────
    private static final String USER_PROFILE =
            "페르소나: 신규 취업. 신입. IT·소프트웨어·데이터 서비스 (AI 딥테크) 산업 희망. "
            + "데이터 엔지니어, 백엔드 개발자 직무 희망. 희망 근무지: 서울 전체, 경기 성남시 (판교). "
            + "희망 고용형태: 정규직. 세부 고민: " + CONCERN;

    private static final String UNSTRUCTURED =
            RESUME + "\n\n" + COVER_LETTER + "\n\n" + PORTFOLIO;

    private static final String CONSULTING_LOG =
            CONSULTING_HISTORY + "\n\n[세부 고민] " + CONCERN;

    @Test
    void 컨설팅_코칭_답변_받기() {
        GenerateResponse resp = PersonaAiTestSupport.run(ai, "A · 신규취업", "/api/consulting",
                GenerateRequest.consulting(USER_PROFILE, UNSTRUCTURED, CONSULTING_LOG));
        assertThat(resp).isNotNull();
        assertThat(resp.getResponse()).isNotBlank();
    }

    @Test
    void 역량평가_JSON_답변_받기() {
        GenerateResponse resp = PersonaAiTestSupport.run(ai, "A · 신규취업", "/api/competency-eval",
                GenerateRequest.competencyEval(TARGET_ROLE, RESUME));
        assertThat(resp).isNotNull();
        assertThat(resp.getResponse()).isNotBlank();
    }
}

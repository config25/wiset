package com.example.wiset.report.persona.support;

import com.example.wiset.dto.ai.GenerationInputs;

/**
 * 4개 페르소나의 AI 입력(GenerationInputs) 단일 소스.
 *   - 라이트 테스트(AI 답변만 보기)와 풀파이프라인 IT(AI 호출+DB 적재)가 같은 데이터를 공유한다.
 *   - 각 메서드는 운영 어셈블러가 만들 법한 형태(이력 섹션·자소서·포트폴리오·컨설팅 이력·고민)를 그대로 담는다.
 */
public final class PersonaFixtures {

    private PersonaFixtures() {}

    // ===================================================== A. 신규취업 (신입)
    public static GenerationInputs newHire() {
        String resume =
                "[학력]\n- 학사 · ICT융합학부 (데이터사이언스 전공) (2027.02 졸업예정) · 학점 3.92/4.50\n\n"
                + "[경력]\n- IT 스타트업 · 데이터분석팀 · 인턴 (2025.12~2026.06): 사용자 로그 ETL 파이프라인 구축, "
                + "Python·SQL 기반 대시보드 지표 자동화\n\n"
                + "[자격증]\n- SQLD · 한국데이터산업진흥원 (2026.03)\n- ADsP · 한국데이터산업진흥원 (2025.09)\n\n"
                + "[어학]\n- 영어 · 비즈니스 · TOEIC 905\n\n"
                + "[인턴·대외활동]\n- 인턴 · IT 스타트업 데이터분석팀 (2025.12~2026.06): 추천 로직 A/B 테스트 데이터 분석\n"
                + "- 동아리 · 교내 데이터분석학회 (2024.03~2025.12): 캐글 경진대회 팀 리드\n\n"
                + "[교육이수]\n- 취업탐색 멘토링 · WISET\n- AI 데이터 분석 전문인력 양성과정(수강 중) · WISET\n\n"
                + "[수상]\n- 글로벌 여성 해커톤 우수상 (2026)";
        String cover =
                "[자기소개서] 제목: 사용자 중심의 확장성 있는 시스템을 지향하는 백엔드 개발자입니다.\n"
                + "대학에서 미디어테크놀로지와 ICT 융합을 전공하며 대용량 데이터 처리와 안정적인 서버 아키텍처 설계에 깊은 관심을 "
                + "가지게 되었습니다.\n\n교내 프로젝트 및 산학 협력을 통해 Java 17과 Spring Boot 기반의 웹 애플리케이션 개발을 "
                + "주도한 경험이 있습니다. 특히 복잡한 비즈니스 로직을 효율적인 데이터베이스 ERD 설계와 SQL 튜닝을 통해 개선하며, "
                + "시스템 쿼리 성능을 최적화한 경험이 강점입니다. Docker를 활용한 컨테이너 기반 배포 환경 구축에도 익숙합니다.\n\n"
                + "단순히 동작하는 코드를 넘어, 동료들이 이해하기 쉬운 깔끔한 코드를 작성하고 변화하는 요구사항에 유연하게 대응할 수 "
                + "있는 확장성 있는 시스템을 만드는 것이 개발자로서의 목표입니다.";
        String portfolio = "[포트폴리오]\n- parkdohyun.com\n- Github (대용량 로그 처리 토이프로젝트)";
        String concern =
                "WISET 멘토링과 인턴십을 통해 데이터 분석 실무를 경험했습니다. 다만, 여성 엔지니어가 상대적으로 적은 "
                + "백엔드/인프라 직무로 전문성을 파고들지, 비교적 융합적인 서비스 기획/기술 PM으로 진로를 잡아야 할지 롤모델이 부족합니다. "
                + "섣불리 기획 직무로 진입했다가 기술적 전문성을 잃고 조직 내에서 '윤활유 업무(Glue work)'에만 매몰될까 봐 두렵습니다. "
                + "커리어 첫 단추를 어떻게 꿰어야 할지 고민입니다.";
        String history =
                "[1:1 커리어컨설팅 이력 2건]\n\n"
                + "1. (2026-05-10)\n  Q: 데이터 분석 인턴 경험을 백엔드 개발자 지원에 어떻게 연결할 수 있을까요?\n"
                + "  A: ETL 과정에서 다룬 대용량 처리·쿼리 최적화 사례를 API 설계 관점으로 재구성하고, Github README에 "
                + "아키텍처 다이어그램과 성능 개선 수치를 명시하세요.\n\n"
                + "2. (2026-05-24)\n  Q: 데이터 엔지니어와 백엔드 중 신입으로 어디를 노리는 게 유리할까요?\n"
                + "  A: 신입 단계에선 SQL·클라우드·컨테이너를 공통 기반으로 쌓고 공고 스택에 맞춰 포트폴리오를 변주해 동시 지원하세요.";

        GenerationInputs in = new GenerationInputs();
        in.setTargetRole("[IT·소프트웨어·데이터 서비스 (AI 딥테크) - 데이터 엔지니어, 백엔드 개발자]");
        in.setResumeText(resume);
        in.setUserProfile("페르소나: 신규 취업. 신입. IT·소프트웨어·데이터 서비스 (AI 딥테크) 산업 희망. "
                + "데이터 엔지니어, 백엔드 개발자 직무 희망. 희망 근무지: 서울 전체, 경기 성남시 (판교). "
                + "희망 고용형태: 정규직. 세부 고민: " + concern);
        in.setUnstructuredData(resume + "\n\n" + cover + "\n\n" + portfolio);
        in.setConsultingLog(history + "\n\n[세부 고민] " + concern);
        in.setExperienceLevel("신입");
        return in;
    }

    // ===================================================== B. 이직 준비 (경력)
    public static GenerationInputs jobChange() {
        String resume =
                "[학력]\n- 석사 · 컴퓨터공학과\n\n"
                + "[경력]\n- 퀀텀에듀솔루션 · 솔루션개발팀 · 주니어 연구원 (3년 6개월)\n\n"
                + "[논문·연구]\n- 시계열 데이터를 활용한 이상탐지 알고리즘 연구\n\n"
                + "[자격증]\n- 정보처리기사\n- AWS Certified Solutions Architect";
        String concern =
                "현재 직장에서는 유지보수 및 기존 솔루션 고도화 위주의 업무를 하고 있습니다. 최신 AI 기술과 데이터 파이프라인 "
                + "구축 쪽으로 커리어를 확장해 이직하고 싶은데, 실무에서 AI를 전담했던 경험이 부족합니다. 제가 가진 기존 유지보수 "
                + "경험을 AI 딥테크 시장에서 요구하는 '클라우드 인프라 및 모델 서빙 역량'으로 어떻게 재번역하고 포트폴리오를 "
                + "재구성해야 할지 막막합니다.";

        GenerationInputs in = new GenerationInputs();
        in.setTargetRole("[AI 및 융합 기술, 딥테크 - AI 모델 개발 연구원, MLOps 엔지니어]");
        in.setResumeText(resume);
        in.setUserProfile("페르소나: 이직 준비. 경력. AI 및 융합 기술, 딥테크 산업 희망. "
                + "AI 모델 개발 연구원, MLOps 엔지니어 직무 희망. 희망 근무지: 경기 성남시 (판교), 서울 강남구. "
                + "희망 고용형태: 정규직. 세부 고민: " + concern);
        in.setUnstructuredData(resume); // 자소서·포트폴리오 없음
        in.setConsultingLog("[세부 고민] " + concern);
        in.setExperienceLevel("경력");
        return in;
    }

    // ===================================================== C. 재취업 (경력 + 공백기)
    public static GenerationInputs reEmployment() {
        String resume =
                "[학력]\n- 석사 · 생명공학과 (화학·바이오)\n\n"
                + "[경력]\n- A제약사 · 신약연구센터 · 선임연구원 (2018.03~2023.05) · 총 5년 3개월, 이후 3년 공백\n\n"
                + "[논문·연구]\n- 특허 출원 1건\n- SCI급 논문 2편\n\n"
                + "[교육이수]\n- WISET 여성과학기술인 경력복귀 R&D 트렌드 교육 · WISET";
        String concern =
                "출산과 육아로 인해 3년간 현업을 떠나있어 최신 연구 장비 활용에 대한 감각이 떨어졌을까 봐 두렵습니다. "
                + "AI 신약 개발과 다중특이 의약품 등 패러다임이 급변하는 상황에서, 면접 시 3년의 공백기를 '단절'이 아닌 "
                + "'지식 융합 및 준비기'로 어떻게 효과적으로 방어하고 이전 5년의 규제/문서 작성 역량을 어필할 수 있을지 막막합니다.";

        GenerationInputs in = new GenerationInputs();
        in.setTargetRole("[제약·바이오, 생명 및 자연과학 연구업 - 연구개발직 (바이오/화학 R&D) 또는 연구지원직(Staff Scientist)]");
        in.setResumeText(resume);
        in.setUserProfile("페르소나: 재취업. 경력. 제약·바이오, 생명 및 자연과학 연구업 산업 희망. "
                + "연구개발직 (바이오/화학 R&D) 또는 연구지원직(Staff Scientist) 직무 희망. 희망 근무지: 서울 전체, 경기 수원시. "
                + "희망 고용형태: 정규직, 시간선택제. 세부 고민: " + concern);
        in.setUnstructuredData(resume);
        in.setConsultingLog("[세부 고민] " + concern);
        in.setExperienceLevel("경력");
        return in;
    }

    // ===================================================== D. 승진/보직 (persona4, 경력)
    public static GenerationInputs promotion() {
        String resume =
                "[학력]\n- 박사 · 산업공학과 (AI 최적화 전공)\n\n"
                + "[경력]\n- B테크기업 · 데이터랩 · 책임연구원 (총 8년)\n\n"
                + "[인턴·대외활동]\n- 사내 기술 세미나 리드\n- 주니어 연구원 멘토 활동";
        String concern =
                "지금까지는 실무 역량과 연구 성과(논문, 특허)로 인정받았으나, 이번에 랩장 승진 대상자가 되었습니다. "
                + "기술 전문가가 리더로 넘어갈 때 겪는 '역량의 덫(Competence Trap)'에 빠지지 않고, 남성 팀원이 다수인 조직에서 "
                + "부드럽지만 결단력 있는 리더십을 구축하고 싶습니다. 당장 앞둔 리더십 다면평가에서 나의 조직 관리 역량을 "
                + "어떻게 정량적 성과로 증명해야 할지 전략이 필요합니다.";

        GenerationInputs in = new GenerationInputs();
        in.setTargetRole("데이터랩 연구소장 / 랩장 (PL)"); // 업종/직무 대신 목표 보직
        in.setResumeText(resume);
        in.setUserProfile("페르소나: 승진·보직 희망. 경력. "
                + "경력성장 목표(목표 보직: 데이터랩 연구소장 / 랩장 (PL); 연차: 8년; "
                + "현재 담당업무: AI 모델 고도화 리딩, 연구 과제 일정·예산 관리, 타 부서 기술 지원·커뮤니케이션; "
                + "목표 처우: 8,000~9,000만원; 평가요소: 리더십 다면평가, 프로젝트 성공률 및 팀 기여도; "
                + "강화역량: 다면평가 방어, 조직·인력 관리, 전략·기획, 갈등관리 및 의사소통). 세부 고민: " + concern);
        in.setUnstructuredData(resume);
        in.setConsultingLog("[컨설팅 결과] WISET 여성 리더십 및 중간관리자 멘토링 이수\n\n[세부 고민] " + concern);
        in.setExperienceLevel("경력");
        return in;
    }
}

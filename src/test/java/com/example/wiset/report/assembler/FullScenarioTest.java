package com.example.wiset.report.assembler;

import com.example.wiset.dto.ai.GenerationInputs;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.Collections;

import static com.example.wiset.report.assembler.AssemblerHarness.act;
import static com.example.wiset.report.assembler.AssemblerHarness.cert;
import static com.example.wiset.report.assembler.AssemblerHarness.edu;
import static com.example.wiset.report.assembler.AssemblerHarness.qna;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * [그룹 G] 실제 로그 케이스(생명과학·연구개발직 신입) 통째 재현 — 5개 필드가 동시에 올바른지.
 *
 * <p>그룹 A~F 가 필드별 단위라면, 여기선 실제 위저드 한 사람분을 그대로 넣어
 *   user_profile / unstructured_data / consulting_log / target_role / resume_text / experience_level
 *   이 한 번의 조립에서 모두 맞물려 나오는지 회귀(regression) 고정한다.
 *
 * <p>실행 : ./gradlew test --tests "com.example.wiset.report.assembler.FullScenarioTest"
 */
class FullScenarioTest {

    private GenerationInputs assembleRealCase() throws Exception {
        return new AssemblerHarness()
                // STEP1 페르소나 + 신입/경력 + 취업우대
                .personaCode(1)
                .profileSelections("신입", Collections.singletonList("병역"))
                // STEP3 희망 업종/직무 + 근무지/고용형태 (근무지·고용형태는 로그처럼 중복 포함)
                .desiredIndustry("생명 및 자연과학 관련직")
                .desiredJob("연구개발직")
                .regions("서울 전체", "경기 성남시", "서울 강남구", "서울 전체", "경기 성남시", "서울 강남구")
                .employment(Arrays.asList("정규직", "계약직", "정규직", "계약직", "파견근로").toArray(new String[0]))
                // STEP4 세부 고민
                .concern("전공에 애착이 없어 직무 선택에 갈피를 못 잡고 있는데, 당장 무엇을 해야 할지 조언을 듣고 싶어요.")
                // STEP2 현 상황: 학력 1 + 자격증 2 + 인턴 1 + 포트폴리오 URL (자기소개서 미입력)
                .education(edu("학사", "한양대학교", "ICT융합학부", "2027.02", "졸업", "3.50", "4.50", "대학물품관리시스템"))
                .certificate(cert("SQLD", "한국데이터산업진흥원", null), cert("ADsP", "한국데이터산업진흥원", null))
                .activity(act("인턴", "(주)퀀텀에듀솔루션", "2026.06", "2026.12", "백엔드 개발"))
                .portfolioUrls("parkdohyun.com")
                // 1:1 컨설팅 Q&A
                .consultingQna(Collections.singletonList(
                        qna("면접 준비 어떻게 하나요?", "발화 연습이 중요합니다.", "2026-04-29")))
                .assembler.assemble();
    }

    @Test
    void competencyEval_입력_target_role과_resume_text가_맞다() throws Exception {
        GenerationInputs in = assembleRealCase();

        assertThat(in.getTargetRole()).isEqualTo("[생명 및 자연과학 관련직 - 연구개발직]");
        assertThat(in.getResumeText())
                .contains("[학력]").contains("한양대학교")
                .contains("SQLD · 한국데이터산업진흥원")
                .contains("인턴 · (주)퀀텀에듀솔루션 (2026.06~2026.12): 백엔드 개발");
        assertThat(in.getExperienceLevel()).isEqualTo("신입");
    }

    @Test
    void consulting_입력_세_필드가_모두_맞다() throws Exception {
        GenerationInputs in = assembleRealCase();

        // user_profile
        assertThat(in.getUserProfile())
                .contains("페르소나: 신규 취업.")
                .contains("생명 및 자연과학 관련직 산업 희망.")
                .contains("취업우대/조건: 병역.")
                .contains("세부 고민: 전공에 애착이 없어");

        // unstructured_data : 이력서 + 포트폴리오 있고, 자기소개서는 미입력이라 없음
        assertThat(in.getUnstructuredData())
                .contains("[학력]")
                .contains("[포트폴리오]").contains("- parkdohyun.com")
                .doesNotContain("[자기소개서]");

        // consulting_log : Q&A + 세부 고민
        assertThat(in.getConsultingLog())
                .startsWith("[1:1 커리어컨설팅 이력 1건]")
                .contains("Q: 면접 준비 어떻게 하나요?")
                .contains("[세부 고민] 전공에 애착이 없어");
    }

    @Test
    void 근무지_고용형태_중복이_요청에_그대로_실린다() throws Exception {
        GenerationInputs in = assembleRealCase();

        // 현 동작 고정: 조립 단계는 중복을 제거하지 않는다(로그에서 관찰된 그대로).
        assertThat(in.getUserProfile())
                .contains("희망 근무지: 서울 전체, 경기 성남시, 서울 강남구, 서울 전체, 경기 성남시, 서울 강남구.")
                .contains("희망 고용형태: 정규직, 계약직, 정규직, 계약직, 파견근로.");
    }
}

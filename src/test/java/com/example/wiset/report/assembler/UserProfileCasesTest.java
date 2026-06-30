package com.example.wiset.report.assembler;

import com.example.wiset.dto.ai.GenerationInputs;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.Collections;

import static com.example.wiset.report.assembler.AssemblerHarness.growth;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * [그룹 D] user_profile 조립 (→ /api/consulting 의 user_profile).
 *
 * <p>페르소나 + 신입/경력 + 희망 업종·직무 + 희망 근무지·고용형태 + 취업우대 + 경력성장 목표(persona4) + 세부 고민을
 *   한 문장 흐름으로 잇는다. 모든 조각이 선택이며, 아무것도 없으면 null.
 *
 * <p>실행 : ./gradlew test --tests "com.example.wiset.report.assembler.UserProfileCasesTest"
 */
class UserProfileCasesTest {

    @Test
    void D1_페르소나만_있으면_페르소나_문구만_남는다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .personaCode(1)
                .assembler.assemble();

        assertThat(in.getUserProfile()).isEqualTo("페르소나: 신규 취업.");
    }

    @Test
    void D2_실제케이스_신규취업_신입_업종직무_근무지_고용형태_우대_고민이_모두_담긴다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .personaCode(1)
                .profileSelections("신입", Collections.singletonList("병역"))
                .desiredIndustry("생명 및 자연과학 관련직")
                .desiredJob("연구개발직")
                .regions("서울 전체", "경기 성남시", "서울 강남구")
                .employment("정규직", "계약직", "파견근로")
                .concern("전공에 애착이 없어 직무 선택에 갈피를 못 잡고 있어요.")
                .assembler.assemble();

        assertThat(in.getUserProfile())
                .contains("페르소나: 신규 취업.")
                .contains("신입.")
                .contains("생명 및 자연과학 관련직 산업 희망.")
                .contains("연구개발직 직무 희망.")
                .contains("희망 근무지: 서울 전체, 경기 성남시, 서울 강남구.")
                .contains("희망 고용형태: 정규직, 계약직, 파견근로.")
                .contains("취업우대/조건: 병역.")
                .contains("세부 고민: 전공에 애착이 없어");
    }

    @Test
    void D3_persona4_경력성장_목표가_상세히_펼쳐진다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .personaCode(4)
                .growthGoal(growth("팀장", "대리", "5", "백엔드 개발", "연봉 6000", "리더십"))
                .growthSkills("리더십", "기획")
                .assembler.assemble();

        assertThat(in.getUserProfile())
                .contains("페르소나: 승진·보직 희망.")
                .contains("경력성장 목표(")
                .contains("목표 보직: 팀장")
                .contains("현재 직급: 대리")
                .contains("연차: 5년")
                .contains("강화역량: 리더십, 기획");
    }

    @Test
    void D4_아무_프로필_조각도_없으면_userProfile_은_null() throws Exception {
        GenerationInputs in = new AssemblerHarness().assembler.assemble();

        assertThat(in.getUserProfile()).isNull();
    }

    @Test
    void D_근무지_고용형태_중복은_그대로_통과된다_현동작_고정() throws Exception {
        // 로그에서 본 현상: DB 에 중복 행이 있으면 조립도 중복을 제거하지 않는다(현재 동작을 고정).
        GenerationInputs in = new AssemblerHarness()
                .personaCode(1)
                .regions("서울 전체", "경기 성남시", "서울 강남구", "서울 전체", "경기 성남시", "서울 강남구")
                .employment(Arrays.asList("정규직", "계약직", "정규직", "계약직", "파견근로").toArray(new String[0]))
                .assembler.assemble();

        assertThat(in.getUserProfile())
                .contains("희망 근무지: 서울 전체, 경기 성남시, 서울 강남구, 서울 전체, 경기 성남시, 서울 강남구.")
                .contains("희망 고용형태: 정규직, 계약직, 정규직, 계약직, 파견근로.");
    }
}

package com.example.wiset.report.assembler;

import com.example.wiset.dto.ai.GenerationInputs;
import org.junit.jupiter.api.Test;

import static com.example.wiset.report.assembler.AssemblerHarness.growth;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * [그룹 A] target_role 결정 규칙 (→ /api/competency-eval 의 target_role).
 *
 * <p>buildTargetRole(industry, job) = "[업종 - 직무]". 단, 둘 다 없고 persona4(경력성장) 목표 보직이 있으면
 *   그 목표 보직으로 대체된다(type1 역량평가는 target_role 이 비면 실패하므로).
 *
 * <p>실행 : ./gradlew test --tests "com.example.wiset.report.assembler.TargetRoleCasesTest"
 */
class TargetRoleCasesTest {

    @Test
    void A1_업종과_직무가_모두_있으면_대괄호_형식으로_조립된다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .desiredIndustry("생명 및 자연과학 관련직")
                .desiredJob("연구개발직")
                .assembler.assemble();

        assertThat(in.getTargetRole()).isEqualTo("[생명 및 자연과학 관련직 - 연구개발직]");
    }

    @Test
    void A2_업종만_있으면_직무자리는_빈칸으로_남는다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .desiredIndustry("생명 및 자연과학 관련직")
                .assembler.assemble();

        assertThat(in.getTargetRole()).isEqualTo("[생명 및 자연과학 관련직 - ]");
    }

    @Test
    void A3_직무만_있으면_업종자리는_빈칸으로_남는다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .desiredJob("연구개발직")
                .assembler.assemble();

        assertThat(in.getTargetRole()).isEqualTo("[ - 연구개발직]");
    }

    @Test
    void A4_업종_직무가_모두_없으면_경력성장_목표보직으로_대체된다() throws Exception {
        // persona4(승진·보직) 흐름: 희망 업종/직무가 없으니 growth.targetRole 을 평가 기준으로 사용
        GenerationInputs in = new AssemblerHarness()
                .personaCode(4)
                .growthGoal(growth("팀장", "대리", "5", null, null, null))
                .assembler.assemble();

        assertThat(in.getTargetRole()).isEqualTo("팀장");
    }

    @Test
    void A5_업종_직무_목표보직이_모두_없으면_targetRole_은_null() throws Exception {
        GenerationInputs in = new AssemblerHarness().assembler.assemble();

        assertThat(in.getTargetRole()).isNull();
    }
}

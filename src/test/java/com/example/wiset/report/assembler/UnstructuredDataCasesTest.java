package com.example.wiset.report.assembler;

import com.example.wiset.dto.ai.GenerationInputs;
import org.junit.jupiter.api.Test;

import static com.example.wiset.report.assembler.AssemblerHarness.edu;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * [그룹 C] unstructured_data 조립 (→ /api/consulting 의 unstructured_data).
 *
 * <p>비정형 = 이력서(resume_text) + [자기소개서](제목·본문) + [포트폴리오](URL). 셋 다 선택이며,
 *   채워진 것만 순서대로 이어 붙고, 셋 다 없으면 null.
 *
 * <p>실행 : ./gradlew test --tests "com.example.wiset.report.assembler.UnstructuredDataCasesTest"
 */
class UnstructuredDataCasesTest {

    /** unstructured 의 머리부분(resume)을 만들기 위한 최소 학력 1건. */
    private static AssemblerHarness withResume() throws Exception {
        return new AssemblerHarness()
                .education(edu("학사", "한양대학교", "ICT융합학부", "2027.02", "졸업", null, null, null));
    }

    @Test
    void C1_이력서만_있으면_자소서_포폴_헤더는_없다() throws Exception {
        GenerationInputs in = withResume().assembler.assemble();

        assertThat(in.getUnstructuredData())
                .startsWith("[학력]")
                .doesNotContain("[자기소개서]")
                .doesNotContain("[포트폴리오]");
    }

    @Test
    void C2_이력서_뒤에_자기소개서_제목과_본문이_붙는다() throws Exception {
        GenerationInputs in = withResume()
                .cover("성장하는 개발자", "저는 어릴 때부터 문제 해결을 좋아했습니다.")
                .assembler.assemble();

        assertThat(in.getUnstructuredData())
                .contains("[자기소개서] 제목: 성장하는 개발자")
                .contains("저는 어릴 때부터 문제 해결을 좋아했습니다.");
    }

    @Test
    void C3_이력서_뒤에_포트폴리오_URL이_붙는다() throws Exception {
        GenerationInputs in = withResume()
                .portfolioUrls("parkdohyun.com")
                .assembler.assemble();

        assertThat(in.getUnstructuredData())
                .contains("[포트폴리오]")
                .contains("- parkdohyun.com");
    }

    @Test
    void C4_이력서_자소서_포트폴리오가_모두_합쳐진다() throws Exception {
        GenerationInputs in = withResume()
                .cover("제목", "자소서 본문")
                .portfolioUrls("parkdohyun.com", "github.com/parkdohyun")
                .assembler.assemble();

        assertThat(in.getUnstructuredData())
                .contains("[학력]").contains("[자기소개서]").contains("[포트폴리오]")
                .contains("- parkdohyun.com").contains("- github.com/parkdohyun");
    }

    @Test
    void C5_이력서_자소서_포폴이_모두_없으면_unstructured_는_null() throws Exception {
        GenerationInputs in = new AssemblerHarness().assembler.assemble();

        assertThat(in.getUnstructuredData()).isNull();
    }
}

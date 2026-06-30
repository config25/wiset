package com.example.wiset.report.assembler;

import com.example.wiset.dto.ai.GenerationInputs;
import org.junit.jupiter.api.Test;

import java.util.Collections;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * [그룹 F] experience_level 결정 (→ /api/market-fit 의 experience_level, 배너 문구에도 사용).
 *
 * <p>신입/경력 선택값(empType)이 그대로 넘어가되, 미선택("")이면 null.
 *
 * <p>실행 : ./gradlew test --tests "com.example.wiset.report.assembler.ExperienceLevelCasesTest"
 */
class ExperienceLevelCasesTest {

    @Test
    void F1_신입_선택은_그대로_신입() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .profileSelections("신입", Collections.emptyList())
                .assembler.assemble();

        assertThat(in.getExperienceLevel()).isEqualTo("신입");
    }

    @Test
    void F2_경력_선택은_그대로_경력() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .profileSelections("경력", Collections.emptyList())
                .assembler.assemble();

        assertThat(in.getExperienceLevel()).isEqualTo("경력");
    }

    @Test
    void F3_미선택이면_experienceLevel_은_null() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .profileSelections("", Collections.emptyList())
                .assembler.assemble();

        assertThat(in.getExperienceLevel()).isNull();
    }
}

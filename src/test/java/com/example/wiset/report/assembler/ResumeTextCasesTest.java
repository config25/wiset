package com.example.wiset.report.assembler;

import com.example.wiset.dto.ai.GenerationInputs;
import org.junit.jupiter.api.Test;

import static com.example.wiset.report.assembler.AssemblerHarness.act;
import static com.example.wiset.report.assembler.AssemblerHarness.award;
import static com.example.wiset.report.assembler.AssemblerHarness.career;
import static com.example.wiset.report.assembler.AssemblerHarness.cert;
import static com.example.wiset.report.assembler.AssemblerHarness.edu;
import static com.example.wiset.report.assembler.AssemblerHarness.lang;
import static com.example.wiset.report.assembler.AssemblerHarness.overseas;
import static com.example.wiset.report.assembler.AssemblerHarness.research;
import static com.example.wiset.report.assembler.AssemblerHarness.training;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * [그룹 B] resume_text 조립 (→ /api/competency-eval 의 resume_text, 또 unstructured_data 의 머리부분).
 *
 * <p>9개 이력 섹션(학력/경력/논문/자격/어학/활동/교육/수상/해외)은 전부 선택. 입력된 섹션만 헤더와 함께 쌓이고,
 *   하나도 없으면 resume_text 는 null.
 *
 * <p>실행 : ./gradlew test --tests "com.example.wiset.report.assembler.ResumeTextCasesTest"
 */
class ResumeTextCasesTest {

    @Test
    void B1_이력_섹션이_하나도_없으면_resumeText_는_null() throws Exception {
        GenerationInputs in = new AssemblerHarness().assembler.assemble();

        assertThat(in.getResumeText()).isNull();
    }

    @Test
    void B2_학력만_있으면_학력_섹션만_조립된다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .education(edu("학사", "한양대학교", "ICT융합학부", "2027.02", "졸업", null, null, null))
                .assembler.assemble();

        assertThat(in.getResumeText())
                .startsWith("[학력]")
                .contains("학사 · 한양대학교 · ICT융합학부 (2027.02 졸업)")
                .doesNotContain("[경력]");
    }

    @Test
    void B3_학력_학점_논문_경력_연봉이_모두_표기된다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .education(edu("학사", "한양대학교", "ICT융합학부", "2027.02", "졸업", "3.50", "4.50", "대학물품관리시스템"))
                .career(career("퀀텀에듀솔루션", "개발팀", "사원", "백엔드", "2024.03", "2025.01", "3200", "API 개발"))
                .assembler.assemble();

        String resume = in.getResumeText();
        assertThat(resume).contains("학점 3.50/4.50");          // gpa/totalGpa
        assertThat(resume).contains("논문: 대학물품관리시스템");   // thesis
        assertThat(resume).contains("[경력]");
        assertThat(resume).contains("(2024.03~2025.01)");        // 기간
        assertThat(resume).contains("연봉 3200");
        assertThat(resume).contains(": API 개발");               // 담당업무
    }

    @Test
    void B4_아홉개_섹션을_모두_채우면_각_헤더가_모두_나타난다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .education(edu("학사", "한양대", "ICT", "2027.02", "졸업", null, null, null))
                .career(career("회사", null, null, null, "2024.03", "2025.01", null, null))
                .research(research("이상탐지 모델 연구"))
                .certificate(cert("SQLD", "한국데이터산업진흥원", "2025.03"))
                .language(lang("영어", null, "비즈니스", "TOEIC", "900"))
                .activity(act("인턴", "퀀텀에듀솔루션", "2026.06", "2026.12", "백엔드 개발"))
                .training(training("정보보안 교육", "KISA"))
                .award(award("우수상", "교내경진대회", "2025"))
                .overseas(overseas("미국", "2023.01", "2023.06"))
                .assembler.assemble();

        assertThat(in.getResumeText())
                .contains("[학력]").contains("[경력]").contains("[논문·연구]").contains("[자격증]")
                .contains("[어학]").contains("[인턴·대외활동]").contains("[교육이수]").contains("[수상]")
                .contains("[해외경험]");
    }

    @Test
    void B5_실제케이스_자격증2건_인턴1건_조합() throws Exception {
        // 로그에서 본 실제 입력 재현: 학력 1 + 자격증 2(SQLD/ADsP) + 인턴 1
        GenerationInputs in = new AssemblerHarness()
                .education(edu("학사", "한양대학교", "ICT융합학부", "2027.02", "졸업", "3.50", "4.50", "대학물품관리시스템"))
                .certificate(cert("SQLD", "한국데이터산업진흥원", null), cert("ADsP", "한국데이터산업진흥원", null))
                .activity(act("인턴", "(주)퀀텀에듀솔루션", "2026.06", "2026.12", "백엔드 개발"))
                .assembler.assemble();

        String resume = in.getResumeText();
        assertThat(resume).contains("SQLD · 한국데이터산업진흥원");
        assertThat(resume).contains("ADsP · 한국데이터산업진흥원");
        assertThat(resume).contains("인턴 · (주)퀀텀에듀솔루션 (2026.06~2026.12): 백엔드 개발");
        assertThat(resume).doesNotContain("[어학]").doesNotContain("[수상]"); // 미입력 섹션은 빠짐
    }
}

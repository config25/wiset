package com.example.wiset.report.assembler;

import com.example.wiset.dto.ai.GenerationInputs;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.Collections;

import static com.example.wiset.report.assembler.AssemblerHarness.qna;
import static org.assertj.core.api.Assertions.assertThat;

/**
 * [그룹 E] consulting_log 조립 (→ /api/consulting 의 consulting_log).
 *
 * <p>1:1 커리어컨설팅 Q&A(완료+답변) + 세부 고민. Q/A 는 각 1000자 캡, Q·A 모두 빈 행은 건너뛴다.
 *   Q&A·고민 둘 다 없으면 null.
 *
 * <p>실행 : ./gradlew test --tests "com.example.wiset.report.assembler.ConsultingLogCasesTest"
 */
class ConsultingLogCasesTest {

    private static String repeat(char c, int n) {
        return new String(new char[n]).replace('\0', c); // Java 8 호환(String.repeat 없음)
    }

    @Test
    void E1_QnA_여러건과_고민이_함께_담긴다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .consultingQna(Arrays.asList(
                        qna("면접 준비 어떻게 하나요?", "발화 연습이 중요합니다.", "2026-04-29"),
                        qna("자소서 첨삭 부탁드립니다.", "구체적 수치를 넣으세요.", "2026-04-28")))
                .concern("직무 선택에 갈피를 못 잡고 있어요.")
                .assembler.assemble();

        assertThat(in.getConsultingLog())
                .startsWith("[1:1 커리어컨설팅 이력 2건]")
                .contains("Q: 면접 준비 어떻게 하나요?")
                .contains("A: 발화 연습이 중요합니다.")
                .contains("[세부 고민] 직무 선택에 갈피를 못 잡고 있어요.");
    }

    @Test
    void E2_QnA가_없고_고민만_있으면_세부고민만_남는다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .concern("직무 선택이 고민이에요.")
                .assembler.assemble();

        assertThat(in.getConsultingLog())
                .isEqualTo("[세부 고민] 직무 선택이 고민이에요.");
    }

    @Test
    void E3_QnA만_있고_고민이_없으면_세부고민_라벨은_없다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .consultingQna(Collections.singletonList(qna("질문", "답변", "2026-04-26")))
                .assembler.assemble();

        assertThat(in.getConsultingLog())
                .contains("[1:1 커리어컨설팅 이력 1건]")
                .doesNotContain("[세부 고민]");
    }

    @Test
    void E4_QnA도_고민도_없으면_consultingLog_은_null() throws Exception {
        GenerationInputs in = new AssemblerHarness().assembler.assemble();

        assertThat(in.getConsultingLog()).isNull();
    }

    @Test
    void E5_긴_질문답변은_각_1000자에서_잘린다() throws Exception {
        String longQ = repeat('가', 1500);
        GenerationInputs in = new AssemblerHarness()
                .consultingQna(Collections.singletonList(qna(longQ, "짧은 답변", "2026-04-26")))
                .assembler.assemble();

        String log = in.getConsultingLog();
        assertThat(log).contains(repeat('가', 1000) + "…"); // 1000자 + 말줄임
        assertThat(log).doesNotContain(repeat('가', 1001));  // 1001자째는 잘려나감
    }

    @Test
    void E6_질문답변이_모두_빈_행은_건너뛴다() throws Exception {
        GenerationInputs in = new AssemblerHarness()
                .consultingQna(Arrays.asList(
                        qna("", "", "2026-04-26"),                 // 빈 행 → skip
                        qna("유효 질문", "유효 답변", "2026-04-27"))) // 표시됨
                .assembler.assemble();

        assertThat(in.getConsultingLog())
                .startsWith("[1:1 커리어컨설팅 이력 2건]") // 헤더 건수는 원본 행 수(2)
                .contains("Q: 유효 질문")
                .contains("A: 유효 답변");
    }
}

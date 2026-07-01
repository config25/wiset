package com.example.wiset.report.persona.promotion;

import com.example.wiset.report.persona.support.AbstractPersonaReportIT;
import com.example.wiset.report.persona.support.PersonaFixtures;
import org.junit.jupiter.api.Test;

/**
 * [시나리오 D] 승진/보직 — 풀 파이프라인 통합 테스트(@SpringBootTest, 베이스 상속).
 *   ▶ 클릭 → Spring 서비스 → 실제 AI 호출 → sys_ai_report 적재 → 재조회 검증.
 *   양식 차이: 희망 업종/직무 대신 경력성장 목표 → target_role 은 목표 보직으로 대체.
 *   데이터: {@link PersonaFixtures#promotion()} · 정의서: dodo/qa/personas/persona4_승진보직.md
 */
class PromotionAiTest extends AbstractPersonaReportIT {

    @Test
    void 승진보직_AI호출_후_DB적재() throws Exception {
        runFullPipeline("D · 승진/보직", PersonaFixtures.promotion());
    }
}

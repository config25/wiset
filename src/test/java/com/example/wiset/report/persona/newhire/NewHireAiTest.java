package com.example.wiset.report.persona.newhire;

import com.example.wiset.report.persona.support.AbstractPersonaReportIT;
import com.example.wiset.report.persona.support.PersonaFixtures;
import org.junit.jupiter.api.Test;

/**
 * [시나리오 A] 신규취업 — 풀 파이프라인 통합 테스트(@SpringBootTest, 베이스 상속).
 *   ▶ 클릭 → Spring 서비스 → 실제 AI 호출 → sys_ai_report 적재 → 재조회 검증.
 *   데이터: {@link PersonaFixtures#newHire()} · 정의서: dodo/qa/personas/persona1_신규취업.md
 */
class NewHireAiTest extends AbstractPersonaReportIT {

    @Test
    void 신규취업_AI호출_후_DB적재() throws Exception {
        runFullPipeline("A · 신규취업", PersonaFixtures.newHire());
    }
}

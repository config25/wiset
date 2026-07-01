package com.example.wiset.report.persona.jobchange;

import com.example.wiset.report.persona.support.AbstractPersonaReportIT;
import com.example.wiset.report.persona.support.PersonaFixtures;
import org.junit.jupiter.api.Test;

/**
 * [시나리오 B] 이직 준비 — 풀 파이프라인 통합 테스트(@SpringBootTest, 베이스 상속).
 *   ▶ 클릭 → Spring 서비스 → 실제 AI 호출 → sys_ai_report 적재 → 재조회 검증.
 *   데이터: {@link PersonaFixtures#jobChange()} · 정의서: dodo/qa/personas/persona2_이직준비.md
 */
class JobChangeAiTest extends AbstractPersonaReportIT {

    @Test
    void 이직준비_AI호출_후_DB적재() throws Exception {
        runFullPipeline("B · 이직 준비", PersonaFixtures.jobChange());
    }
}

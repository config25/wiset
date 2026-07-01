package com.example.wiset.report.persona;

import com.example.wiset.dto.ai.GenerationInputs;
import com.example.wiset.report.persona.support.AbstractPersonaReportIT;
import com.example.wiset.report.persona.support.PersonaFixtures;
import org.junit.jupiter.api.Test;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * [전체] 4개 페르소나를 한 번에 순차 실행 — 실제 AI 호출 + DB 적재(풀 파이프라인 베이스 상속).
 *
 * <p>각 페르소나를 {@code log.info} 로 <b>구분해서 로깅만</b> 한다(하드 assert 없음).
 *   → 한 페르소나가 실패해도 나머지는 계속 돌며 로그를 남긴다(4종 결과를 한 번에 눈으로 비교하는 용도).
 *   개별 검증(assert)이 필요하면 페르소나별 전용 테스트({@code NewHireAiTest} 등)를 사용한다.
 *
 * <p>전제: DB(localhost:3306/wiset)와 AI 서버가 모두 떠 있어야 한다. AI 서버 미연결 시 SKIP(베이스 @BeforeEach).
 */
class AllPersonasAiTest extends AbstractPersonaReportIT {

    @Test
    void 전체_페르소나_AI호출_로깅() {
        Map<String, GenerationInputs> personas = new LinkedHashMap<>();
        personas.put("1 · 신규취업",  PersonaFixtures.newHire());
        personas.put("2 · 이직준비",  PersonaFixtures.jobChange());
        personas.put("3 · 재취업",    PersonaFixtures.reEmployment());
        personas.put("4 · 승진/보직", PersonaFixtures.promotion());

        for (Map.Entry<String, GenerationInputs> e : personas.entrySet()) {
            String persona = e.getKey();
            log.info("\n\n==================== [페르소나 {} 시작] ====================", persona);
            try {
                // 실제 AI 호출(consulting + competency-eval) + persist(DB 적재)
                Map<String, Object> result = service.generate(e.getValue());
                log.info("[페르소나 {}] generate 결과 요약 = {}", persona, result);

                // 적재분 재조회 — sys_ai_report content/배너 확인(로그만)
                Map<String, Object> saved = coachingRead.getCoachingReport(null);
                log.info("[페르소나 {}] sys_ai_report 재조회 — content 존재={}, bannerTitle={}",
                        persona, saved.get("content") != null, saved.get("bannerTitle"));
            } catch (Exception ex) {
                // 로깅만 목적 — 예외도 삼켜서 다음 페르소나로 진행
                log.error("[페르소나 {}] 실행 중 오류 — {}", persona, ex.toString(), ex);
            }
            log.info("==================== [페르소나 {} 완료] ====================\n", persona);
        }
    }
}

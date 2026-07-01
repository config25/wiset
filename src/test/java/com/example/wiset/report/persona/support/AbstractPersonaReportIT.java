package com.example.wiset.report.persona.support;

import com.example.wiset.dto.ai.GenerationInputs;
import com.example.wiset.report.service.impl.AiCoachingServiceImpl;
import com.example.wiset.report.service.impl.ReportGenerationServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * 페르소나 "풀 파이프라인" 통합 테스트 공통 베이스.
 *
 * <p>각 페르소나 테스트가 이 클래스를 상속해 {@code runFullPipeline(...)} 한 줄로 <b>실제 Spring 서비스</b>를 돈다:
 *   ▶ 클릭 → {@link ReportGenerationServiceImpl#generate}
 *   → 실제 AI 호출(consulting + competency-eval 병렬)
 *   → persist 로 <b>sys_ai_report 등 DB 적재</b>
 *   → {@link AiCoachingServiceImpl#getCoachingReport} 로 다시 읽어 적재 검증.
 *
 * <p>전제: <b>DB(localhost:3306/wiset)와 AI 서버가 모두 떠 있어야</b> 한다.
 *   @SpringBootTest 라 전체 컨텍스트(DataSource·MyBatis·빈)가 뜬다 → DB 필수.
 *   AI 서버 미연결 시 SKIP(실패 아님). 적재 대상은 개발 고정 사용자(CurrentUser.userSn()=1).
 */
@SpringBootTest
public abstract class AbstractPersonaReportIT {

    protected static final Logger log = LoggerFactory.getLogger("PERSONA-IT");

    @Autowired protected ReportGenerationServiceImpl service;  // 실제 AI 호출 + persist
    @Autowired protected AiCoachingServiceImpl coachingRead;   // sys_ai_report 읽기(적재 검증)

    @BeforeEach
    void requireAiServer() {
        PersonaAiTestSupport.assumeAiReachable();
    }

    /** 페르소나 입력 한 건을 풀 파이프라인으로 돌리고, sys_ai_report 적재까지 검증한다. */
    protected void runFullPipeline(String persona, GenerationInputs in) throws Exception {
        log.info("\n################## [풀파이프라인 {} 시작] ##################", persona);

        // 실제 AI 호출 + DB 적재
        Map<String, Object> result = service.generate(in);
        log.info("[{}] generate 결과 요약 = {}", persona, result);

        // 적재 검증 — sys_ai_report 에서 다시 읽어 content 가 채워졌는지
        Map<String, Object> saved = coachingRead.getCoachingReport(null);
        Object content = saved.get("content");
        log.info("[{}] sys_ai_report 재조회 — content 존재={}, bannerTitle={}",
                persona, content != null, saved.get("bannerTitle"));
        log.info("################## [풀파이프라인 {} 완료] ##################\n", persona);

        assertThat(result.get("ok")).isEqualTo(true);
        assertThat(result.get("coachingGenerated"))
                .as("AI 코칭 답변이 생성되어야 적재됨(=AI 서버 정상 응답)")
                .isEqualTo(true);
        assertThat(content)
                .as("sys_ai_report.content 가 적재되어 다시 읽혀야 함")
                .isNotNull();
    }
}

package com.example.wiset.report.service.impl;

import com.example.wiset.client.WisetAiClient;
import com.example.wiset.dto.ai.GenerateResponse;
import com.example.wiset.dto.ai.GenerationInputs;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * AI 리포트 생성 오케스트레이션(ReportGenerationServiceImpl) 검증.
 *
 * <p>무엇을 보장하나
 * <ul>
 *   <li>type0(컨설팅) 본문 + type1(역량평가) JSON 을 병렬 호출 후 적재 서비스로 넘기는 흐름</li>
 *   <li>코칭 HTML 본문이 백엔드에서 변형 없이 그대로 persist 로 전달됨 (이번 이슈의 핵심)</li>
 *   <li>type1 JSON 형식이 깨졌을 때(알려진 이슈: 점수를 객체로 감싸 보냄) 역량 적재가 생략됨</li>
 *   <li>한쪽 AI 호출이 실패해도 전체가 죽지 않고 나머지로 진행됨</li>
 * </ul>
 *
 * <p>테스트 종류 : 단위 테스트(Mockito) — Spring 컨텍스트 없이 의존성을 직접 가짜로 끼워 넣는다.
 *   외부 AI(WisetAiClient)·적재(ReportPersistServiceImpl)·자동조립(ReportInputAssembler)을 @Mock 으로 대체 →
 *   네트워크·DB 없이 "오케스트레이션 로직"만 격리해서 검증.
 * <p>핵심 도구
 * <ul>
 *   <li>@Mock            : 의존성을 가짜 객체로 생성</li>
 *   <li>when(...).thenReturn / thenThrow : 가짜가 어떻게 반응할지 스텁</li>
 *   <li>ArgumentCaptor   : 가짜에 "어떤 인자가 전달됐는지" 붙잡아 검증(여기선 코칭 본문·역량 그룹)</li>
 *   <li>ExecutorService  : 병렬 호출용 — 테스트에선 진짜 스레드풀을 만들어 쓰고 끝나면 종료</li>
 * </ul>
 * <p>테스트 패턴 : given(AI/적재 가짜 응답 스텁) → when(generate 호출) → then(전달 인자·반환 요약 검증).
 * <p>참고 : CurrentUser.userSn() 은 개발용 고정값(1L)을 돌려주므로 별도 mocking 이 필요 없다.
 *
 * <p>실행 방법
 * <pre>
 *   이 클래스만 : ./gradlew test --tests "com.example.wiset.report.service.impl.ReportGenerationServiceImplTest"
 * </pre>
 */
@ExtendWith(MockitoExtension.class)
class ReportGenerationServiceImplTest {

    @Mock WisetAiClient ai;                       // 외부 AI 추론 서버 호출 — 가짜로 대체
    @Mock ReportPersistServiceImpl persistService;// DB 적재 — 가짜로 대체
    @Mock ReportInputAssembler assembler;         // 입력 자동조립 — 본 테스트에선 입력을 직접 줘서 미사용

    ExecutorService exec;                  // 병렬 호출용 진짜 스레드풀(외부 자원 아님)
    ReportGenerationServiceImpl sut;       // sut = System Under Test(검증 대상)

    @Captor ArgumentCaptor<String> coachingTextCaptor;                       // persist 로 넘어간 코칭 본문 포획
    @Captor ArgumentCaptor<Map<String, Map<String, Double>>> groupsCaptor;   // persist 로 넘어간 역량 그룹 포획

    @BeforeEach
    void setUp() {
        // 매 테스트마다 새 스레드풀 + 검증 대상 생성(가짜 의존성 주입)
        exec = Executors.newFixedThreadPool(2);
        sut = new ReportGenerationServiceImpl(ai, exec, persistService, assembler);
    }

    @AfterEach
    void tearDown() {
        // 테스트가 만든 스레드풀 정리(누수 방지)
        exec.shutdownNow();
    }

    /** AI 응답 객체를 만드는 헬퍼. */
    private static GenerateResponse resp(String text) {
        GenerateResponse r = new GenerateResponse();
        r.setResponse(text);
        r.setElapsedSeconds(0.1);
        return r;
    }

    /** 입력이 비어 있지 않게 채워(=내부 자동조립 분기를 타지 않도록) 전달하는 헬퍼. */
    private static GenerationInputs nonEmptyInputs() {
        GenerationInputs in = new GenerationInputs();
        in.setTargetRole("[IT·SW - 백엔드]");
        in.setResumeText("이력서 텍스트");
        in.setUserProfile("프로필");
        in.setExperienceLevel("신입");
        return in;
    }

    @Test
    void 코칭_HTML_본문은_변형없이_persist_로_전달되고_type1_은_그룹으로_파싱된다() throws Exception {
        // given : 컨설팅=HTML 본문, 역량평가=정상 JSON 을 돌려주도록 AI 가짜를 스텁
        String html = "<h2>1. 전공·직무 기초 이해</h2><p>본문입니다.</p>";
        when(ai.generate(eq("/api/consulting"), any())).thenReturn(resp(html));
        when(ai.generate(eq("/api/competency-eval"), any()))
                .thenReturn(resp("{\"공통활동\":{\"문제해결\":2.0,\"소통\":3.0}}"));
        when(persistService.persist(anyLong(), any(), any(), any(), any(), any()))
                .thenReturn(new HashMap<>());

        // when : 리포트 생성 실행
        Map<String, Object> out = sut.generate(nonEmptyInputs());

        // then : persist 로 넘어간 인자(코칭 본문·역량 그룹)를 붙잡아 검증
        verify(persistService).persist(anyLong(), coachingTextCaptor.capture(),
                any(), any(), any(), groupsCaptor.capture());

        assertThat(coachingTextCaptor.getValue()).isEqualTo(html).contains("<h2>"); // 본문 변형 없음
        assertThat(groupsCaptor.getValue()).containsKey("공통활동");                  // type1 정상 파싱
        assertThat(out.get("ok")).isEqualTo(true);
        assertThat(out.get("coachingGenerated")).isEqualTo(true);
        assertThat(out.get("competencyGroups")).isEqualTo(1);
    }

    @Test
    void type1_JSON_형식이_깨지면_역량적재는_생략된다() throws Exception {
        // given : 역량평가 응답이 "점수를 객체로 감싼" 잘못된 형식(알려진 이슈)
        //         → Map<String,Map<String,Double>> 로 파싱 실패해야 한다
        when(ai.generate(eq("/api/consulting"), any())).thenReturn(resp("코칭 본문"));
        when(ai.generate(eq("/api/competency-eval"), any()))
                .thenReturn(resp("{\"공통활동\":{\"문제해결\":{\"score\":2}}}"));
        when(persistService.persist(anyLong(), any(), any(), any(), any(), any()))
                .thenReturn(new HashMap<>());

        // when
        Map<String, Object> out = sut.generate(nonEmptyInputs());

        // then : 파싱 실패 → groups=null 로 persist 호출, 요약의 역량 그룹 수는 0
        verify(persistService).persist(anyLong(), any(), any(), any(), any(), groupsCaptor.capture());
        assertThat(groupsCaptor.getValue()).isNull();
        assertThat(out.get("competencyGroups")).isEqualTo(0);
    }

    @Test
    void AI_호출이_한쪽_실패해도_전체는_죽지않고_나머지로_진행된다() throws Exception {
        // given : 컨설팅 호출은 예외(타임아웃), 역량평가는 정상
        when(ai.generate(eq("/api/consulting"), any()))
                .thenThrow(new RuntimeException("connect timed out"));
        when(ai.generate(eq("/api/competency-eval"), any()))
                .thenReturn(resp("{\"공통활동\":{\"문제해결\":2.0}}"));
        when(persistService.persist(anyLong(), any(), any(), any(), any(), any()))
                .thenReturn(new HashMap<>());

        // when : 예외가 밖으로 터지지 않고 끝까지 진행되어야 한다
        Map<String, Object> out = sut.generate(nonEmptyInputs());

        // then : 코칭은 실패(null)로 표시되지만 역량은 정상 적재
        assertThat(out.get("coachingGenerated")).isEqualTo(false);
        assertThat(out.get("competencyGroups")).isEqualTo(1);
    }
}

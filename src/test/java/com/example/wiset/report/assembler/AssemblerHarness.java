package com.example.wiset.report.assembler;

import com.example.wiset.dto.ActivityDto;
import com.example.wiset.dto.AwardDto;
import com.example.wiset.dto.CareerDto;
import com.example.wiset.dto.CertificateDto;
import com.example.wiset.dto.EducationDto;
import com.example.wiset.dto.LanguageDto;
import com.example.wiset.dto.OverseasDto;
import com.example.wiset.dto.PortfolioUrlDto;
import com.example.wiset.dto.ResearchDto;
import com.example.wiset.dto.TrainingDto;
import com.example.wiset.report.service.impl.ReportInputAssembler;
import com.example.wiset.stage.service.impl.CurrentSituationServiceImpl;
import com.example.wiset.support.CommonDAO;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * ReportInputAssembler.assemble() 동적 조립 테스트용 공용 하네스.
 *
 * <p>왜 필요한가
 * <ul>
 *   <li>assemble() 한 번이 DAO·CurrentSituation 으로 ~20개 호출을 한다. 매 테스트마다 다 스텁하면
 *       본질(어떤 입력 → 어떤 요청)이 묻힌다. → 기본값 "전부 비어있음"을 깔고, 케이스가 바꾸는 부분만 override.</li>
 *   <li>가짜 데이터는 전부 DTO 빌더(static)로 조립한다. 틀이 같으니 빌더 한 벌이면 9개 섹션 다 커버된다.</li>
 * </ul>
 *
 * <p>설계
 * <ul>
 *   <li>CommonDAO 의 selectOne/selectList 는 queryId → 반환값 Map 으로 라우팅(없으면 null / 빈 리스트).</li>
 *   <li>CurrentSituationServiceImpl 은 mock 기본값(빈 리스트·빈 맵)이 곧 "미입력"이라 별도 셋업 불필요.
 *       특정 섹션만 채울 땐 education(...)/career(...) 같은 helper 로 override.</li>
 *   <li>CurrentUser.userSn() 은 개발 고정값(1L) → static mocking 불필요(기존 테스트와 동일).</li>
 * </ul>
 */
class AssemblerHarness {

    final CurrentSituationServiceImpl situation = mock(CurrentSituationServiceImpl.class);
    final CommonDAO dao = mock(CommonDAO.class);
    final ReportInputAssembler assembler = new ReportInputAssembler(situation, dao);

    /** queryId → selectOne 반환값. */
    private final Map<String, Object> oneReturns = new HashMap<>();
    /** queryId → selectList 반환값. */
    private final Map<String, List<?>> listReturns = new HashMap<>();

    AssemblerHarness() {
        try {
            when(dao.selectOne(anyString(), any()))
                    .thenAnswer(inv -> oneReturns.get((String) inv.getArgument(0)));
            when(dao.selectList(anyString(), any())).thenAnswer(inv -> {
                List<?> v = listReturns.get((String) inv.getArgument(0));
                return v != null ? v : Collections.emptyList();
            });
        } catch (Exception e) {
            throw new RuntimeException(e); // 스텁 등록은 실제로 던지지 않음 — 체크예외 우회용
        }
    }

    // ----------------------------------------------------- STEP3 희망 업종/직무/근무지/고용형태
    AssemblerHarness desiredIndustry(String v) { oneReturns.put("mypage.scrap.findDesiredIndustry", v); return this; }
    AssemblerHarness desiredJob(String v)      { oneReturns.put("mypage.scrap.findDesiredJob", v); return this; }
    AssemblerHarness regions(String... v)      { listReturns.put("mypage.scrap.listDesiredRegions", Arrays.asList(v)); return this; }
    AssemblerHarness employment(String... v)   { listReturns.put("mypage.scrap.listDesiredEmployment", Arrays.asList(v)); return this; }

    // ----------------------------------------------------- STEP1 페르소나 / STEP4 고민 / 경력성장(persona4)
    AssemblerHarness personaCode(Integer v)        { oneReturns.put("stage.analysis.findPersonaCode", v); return this; }
    AssemblerHarness concern(String v)             { oneReturns.put("mypage.scrap.findLatestConcern", v); return this; }
    AssemblerHarness growthGoal(Map<String, Object> v) { oneReturns.put("stage.analysis.findGrowthGoal", v); return this; }
    AssemblerHarness growthSkills(String... v)     { listReturns.put("stage.analysis.findGrowthSkills", Arrays.asList(v)); return this; }

    // ----------------------------------------------------- 신입/경력 + 취업우대(prefs)
    AssemblerHarness profileSelections(String empType, List<String> prefs) throws Exception {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("empType", empType);
        m.put("prefs", prefs);
        when(situation.getProfileSelections()).thenReturn(m);
        return this;
    }

    // ----------------------------------------------------- STEP2 현 상황(9개 이력 섹션)
    AssemblerHarness education(EducationDto... rows)  throws Exception { when(situation.listEducation()).thenReturn(Arrays.asList(rows)); return this; }
    AssemblerHarness career(CareerDto... rows)        throws Exception { when(situation.listCareer()).thenReturn(Arrays.asList(rows)); return this; }
    AssemblerHarness research(ResearchDto... rows)    throws Exception { when(situation.listResearch()).thenReturn(Arrays.asList(rows)); return this; }
    AssemblerHarness certificate(CertificateDto... rows) throws Exception { when(situation.listCertificate()).thenReturn(Arrays.asList(rows)); return this; }
    AssemblerHarness language(LanguageDto... rows)    throws Exception { when(situation.listLanguage()).thenReturn(Arrays.asList(rows)); return this; }
    AssemblerHarness activity(ActivityDto... rows)    throws Exception { when(situation.listActivity()).thenReturn(Arrays.asList(rows)); return this; }
    AssemblerHarness training(TrainingDto... rows)    throws Exception { when(situation.listTraining()).thenReturn(Arrays.asList(rows)); return this; }
    AssemblerHarness award(AwardDto... rows)          throws Exception { when(situation.listAward()).thenReturn(Arrays.asList(rows)); return this; }
    AssemblerHarness overseas(OverseasDto... rows)    throws Exception { when(situation.listOverseas()).thenReturn(Arrays.asList(rows)); return this; }

    // ----------------------------------------------------- 자기소개서 / 포트폴리오
    AssemblerHarness cover(String title, String content) throws Exception {
        Map<String, Object> m = new HashMap<>();
        m.put("title", title);
        m.put("content", content);
        when(situation.getCover()).thenReturn(m);
        return this;
    }

    AssemblerHarness portfolioUrls(String... urls) throws Exception {
        Map<String, Object> m = new HashMap<>();
        m.put("urls", Arrays.stream(urls).map(AssemblerHarness::url).collect(java.util.stream.Collectors.toList()));
        when(situation.getPortfolio()).thenReturn(m);
        return this;
    }

    // ----------------------------------------------------- 1:1 커리어컨설팅 Q&A
    AssemblerHarness consultingQna(List<Map<String, Object>> rows) {
        listReturns.put("indvdl.cnsl.selectCnslQnaListByUser", rows);
        return this;
    }

    // ===================================================== DTO 빌더 (가짜 데이터 — 틀은 같음)

    static EducationDto edu(String seLabel, String school, String major, String gradYm,
                            String gradStatus, String gpa, String totalGpa, String thesis) {
        EducationDto d = new EducationDto();
        d.setSeLabel(seLabel); d.setSchoolName(school); d.setMajorName(major);
        d.setGraduationYm(gradYm); d.setGradStatusLabel(gradStatus);
        d.setGpa(gpa); d.setTotalGpa(totalGpa); d.setThesis(thesis);
        return d;
    }

    static CareerDto career(String company, String dept, String position, String jobField,
                            String startYm, String endYm, String salary, String jobDesc) {
        CareerDto d = new CareerDto();
        d.setCompanyName(company); d.setDeptName(dept); d.setPosition(position); d.setJobField(jobField);
        d.setStartYm(startYm); d.setEndYm(endYm); d.setSalary(salary); d.setJobDescription(jobDesc);
        return d;
    }

    static ResearchDto research(String content) {
        ResearchDto d = new ResearchDto(); d.setContent(content); return d;
    }

    static CertificateDto cert(String name, String issuer, String got) {
        CertificateDto d = new CertificateDto(); d.setName(name); d.setIssuer(issuer); d.setGot(got); return d;
    }

    static LanguageDto lang(String langName, String manual, String speak, String testName, String testScore) {
        LanguageDto d = new LanguageDto();
        d.setLang(langName); d.setManual(manual); d.setSpeak(speak); d.setTestName(testName); d.setTestScore(testScore);
        return d;
    }

    static ActivityDto act(String kind, String org, String start, String end, String desc) {
        ActivityDto d = new ActivityDto();
        d.setKind(kind); d.setOrg(org); d.setStart(start); d.setEnd(end); d.setDesc(desc);
        return d;
    }

    static TrainingDto training(String name, String org) {
        TrainingDto d = new TrainingDto(); d.setName(name); d.setOrg(org); return d;
    }

    static AwardDto award(String name, String org, String year) {
        AwardDto d = new AwardDto(); d.setName(name); d.setOrg(org); d.setYear(year); return d;
    }

    static OverseasDto overseas(String country, String start, String end) {
        OverseasDto d = new OverseasDto(); d.setCountry(country); d.setStart(start); d.setEnd(end); return d;
    }

    static PortfolioUrlDto url(String u) {
        PortfolioUrlDto d = new PortfolioUrlDto(); d.setUrl(u); return d;
    }

    /** 1:1 컨설팅 Q&A 한 건. 컬럼키는 대문자(QUESTION/ANSWER/CNSL_COMPT_DE) — 매퍼 결과와 동일. */
    static Map<String, Object> qna(String question, String answer, String date) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("QUESTION", question);
        m.put("ANSWER", answer);
        m.put("CNSL_COMPT_DE", date);
        return m;
    }

    /** 경력성장 목표(persona4) 맵. 값 없는 키는 null 로 두면 buildProfile 에서 생략된다. */
    static Map<String, Object> growth(String targetRole, String rankName, String years,
                                      String duties, String targetPay, String evalName) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("targetRole", targetRole);
        m.put("rankName", rankName);
        m.put("years", years);
        m.put("duties", duties);
        m.put("targetPay", targetPay);
        m.put("evalName", evalName);
        return m;
    }
}

package com.example.wiset.devtest;

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
import com.example.wiset.stage.service.impl.CurrentSituationServiceImpl;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * [개발용] 시연 프리셋 로더. per1~per4.md 페르소나 데이터를 데모 계정(user 1)에 '미리' 채운다.
 *   - 현 상황(학력/경력/부가정보 9종): 기존 {@link CurrentSituationServiceImpl}의 save/list/delete 재사용
 *     (라벨→코드 변환·RESUME_SN 채번 로직을 그대로 타므로 정상 화면과 100% 동일하게 저장됨).
 *   - 페르소나/희망목표/세부고민: sessionStorage 용 페이로드로 반환 → 컨트롤러가 JSON으로 내려주고
 *     /api/test 페이지 JS가 wb_* 키에 심는다.
 *   재실행 안전: seed 전에 현 상황 전량 삭제(중복 방지). cover 텍스트는 upsert.
 *   ※ 인증/세션 사용자 개념이 없어 모든 데이터는 user 1(CurrentUser.userSn)에 귀속된다.
 */
@Service
public class TestPresetService {

    private final CurrentSituationServiceImpl cs;

    public TestPresetService(CurrentSituationServiceImpl cs) {
        this.cs = cs;
    }

    /** 페르소나(1~4) 프리셋을 로드하고 sessionStorage 페이로드를 반환한다. */
    @Transactional
    public Map<String, Object> load(int persona) throws Exception {
        clearCurrentSituation();
        switch (persona) {
            case 1: seed1(); return session1();
            case 2: seed2(); return session2();
            case 3: seed3(); return session3();
            case 4: seed4(); return session4();
            default: throw new IllegalArgumentException("persona 는 1~4 만 지원합니다.");
        }
    }

    // ===================== 현 상황 전량 삭제 (재실행 시 중복 방지) =====================
    private void clearCurrentSituation() throws Exception {
        for (EducationDto d : cs.listEducation())   cs.deleteEducation(d.getAcdmcrSn());
        for (CareerDto d : cs.listCareer())         cs.deleteCareer(d.getCareerSn());
        for (ResearchDto d : cs.listResearch())     cs.deleteResearch(d.getResearchId());
        for (ActivityDto d : cs.listActivity())     cs.deleteActivity(d.getActSn());
        for (TrainingDto d : cs.listTraining())     cs.deleteTraining(d.getEdcSn());
        for (CertificateDto d : cs.listCertificate()) cs.deleteCertificate(d.getCrqfcSn());
        for (AwardDto d : cs.listAward())           cs.deleteAward(d.getWnpzSn());
        for (OverseasDto d : cs.listOverseas())     cs.deleteOverseas(d.getOvseaSn());
        for (LanguageDto d : cs.listLanguage())     cs.deleteLanguage(d.getLstcsSn());
        Object urls = cs.getPortfolio().get("urls");
        if (urls instanceof List) {
            for (Object o : (List<?>) urls) {
                Long sn = urlSn(o);
                if (sn != null) cs.deletePortfolioUrl(sn);
            }
        }
        // 자기소개서(cover)는 이력서당 1건 upsert 이므로 seed 단계에서 덮어씀(별도 삭제 불필요).
    }

    private static Long urlSn(Object o) {
        if (o instanceof PortfolioUrlDto) return ((PortfolioUrlDto) o).getSn();
        if (o instanceof Map) {
            Object v = ((Map<?, ?>) o).get("sn");
            if (v == null) v = ((Map<?, ?>) o).get("SN");
            return v == null ? null : Long.valueOf(v.toString());
        }
        return null;
    }

    // ============================ 페르소나 1 · AI 정보보안 (신규취업) ============================
    private void seed1() throws Exception {
        cs.saveEducation(edu("석사", "고려대학교", "정보보호대학원 (AI보안·머신러닝)", "2026.08", "졸업예정",
                "적대적 공격에 강건한 악성코드 탐지 모델", true));
        cs.saveEducation(edu("학사", "고려대학교", "사이버국방학과", "2024.02", "졸업", null, false));
        cs.saveEducation(edu("고등학교 졸업", "한영외국어고등학교", "자연계", null, "졸업", null, false));
        cs.saveCareer(career("시큐어링크", "보안AI연구팀", "연구 인턴", "보안 AI 연구", "2025.06", "2026.02",
                "악성코드 탐지 모델 학습·평가"));
        cs.addResearch(research("딥러닝 기반 네트워크 침입탐지(IDS)의 오탐 저감 연구 (석사 학위논문 진행)"));
        cs.addResearch(research("정보보호학회 학술대회 포스터 1편: 적대적 예제 기반 악성코드 분류기 강건성 평가"));
        cs.addActivity(act("인턴", "시큐어링크 보안AI연구팀", "2025.06", "2026.02", "악성코드 탐지 모델 학습·평가"));
        cs.addActivity(act("사회활동", "화이트해커 CTF 대회", null, null, "국내 예선 상위 10% (2025)"));
        cs.addTraining(train("취업탐색 멘토링", "WISET", null, null, null));
        cs.addTraining(train("AI 보안 전문인력 양성과정", "KISA", null, null, "수강 중"));
        cs.addCertificate(cert("정보보안기사", "한국인터넷진흥원", "2025.05"));
        cs.addCertificate(cert("정보처리기사", "한국산업인력공단", "2024.08"));
        cs.addAward(award("글로벌 여성 사이버보안 해커톤 우수상", null, "2026", null));
        cs.addOverseas(overseas("싱가포르", null, null, "국제 보안 컨퍼런스 참관 (2025)"));
        cs.addLanguage(lang("영어", "비즈니스 회화 가능", "TOEIC", "915"));
        cs.addPortfolioUrl("GitHub - 적대적 공격 강건성 평가 도구 · IDS 오탐 저감 실험 코드");
        cs.addPortfolioUrl("기술블로그 - 악성코드 탐지 회피 공격 실험기 · CTF 문제풀이");
        cs.saveCoverText("공격자의 시선으로 방어를 설계하는 AI 보안 연구자", COVER1);
    }

    private Map<String, Object> session1() {
        return payload("1", curSit("신입"),
                goal("정보통신 관련직", "연구개발직",
                        Arrays.asList("서울 전체", "경기 성남시"),
                        Arrays.asList("정규직", "계약직", "무기계약직", "인턴직")),
                null, CONCERN1);
    }

    // ============================ 페르소나 2 · 화학·바이오 (이직) ============================
    private void seed2() throws Exception {
        cs.saveEducation(edu("석사", "성균관대학교", "화학공학과 (고분자·소재)", "2019.02", "졸업", null, true));
        cs.saveEducation(edu("고등학교 졸업", "대전과학고등학교", "자연계", null, "졸업", null, false));
        cs.saveCareer(career("한울케미칼", "생산기술팀", "선임연구원", "정밀화학 생산기술", "2019.03", null,
                "정밀화학 소재 스케일업 공정 개발, 반응 조건 최적화 및 수율 개선, 생산 라인 트러블슈팅 및 공정 표준화(SOP) 작성"));
        cs.addResearch(research("특허 등록 2건 (연속 흐름 반응 공정, 촉매 재사용 공정)"));
        cs.addResearch(research("SCI급 논문 1편 (친환경 용매 기반 합성 공정)"));
        cs.addActivity(act("사회활동", "한울케미칼", null, null, "사내 공정안전(PSM) 개선 TF 참여 (2023)"));
        cs.addTraining(train("여성과학기술인 커리어 전환 멘토링", "WISET", null, null, "수강 중"));
        cs.addTraining(train("GMP 및 바이오공정 실무 교육", "한국바이오협회", null, null, "2025 이수"));
        cs.addCertificate(cert("화공기사", "한국산업인력공단", "2018.05"));
        cs.addCertificate(cert("위험물산업기사", "한국산업인력공단", "2018.11"));
        cs.addAward(award("사내 공정혁신 우수상", "한울케미칼", "2022", null));
        cs.addOverseas(overseas("독일", null, null, "화학소재 파트너사 기술교류 출장 (2023)"));
        cs.addLanguage(lang("영어", "비즈니스 회화 가능", "TOEIC", "850"));
        cs.addPortfolioUrl("공정 개선 실적 요약 (스케일업 수율 개선·연속 흐름 공정 도입)");
        cs.addPortfolioUrl("특허 2건 · SCI 1편 목록");
        cs.saveCoverText("실험실의 반응식을 공장의 수율로 옮기는 공정 엔지니어", COVER2);
    }

    private Map<String, Object> session2() {
        return payload("2", curSit("경력"),
                goal("화학/식품가공 관련직", "기술직",
                        Arrays.asList("경기 화성시", "충북 청주시"),
                        Arrays.asList("정규직")),
                null, CONCERN2);
    }

    // ============================ 페르소나 3 · 반도체 (재취업) ============================
    private void seed3() throws Exception {
        cs.saveEducation(edu("석사", "한양대학교", "신소재공학과 (반도체 소자)", "2015.02", "졸업", null, true));
        cs.saveEducation(edu("고등학교 졸업", "진선여자고등학교", "자연계", null, "졸업", null, false));
        cs.saveCareer(career("에스제이하이맥스", "소자개발팀", "선임연구원", "반도체 소자 평가", "2015.03", "2022.12",
                "DRAM 소자 특성 평가 및 신뢰성 분석 데이터 관리, 공정-소자 상관 분석 리포트 작성, 측정 장비 운용 및 실험 데이터 표준화 (2023~2026 출산·육아 경력 공백)"));
        cs.addResearch(research("SCI급 논문 2편 (제1저자 1편, 고유전율 게이트 절연막)"));
        cs.addResearch(research("특허 출원 1건 (소자 신뢰성 평가 방법)"));
        cs.addActivity(act("사회활동", "에스제이하이맥스", null, null, "사내 실험데이터 관리 표준화 프로젝트 리드 (2021)"));
        cs.addTraining(train("여성과학기술인 경력복귀 R&D 재교육 과정", "WISET", null, null, "2026 이수"));
        cs.addTraining(train("반도체 계측·분석 실무 재교육", "한국반도체산업협회", null, null, "수강 중"));
        cs.addCertificate(cert("반도체설계산업기사", "한국산업인력공단", "2014.05"));
        cs.addCertificate(cert("품질경영기사", "한국산업인력공단", "2016.11"));
        cs.addAward(award("사내 데이터 표준화 개선 우수상", "에스제이하이맥스", "2021", null));
        cs.addOverseas(overseas("미국", null, null, "반도체 학회 참가 (2019)"));
        cs.addLanguage(lang("영어", "비즈니스 회화 가능", "TOEIC", "880"));
        cs.addPortfolioUrl("연구 실적 요약 (DRAM 신뢰성 평가·데이터 표준화 리드)");
        cs.addPortfolioUrl("SCI 2편(제1저자 1편) · 소자 신뢰성 평가 특허 출원 1건");
        cs.saveCoverText("데이터로 소자를 읽어온 8년, 다시 실험실로 돌아갑니다", COVER3);
    }

    private Map<String, Object> session3() {
        return payload("3", curSit("경력"),
                goal("전기/전자 관련직", "연구지원직",
                        Arrays.asList("경기 이천시", "경기 용인시"),
                        Arrays.asList("정규직", "시간제", "무기계약직")),
                null, CONCERN3);
    }

    // ============================ 페르소나 4 · 일반산업 (승진/보직) ============================
    private void seed4() throws Exception {
        cs.saveEducation(edu("박사", "서울대학교", "기계공학부 (열유체·설계)", "2015.02", "졸업", null, true));
        cs.saveEducation(edu("고등학교 졸업", "창덕여자고등학교", "자연계", null, "졸업", null, false));
        cs.saveCareer(career("대성인더스트리", "기술연구소", "책임연구원/팀장", "산업용 공조·열교환 R&D", "2015.03", null,
                "산업용 공조·열교환 시스템 R&D 총괄, 신제품 설계-검증-양산이관 프로세스 표준화, 연구 과제 일정·예산 관리, 타 부서 기술지원, 연구원 6인 직접 지도"));
        cs.addResearch(research("SCI급 논문 4편"));
        cs.addResearch(research("국내외 특허 5건 (등록 3, 출원 2)"));
        cs.addActivity(act("사회활동", "대성인더스트리", null, null, "사내 기술 세미나 분기 리드"));
        cs.addActivity(act("사회활동", "대성인더스트리", null, null, "신입 연구원 온보딩 멘토 활동"));
        cs.addTraining(train("여성 관리자 리더십 아카데미", "WISET", null, null, "2026 이수"));
        cs.addTraining(train("R&D 프로젝트 리더십 과정", "한국산업기술진흥협회", null, null, "2024 이수"));
        cs.addCertificate(cert("기계기술사", "한국산업인력공단", "2018.11"));
        cs.addCertificate(cert("PMP", "PMI", "2020.01"));
        cs.addAward(award("사내 R&D 우수과제상", "대성인더스트리", "2022", null));
        cs.addAward(award("대한민국 기술대상 산업부문 수상 프로젝트 참여", null, "2023", null));
        cs.addOverseas(overseas("일본", null, null, "산업기계 전시회 기술조사 출장 (2022)"));
        cs.addLanguage(lang("영어", "비즈니스 회화 가능", "TOEIC", "900"));
        cs.addPortfolioUrl("리더십·프로젝트 실적 (열교환 R&D 총괄·프로세스 표준화)");
        cs.addPortfolioUrl("연구원 6인 육성 · 대한민국 기술대상 수상 프로젝트 참여");
        cs.saveCoverText("뛰어난 연구자를 넘어, 팀의 성과를 만드는 R&D 리더", COVER4);
    }

    private Map<String, Object> session4() {
        Map<String, Object> growth = new LinkedHashMap<>();
        growth.put("rank", "차장급");
        growth.put("years", "11년");
        growth.put("duties", "산업용 공조·열교환 R&D 총괄, 설계-검증-양산이관 프로세스 표준화, 연구 과제 일정·예산 관리, 연구원 6인 지도");
        growth.put("targetRole", "연구소 상위 보직 (연구소장/그룹장)");
        growth.put("skills", Arrays.asList("조직·인력 관리", "전략·기획", "의사결정", "성과관리"));
        growth.put("targetPay", "성과급 포함 상향 협의");
        growth.put("evalFactor", "리더십 다면평가");
        return payload("4", curSit("경력"), null, growth, CONCERN4);
    }

    // ============================ DTO 팩토리 ============================
    private EducationDto edu(String seLabel, String school, String major, String gradYm,
                            String gradStatus, String thesis, boolean isFinal) {
        EducationDto d = new EducationDto();
        d.setSeLabel(seLabel);
        d.setSchoolName(school);
        d.setMajorName(major);
        d.setGraduationYm(gradYm);
        d.setGradStatusLabel(gradStatus);
        d.setThesis(thesis);
        d.setFinal(isFinal);
        return d;
    }

    private CareerDto career(String company, String dept, String position, String jobField,
                            String startYm, String endYm, String desc) {
        CareerDto d = new CareerDto();
        d.setCompanyName(company);
        d.setDeptName(dept);
        d.setPosition(position);
        d.setJobField(jobField);
        d.setStartYm(startYm);
        d.setEndYm(endYm);
        d.setJobDescription(desc);
        return d;
    }

    private ResearchDto research(String content) {
        ResearchDto d = new ResearchDto();
        d.setContent(content);
        return d;
    }

    private ActivityDto act(String kind, String org, String start, String end, String desc) {
        ActivityDto d = new ActivityDto();
        d.setKind(kind);
        d.setOrg(org);
        d.setStart(start);
        d.setEnd(end);
        d.setDesc(desc);
        return d;
    }

    private TrainingDto train(String name, String org, String start, String end, String desc) {
        TrainingDto d = new TrainingDto();
        d.setName(name);
        d.setOrg(org);
        d.setStart(start);
        d.setEnd(end);
        d.setDesc(desc);
        return d;
    }

    private CertificateDto cert(String name, String issuer, String got) {
        CertificateDto d = new CertificateDto();
        d.setName(name);
        d.setIssuer(issuer);
        d.setGot(got);
        return d;
    }

    private AwardDto award(String name, String org, String year, String desc) {
        AwardDto d = new AwardDto();
        d.setName(name);
        d.setOrg(org);
        d.setYear(year);
        d.setDesc(desc);
        return d;
    }

    private OverseasDto overseas(String country, String start, String end, String desc) {
        OverseasDto d = new OverseasDto();
        d.setCountry(country);
        d.setStart(start);
        d.setEnd(end);
        d.setDesc(desc);
        return d;
    }

    private LanguageDto lang(String langName, String speak, String testName, String testScore) {
        LanguageDto d = new LanguageDto();
        d.setLang(langName);
        d.setSpeak(speak);
        d.setTestName(testName);
        d.setTestScore(testScore);
        return d;
    }

    // ============================ sessionStorage 페이로드 ============================
    private Map<String, Object> curSit(String empType) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("empType", empType);
        m.put("prefs", new ArrayList<String>());
        return m;
    }

    private Map<String, Object> goal(String industry, String job, List<String> regions, List<String> employment) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("industry", industry);
        m.put("job", job);
        m.put("regions", regions);
        m.put("employment", employment);
        m.put("targets", new ArrayList<Object>());
        return m;
    }

    private Map<String, Object> payload(String persona, Map<String, Object> curSit,
                                       Map<String, Object> careerGoal, Map<String, Object> careerGrowth,
                                       String concern) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("persona", persona);
        m.put("currentSituation", curSit);
        m.put("careerGoal", careerGoal);     // 페르소나 4 는 null
        m.put("careerGrowth", careerGrowth); // 페르소나 1~3 은 null
        m.put("concern", concern);
        return m;
    }

    // ============================ 세부 고민 (per*.md 원문) ============================
    private static final String CONCERN1 =
            "AI와 보안을 함께 전공했지만, 신입으로 AI 보안 연구개발직에 지원할 때 보안 도메인 지식과 머신러닝 역량 중 어느 쪽을 전면에 내세워야 할지 확신이 서지 않습니다. "
            + "연구개발직은 석박사 논문 실적을 많이 보는데, 석사 신입으로서 연구 경험을 실무 역량으로 어떻게 번역해 어필할지 고민입니다. "
            + "주변에 여성 보안 연구자 롤모델이 적어 진로 방향을 잡기도 어렵습니다.";

    private static final String CONCERN2 =
            "정밀화학 생산기술 경력 7년을 쌓았지만, 화학에서 바이오 분야로 이직하려니 실무에서 바이오 공정(세포배양·정제)을 직접 다뤄본 경험이 없어 교육 수준에 머물러 있습니다. "
            + "화학 공정에서 쌓은 스케일업·수율 개선 역량을 바이오 시장이 요구하는 기술직 언어로 어떻게 재번역해야 할지 막막합니다. "
            + "화학 경력이 바이오 기술직에서 오히려 강점으로 읽히도록 이력을 어떻게 재구성해야 할지 고민입니다.";

    private static final String CONCERN3 =
            "출산과 육아로 3년간 현업을 떠나 있어, 그사이 미세화된 공정과 최신 계측·분석 장비 감각이 뒤처졌을까 두렵습니다. "
            + "이전 8년간 쌓은 소자 특성 평가와 실험 데이터 관리 역량을 어떻게 다시 전면에 내세워야 할지 막막합니다. "
            + "면접에서 3년 공백을 '단절'이 아닌 '재교육기'로 방어할 논리가 필요합니다. "
            + "육아를 병행해야 해서 시간선택제로도 반도체 연구지원직 복귀가 현실적인지 고민입니다.";

    private static final String CONCERN4 =
            "지금까지는 설계 전문성과 연구 성과(논문·특허)로 인정받아 왔으나, 이번에 연구소 상위 보직 승진 대상자가 되었습니다. "
            + "뛰어난 실무자가 관리자로 넘어갈 때 흔히 겪는 '플레이어의 함정'에 빠져 설계를 계속 직접 붙잡을까 봐 걱정입니다. "
            + "남성 연구원이 다수인 조직에서 부드럽지만 결단력 있는 리더십을 어떻게 구축할지 막막합니다. "
            + "곧 있을 리더십 다면평가에서 저의 조직 관리 역량을 R&D 성과 지표로 어떻게 정량 증명할지 전략이 필요합니다.";

    // ============================ 자기소개서 본문 (per*.md 원문) ============================
    private static final String COVER1 =
            "사이버국방과 정보보호를 전공하며, 보안은 규칙을 쌓는 일이 아니라 끊임없이 진화하는 공격자와의 지적 대결임을 배웠습니다. "
            + "특히 머신러닝 모델 자체가 적대적 공격의 표적이 될 수 있다는 점에 매료되어 AI와 보안의 교집합을 연구 주제로 삼았습니다.\n\n"
            + "시큐어링크 연구 인턴으로 악성코드 탐지 모델을 다루며, 탐지율만 높은 모델이 실제로는 회피 공격에 얼마나 취약한지 실험으로 확인했습니다. "
            + "오탐을 줄이면서도 적대적 예제에 강건한 모델을 만드는 것이 진짜 연구 과제임을 체감했습니다.\n\n"
            + "단순히 최신 모델을 적용하는 것을 넘어, 위협 모델을 스스로 정의하고 방어 성능을 정직하게 평가할 줄 아는 연구개발자가 되고 싶습니다. "
            + "실제 위협 환경에서 신뢰할 수 있는 AI 보안 기술을 만드는 것이 목표입니다.";

    private static final String COVER2 =
            "7년간 정밀화학 소재의 생산기술을 담당하며, 좋은 반응식이 곧 좋은 공정은 아니라는 것을 현장에서 배웠습니다. "
            + "그램 단위 실험을 톤 단위 생산으로 옮기는 스케일업 과정에서 온도·체류시간·촉매 조건을 다투며 수율과 품질을 함께 끌어올리는 일에 강점을 쌓았습니다.\n\n"
            + "최근 바이오 의약품 공정이 화학 합성 공정과 맞닿는 지점에 관심을 갖고 GMP·바이오공정 교육을 이수했습니다. "
            + "화학 공정에서 검증한 스케일업과 공정 최적화 역량이 바이오 소재·원료의약품(API) 생산기술로도 확장될 수 있다는 확신을 얻었습니다.\n\n"
            + "정밀화학에서 쌓은 생산기술 역량 위에 바이오 공정 지식을 더해, 화학·바이오 소재의 안정적 양산을 책임지는 기술직 엔지니어로 커리어를 확장하고자 합니다.";

    private static final String COVER3 =
            "소자개발팀에서 8년간 DRAM 소자의 특성 평가와 신뢰성 분석 데이터를 관리하며, 수많은 실험 데이터를 표준화하고 공정-소자 상관을 리포트로 엮는 일에 강점을 쌓았습니다. "
            + "측정 장비를 운용하고 데이터 품질을 책임지는 연구지원 실무가 연구의 신뢰성을 떠받친다는 것을 현장에서 배웠습니다.\n\n"
            + "출산·육아로 인한 3년의 공백기에도 반도체 분야에서 손을 놓지 않았습니다. "
            + "WISET 경력복귀 재교육과 계측·분석 실무 재교육을 이수하며 미세화된 공정과 최신 계측 기법을 따라잡았습니다.\n\n"
            + "검증된 소자 평가·데이터 관리 역량 위에 최신 계측 감각을 더해, 시간선택제로도 실험 데이터 품질과 분석을 책임지는 연구지원직으로 즉시 기여할 준비가 되어 있습니다.";

    private static final String COVER4 =
            "11년간 산업용 공조·열교환 시스템의 R&D를 담당하며 설계·검증·양산이관 전 과정을 책임졌고, 논문과 특허로 전문성을 인정받았습니다. "
            + "최근 3년은 개인 성과를 넘어 연구 과제의 일정·예산을 관리하고 타 부서와의 기술 커뮤니케이션을 조율하는 역할을 해왔습니다.\n\n"
            + "이제 연구소 상위 보직으로서, 제가 잘하던 '직접 설계하는 일'에서 '팀이 더 좋은 설계를 하게 하는 일'로 중심을 옮기려 합니다. "
            + "연구원들의 자율성과 과제 일정을 함께 지키고, 부드럽지만 결단력 있는 리더십으로 팀의 성과를 정량으로 증명하는 관리자가 되고자 합니다.";
}

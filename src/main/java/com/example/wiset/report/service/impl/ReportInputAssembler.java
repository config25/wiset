package com.example.wiset.report.service.impl;

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
import com.example.wiset.dto.ai.GenerationInputs;
import com.example.wiset.stage.service.impl.CurrentSituationServiceImpl;
import com.example.wiset.support.CommonDAO;
import com.example.wiset.support.CurrentUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 저장된 사용자 데이터(현황/경력/자격/어학/자소서/희망직무/고민) → AI 입력 텍스트 조립.
 *   targetRole       ← 희망 업종·직무
 *   resumeText       ← 학력(+학점)+경력(+연봉)+자격+어학+논문+활동+교육+수상+해외
 *   unstructuredData ← resumeText + 자기소개서 제목·본문 + 포트폴리오 URL
 *   userProfile      ← 페르소나 + 신입/경력 + 희망 업종·직무 + 희망 근무지·고용형태 + 취업우대 + 경력성장 목표(페르소나4) + 고민
 *   consultingLog    ← 1:1 커리어컨설팅 Q&A + 세부 고민
 */
// [wbridge] @Mapper 제거 → CommonDAO(mypage.scrap.*) 이식. DTO 유지.
@Service
public class ReportInputAssembler {

    private static final Logger log = LoggerFactory.getLogger(ReportInputAssembler.class);

    private final CurrentSituationServiceImpl situation;
    private final CommonDAO commonDAO;

    public ReportInputAssembler(CurrentSituationServiceImpl situation, CommonDAO commonDAO) {
        this.situation = situation;
        this.commonDAO = commonDAO;
    }

    public GenerationInputs assemble() throws Exception {
        long u = CurrentUser.userSn();
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", u);
        String industry = blankToNull((String) commonDAO.selectOne("mypage.scrap.findDesiredIndustry", p));
        String job = blankToNull((String) commonDAO.selectOne("mypage.scrap.findDesiredJob", p));
        String concern = blankToNull((String) commonDAO.selectOne("mypage.scrap.findLatestConcern", p));

        // 프로필 선택값(신입/경력 + 취업우대 prefs) — 한 번만 조회
        Map<String, Object> sel = situation.getProfileSelections();
        String empType = str(sel.get("empType")); // 신입/경력/""
        List<?> prefs = (sel.get("prefs") instanceof List) ? (List<?>) sel.get("prefs") : java.util.Collections.emptyList();

        // 희망 근무지 · 고용형태 · 페르소나 · 경력성장 목표(페르소나4) — AI 입력 보강
        List<String> regions = commonDAO.selectList("mypage.scrap.listDesiredRegions", p);
        List<String> employment = commonDAO.selectList("mypage.scrap.listDesiredEmployment", p);
        Integer persona = commonDAO.selectOne("stage.analysis.findPersonaCode", p);
        Map<String, Object> growth = commonDAO.selectOne("stage.analysis.findGrowthGoal", p);
        List<String> growthSkills = commonDAO.selectList("stage.analysis.findGrowthSkills", p);

        String resumeText = buildResume();
        Map<String, Object> cover = situation.getCover();
        String coverContent = str(cover.get("content"));
        String coverTitle = str(cover.get("title"));

        GenerationInputs in = new GenerationInputs();
        // 희망 업종/직무 → "[업종 - 직무]". 페르소나4(경력성장)는 희망직무가 없으니 '목표 보직'으로 대체
        //   (type1 역량평가는 target_role 이 비면 실패 → 페르소나4도 평가 기준이 들어가도록).
        String targetRole = buildTargetRole(industry, job);
        if (targetRole == null && growth != null) {
            String goalRole = blankToNull(str(growth.get("targetRole")));
            if (goalRole != null) targetRole = goalRole;
        }
        
        if("정보통신 관련직".equals(targetRole)) {
            targetRole = "AI 정보보안";
        } else if ("생명 및 자연과학 관련직".equals(targetRole) || "화학/식품가공 관련직".equals(targetRole)) {
            targetRole = "화학바이오";
        } else if ("전기/전자 관련직".equals(targetRole)) {
            targetRole = "반도체";
        }else {
            targetRole = "일반산업";
        }

        in.setTargetRole(targetRole);
        in.setResumeText(resumeText);
        in.setUnstructuredData(buildUnstructured(resumeText, coverContent, coverTitle));
        in.setUserProfile(buildProfile(persona, empType, industry, job, concern, regions, employment, prefs, growth, growthSkills));
        // 1:1 커리어컨설팅 Q&A(완료+답변, TN_CNSL_REQST_INFO) + 세부 고민 → AI 입력(consultingLog). DB 에서 직접 조립.
        List<Map<String, Object>> cnslQna = commonDAO.selectList("indvdl.cnsl.selectCnslQnaListByUser", p);
        in.setConsultingLog(buildConsultingLog(cnslQna, concern));
        in.setExperienceLevel(empType.isEmpty() ? null : empType);
        log.info("[입력조립] user={} — 희망={}, 신입경력={}, 이력서 {}자, 자소서 {}자, 근무지 {}, 고용형태 {}, 경력성장 {}, 고민={}",
                u, in.getTargetRole(), empType.isEmpty() ? "미선택" : empType,
                resumeText == null ? 0 : resumeText.length(),
                coverContent == null ? 0 : coverContent.length(),
                regions == null ? 0 : regions.size(), employment == null ? 0 : employment.size(),
                growth != null && !growth.isEmpty(), concern != null);
        return in;
    }

    /**
     * 1:1 커리어컨설팅 Q&A(완료+답변) + 세부 고민 → AI 입력용 consultingLog 텍스트. 둘 다 없으면 null.
     * 컬럼키 대문자(QUESTION/ANSWER/CNSL_COMPT_DE). 항목별 과대입력 방지로 Q/A 각 1000자 캡.
     */
    private String buildConsultingLog(List<Map<String, Object>> qna, String concern) {
        StringBuilder sb = new StringBuilder();
        if (qna != null && !qna.isEmpty()) {
            sb.append("[1:1 커리어컨설팅 이력 ").append(qna.size()).append("건]");
            int i = 1;
            for (Map<String, Object> r : qna) {
                String q = clean(str(r.get("QUESTION")));
                String a = clean(str(r.get("ANSWER")));
                if (q.isEmpty() && a.isEmpty()) continue;
                String date = clean(str(r.get("CNSL_COMPT_DE")));
                sb.append("\n\n").append(i++).append(". ");
                if (!date.isEmpty()) sb.append("(").append(date).append(")");
                if (!q.isEmpty()) sb.append("\n  Q: ").append(cap(q, 1000));
                if (!a.isEmpty()) sb.append("\n  A: ").append(cap(a, 1000));
            }
        }
        if (concern != null) {
            sb.append(sb.length() > 0 ? "\n\n" : "").append("[세부 고민] ").append(concern);
        }
        return sb.length() == 0 ? null : sb.toString();
    }

    private static String clean(String s) { return s == null ? "" : s.replaceAll("\\s+", " ").trim(); }
    private static String cap(String s, int n) { return s.length() > n ? s.substring(0, n) + "…" : s; }

    private String buildTargetRole(String industry, String job) {
        if (industry == null && job == null) return null;
        return "[" + (industry == null ? "" : industry) + " - " + (job == null ? "" : job) + "]";
    }

    private String buildProfile(Integer persona, String empType, String industry, String job, String concern,
                                List<String> regions, List<String> employment, List<?> prefs,
                                Map<String, Object> growth, List<String> growthSkills) {
        StringBuilder sb = new StringBuilder();
        String pName = personaLabel(persona);
        if (pName != null) sb.append("페르소나: ").append(pName).append(". ");
        if (!empType.isEmpty()) sb.append(empType).append(". ");
        if (industry != null) sb.append(industry).append(" 산업 희망. ");
        if (job != null) sb.append(job).append(" 직무 희망. ");
        if (regions != null && !regions.isEmpty()) sb.append("희망 근무지: ").append(joinComma(regions)).append(". ");
        if (employment != null && !employment.isEmpty()) sb.append("희망 고용형태: ").append(joinComma(employment)).append(". ");
        if (prefs != null && !prefs.isEmpty()) sb.append("취업우대/조건: ").append(joinComma(prefs)).append(". ");
        // 경력성장 목표(페르소나4)
        if (growth != null && !growth.isEmpty()) {
            StringBuilder g = new StringBuilder();
            kv(g, "목표 보직", str(growth.get("targetRole")));
            kv(g, "현재 직급", str(growth.get("rankName")));
            String yrs = str(growth.get("years"));
            if (!yrs.isEmpty()) kv(g, "연차", yrs + "년");
            kv(g, "현재 담당업무", str(growth.get("duties")));
            kv(g, "목표 처우", str(growth.get("targetPay")));
            kv(g, "평가요소", str(growth.get("evalName")));
            if (growthSkills != null && !growthSkills.isEmpty()) kv(g, "강화역량", joinComma(growthSkills));
            if (g.length() > 0) sb.append("경력성장 목표(").append(g).append("). ");
        }
        if (concern != null) sb.append("세부 고민: ").append(concern);
        String out = sb.toString().trim();
        return out.isEmpty() ? null : out;
    }

    /** persona_code → 표시명. */
    private static String personaLabel(Integer code) {
        if (code == null) return null;
        switch (code) {
            case 1: return "신규 취업";
            case 2: return "이직 준비";
            case 3: return "재취업";
            case 4: return "승진·보직 희망";
            default: return null;
        }
    }

    /** "라벨: 값; " 누적(값 비면 생략). */
    private static void kv(StringBuilder sb, String label, String value) {
        if (value == null || value.trim().isEmpty()) return;
        sb.append(sb.length() > 0 ? "; " : "").append(label).append(": ").append(value.trim());
    }

    private static String joinComma(List<?> list) {
        StringBuilder sb = new StringBuilder();
        for (Object o : list) {
            String s = str(o).trim();
            if (!s.isEmpty()) sb.append(sb.length() > 0 ? ", " : "").append(s);
        }
        return sb.toString();
    }

    private String buildUnstructured(String resumeText, String coverContent, String coverTitle) throws Exception {
        StringBuilder sb = new StringBuilder();
        if (resumeText != null) sb.append(resumeText);
        if (coverContent != null && !coverContent.isEmpty()) {
            sb.append(sb.length() > 0 ? "\n\n" : "").append("[자기소개서]");
            if (notBlank(coverTitle)) sb.append(" 제목: ").append(coverTitle.trim());
            sb.append("\n").append(coverContent);
        }
        String urls = joinPortfolioUrls();
        if (urls != null) sb.append(sb.length() > 0 ? "\n\n" : "").append("[포트폴리오]\n").append(urls);
        return sb.length() == 0 ? null : sb.toString();
    }

    /** 이력서 텍스트(학력~해외경험). 비면 null. */
    private String buildResume() throws Exception {
        StringBuilder sb = new StringBuilder();

        List<EducationDto> edus = situation.listEducation();
        if (!edus.isEmpty()) {
            sb.append("[학력]");
            for (EducationDto e : edus) {
                sb.append("\n- ").append(joinDot(e.getSeLabel(), e.getSchoolName(), e.getMajorName()));
                String grad = joinSpace(e.getGraduationYm(), e.getGradStatusLabel());
                if (!grad.isEmpty()) sb.append(" (").append(grad).append(")");
                if (notBlank(e.getGpa())) sb.append(" · 학점 ").append(e.getGpa().trim())
                        .append(notBlank(e.getTotalGpa()) ? ("/" + e.getTotalGpa().trim()) : "");
                if (notBlank(e.getThesis())) sb.append(" · 논문: ").append(e.getThesis().trim());
            }
        }

        List<CareerDto> careers = situation.listCareer();
        if (!careers.isEmpty()) {
            section(sb, "[경력]");
            for (CareerDto c : careers) {
                sb.append("\n- ").append(joinDot(c.getCompanyName(), c.getDeptName(), c.getPosition(), c.getJobField()));
                String period = period(c.getStartYm(), c.getEndYm());
                if (!period.isEmpty()) sb.append(" (").append(period).append(")");
                if (notBlank(c.getSalary())) sb.append(" · 연봉 ").append(c.getSalary().trim());
                if (notBlank(c.getJobDescription())) sb.append(": ").append(c.getJobDescription().trim());
            }
        }

        List<ResearchDto> research = situation.listResearch();
        if (!research.isEmpty()) {
            section(sb, "[논문·연구]");
            for (ResearchDto r : research) if (notBlank(r.getContent())) sb.append("\n- ").append(r.getContent().trim());
        }

        List<CertificateDto> certs = situation.listCertificate();
        if (!certs.isEmpty()) {
            section(sb, "[자격증]");
            for (CertificateDto c : certs) sb.append("\n- ").append(joinDot(c.getName(), c.getIssuer(), c.getGot()));
        }

        List<LanguageDto> langs = situation.listLanguage();
        if (!langs.isEmpty()) {
            section(sb, "[어학]");
            for (LanguageDto l : langs) {
                String name = notBlank(l.getLang()) ? l.getLang() : l.getManual();
                sb.append("\n- ").append(joinDot(name, l.getSpeak(), joinSpace(l.getTestName(), l.getTestScore())));
            }
        }

        List<ActivityDto> acts = situation.listActivity();
        if (!acts.isEmpty()) {
            section(sb, "[인턴·대외활동]");
            for (ActivityDto a : acts) {
                sb.append("\n- ").append(joinDot(a.getKind(), a.getOrg()));
                String period = period(a.getStart(), a.getEnd());
                if (!period.isEmpty()) sb.append(" (").append(period).append(")");
                if (notBlank(a.getDesc())) sb.append(": ").append(a.getDesc().trim());
            }
        }

        List<TrainingDto> trainings = situation.listTraining();
        if (!trainings.isEmpty()) {
            section(sb, "[교육이수]");
            for (TrainingDto t : trainings) sb.append("\n- ").append(joinDot(t.getName(), t.getOrg()));
        }

        List<AwardDto> awards = situation.listAward();
        if (!awards.isEmpty()) {
            section(sb, "[수상]");
            for (AwardDto a : awards) sb.append("\n- ").append(joinDot(a.getName(), a.getOrg(), a.getYear()));
        }

        List<OverseasDto> overseas = situation.listOverseas();
        if (!overseas.isEmpty()) {
            section(sb, "[해외경험]");
            for (OverseasDto o : overseas) {
                sb.append("\n- ").append(o.getCountry() == null ? "" : o.getCountry());
                String period = period(o.getStart(), o.getEnd());
                if (!period.isEmpty()) sb.append(" (").append(period).append(")");
            }
        }

        return sb.length() == 0 ? null : sb.toString();
    }

    private String joinPortfolioUrls() throws Exception {
        Object urlsObj = situation.getPortfolio().get("urls");
        if (!(urlsObj instanceof List)) return null;
        StringBuilder sb = new StringBuilder();
        for (Object o : (List<?>) urlsObj) {
            if (o instanceof PortfolioUrlDto) {
                String u = ((PortfolioUrlDto) o).getUrl();
                if (notBlank(u)) sb.append(sb.length() > 0 ? "\n" : "").append("- ").append(u.trim());
            }
        }
        return sb.length() == 0 ? null : sb.toString();
    }

    // ---------- helpers ----------
    private static void section(StringBuilder sb, String header) {
        sb.append(sb.length() > 0 ? "\n\n" : "").append(header);
    }
    private static String period(String start, String end) {
        String s = blankToNull(start), e = blankToNull(end);
        if (s == null && e == null) return "";
        return (s == null ? "" : s) + "~" + (e == null ? "" : e);
    }
    private static String joinDot(String... parts) { return joinWith(" · ", parts); }
    private static String joinSpace(String... parts) { return joinWith(" ", parts); }
    private static String joinWith(String sep, String... parts) {
        StringBuilder sb = new StringBuilder();
        for (String p : parts) {
            if (notBlank(p)) sb.append(sb.length() > 0 ? sep : "").append(p.trim());
        }
        return sb.toString();
    }
    private static boolean notBlank(String s) { return s != null && !s.trim().isEmpty(); }
    private static String blankToNull(String s) { return notBlank(s) ? s.trim() : null; }
    private static String str(Object o) { return o == null ? "" : o.toString(); }
}

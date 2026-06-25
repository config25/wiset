package com.example.wiset.service;

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
import com.example.wiset.mapper.ScrapMapper;
import com.example.wiset.support.CurrentUser;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * 저장된 사용자 데이터(현황/경력/자격/어학/자소서/희망직무/고민) → AI 입력 텍스트 조립.
 *   targetRole       ← 희망 업종·직무
 *   resumeText       ← 학력+경력+자격+어학+논문+활동+교육+수상+해외
 *   unstructuredData ← resumeText + 자기소개서 본문 + 포트폴리오 URL
 *   userProfile      ← 신입/경력 + 희망 업종·직무 + 고민 요약
 *   consultingLog    ← 세부 고민(질문)
 */
@Slf4j
@Service
public class ReportInputAssembler {

    private final CurrentSituationService situation;
    private final ScrapMapper scrapMapper;

    public ReportInputAssembler(CurrentSituationService situation, ScrapMapper scrapMapper) {
        this.situation = situation;
        this.scrapMapper = scrapMapper;
    }

    public GenerationInputs assemble() {
        long u = CurrentUser.userSn();
        String industry = blankToNull(scrapMapper.findDesiredIndustry(u));
        String job = blankToNull(scrapMapper.findDesiredJob(u));
        String concern = blankToNull(scrapMapper.findLatestConcern(u));
        String empType = str((String) situation.getProfileSelections().get("empType")); // 신입/경력/""

        String resumeText = buildResume();
        String coverContent = str((String) situation.getCover().get("content"));

        GenerationInputs in = new GenerationInputs();
        in.setTargetRole(buildTargetRole(industry, job));
        in.setResumeText(resumeText);
        in.setUnstructuredData(buildUnstructured(resumeText, coverContent));
        in.setUserProfile(buildProfile(empType, industry, job, concern));
        in.setConsultingLog(concern == null ? null : "질문: " + concern);
        in.setExperienceLevel(empType.isEmpty() ? null : empType);
        log.info("[입력조립] user={} — 희망={}, 신입경력={}, 이력서 {}자, 자소서 {}자, 고민={}",
                u, in.getTargetRole(), empType.isEmpty() ? "미선택" : empType,
                resumeText == null ? 0 : resumeText.length(),
                coverContent == null ? 0 : coverContent.length(), concern != null);
        return in;
    }

    private String buildTargetRole(String industry, String job) {
        if (industry == null && job == null) return null;
        return "[" + (industry == null ? "" : industry) + " - " + (job == null ? "" : job) + "]";
    }

    private String buildProfile(String empType, String industry, String job, String concern) {
        StringBuilder sb = new StringBuilder();
        if (!empType.isEmpty()) sb.append(empType);
        if (industry != null) sb.append(sb.length() > 0 ? ", " : "").append(industry).append(" 산업 희망");
        if (job != null) sb.append(sb.length() > 0 ? ", " : "").append(job).append(" 직무 희망");
        if (concern != null) sb.append(sb.length() > 0 ? ". " : "").append("세부 고민: ").append(concern);
        return sb.length() == 0 ? null : sb.toString();
    }

    private String buildUnstructured(String resumeText, String coverContent) {
        StringBuilder sb = new StringBuilder();
        if (resumeText != null) sb.append(resumeText);
        if (coverContent != null && !coverContent.isEmpty()) {
            sb.append(sb.length() > 0 ? "\n\n" : "").append("[자기소개서]\n").append(coverContent);
        }
        String urls = joinPortfolioUrls();
        if (urls != null) sb.append(sb.length() > 0 ? "\n\n" : "").append("[포트폴리오]\n").append(urls);
        return sb.length() == 0 ? null : sb.toString();
    }

    /** 이력서 텍스트(학력~해외경험). 비면 null. */
    private String buildResume() {
        StringBuilder sb = new StringBuilder();

        List<EducationDto> edus = situation.listEducation();
        if (!edus.isEmpty()) {
            sb.append("[학력]");
            for (EducationDto e : edus) {
                sb.append("\n- ").append(joinDot(e.getSeLabel(), e.getSchoolName(), e.getMajorName()));
                String grad = joinSpace(e.getGraduationYm(), e.getGradStatusLabel());
                if (!grad.isEmpty()) sb.append(" (").append(grad).append(")");
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

    private String joinPortfolioUrls() {
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

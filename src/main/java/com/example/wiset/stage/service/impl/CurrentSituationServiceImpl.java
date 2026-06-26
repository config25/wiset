package com.example.wiset.stage.service.impl;

import com.example.wiset.dto.ActivityDto;
import com.example.wiset.dto.AwardDto;
import com.example.wiset.dto.CareerDto;
import com.example.wiset.dto.CertificateDto;
import com.example.wiset.dto.EducationDto;
import com.example.wiset.dto.LanguageDto;
import com.example.wiset.dto.OverseasDto;
import com.example.wiset.dto.PortfolioFileDto;
import com.example.wiset.dto.PortfolioUrlDto;
import com.example.wiset.dto.ResearchDto;
import com.example.wiset.dto.SelfIntroDto;
import com.example.wiset.dto.TrainingDto;
import com.example.wiset.support.CommonDAO;
import com.example.wiset.support.CurrentUser;
import com.example.wiset.support.ResumeCodeMap;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 03 현 상황 입력 - 학력/경력 저장 (팝업 즉시저장).
 *   학력 = TN_RESUME_ACDMCR + sys_education 델타, 경력 = TN_RESUME_CAREER.
 *   사용자의 TN_RESUME(헤더)가 없으면 자동 생성한다.
 *   // [wbridge] @Mapper 제거 → CommonDAO(mypage.resume.*) 이식. DTO 유지.
 */
@Service
public class CurrentSituationServiceImpl {

    private final CommonDAO commonDAO;

    /** 업로드 저장 루트 (application.properties: app.upload.dir) */
    @Value("${app.upload.dir}")
    private String uploadDir;

    public CurrentSituationServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    /** 현재 사용자의 이력서 헤더 RESUME_SN 확보(없으면 생성) */
    private long ensureResumeSn() throws Exception {
        long userSn = CurrentUser.userSn();
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", userSn);
        Long sn = commonDAO.selectOne("mypage.resume.findResumeSn", p);
        if (sn != null) {
            return sn;
        }
        long created = commonDAO.selectOne("mypage.resume.nextResumeSn");
        Map<String, Object> ph = new HashMap<>();
        ph.put("resumeSn", created);
        ph.put("userSn", userSn);
        ph.put("reg", CurrentUser.userId());
        commonDAO.insert("mypage.resume.insertResumeHeader", ph);
        return created;
    }

    // ------------------- 현 상황 화면 재진입 복원 (신입/경력 + 취업우대·병역) -------------------

    /**
     * 최종제출(분석 시작) 때 저장된 신입/경력·우대 선택을 화면 재진입 시 복원.
     *   empType: career_level_sel(NULL=미선택) → '신입'/'경력' / 없으면 빈 문자열
     *   prefs:   sys_user_type ∩ JOB_PREFERENCE 라벨 목록(미선택이면 빈 배열)
     */
    public Map<String, Object> getProfileSelections() throws Exception {
        long userSn = CurrentUser.userSn();
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", userSn);
        Integer sel = commonDAO.selectOne("mypage.resume.findCareerLevelSel", p);
        String empType = sel == null ? "" : (sel == 1 ? "신입" : sel == 2 ? "경력" : "");
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("empType", empType);
        m.put("prefs", commonDAO.selectList("mypage.resume.listJobPreferences", p));
        return m;
    }

    // ----------------------------- 학력 -----------------------------

    @Transactional
    public EducationDto saveEducation(EducationDto d) throws Exception {
        long resumeSn = ensureResumeSn();
        String reg = CurrentUser.userId();
        String seCode = ResumeCodeMap.acdmcrSeCode(d.getSeLabel());
        String gradCode = ResumeCodeMap.gradStatusCode(d.getGradStatusLabel());

        // NOT NULL/타입 보호
        d.setSchoolName(nz(d.getSchoolName()));
        d.setGpa(blankToNull(d.getGpa()));
        d.setTotalGpa(blankToNull(d.getTotalGpa()));

        if (d.getAcdmcrSn() == null) {
            d.setAcdmcrSn(commonDAO.selectOne("mypage.resume.nextAcdmcrSn"));
            Map<String, Object> p = new HashMap<>();
            p.put("d", d);
            p.put("resumeSn", resumeSn);
            p.put("seCode", seCode);
            p.put("reg", reg);
            commonDAO.insert("mypage.resume.insertAcdmcr", p);
        } else {
            Map<String, Object> p = new HashMap<>();
            p.put("d", d);
            p.put("seCode", seCode);
            p.put("reg", reg);
            commonDAO.update("mypage.resume.updateAcdmcr", p);
        }
        Map<String, Object> pd = new HashMap<>();
        pd.put("acdmcrSn", d.getAcdmcrSn());
        pd.put("minorMajor", blankToNull(d.getMinorMajor()));
        pd.put("gradCode", gradCode);
        pd.put("isFinal", d.isFinal());
        commonDAO.update("mypage.resume.upsertEducationDelta", pd);
        return d;
    }

    @Transactional
    public void deleteEducation(long acdmcrSn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("acdmcrSn", acdmcrSn);
        commonDAO.delete("mypage.resume.deleteEducationDelta", p); // FK 자식 먼저
        commonDAO.delete("mypage.resume.deleteAcdmcr", p);
    }

    public List<EducationDto> listEducation() throws Exception {
        long resumeSn = ensureResumeSn();
        Map<String, Object> p = new HashMap<>();
        p.put("resumeSn", resumeSn);
        List<EducationDto> rows = commonDAO.selectList("mypage.resume.listEducation", p);
        for (EducationDto r : rows) {
            // 조회 시 seLabel/gradStatusLabel 에는 '코드'가 담겨오므로 라벨로 변환
            r.setSeLabel(ResumeCodeMap.acdmcrSeLabel(r.getSeLabel()));
            r.setGradStatusLabel(ResumeCodeMap.gradStatusLabel(r.getGradStatusLabel()));
        }
        return rows;
    }

    // ----------------------------- 경력 -----------------------------

    @Transactional
    public CareerDto saveCareer(CareerDto d) throws Exception {
        long resumeSn = ensureResumeSn();
        String reg = CurrentUser.userId();
        Long salary = parseMoney(d.getSalary());

        if (d.getCareerSn() == null) {
            d.setCareerSn(commonDAO.selectOne("mypage.resume.nextCareerSn"));
            Map<String, Object> p = new HashMap<>();
            p.put("d", d);
            p.put("resumeSn", resumeSn);
            p.put("salary", salary);
            p.put("reg", reg);
            commonDAO.insert("mypage.resume.insertCareer", p);
        } else {
            Map<String, Object> p = new HashMap<>();
            p.put("d", d);
            p.put("salary", salary);
            p.put("reg", reg);
            commonDAO.update("mypage.resume.updateCareer", p);
        }
        return d;
    }

    @Transactional
    public void deleteCareer(long careerSn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("careerSn", careerSn);
        commonDAO.delete("mypage.resume.deleteCareer", p);
    }

    public List<CareerDto> listCareer() throws Exception {
        long resumeSn = ensureResumeSn();
        Map<String, Object> p = new HashMap<>();
        p.put("resumeSn", resumeSn);
        return commonDAO.selectList("mypage.resume.listCareer", p);
    }

    // ===================== 추가정보 (목록 일괄저장 replace-all) =====================

    /** sys_user_* (research 등) FK 충족용 프로필 보장. persona/career_level 은 placeholder. */
    private void ensureUserProfile() throws Exception {
        long userSn = CurrentUser.userSn();
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", userSn);
        if (commonDAO.selectOne("mypage.resume.findUserProfile", p) == null) {
            commonDAO.insert("mypage.resume.insertUserProfilePlaceholder", p);
        }
    }

    // ---- 논문/연구 (sys_user_research) ----
    public List<ResearchDto> listResearch() throws Exception {
        ensureUserProfile();
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", CurrentUser.userSn());
        return commonDAO.selectList("mypage.resume.listResearch", p);
    }

    @Transactional
    public ResearchDto addResearch(ResearchDto d) throws Exception {
        ensureUserProfile();
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", CurrentUser.userSn());
        p.put("d", d);
        commonDAO.insert("mypage.resume.insertResearch", p); // d.researchId 채워짐(AUTO_INCREMENT)
        return d;
    }

    @Transactional
    public void deleteResearch(long researchId) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("researchId", researchId);
        commonDAO.delete("mypage.resume.deleteResearch", p);
    }

    // ---- 인턴·대외활동 (TN_RESUME_ACT) ----
    public List<ActivityDto> listActivity() throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("resumeSn", ensureResumeSn());
        List<ActivityDto> rows = commonDAO.selectList("mypage.resume.listActivity", p);
        for (ActivityDto r : rows) r.setKind(orRaw(ResumeCodeMap.actSeLabel(r.getKind()), r.getKind()));
        return rows;
    }

    @Transactional
    public ActivityDto addActivity(ActivityDto d) throws Exception {
        long resumeSn = ensureResumeSn();
        String seCode = ResumeCodeMap.actSeCode(d.getKind());
        if (seCode == null) seCode = "99";
        d.setActSn(commonDAO.selectOne("mypage.resume.nextActSn"));
        Map<String, Object> p = new HashMap<>();
        p.put("d", d);
        p.put("resumeSn", resumeSn);
        p.put("actSn", d.getActSn());
        p.put("seCode", seCode);
        p.put("startDate", ymToSqlDate(d.getStart()));
        p.put("endDate", ymToSqlDate(d.getEnd()));
        p.put("reg", CurrentUser.userId());
        commonDAO.insert("mypage.resume.insertActivity", p);
        return d;
    }

    @Transactional
    public void deleteActivity(long actSn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("actSn", actSn);
        commonDAO.delete("mypage.resume.deleteActivity", p);
    }

    // ---- 교육이수 (TN_RESUME_EDC) ----
    public List<TrainingDto> listTraining() throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("resumeSn", ensureResumeSn());
        return commonDAO.selectList("mypage.resume.listTraining", p);
    }

    @Transactional
    public TrainingDto addTraining(TrainingDto d) throws Exception {
        long resumeSn = ensureResumeSn();
        d.setEdcSn(commonDAO.selectOne("mypage.resume.nextEdcSn"));
        Map<String, Object> p = new HashMap<>();
        p.put("d", d);
        p.put("resumeSn", resumeSn);
        p.put("edcSn", d.getEdcSn());
        p.put("startDate", ymToSqlDate(d.getStart()));
        p.put("endDate", ymToSqlDate(d.getEnd()));
        p.put("reg", CurrentUser.userId());
        commonDAO.insert("mypage.resume.insertTraining", p);
        return d;
    }

    @Transactional
    public void deleteTraining(long edcSn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("edcSn", edcSn);
        commonDAO.delete("mypage.resume.deleteTraining", p);
    }

    // ---- 자격증 (TN_RESUME_CRQFC) ----
    public List<CertificateDto> listCertificate() throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("resumeSn", ensureResumeSn());
        return commonDAO.selectList("mypage.resume.listCertificate", p);
    }

    @Transactional
    public CertificateDto addCertificate(CertificateDto d) throws Exception {
        long resumeSn = ensureResumeSn();
        d.setName(nz(d.getName())); // CRQFC_NM NOT NULL
        d.setCrqfcSn(commonDAO.selectOne("mypage.resume.nextCrqfcSn"));
        Map<String, Object> p = new HashMap<>();
        p.put("d", d);
        p.put("resumeSn", resumeSn);
        p.put("crqfcSn", d.getCrqfcSn());
        p.put("acqsDate", ymToSqlDate(d.getGot()));
        p.put("reg", CurrentUser.userId());
        commonDAO.insert("mypage.resume.insertCertificate", p);
        return d;
    }

    @Transactional
    public void deleteCertificate(long crqfcSn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("crqfcSn", crqfcSn);
        commonDAO.delete("mypage.resume.deleteCertificate", p);
    }

    // ---- 수상 (TN_RESUME_WNPZ) ----
    public List<AwardDto> listAward() throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("resumeSn", ensureResumeSn());
        return commonDAO.selectList("mypage.resume.listAward", p);
    }

    @Transactional
    public AwardDto addAward(AwardDto d) throws Exception {
        long resumeSn = ensureResumeSn();
        d.setName(nz(d.getName())); // WNPZ_NM NOT NULL
        d.setWnpzSn(commonDAO.selectOne("mypage.resume.nextWnpzSn"));
        Map<String, Object> p = new HashMap<>();
        p.put("d", d);
        p.put("resumeSn", resumeSn);
        p.put("wnpzSn", d.getWnpzSn());
        p.put("reg", CurrentUser.userId());
        commonDAO.insert("mypage.resume.insertAward", p);
        return d;
    }

    @Transactional
    public void deleteAward(long wnpzSn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("wnpzSn", wnpzSn);
        commonDAO.delete("mypage.resume.deleteAward", p);
    }

    // ---- 해외경험 (TN_RESUME_OVSEA) ----
    public List<OverseasDto> listOverseas() throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("resumeSn", ensureResumeSn());
        return commonDAO.selectList("mypage.resume.listOverseas", p);
    }

    @Transactional
    public OverseasDto addOverseas(OverseasDto d) throws Exception {
        long resumeSn = ensureResumeSn();
        d.setOvseaSn(commonDAO.selectOne("mypage.resume.nextOvseaSn"));
        Map<String, Object> p = new HashMap<>();
        p.put("d", d);
        p.put("resumeSn", resumeSn);
        p.put("ovseaSn", d.getOvseaSn());
        p.put("reg", CurrentUser.userId());
        commonDAO.insert("mypage.resume.insertOverseas", p);
        return d;
    }

    @Transactional
    public void deleteOverseas(long ovseaSn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("ovseaSn", ovseaSn);
        commonDAO.delete("mypage.resume.deleteOverseas", p);
    }

    // ---- 어학 (TN_RESUME_LSTCS) ----
    public List<LanguageDto> listLanguage() throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("resumeSn", ensureResumeSn());
        List<LanguageDto> rows = commonDAO.selectList("mypage.resume.listLanguage", p);
        for (LanguageDto r : rows) r.setSpeak(orRaw(ResumeCodeMap.speakLabel(r.getSpeak()), r.getSpeak()));
        return rows;
    }

    @Transactional
    public LanguageDto addLanguage(LanguageDto d) throws Exception {
        long resumeSn = ensureResumeSn();
        String langName = "직접입력".equals(d.getLang()) ? d.getManual() : d.getLang();
        String ablty = ResumeCodeMap.speakCode(d.getSpeak());
        d.setLstcsSn(commonDAO.selectOne("mypage.resume.nextLstcsSn"));
        Map<String, Object> p = new HashMap<>();
        p.put("d", d);
        p.put("resumeSn", resumeSn);
        p.put("lstcsSn", d.getLstcsSn());
        p.put("langName", langName);
        p.put("ablty", ablty);
        p.put("reg", CurrentUser.userId());
        commonDAO.insert("mypage.resume.insertLanguage", p);
        return d;
    }

    @Transactional
    public void deleteLanguage(long lstcsSn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("lstcsSn", lstcsSn);
        commonDAO.delete("mypage.resume.deleteLanguage", p);
    }

    // ============ 첨부파일 공통 (TN_ATCH_FILE, FILE_ID = RESUME_SN, FILE_PATH = 용도) ============
    //   용도(portfolio/cover)는 FILE_PATH 로 구분 + 디스크 하위 디렉터리로도 사용.
    private static final String PORTFOLIO_SUBDIR = "portfolio";
    private static final String COVER_SUBDIR     = "cover";

    /** 파일 다건 업로드 → 디스크 저장 + TN_ATCH_FILE 기록 (호출자 트랜잭션 내). */
    private List<PortfolioFileDto> addFilesImpl(String path, MultipartFile[] files) throws Exception {
        long resumeSn = ensureResumeSn();
        if (files != null && files.length > 0) {
            Path dir = Paths.get(uploadDir, path);
            Files.createDirectories(dir);
            for (MultipartFile f : files) {
                if (f == null || f.isEmpty()) continue;
                String orig = f.getOriginalFilename();
                if (orig == null || orig.trim().isEmpty()) orig = "file";
                orig = Paths.get(orig).getFileName().toString(); // 경로 성분 제거(경로 조작 방지)
                String ext = "";
                int dot = orig.lastIndexOf('.');
                if (dot >= 0) ext = orig.substring(dot);
                String stre = UUID.randomUUID().toString().replace("-", "") + ext;
                // try-with-resources 로 입력 스트림을 반드시 닫는다(Windows 멀티파트 임시파일 잠금 방지).
                try (java.io.InputStream in = f.getInputStream()) {
                    Files.copy(in, dir.resolve(stre), StandardCopyOption.REPLACE_EXISTING);
                }
                Map<String, Object> p = new HashMap<>();
                p.put("fileId", resumeSn);
                p.put("path", path);
                p.put("orgNm", orig);
                p.put("streNm", stre);
                p.put("size", f.getSize());
                p.put("reg", CurrentUser.userId());
                commonDAO.insert("mypage.resume.insertAtchFile", p);
            }
        }
        Map<String, Object> p = new HashMap<>();
        p.put("fileId", resumeSn);
        p.put("path", path);
        return commonDAO.selectList("mypage.resume.listAtchFiles", p);
    }

    private void deleteFileImpl(String path, long fileSn) throws Exception {
        long resumeSn = ensureResumeSn();
        Map<String, Object> p = new HashMap<>();
        p.put("fileSn", fileSn);
        p.put("fileId", resumeSn);
        p.put("path", path);
        PortfolioFileDto f = commonDAO.selectOne("mypage.resume.findAtchFile", p); // 본인 소유 + 용도 일치만
        if (f == null) return;
        commonDAO.delete("mypage.resume.deleteAtchFile", p);
        try {
            Files.deleteIfExists(Paths.get(uploadDir, f.getPath(), f.getStreName()));
        } catch (IOException ignore) { /* 디스크 정리 실패는 무시(레코드는 삭제됨) */ }
    }

    /** 메타 → 실제 파일 리소스. 없거나 못 읽으면 null. */
    public Resource resolveAtchResource(PortfolioFileDto f) {
        if (f == null) return null;
        try {
            Path p = Paths.get(uploadDir, f.getPath(), f.getStreName());
            Resource r = new UrlResource(p.toUri());
            return (r.exists() && r.isReadable()) ? r : null;
        } catch (Exception e) {
            return null;
        }
    }

    // ------------------- 포트폴리오 (URL: TN_RESUME_PRTFOLIO_URL / 파일: TN_ATCH_FILE 'portfolio') -------------------

    /** 포트폴리오 URL+파일 일괄 조회 */
    public Map<String, Object> getPortfolio() throws Exception {
        long resumeSn = ensureResumeSn();
        Map<String, Object> m = new LinkedHashMap<>();
        Map<String, Object> pu = new HashMap<>();
        pu.put("resumeSn", resumeSn);
        m.put("urls", commonDAO.selectList("mypage.resume.listPortfolioUrls", pu));
        Map<String, Object> pf = new HashMap<>();
        pf.put("fileId", resumeSn);
        pf.put("path", PORTFOLIO_SUBDIR);
        m.put("files", commonDAO.selectList("mypage.resume.listAtchFiles", pf));
        return m;
    }

    @Transactional
    public PortfolioUrlDto addPortfolioUrl(String url) throws Exception {
        String u = blankToNull(url);
        if (u == null) throw new IllegalArgumentException("url is required");
        long resumeSn = ensureResumeSn();
        long sn = commonDAO.selectOne("mypage.resume.nextPrtfolioUrlSn");
        Map<String, Object> p = new HashMap<>();
        p.put("sn", sn);
        p.put("resumeSn", resumeSn);
        p.put("url", u);
        p.put("reg", CurrentUser.userId());
        commonDAO.insert("mypage.resume.insertPortfolioUrl", p);
        PortfolioUrlDto d = new PortfolioUrlDto();
        d.setSn(sn);
        d.setUrl(u);
        return d;
    }

    @Transactional
    public void deletePortfolioUrl(long sn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("sn", sn);
        p.put("resumeSn", ensureResumeSn());
        commonDAO.delete("mypage.resume.deletePortfolioUrl", p); // 소유권 가드 포함
    }

    @Transactional
    public List<PortfolioFileDto> addPortfolioFiles(MultipartFile[] files) throws Exception {
        return addFilesImpl(PORTFOLIO_SUBDIR, files);
    }

    @Transactional
    public void deletePortfolioFile(long fileSn) throws Exception {
        deleteFileImpl(PORTFOLIO_SUBDIR, fileSn);
    }

    /** 다운로드용 메타(본인 소유 + portfolio 한정). 없으면 null. */
    public PortfolioFileDto getPortfolioFileMeta(long fileSn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("fileSn", fileSn);
        p.put("fileId", ensureResumeSn());
        p.put("path", PORTFOLIO_SUBDIR);
        return commonDAO.selectOne("mypage.resume.findAtchFile", p);
    }

    // ------------------- 자기소개서 (텍스트: TN_RESUME_SELF_INTRCN / 파일: TN_ATCH_FILE 'cover') -------------------

    /** 자기소개서 제목+내용+파일 일괄 조회 */
    public Map<String, Object> getCover() throws Exception {
        long resumeSn = ensureResumeSn();
        Map<String, Object> ps = new HashMap<>();
        ps.put("resumeSn", resumeSn);
        SelfIntroDto s = commonDAO.selectOne("mypage.resume.findSelfIntro", ps);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("title", s != null ? s.getTitle() : null);
        m.put("content", s != null ? s.getContent() : null);
        Map<String, Object> pf = new HashMap<>();
        pf.put("fileId", resumeSn);
        pf.put("path", COVER_SUBDIR);
        m.put("files", commonDAO.selectList("mypage.resume.listAtchFiles", pf));
        return m;
    }

    /** 제목+내용 upsert (이력서당 1건) */
    @Transactional
    public void saveCoverText(String title, String content) throws Exception {
        long resumeSn = ensureResumeSn();
        Map<String, Object> ps = new HashMap<>();
        ps.put("resumeSn", resumeSn);
        SelfIntroDto s = commonDAO.selectOne("mypage.resume.findSelfIntro", ps);
        if (s != null) {
            Map<String, Object> p = new HashMap<>();
            p.put("sn", s.getSn());
            p.put("title", title);
            p.put("content", content);
            p.put("reg", CurrentUser.userId());
            commonDAO.update("mypage.resume.updateSelfIntro", p);
        } else {
            long sn = commonDAO.selectOne("mypage.resume.nextSelfIntrcnSn");
            Map<String, Object> p = new HashMap<>();
            p.put("sn", sn);
            p.put("resumeSn", resumeSn);
            p.put("title", title);
            p.put("content", content);
            p.put("reg", CurrentUser.userId());
            commonDAO.insert("mypage.resume.insertSelfIntro", p);
        }
    }

    @Transactional
    public List<PortfolioFileDto> addCoverFiles(MultipartFile[] files) throws Exception {
        return addFilesImpl(COVER_SUBDIR, files);
    }

    @Transactional
    public void deleteCoverFile(long fileSn) throws Exception {
        deleteFileImpl(COVER_SUBDIR, fileSn);
    }

    /** 다운로드용 메타(본인 소유 + cover 한정). 없으면 null. */
    public PortfolioFileDto getCoverFileMeta(long fileSn) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("fileSn", fileSn);
        p.put("fileId", ensureResumeSn());
        p.put("path", COVER_SUBDIR);
        return commonDAO.selectOne("mypage.resume.findAtchFile", p);
    }

    // ----------------------------- helpers -----------------------------

    private static String orRaw(String mapped, String raw) {
        return mapped != null ? mapped : raw;
    }

    /** 'YYYY.MM' / 'YYYY.MM.DD' -> SQL date 문자열(YYYY-MM-01 / YYYY-MM-DD). 빈값이면 null. */
    private static String ymToSqlDate(String s) {
        if (s == null) return null;
        String t = s.trim();
        if (t.isEmpty()) return null;
        t = t.replace('.', '-');
        if (t.split("-").length == 2) t = t + "-01";
        return t;
    }


    private static String nz(String s) {
        return s == null ? "" : s;
    }

    private static String blankToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }

    /** '40,000,000원' 같은 표기에서 숫자만 추출 → 연봉(원). 없으면 null. */
    private static Long parseMoney(String s) {
        if (s == null) return null;
        String digits = s.replaceAll("[^0-9]", "");
        return digits.isEmpty() ? null : Long.valueOf(digits);
    }
}

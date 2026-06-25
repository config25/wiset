package com.example.wiset.service;

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
import com.example.wiset.mapper.ResumeMapper;
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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * 03 현 상황 입력 - 학력/경력 저장 (팝업 즉시저장).
 *   학력 = TN_RESUME_ACDMCR + sys_education 델타, 경력 = TN_RESUME_CAREER.
 *   사용자의 TN_RESUME(헤더)가 없으면 자동 생성한다.
 */
@Service
public class CurrentSituationService {

    private final ResumeMapper mapper;

    /** 업로드 저장 루트 (application.properties: app.upload.dir) */
    @Value("${app.upload.dir}")
    private String uploadDir;

    public CurrentSituationService(ResumeMapper mapper) {
        this.mapper = mapper;
    }

    /** 현재 사용자의 이력서 헤더 RESUME_SN 확보(없으면 생성) */
    private long ensureResumeSn() {
        long userSn = CurrentUser.userSn();
        Long sn = mapper.findResumeSn(userSn);
        if (sn != null) {
            return sn;
        }
        long created = mapper.nextResumeSn();
        mapper.insertResumeHeader(created, userSn, CurrentUser.userId());
        return created;
    }

    // ------------------- 현 상황 화면 재진입 복원 (신입/경력 + 취업우대·병역) -------------------

    /**
     * 최종제출(분석 시작) 때 저장된 신입/경력·우대 선택을 화면 재진입 시 복원.
     *   empType: career_level_sel(NULL=미선택) → '신입'/'경력' / 없으면 빈 문자열
     *   prefs:   sys_user_type ∩ JOB_PREFERENCE 라벨 목록(미선택이면 빈 배열)
     */
    public Map<String, Object> getProfileSelections() {
        long userSn = CurrentUser.userSn();
        Integer sel = mapper.findCareerLevelSel(userSn);
        String empType = sel == null ? "" : (sel == 1 ? "신입" : sel == 2 ? "경력" : "");
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("empType", empType);
        m.put("prefs", mapper.listJobPreferences(userSn));
        return m;
    }

    // ----------------------------- 학력 -----------------------------

    @Transactional
    public EducationDto saveEducation(EducationDto d) {
        long resumeSn = ensureResumeSn();
        String reg = CurrentUser.userId();
        String seCode = ResumeCodeMap.acdmcrSeCode(d.getSeLabel());
        String gradCode = ResumeCodeMap.gradStatusCode(d.getGradStatusLabel());

        // NOT NULL/타입 보호
        d.setSchoolName(nz(d.getSchoolName()));
        d.setGpa(blankToNull(d.getGpa()));
        d.setTotalGpa(blankToNull(d.getTotalGpa()));

        if (d.getAcdmcrSn() == null) {
            d.setAcdmcrSn(mapper.nextAcdmcrSn());
            mapper.insertAcdmcr(d, resumeSn, seCode, reg);
        } else {
            mapper.updateAcdmcr(d, seCode, reg);
        }
        mapper.upsertEducationDelta(d.getAcdmcrSn(), blankToNull(d.getMinorMajor()), gradCode, d.isFinal());
        return d;
    }

    @Transactional
    public void deleteEducation(long acdmcrSn) {
        mapper.deleteEducationDelta(acdmcrSn); // FK 자식 먼저
        mapper.deleteAcdmcr(acdmcrSn);
    }

    public List<EducationDto> listEducation() {
        long resumeSn = ensureResumeSn();
        List<EducationDto> rows = mapper.listEducation(resumeSn);
        for (EducationDto r : rows) {
            // 조회 시 seLabel/gradStatusLabel 에는 '코드'가 담겨오므로 라벨로 변환
            r.setSeLabel(ResumeCodeMap.acdmcrSeLabel(r.getSeLabel()));
            r.setGradStatusLabel(ResumeCodeMap.gradStatusLabel(r.getGradStatusLabel()));
        }
        return rows;
    }

    // ----------------------------- 경력 -----------------------------

    @Transactional
    public CareerDto saveCareer(CareerDto d) {
        long resumeSn = ensureResumeSn();
        String reg = CurrentUser.userId();
        Long salary = parseMoney(d.getSalary());

        if (d.getCareerSn() == null) {
            d.setCareerSn(mapper.nextCareerSn());
            mapper.insertCareer(d, resumeSn, salary, reg);
        } else {
            mapper.updateCareer(d, salary, reg);
        }
        return d;
    }

    @Transactional
    public void deleteCareer(long careerSn) {
        mapper.deleteCareer(careerSn);
    }

    public List<CareerDto> listCareer() {
        long resumeSn = ensureResumeSn();
        return mapper.listCareer(resumeSn);
    }

    // ===================== 추가정보 (목록 일괄저장 replace-all) =====================

    /** sys_user_* (research 등) FK 충족용 프로필 보장. persona/career_level 은 placeholder. */
    private void ensureUserProfile() {
        long userSn = CurrentUser.userSn();
        if (mapper.findUserProfile(userSn) == null) {
            mapper.insertUserProfilePlaceholder(userSn);
        }
    }

    // ---- 논문/연구 (sys_user_research) ----
    public List<ResearchDto> listResearch() {
        ensureUserProfile();
        return mapper.listResearch(CurrentUser.userSn());
    }

    @Transactional
    public ResearchDto addResearch(ResearchDto d) {
        ensureUserProfile();
        mapper.insertResearch(CurrentUser.userSn(), d); // d.researchId 채워짐(AUTO_INCREMENT)
        return d;
    }

    @Transactional
    public void deleteResearch(long researchId) {
        mapper.deleteResearch(researchId);
    }

    // ---- 인턴·대외활동 (TN_RESUME_ACT) ----
    public List<ActivityDto> listActivity() {
        List<ActivityDto> rows = mapper.listActivity(ensureResumeSn());
        for (ActivityDto r : rows) r.setKind(orRaw(ResumeCodeMap.actSeLabel(r.getKind()), r.getKind()));
        return rows;
    }

    @Transactional
    public ActivityDto addActivity(ActivityDto d) {
        long resumeSn = ensureResumeSn();
        String seCode = ResumeCodeMap.actSeCode(d.getKind());
        if (seCode == null) seCode = "99";
        d.setActSn(mapper.nextActSn());
        mapper.insertActivity(d, resumeSn, d.getActSn(), seCode,
                ymToSqlDate(d.getStart()), ymToSqlDate(d.getEnd()), CurrentUser.userId());
        return d;
    }

    @Transactional
    public void deleteActivity(long actSn) {
        mapper.deleteActivity(actSn);
    }

    // ---- 교육이수 (TN_RESUME_EDC) ----
    public List<TrainingDto> listTraining() {
        return mapper.listTraining(ensureResumeSn());
    }

    @Transactional
    public TrainingDto addTraining(TrainingDto d) {
        long resumeSn = ensureResumeSn();
        d.setEdcSn(mapper.nextEdcSn());
        mapper.insertTraining(d, resumeSn, d.getEdcSn(),
                ymToSqlDate(d.getStart()), ymToSqlDate(d.getEnd()), CurrentUser.userId());
        return d;
    }

    @Transactional
    public void deleteTraining(long edcSn) {
        mapper.deleteTraining(edcSn);
    }

    // ---- 자격증 (TN_RESUME_CRQFC) ----
    public List<CertificateDto> listCertificate() {
        return mapper.listCertificate(ensureResumeSn());
    }

    @Transactional
    public CertificateDto addCertificate(CertificateDto d) {
        long resumeSn = ensureResumeSn();
        d.setName(nz(d.getName())); // CRQFC_NM NOT NULL
        d.setCrqfcSn(mapper.nextCrqfcSn());
        mapper.insertCertificate(d, resumeSn, d.getCrqfcSn(), ymToSqlDate(d.getGot()), CurrentUser.userId());
        return d;
    }

    @Transactional
    public void deleteCertificate(long crqfcSn) {
        mapper.deleteCertificate(crqfcSn);
    }

    // ---- 수상 (TN_RESUME_WNPZ) ----
    public List<AwardDto> listAward() {
        return mapper.listAward(ensureResumeSn());
    }

    @Transactional
    public AwardDto addAward(AwardDto d) {
        long resumeSn = ensureResumeSn();
        d.setName(nz(d.getName())); // WNPZ_NM NOT NULL
        d.setWnpzSn(mapper.nextWnpzSn());
        mapper.insertAward(d, resumeSn, d.getWnpzSn(), CurrentUser.userId());
        return d;
    }

    @Transactional
    public void deleteAward(long wnpzSn) {
        mapper.deleteAward(wnpzSn);
    }

    // ---- 해외경험 (TN_RESUME_OVSEA) ----
    public List<OverseasDto> listOverseas() {
        return mapper.listOverseas(ensureResumeSn());
    }

    @Transactional
    public OverseasDto addOverseas(OverseasDto d) {
        long resumeSn = ensureResumeSn();
        d.setOvseaSn(mapper.nextOvseaSn());
        mapper.insertOverseas(d, resumeSn, d.getOvseaSn(), CurrentUser.userId());
        return d;
    }

    @Transactional
    public void deleteOverseas(long ovseaSn) {
        mapper.deleteOverseas(ovseaSn);
    }

    // ---- 어학 (TN_RESUME_LSTCS) ----
    public List<LanguageDto> listLanguage() {
        List<LanguageDto> rows = mapper.listLanguage(ensureResumeSn());
        for (LanguageDto r : rows) r.setSpeak(orRaw(ResumeCodeMap.speakLabel(r.getSpeak()), r.getSpeak()));
        return rows;
    }

    @Transactional
    public LanguageDto addLanguage(LanguageDto d) {
        long resumeSn = ensureResumeSn();
        String langName = "직접입력".equals(d.getLang()) ? d.getManual() : d.getLang();
        String ablty = ResumeCodeMap.speakCode(d.getSpeak());
        d.setLstcsSn(mapper.nextLstcsSn());
        mapper.insertLanguage(d, resumeSn, d.getLstcsSn(), langName, ablty, CurrentUser.userId());
        return d;
    }

    @Transactional
    public void deleteLanguage(long lstcsSn) {
        mapper.deleteLanguage(lstcsSn);
    }

    // ============ 첨부파일 공통 (TN_ATCH_FILE, FILE_ID = RESUME_SN, FILE_PATH = 용도) ============
    //   용도(portfolio/cover)는 FILE_PATH 로 구분 + 디스크 하위 디렉터리로도 사용.
    private static final String PORTFOLIO_SUBDIR = "portfolio";
    private static final String COVER_SUBDIR     = "cover";

    /** 파일 다건 업로드 → 디스크 저장 + TN_ATCH_FILE 기록 (호출자 트랜잭션 내). */
    private List<PortfolioFileDto> addFilesImpl(String path, MultipartFile[] files) throws IOException {
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
                mapper.insertAtchFile(resumeSn, path, orig, stre, f.getSize(), CurrentUser.userId());
            }
        }
        return mapper.listAtchFiles(resumeSn, path);
    }

    private void deleteFileImpl(String path, long fileSn) {
        long resumeSn = ensureResumeSn();
        PortfolioFileDto f = mapper.findAtchFile(fileSn, resumeSn, path); // 본인 소유 + 용도 일치만
        if (f == null) return;
        mapper.deleteAtchFile(fileSn, resumeSn, path);
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
    public Map<String, Object> getPortfolio() {
        long resumeSn = ensureResumeSn();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("urls", mapper.listPortfolioUrls(resumeSn));
        m.put("files", mapper.listAtchFiles(resumeSn, PORTFOLIO_SUBDIR));
        return m;
    }

    @Transactional
    public PortfolioUrlDto addPortfolioUrl(String url) {
        String u = blankToNull(url);
        if (u == null) throw new IllegalArgumentException("url is required");
        long resumeSn = ensureResumeSn();
        long sn = mapper.nextPrtfolioUrlSn();
        mapper.insertPortfolioUrl(sn, resumeSn, u, CurrentUser.userId());
        PortfolioUrlDto d = new PortfolioUrlDto();
        d.setSn(sn);
        d.setUrl(u);
        return d;
    }

    @Transactional
    public void deletePortfolioUrl(long sn) {
        mapper.deletePortfolioUrl(sn, ensureResumeSn()); // 소유권 가드 포함
    }

    @Transactional
    public List<PortfolioFileDto> addPortfolioFiles(MultipartFile[] files) throws IOException {
        return addFilesImpl(PORTFOLIO_SUBDIR, files);
    }

    @Transactional
    public void deletePortfolioFile(long fileSn) {
        deleteFileImpl(PORTFOLIO_SUBDIR, fileSn);
    }

    /** 다운로드용 메타(본인 소유 + portfolio 한정). 없으면 null. */
    public PortfolioFileDto getPortfolioFileMeta(long fileSn) {
        return mapper.findAtchFile(fileSn, ensureResumeSn(), PORTFOLIO_SUBDIR);
    }

    // ------------------- 자기소개서 (텍스트: TN_RESUME_SELF_INTRCN / 파일: TN_ATCH_FILE 'cover') -------------------

    /** 자기소개서 제목+내용+파일 일괄 조회 */
    public Map<String, Object> getCover() {
        long resumeSn = ensureResumeSn();
        SelfIntroDto s = mapper.findSelfIntro(resumeSn);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("title", s != null ? s.getTitle() : null);
        m.put("content", s != null ? s.getContent() : null);
        m.put("files", mapper.listAtchFiles(resumeSn, COVER_SUBDIR));
        return m;
    }

    /** 제목+내용 upsert (이력서당 1건) */
    @Transactional
    public void saveCoverText(String title, String content) {
        long resumeSn = ensureResumeSn();
        SelfIntroDto s = mapper.findSelfIntro(resumeSn);
        if (s != null) {
            mapper.updateSelfIntro(s.getSn(), title, content, CurrentUser.userId());
        } else {
            long sn = mapper.nextSelfIntrcnSn();
            mapper.insertSelfIntro(sn, resumeSn, title, content, CurrentUser.userId());
        }
    }

    @Transactional
    public List<PortfolioFileDto> addCoverFiles(MultipartFile[] files) throws IOException {
        return addFilesImpl(COVER_SUBDIR, files);
    }

    @Transactional
    public void deleteCoverFile(long fileSn) {
        deleteFileImpl(COVER_SUBDIR, fileSn);
    }

    /** 다운로드용 메타(본인 소유 + cover 한정). 없으면 null. */
    public PortfolioFileDto getCoverFileMeta(long fileSn) {
        return mapper.findAtchFile(fileSn, ensureResumeSn(), COVER_SUBDIR);
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

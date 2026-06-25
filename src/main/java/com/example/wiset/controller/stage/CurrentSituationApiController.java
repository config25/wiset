package com.example.wiset.controller.stage;

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
import com.example.wiset.dto.TrainingDto;
import com.example.wiset.service.CurrentSituationService;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

/**
 * 03 현 상황 입력 - 팝업 즉시저장 API.
 *   학력/경력은 팝업에서 저장할 때마다 즉시 DB 반영(저장/수정/삭제).
 *   (신입·경력 구분, 취업우대·병역 등 '나머지'는 최종제출 시 별도 처리 예정)
 */
@RestController
@RequestMapping("/api/current-situation")
public class CurrentSituationApiController {

    private final CurrentSituationService currentSituationService;

    public CurrentSituationApiController(CurrentSituationService currentSituationService) {
        this.currentSituationService = currentSituationService;
    }

    // ---------- 신입/경력 · 취업우대·병역 (재진입 복원: 최종제출 때 저장된 값 로드) ----------
    @GetMapping("/profile-selections")
    public Map<String, Object> getProfileSelections() {
        return currentSituationService.getProfileSelections();
    }

    // ---------- 학력 ----------
    @GetMapping("/education")
    public List<EducationDto> listEducation() {
        return currentSituationService.listEducation();
    }

    @PostMapping("/education")
    public EducationDto saveEducation(@RequestBody EducationDto dto) {
        return currentSituationService.saveEducation(dto);
    }

    @DeleteMapping("/education/{acdmcrSn}")
    public void deleteEducation(@PathVariable long acdmcrSn) {
        currentSituationService.deleteEducation(acdmcrSn);
    }

    // ---------- 경력 ----------
    @GetMapping("/career")
    public List<CareerDto> listCareer() {
        return currentSituationService.listCareer();
    }

    @PostMapping("/career")
    public CareerDto saveCareer(@RequestBody CareerDto dto) {
        return currentSituationService.saveCareer(dto);
    }

    @DeleteMapping("/career/{careerSn}")
    public void deleteCareer(@PathVariable long careerSn) {
        currentSituationService.deleteCareer(careerSn);
    }

    // ---------- 추가정보 (건별: GET 조회 / POST 추가 / DELETE 삭제) ----------
    @GetMapping("/research")
    public List<ResearchDto> listResearch() { return currentSituationService.listResearch(); }
    @PostMapping("/research")
    public ResearchDto addResearch(@RequestBody ResearchDto dto) { return currentSituationService.addResearch(dto); }
    @DeleteMapping("/research/{researchId}")
    public void deleteResearch(@PathVariable long researchId) { currentSituationService.deleteResearch(researchId); }

    @GetMapping("/activity")
    public List<ActivityDto> listActivity() { return currentSituationService.listActivity(); }
    @PostMapping("/activity")
    public ActivityDto addActivity(@RequestBody ActivityDto dto) { return currentSituationService.addActivity(dto); }
    @DeleteMapping("/activity/{actSn}")
    public void deleteActivity(@PathVariable long actSn) { currentSituationService.deleteActivity(actSn); }

    @GetMapping("/training")
    public List<TrainingDto> listTraining() { return currentSituationService.listTraining(); }
    @PostMapping("/training")
    public TrainingDto addTraining(@RequestBody TrainingDto dto) { return currentSituationService.addTraining(dto); }
    @DeleteMapping("/training/{edcSn}")
    public void deleteTraining(@PathVariable long edcSn) { currentSituationService.deleteTraining(edcSn); }

    @GetMapping("/certificate")
    public List<CertificateDto> listCertificate() { return currentSituationService.listCertificate(); }
    @PostMapping("/certificate")
    public CertificateDto addCertificate(@RequestBody CertificateDto dto) { return currentSituationService.addCertificate(dto); }
    @DeleteMapping("/certificate/{crqfcSn}")
    public void deleteCertificate(@PathVariable long crqfcSn) { currentSituationService.deleteCertificate(crqfcSn); }

    @GetMapping("/award")
    public List<AwardDto> listAward() { return currentSituationService.listAward(); }
    @PostMapping("/award")
    public AwardDto addAward(@RequestBody AwardDto dto) { return currentSituationService.addAward(dto); }
    @DeleteMapping("/award/{wnpzSn}")
    public void deleteAward(@PathVariable long wnpzSn) { currentSituationService.deleteAward(wnpzSn); }

    @GetMapping("/overseas")
    public List<OverseasDto> listOverseas() { return currentSituationService.listOverseas(); }
    @PostMapping("/overseas")
    public OverseasDto addOverseas(@RequestBody OverseasDto dto) { return currentSituationService.addOverseas(dto); }
    @DeleteMapping("/overseas/{ovseaSn}")
    public void deleteOverseas(@PathVariable long ovseaSn) { currentSituationService.deleteOverseas(ovseaSn); }

    @GetMapping("/language")
    public List<LanguageDto> listLanguage() { return currentSituationService.listLanguage(); }
    @PostMapping("/language")
    public LanguageDto addLanguage(@RequestBody LanguageDto dto) { return currentSituationService.addLanguage(dto); }
    @DeleteMapping("/language/{lstcsSn}")
    public void deleteLanguage(@PathVariable long lstcsSn) { currentSituationService.deleteLanguage(lstcsSn); }

    // ---------- 포트폴리오 (URL: TN_RESUME_PRTFOLIO_URL / 파일: TN_ATCH_FILE) ----------
    @GetMapping("/portfolio")
    public Map<String, Object> getPortfolio() { return currentSituationService.getPortfolio(); }

    @PostMapping("/portfolio/url")
    public PortfolioUrlDto addPortfolioUrl(@RequestBody Map<String, String> body) {
        return currentSituationService.addPortfolioUrl(body.get("url"));
    }

    @DeleteMapping("/portfolio/url/{sn}")
    public void deletePortfolioUrl(@PathVariable long sn) { currentSituationService.deletePortfolioUrl(sn); }

    @PostMapping("/portfolio/files")
    public List<PortfolioFileDto> uploadPortfolioFiles(@RequestParam("files") MultipartFile[] files) throws IOException {
        return currentSituationService.addPortfolioFiles(files);
    }

    @DeleteMapping("/portfolio/file/{fileSn}")
    public void deletePortfolioFile(@PathVariable long fileSn) { currentSituationService.deletePortfolioFile(fileSn); }

    @GetMapping("/portfolio/file/{fileSn}")
    public ResponseEntity<Resource> downloadPortfolioFile(@PathVariable long fileSn) {
        return fileDownload(currentSituationService.getPortfolioFileMeta(fileSn));
    }

    // ---------- 자기소개서 (텍스트: TN_RESUME_SELF_INTRCN / 파일: TN_ATCH_FILE 'cover') ----------
    @GetMapping("/cover")
    public Map<String, Object> getCover() { return currentSituationService.getCover(); }

    @PostMapping("/cover/text")
    public void saveCoverText(@RequestBody Map<String, String> body) {
        currentSituationService.saveCoverText(body.get("title"), body.get("content"));
    }

    @PostMapping("/cover/files")
    public List<PortfolioFileDto> uploadCoverFiles(@RequestParam("files") MultipartFile[] files) throws IOException {
        return currentSituationService.addCoverFiles(files);
    }

    @DeleteMapping("/cover/file/{fileSn}")
    public void deleteCoverFile(@PathVariable long fileSn) { currentSituationService.deleteCoverFile(fileSn); }

    @GetMapping("/cover/file/{fileSn}")
    public ResponseEntity<Resource> downloadCoverFile(@PathVariable long fileSn) {
        return fileDownload(currentSituationService.getCoverFileMeta(fileSn));
    }

    /** 첨부파일 다운로드 공통 (원본명으로 attachment 응답) */
    private ResponseEntity<Resource> fileDownload(PortfolioFileDto f) {
        Resource r = currentSituationService.resolveAtchResource(f);
        if (r == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        ContentDisposition.attachment().filename(f.getName(), StandardCharsets.UTF_8).build().toString())
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(r);
    }
}

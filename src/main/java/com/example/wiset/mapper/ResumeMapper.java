package com.example.wiset.mapper;

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
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 현 상황(이력서) 영속성. TN_RESUME(헤더) + TN_RESUME_ACDMCR/CAREER + sys_education 델타.
 *   ※ TN PK 는 AUTO_INCREMENT 가 아니므로 next*Sn() 으로 MAX+1 채번(로컬/개발용).
 *     실제 운영은 시퀀스를 쓰므로 통합 시 채번부만 교체.
 */
@Mapper
public interface ResumeMapper {

    // ---- 이력서 헤더 (TN_RESUME) ----
    Long findResumeSn(@Param("userSn") long userSn);
    long nextResumeSn();
    void insertResumeHeader(@Param("resumeSn") long resumeSn,
                            @Param("userSn") long userSn,
                            @Param("reg") String reg);

    // ---- 현 상황 화면 재진입 시 복원: 신입/경력(실제 선택값) + 취업우대·병역 라벨 ----
    Integer findCareerLevelSel(@Param("userSn") long userSn);
    List<String> listJobPreferences(@Param("userSn") long userSn);

    // ---- 학력 (TN_RESUME_ACDMCR) ----
    long nextAcdmcrSn();
    void insertAcdmcr(@Param("d") EducationDto d,
                      @Param("resumeSn") long resumeSn,
                      @Param("seCode") String seCode,
                      @Param("reg") String reg);
    void updateAcdmcr(@Param("d") EducationDto d,
                      @Param("seCode") String seCode,
                      @Param("reg") String reg);
    void deleteAcdmcr(@Param("acdmcrSn") long acdmcrSn);
    List<EducationDto> listEducation(@Param("resumeSn") long resumeSn);

    // ---- 학력 델타 (sys_education) ----
    void upsertEducationDelta(@Param("acdmcrSn") long acdmcrSn,
                              @Param("minorMajor") String minorMajor,
                              @Param("gradCode") String gradCode,
                              @Param("isFinal") boolean isFinal);
    void deleteEducationDelta(@Param("acdmcrSn") long acdmcrSn);

    // ---- 경력 (TN_RESUME_CAREER) ----
    long nextCareerSn();
    void insertCareer(@Param("d") CareerDto d,
                      @Param("resumeSn") long resumeSn,
                      @Param("salary") Long salary,
                      @Param("reg") String reg);
    void updateCareer(@Param("d") CareerDto d,
                      @Param("salary") Long salary,
                      @Param("reg") String reg);
    void deleteCareer(@Param("careerSn") long careerSn);
    List<CareerDto> listCareer(@Param("resumeSn") long resumeSn);

    // ============ 추가정보 (목록 일괄저장 = replace-all) ============

    // ---- 프로필 보장 (sys_user_* FK 충족용; persona/career_level 은 placeholder, 이후 단계서 갱신) ----
    Long findUserProfile(@Param("userSn") long userSn);
    void insertUserProfilePlaceholder(@Param("userSn") long userSn);

    // ---- 논문/연구 (sys_user_research · research_id AUTO_INCREMENT) ----
    List<ResearchDto> listResearch(@Param("userSn") long userSn);
    void deleteResearch(@Param("researchId") long researchId);
    void insertResearch(@Param("userSn") long userSn, @Param("d") ResearchDto d); // research_id AUTO_INCREMENT → d.researchId 채움

    // ---- 인턴·대외활동 (TN_RESUME_ACT) ----
    long nextActSn();
    List<ActivityDto> listActivity(@Param("resumeSn") long resumeSn);
    void deleteActivity(@Param("actSn") long actSn);
    void insertActivity(@Param("d") ActivityDto d, @Param("resumeSn") long resumeSn, @Param("actSn") long actSn,
                        @Param("seCode") String seCode, @Param("startDate") String startDate,
                        @Param("endDate") String endDate, @Param("reg") String reg);

    // ---- 교육이수 (TN_RESUME_EDC) ----
    long nextEdcSn();
    List<TrainingDto> listTraining(@Param("resumeSn") long resumeSn);
    void deleteTraining(@Param("edcSn") long edcSn);
    void insertTraining(@Param("d") TrainingDto d, @Param("resumeSn") long resumeSn, @Param("edcSn") long edcSn,
                        @Param("startDate") String startDate, @Param("endDate") String endDate, @Param("reg") String reg);

    // ---- 자격증 (TN_RESUME_CRQFC) ----
    long nextCrqfcSn();
    List<CertificateDto> listCertificate(@Param("resumeSn") long resumeSn);
    void deleteCertificate(@Param("crqfcSn") long crqfcSn);
    void insertCertificate(@Param("d") CertificateDto d, @Param("resumeSn") long resumeSn, @Param("crqfcSn") long crqfcSn,
                           @Param("acqsDate") String acqsDate, @Param("reg") String reg);

    // ---- 수상 (TN_RESUME_WNPZ) ----
    long nextWnpzSn();
    List<AwardDto> listAward(@Param("resumeSn") long resumeSn);
    void deleteAward(@Param("wnpzSn") long wnpzSn);
    void insertAward(@Param("d") AwardDto d, @Param("resumeSn") long resumeSn, @Param("wnpzSn") long wnpzSn,
                     @Param("reg") String reg);

    // ---- 해외경험 (TN_RESUME_OVSEA) ----
    long nextOvseaSn();
    List<OverseasDto> listOverseas(@Param("resumeSn") long resumeSn);
    void deleteOverseas(@Param("ovseaSn") long ovseaSn);
    void insertOverseas(@Param("d") OverseasDto d, @Param("resumeSn") long resumeSn, @Param("ovseaSn") long ovseaSn,
                        @Param("reg") String reg);

    // ---- 어학 (TN_RESUME_LSTCS) ----
    long nextLstcsSn();
    List<LanguageDto> listLanguage(@Param("resumeSn") long resumeSn);
    void deleteLanguage(@Param("lstcsSn") long lstcsSn);
    void insertLanguage(@Param("d") LanguageDto d, @Param("resumeSn") long resumeSn, @Param("lstcsSn") long lstcsSn,
                        @Param("langName") String langName, @Param("ablty") String ablty, @Param("reg") String reg);

    // ---- 포트폴리오 URL (TN_RESUME_PRTFOLIO_URL) ----
    long nextPrtfolioUrlSn();
    List<PortfolioUrlDto> listPortfolioUrls(@Param("resumeSn") long resumeSn);
    void insertPortfolioUrl(@Param("sn") long sn, @Param("resumeSn") long resumeSn,
                            @Param("url") String url, @Param("reg") String reg);
    int deletePortfolioUrl(@Param("sn") long sn, @Param("resumeSn") long resumeSn);

    // ---- 첨부파일 (TN_ATCH_FILE, FILE_ID = RESUME_SN 그룹, FILE_PATH = 용도 portfolio/cover) ----
    List<PortfolioFileDto> listAtchFiles(@Param("fileId") long fileId, @Param("path") String path);
    void insertAtchFile(@Param("fileId") long fileId, @Param("path") String path,
                        @Param("orgNm") String orgNm, @Param("streNm") String streNm,
                        @Param("size") Long size, @Param("reg") String reg);
    PortfolioFileDto findAtchFile(@Param("fileSn") long fileSn, @Param("fileId") long fileId, @Param("path") String path);
    int deleteAtchFile(@Param("fileSn") long fileSn, @Param("fileId") long fileId, @Param("path") String path);

    // ---- 자기소개서 텍스트 (TN_RESUME_SELF_INTRCN, 이력서당 1건 upsert) ----
    SelfIntroDto findSelfIntro(@Param("resumeSn") long resumeSn);
    long nextSelfIntrcnSn();
    void insertSelfIntro(@Param("sn") long sn, @Param("resumeSn") long resumeSn,
                         @Param("title") String title, @Param("content") String content, @Param("reg") String reg);
    void updateSelfIntro(@Param("sn") long sn, @Param("title") String title,
                         @Param("content") String content, @Param("reg") String reg);
}

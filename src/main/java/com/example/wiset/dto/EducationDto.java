package com.example.wiset.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * 학력/전공 1건. (current-situation 학력 팝업 ↔ TN_RESUME_ACDMCR + sys_education 델타)
 *   본체(학교/전공/학점/기간/논문)는 TN_RESUME_ACDMCR,
 *   델타(다른전공/졸업상태/최종학력여부)는 sys_education.
 */
public class EducationDto {
    private Long   acdmcrSn;       // TN_RESUME_ACDMCR.ACDMCR_SN (신규=null)
    private String seLabel;        // 학력구분 라벨(학사/석사 ...)
    private String schoolName;     // 학교명
    private String entranceYm;     // 입학년월(YYYY.MM)
    private String graduationYm;   // 졸업년월(YYYY.MM)
    private String gradStatusLabel;// 졸업상태(졸업/졸업예정 ...)
    private String majorName;      // 전공명
    private String gpa;            // 학점
    private String totalGpa;       // 총점
    private String minorMajor;     // 다른 전공(부전공/복수전공)
    private String thesis;         // 졸업논문/작품
    @JsonProperty("isFinal")
    private boolean isFinal;       // 최종학력 여부

    public Long getAcdmcrSn() { return acdmcrSn; }
    public void setAcdmcrSn(Long acdmcrSn) { this.acdmcrSn = acdmcrSn; }
    public String getSeLabel() { return seLabel; }
    public void setSeLabel(String seLabel) { this.seLabel = seLabel; }
    public String getSchoolName() { return schoolName; }
    public void setSchoolName(String schoolName) { this.schoolName = schoolName; }
    public String getEntranceYm() { return entranceYm; }
    public void setEntranceYm(String entranceYm) { this.entranceYm = entranceYm; }
    public String getGraduationYm() { return graduationYm; }
    public void setGraduationYm(String graduationYm) { this.graduationYm = graduationYm; }
    public String getGradStatusLabel() { return gradStatusLabel; }
    public void setGradStatusLabel(String gradStatusLabel) { this.gradStatusLabel = gradStatusLabel; }
    public String getMajorName() { return majorName; }
    public void setMajorName(String majorName) { this.majorName = majorName; }
    public String getGpa() { return gpa; }
    public void setGpa(String gpa) { this.gpa = gpa; }
    public String getTotalGpa() { return totalGpa; }
    public void setTotalGpa(String totalGpa) { this.totalGpa = totalGpa; }
    public String getMinorMajor() { return minorMajor; }
    public void setMinorMajor(String minorMajor) { this.minorMajor = minorMajor; }
    public String getThesis() { return thesis; }
    public void setThesis(String thesis) { this.thesis = thesis; }
    public boolean isFinal() { return isFinal; }
    public void setFinal(boolean isFinal) { this.isFinal = isFinal; }
}

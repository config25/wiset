package com.example.wiset.dto.ai;

/**
 * 리포트 생성 입력 묶음 — 3개 AI API 로 분배된다.
 *   consulting    ← userProfile, unstructuredData, consultingLog
 *   competencyEval← targetRole, resumeText
 *   marketFit     ← experienceLevel, jobPostingText, resumeText
 * (현재는 호출 측에서 직접 전달. 추후 CurrentUser 기준 DB 자동 조립 예정.)
 */
public class GenerationInputs {
    private String userProfile;
    private String unstructuredData;
    private String consultingLog;
    private String resumeText;
    private String targetRole;
    private String jobPostingText;
    private String experienceLevel; // 신입 | 경력

    public String getUserProfile() { return userProfile; }
    public void setUserProfile(String userProfile) { this.userProfile = userProfile; }

    public String getUnstructuredData() { return unstructuredData; }
    public void setUnstructuredData(String unstructuredData) { this.unstructuredData = unstructuredData; }

    public String getConsultingLog() { return consultingLog; }
    public void setConsultingLog(String consultingLog) { this.consultingLog = consultingLog; }

    public String getResumeText() { return resumeText; }
    public void setResumeText(String resumeText) { this.resumeText = resumeText; }

    public String getTargetRole() { return targetRole; }
    public void setTargetRole(String targetRole) { this.targetRole = targetRole; }

    public String getJobPostingText() { return jobPostingText; }
    public void setJobPostingText(String jobPostingText) { this.jobPostingText = jobPostingText; }

    public String getExperienceLevel() { return experienceLevel; }
    public void setExperienceLevel(String experienceLevel) { this.experienceLevel = experienceLevel; }
}

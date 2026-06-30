package com.example.wiset.dto.ai;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

/**
 * AI 추론 서버 요청 바디 — 전용 엔드포인트별로 필드 구성이 다르다.
 *   /api/consulting       : user_profile / unstructured_data / consulting_log (+ user_prompt 선택)
 *   /api/competency-eval  : target_role / resume_text
 *   /api/market-fit       : job_posting_text / resume_text / experience_level("신입"|"경력")
 *   /api/generate(일반)   : system_prompt / user_prompt
 *   @JsonInclude(NON_NULL) 이라 각 호출에서 set 안 한 필드는 JSON 에서 자동 생략됨 → 엔드포인트별 바디로 맞춰진다.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class GenerateRequest {
    private String  systemPrompt;     // /api/generate(일반)
    private String  userPrompt;       // /api/generate, /api/consulting(선택)
    private String  targetRole;       // competency-eval
    private String  resumeText;       // competency-eval, market-fit
    private String  userProfile;      // consulting
    private String  unstructuredData; // consulting
    private String  consultingLog;    // consulting
    private String  jobPostingText;   // market-fit
    private String  experienceLevel;  // market-fit ("신입"|"경력")
    private Integer maxNewTokens = 512;
    private Double  temperature = 0.9;
    private Double  topP = 0.8;

    /** /api/consulting — 코칭 본문(장문). */
    public static GenerateRequest consulting(String userProfile, String unstructuredData, String consultingLog) {
        GenerateRequest r = new GenerateRequest();
        r.userProfile = userProfile;
        r.unstructuredData = unstructuredData;
        r.consultingLog = consultingLog;
        r.maxNewTokens = 1536;
        return r;
    }

    /** /api/competency-eval — 공통/직무/리더십 0~3점 JSON. */
    public static GenerateRequest competencyEval(String targetRole, String resumeText) {
        GenerateRequest r = new GenerateRequest();
        r.targetRole = targetRole;
        r.resumeText = resumeText;
        r.maxNewTokens = 512;
        return r;
    }

    /** /api/market-fit — 시장 정합도. experienceLevel = "신입"|"경력". */
    public static GenerateRequest marketFit(String jobPostingText, String resumeText, String experienceLevel) {
        GenerateRequest r = new GenerateRequest();
        r.jobPostingText = jobPostingText;
        r.resumeText = resumeText;
        r.experienceLevel = experienceLevel;
        r.maxNewTokens = 1536;
        return r;
    }

    public String getSystemPrompt() { return systemPrompt; }
    public void setSystemPrompt(String systemPrompt) { this.systemPrompt = systemPrompt; }

    public String getUserPrompt() { return userPrompt; }
    public void setUserPrompt(String userPrompt) { this.userPrompt = userPrompt; }

    public String getTargetRole() { return targetRole; }
    public void setTargetRole(String targetRole) { this.targetRole = targetRole; }

    public String getResumeText() { return resumeText; }
    public void setResumeText(String resumeText) { this.resumeText = resumeText; }

    public String getUserProfile() { return userProfile; }
    public void setUserProfile(String userProfile) { this.userProfile = userProfile; }

    public String getUnstructuredData() { return unstructuredData; }
    public void setUnstructuredData(String unstructuredData) { this.unstructuredData = unstructuredData; }

    public String getConsultingLog() { return consultingLog; }
    public void setConsultingLog(String consultingLog) { this.consultingLog = consultingLog; }

    public String getJobPostingText() { return jobPostingText; }
    public void setJobPostingText(String jobPostingText) { this.jobPostingText = jobPostingText; }

    public String getExperienceLevel() { return experienceLevel; }
    public void setExperienceLevel(String experienceLevel) { this.experienceLevel = experienceLevel; }

    public Integer getMaxNewTokens() { return maxNewTokens; }
    public void setMaxNewTokens(Integer maxNewTokens) { this.maxNewTokens = maxNewTokens; }

    public Double getTemperature() { return temperature; }
    public void setTemperature(Double temperature) { this.temperature = temperature; }

    public Double getTopP() { return topP; }
    public void setTopP(Double topP) { this.topP = topP; }
}

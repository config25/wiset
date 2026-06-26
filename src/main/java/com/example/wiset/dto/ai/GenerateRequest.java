package com.example.wiset.dto.ai;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

/**
 * POST /api/generate 요청 (Qwen Fine-tuned 서버, 단일 엔드포인트).
 *   type0 : WISET AI 경력개발 컨설턴트  → userProfile / unstructuredData / consultingLog
 *   type1 : 역량 평가(0~3점 JSON)        → targetRole / resumeText
 *   null  : 범용                          → systemPrompt / userPrompt
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class GenerateRequest {
    private String  type;             // "type0" | "type1" | null
    private String  systemPrompt;
    private String  userPrompt;
    private String  targetRole;       // type1
    private String  resumeText;       // type1
    private String  userProfile;      // type0
    private String  unstructuredData; // type0
    private String  consultingLog;    // type0
    private Integer maxNewTokens = 512;
    private Double  temperature = 0.1;
    private Double  topP = 0.9;

    /** type0 컨설팅 요청 (코칭 본문 장문). */
    public static GenerateRequest consulting(String userProfile, String unstructuredData, String consultingLog) {
        GenerateRequest r = new GenerateRequest();
        r.type = "type0";
        r.userProfile = userProfile;
        r.unstructuredData = unstructuredData;
        r.consultingLog = consultingLog;
        r.maxNewTokens = 1536;
        return r;
    }

    /** type1 역량평가 요청 (공통/직무/리더십 0~3점 JSON). */
    public static GenerateRequest competencyEval(String targetRole, String resumeText) {
        GenerateRequest r = new GenerateRequest();
        r.type = "type1";
        r.targetRole = targetRole;
        r.resumeText = resumeText;
        r.maxNewTokens = 512;
        return r;
    }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

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

    public Integer getMaxNewTokens() { return maxNewTokens; }
    public void setMaxNewTokens(Integer maxNewTokens) { this.maxNewTokens = maxNewTokens; }

    public Double getTemperature() { return temperature; }
    public void setTemperature(Double temperature) { this.temperature = temperature; }

    public Double getTopP() { return topP; }
    public void setTopP(Double topP) { this.topP = topP; }
}

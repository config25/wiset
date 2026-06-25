package com.example.wiset.dto.ai;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.Data;

/**
 * POST /api/generate 요청 (Qwen Fine-tuned 서버, 단일 엔드포인트).
 *   type0 : WISET AI 경력개발 컨설턴트  → userProfile / unstructuredData / consultingLog
 *   type1 : 역량 평가(0~3점 JSON)        → targetRole / resumeText
 *   null  : 범용                          → systemPrompt / userPrompt
 */
@Data
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
}

package com.example.wiset.dto.ai;

import lombok.Data;

/**
 * 리포트 생성 입력 묶음 — 3개 AI API 로 분배된다.
 *   consulting    ← userProfile, unstructuredData, consultingLog
 *   competencyEval← targetRole, resumeText
 *   marketFit     ← experienceLevel, jobPostingText, resumeText
 * (현재는 호출 측에서 직접 전달. 추후 CurrentUser 기준 DB 자동 조립 예정.)
 */
@Data
public class GenerationInputs {
    private String userProfile;
    private String unstructuredData;
    private String consultingLog;
    private String resumeText;
    private String targetRole;
    private String jobPostingText;
    private String experienceLevel; // 신입 | 경력
}

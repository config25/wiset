package com.example.wiset.dto;

import lombok.Data;

/**
 * 경력 1건. (current-situation 경력 팝업 ↔ TN_RESUME_CAREER · 델타 없음)
 */
@Data
public class CareerDto {
    private Long   careerSn;       // TN_RESUME_CAREER.CAREER_SN (신규=null)
    private String companyName;    // 회사명
    private String deptName;       // 부서명
    private String startYm;        // 입사년월(YYYY.MM)
    private String endYm;          // 퇴사년월(YYYY.MM)
    private String position;       // 직급/직책
    private String jobField;       // 직무
    private String salary;         // 연봉(화면 표기 '40,000,000원' 등 원문)
    private String jobDescription; // 담당업무 서술
}

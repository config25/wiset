package com.example.wiset.dto;

import lombok.Data;

/** AI 리포트 만족도 조사 1문항 → sys_ai_report_survey (action-plan 별점) */
@Data
public class SurveyDto {
    private Integer questionNo; // 문항 번호(1~4 별점, 5 자유 의견)
    private Integer rating;     // 별점(1~5), 의견 문항은 NULL
    private String  opinion;    // 의견(선택)
}

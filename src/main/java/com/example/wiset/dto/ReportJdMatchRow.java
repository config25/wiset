package com.example.wiset.dto;

import lombok.Data;

/**
 * 스크랩 JD 비교 1행(sys_report_jd_match).
 *   리스트(부족역량/충족강점/보완제안)는 줄바꿈 구분 TEXT.
 */
@Data
public class ReportJdMatchRow {
    private String  company;
    private String  role;
    private String  meta;
    private Integer fitRate;
    private String  matchCount;
    private String  recommendation;  // 추천/도전/관심
    private String  gapKeywords;     // 부족 역량(줄바꿈)
    private String  strengths;       // 충족 강점(줄바꿈)
    private String  advices;         // 보완 제안(줄바꿈)
}

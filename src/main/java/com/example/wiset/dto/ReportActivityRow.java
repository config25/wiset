package com.example.wiset.dto;

import lombok.Data;

/**
 * 활동분석 요약 1행(sys_report_activity, 리포트 1:1).
 *   CFI(경력활동지수) + 기준/시장 종합해설 + CFI 배지(줄바꿈 tone|라벨).
 */
@Data
public class ReportActivityRow {
    private Integer cfiScore;
    private String  cfiDelta;
    private String  summaryTitle;     // CFI 제목
    private String  summaryText;      // CFI 요약(<b> 허용)
    private String  keywordBadges;    // 줄바꿈, 줄 = tone|라벨
    private String  criteriaSummary;  // 기준 정합도 종합해설
    private String  marketSummary;    // 시장 정합도 종합해설
}

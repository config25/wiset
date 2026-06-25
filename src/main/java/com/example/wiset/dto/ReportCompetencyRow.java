package com.example.wiset.dto;

import lombok.Data;

/**
 * 활동분석 역량 1행(sys_report_competency).
 *   fitType: CRITERIA(기준정합도/rows) · MARKET(시장정합도/ksa) · HIGHLIGHT(강점·보완 TOP3).
 *   점수(myScore/requiredScore)는 비교 가능한 INT 컬럼.
 */
@Data
public class ReportCompetencyRow {
    private Long    competencyId;
    private String  fitType;
    private String  groupCode;
    private String  levelCode;
    private String  name;
    private Integer myScore;
    private Integer requiredScore;
    private String  status;   // STRENGTH / GAP (HIGHLIGHT 행)
    private String  icon;
    private String  comment;
    private Integer sortOrder;
}

package com.example.wiset.dto;

import lombok.Data;

/** 역량별 근거 소스 1행(sys_report_competency_source). competencyId 로 역량에 매핑. */
@Data
public class ReportCompetencySource {
    private Long    competencyId;
    private String  sourceType; // 이력서 / NCS 기준 / 시장 동향 ...
    private String  detail;     // "산업 키워드 9회 매칭"
    private Boolean isPrimary;
}

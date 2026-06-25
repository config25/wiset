package com.example.wiset.dto;

import lombok.Data;

/** 역량 진단 1건 (대시보드 추이/이력/요약용) → sys_competency_diagnosis */
@Data
public class DiagnosisRow {
    private String  date;            // YYYY.MM.DD
    private String  ym;              // YYYY.MM
    private Integer totalScore;
    private String  diagnosisType;   // LIGHT / COMPREHENSIVE / AI_COACHING
    private String  versionCode;
    private String  desiredJob;
    private Integer cohortSize;
    private Integer cohortPercentile;
    private Integer professionalism;
    private Integer digital;
    private Integer leadership;
    private Integer problemSolving;
    private Integer communication;
}

package com.example.wiset.dto;

import lombok.Data;

/** 진단·코칭 이력 1건 raw (mypage-history 타임라인) → sys_competency_diagnosis (+파생) */
@Data
public class HistoryRow {
    private Long    diagnosisId;     // sys_competency_diagnosis.competency_id (상세보기 연결용)
    private String  date;            // YYYY.MM.DD
    private String  time;            // HH:mm
    private String  code;            // 표시용 코드
    private String  versionCode;
    private String  diagnosisType;
    private String  desiredJob;
    private String  concernSummary;
    private Integer totalScore;
    private Integer personaCode;
    private Integer actions;         // 이 진단에서 담은 액션 수
    private Double  satisfaction;    // 만족도 평균(없으면 null)
}

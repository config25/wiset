package com.example.wiset.dto;

import lombok.Data;

/** 교육이수 1건 → TN_RESUME_EDC (start/end 는 YYYY.MM, DB는 DATETIME) */
@Data
public class TrainingDto {
    private Long   edcSn;
    private String name;   // 교육명
    private String org;    // 교육기관
    private String start;  // 시작년월(YYYY.MM)
    private String end;    // 종료년월(YYYY.MM)
    private String desc;   // 교육내용
}

package com.example.wiset.dto;

import lombok.Data;

/** 인턴·대외활동 1건 → TN_RESUME_ACT (start/end 는 YYYY.MM, DB는 DATETIME) */
@Data
public class ActivityDto {
    private Long   actSn;
    private String kind;   // 구분(인턴/아르바이트/동아리/사회활동) → ACT_SE_CODE
    private String org;    // 기관/단체명
    private String start;  // 시작년월(YYYY.MM)
    private String end;    // 종료년월(YYYY.MM)
    private String desc;   // 활동내용
}

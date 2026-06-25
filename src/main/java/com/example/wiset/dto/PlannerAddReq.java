package com.example.wiset.dto;

import lombok.Data;

/** 플래너 담기 요청. 직접입력=customTitle, 추천담기=resourceId */
@Data
public class PlannerAddReq {
    private String customTitle;
    private Long   resourceId;
    private String term;    // SHORT/MID/LONG
    private String source;  // source_type_code (MANUAL / WBRIDGE …)
}

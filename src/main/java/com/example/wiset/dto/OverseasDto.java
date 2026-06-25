package com.example.wiset.dto;

import lombok.Data;

/** 해외경험 1건 → TN_RESUME_OVSEA (start/end 는 YYYY.MM, DB는 VARCHAR(7) 그대로) */
@Data
public class OverseasDto {
    private Long   ovseaSn;
    private String country; // 경험국가명
    private String start;   // 시작년월(YYYY.MM)
    private String end;     // 종료년월(YYYY.MM)
    private String desc;    // 경험내용
}

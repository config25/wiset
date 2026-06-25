package com.example.wiset.dto;

import lombok.Data;

/** 수상 1건 → TN_RESUME_WNPZ */
@Data
public class AwardDto {
    private Long   wnpzSn;
    private String name;  // 수상명
    private String org;   // 수여기관
    private String year;  // 수상년도
    private String desc;  // 수상내용 및 결과
}

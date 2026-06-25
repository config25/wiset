package com.example.wiset.dto;

import lombok.Data;

/** 추천 활동 (action-planner 추천 탭) → sys_resource */
@Data
public class RecommendationDto {
    private Long    resourceId;
    private String  type;        // JOB / EDUCATION / SUPPORT
    private String  title;
    private String  content;
    private String  org;         // organization_name
    private String  location;
    private Integer salaryMin;
    private Integer salaryMax;
    private String  sourceType;  // WBRIDGE / EXTERNAL …
}

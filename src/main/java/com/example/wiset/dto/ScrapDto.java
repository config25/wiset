package com.example.wiset.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/** 스크랩한 채용공고 1건 (career-goal 타겟공고 선택용 조회 전용) */
@Data
public class ScrapDto {
    private Long    id;       // PBLANC_SN
    private String  title;    // 공고명
    private String  meta;     // '회사 · 고용형태 · 지역'
    private String  date;     // 스크랩일(YYYY.MM.DD)
    @JsonProperty("isTarget")
    private boolean isTarget;  // 기존 타깃 지정 여부(sys_user_job_scrap)
}

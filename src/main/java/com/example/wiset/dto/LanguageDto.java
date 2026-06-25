package com.example.wiset.dto;

import lombok.Data;

/** 어학 1건 → TN_RESUME_LSTCS (lang=외국어명, speak=회화능력→LSTCS_ABLTY_CODE) */
@Data
public class LanguageDto {
    private Long   lstcsSn;
    private String lang;      // 외국어명(선택값)
    private String manual;    // 직접입력 외국어명
    private String speak;     // 회화능력(일상/비즈니스/원어민)
    private String testName;  // 공인시험명
    private String testScore; // 공인시험점수
}

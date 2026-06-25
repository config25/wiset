package com.example.wiset.dto;

import lombok.Data;

/** 자기소개서 텍스트 1건. (current-situation 자기소개서 ↔ TN_RESUME_SELF_INTRCN) */
@Data
public class SelfIntroDto {
    private Long   sn;       // TN_RESUME_SELF_INTRCN.SELF_INTRCN_SN
    private String title;    // SELF_INTRCN_SJ (제목)
    private String content;  // SELF_INTRCN_CN (내용)
}

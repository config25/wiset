package com.example.wiset.dto;

/** 자기소개서 텍스트 1건. (current-situation 자기소개서 ↔ TN_RESUME_SELF_INTRCN) */
public class SelfIntroDto {
    private Long   sn;       // TN_RESUME_SELF_INTRCN.SELF_INTRCN_SN
    private String title;    // SELF_INTRCN_SJ (제목)
    private String content;  // SELF_INTRCN_CN (내용)

    public Long getSn() { return sn; }
    public void setSn(Long sn) { this.sn = sn; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
}

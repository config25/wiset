package com.example.wiset.dto;

/** 논문/연구내역 1건 → sys_user_research */
public class ResearchDto {
    private Long   researchId;
    private String content;

    public Long getResearchId() { return researchId; }
    public void setResearchId(Long researchId) { this.researchId = researchId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
}

package com.example.wiset.dto;

/** 플래너 담기 요청. 직접입력=customTitle, 추천담기=resourceId */
public class PlannerAddReq {
    private String customTitle;
    private Long   resourceId;
    private String term;    // SHORT/MID/LONG
    private String source;  // source_type_code (MANUAL / WBRIDGE …)

    public String getCustomTitle() { return customTitle; }
    public void setCustomTitle(String customTitle) { this.customTitle = customTitle; }
    public Long getResourceId() { return resourceId; }
    public void setResourceId(Long resourceId) { this.resourceId = resourceId; }
    public String getTerm() { return term; }
    public void setTerm(String term) { this.term = term; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
}

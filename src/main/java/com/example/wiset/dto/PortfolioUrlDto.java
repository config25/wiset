package com.example.wiset.dto;

/** 포트폴리오 URL 1건. (current-situation 포트폴리오 ↔ TN_RESUME_PRTFOLIO_URL) */
public class PortfolioUrlDto {
    private Long   sn;   // TN_RESUME_PRTFOLIO_URL.PRTFOLIO_URL_SN
    private String url;  // PRTFOLIO_URL

    public Long getSn() { return sn; }
    public void setSn(Long sn) { this.sn = sn; }

    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
}

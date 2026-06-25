package com.example.wiset.dto;

import lombok.Data;

/** 포트폴리오 URL 1건. (current-situation 포트폴리오 ↔ TN_RESUME_PRTFOLIO_URL) */
@Data
public class PortfolioUrlDto {
    private Long   sn;   // TN_RESUME_PRTFOLIO_URL.PRTFOLIO_URL_SN
    private String url;  // PRTFOLIO_URL
}

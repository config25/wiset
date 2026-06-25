package com.example.wiset.dto;

import lombok.Data;

/** 자격증 1건 → TN_RESUME_CRQFC (got=취득일 YYYY.MM.DD→DATETIME, exp=만기는 TN MTD(5자)라 보류) */
@Data
public class CertificateDto {
    private Long   crqfcSn;
    private String name;    // 자격증명
    private String issuer;  // 발행처
    private String got;     // 취득일(YYYY.MM.DD)
    private String exp;     // 만기일(현재 미저장 — TN MTD 형식 확인 필요)
}

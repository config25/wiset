package com.example.wiset.dto;

/** 자격증 1건 → TN_RESUME_CRQFC (got=취득일 YYYY.MM.DD→DATETIME, exp=만기는 TN MTD(5자)라 보류) */
public class CertificateDto {
    private Long   crqfcSn;
    private String name;    // 자격증명
    private String issuer;  // 발행처
    private String got;     // 취득일(YYYY.MM.DD)
    private String exp;     // 만기일(현재 미저장 — TN MTD 형식 확인 필요)

    public Long getCrqfcSn() { return crqfcSn; }
    public void setCrqfcSn(Long crqfcSn) { this.crqfcSn = crqfcSn; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getIssuer() { return issuer; }
    public void setIssuer(String issuer) { this.issuer = issuer; }
    public String getGot() { return got; }
    public void setGot(String got) { this.got = got; }
    public String getExp() { return exp; }
    public void setExp(String exp) { this.exp = exp; }
}

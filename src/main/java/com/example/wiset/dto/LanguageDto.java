package com.example.wiset.dto;

/** 어학 1건 → TN_RESUME_LSTCS (lang=외국어명, speak=회화능력→LSTCS_ABLTY_CODE) */
public class LanguageDto {
    private Long   lstcsSn;
    private String lang;      // 외국어명(선택값)
    private String manual;    // 직접입력 외국어명
    private String speak;     // 회화능력(일상/비즈니스/원어민)
    private String testName;  // 공인시험명
    private String testScore; // 공인시험점수

    public Long getLstcsSn() { return lstcsSn; }
    public void setLstcsSn(Long lstcsSn) { this.lstcsSn = lstcsSn; }
    public String getLang() { return lang; }
    public void setLang(String lang) { this.lang = lang; }
    public String getManual() { return manual; }
    public void setManual(String manual) { this.manual = manual; }
    public String getSpeak() { return speak; }
    public void setSpeak(String speak) { this.speak = speak; }
    public String getTestName() { return testName; }
    public void setTestName(String testName) { this.testName = testName; }
    public String getTestScore() { return testScore; }
    public void setTestScore(String testScore) { this.testScore = testScore; }
}

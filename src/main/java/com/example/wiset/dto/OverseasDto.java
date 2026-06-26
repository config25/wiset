package com.example.wiset.dto;

/** 해외경험 1건 → TN_RESUME_OVSEA (start/end 는 YYYY.MM, DB는 VARCHAR(7) 그대로) */
public class OverseasDto {
    private Long   ovseaSn;
    private String country; // 경험국가명
    private String start;   // 시작년월(YYYY.MM)
    private String end;     // 종료년월(YYYY.MM)
    private String desc;    // 경험내용

    public Long getOvseaSn() { return ovseaSn; }
    public void setOvseaSn(Long ovseaSn) { this.ovseaSn = ovseaSn; }
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
    public String getStart() { return start; }
    public void setStart(String start) { this.start = start; }
    public String getEnd() { return end; }
    public void setEnd(String end) { this.end = end; }
    public String getDesc() { return desc; }
    public void setDesc(String desc) { this.desc = desc; }
}

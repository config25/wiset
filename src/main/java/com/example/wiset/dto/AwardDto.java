package com.example.wiset.dto;

/** 수상 1건 → TN_RESUME_WNPZ */
public class AwardDto {
    private Long   wnpzSn;
    private String name;  // 수상명
    private String org;   // 수여기관
    private String year;  // 수상년도
    private String desc;  // 수상내용 및 결과

    public Long getWnpzSn() { return wnpzSn; }
    public void setWnpzSn(Long wnpzSn) { this.wnpzSn = wnpzSn; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getOrg() { return org; }
    public void setOrg(String org) { this.org = org; }
    public String getYear() { return year; }
    public void setYear(String year) { this.year = year; }
    public String getDesc() { return desc; }
    public void setDesc(String desc) { this.desc = desc; }
}

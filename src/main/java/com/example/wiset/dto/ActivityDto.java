package com.example.wiset.dto;

/** 인턴·대외활동 1건 → TN_RESUME_ACT (start/end 는 YYYY.MM, DB는 DATETIME) */
public class ActivityDto {
    private Long   actSn;
    private String kind;   // 구분(인턴/아르바이트/동아리/사회활동) → ACT_SE_CODE
    private String org;    // 기관/단체명
    private String start;  // 시작년월(YYYY.MM)
    private String end;    // 종료년월(YYYY.MM)
    private String desc;   // 활동내용

    public Long getActSn() { return actSn; }
    public void setActSn(Long actSn) { this.actSn = actSn; }
    public String getKind() { return kind; }
    public void setKind(String kind) { this.kind = kind; }
    public String getOrg() { return org; }
    public void setOrg(String org) { this.org = org; }
    public String getStart() { return start; }
    public void setStart(String start) { this.start = start; }
    public String getEnd() { return end; }
    public void setEnd(String end) { this.end = end; }
    public String getDesc() { return desc; }
    public void setDesc(String desc) { this.desc = desc; }
}

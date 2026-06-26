package com.example.wiset.dto;

/** 교육이수 1건 → TN_RESUME_EDC (start/end 는 YYYY.MM, DB는 DATETIME) */
public class TrainingDto {
    private Long   edcSn;
    private String name;   // 교육명
    private String org;    // 교육기관
    private String start;  // 시작년월(YYYY.MM)
    private String end;    // 종료년월(YYYY.MM)
    private String desc;   // 교육내용

    public Long getEdcSn() { return edcSn; }
    public void setEdcSn(Long edcSn) { this.edcSn = edcSn; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getOrg() { return org; }
    public void setOrg(String org) { this.org = org; }

    public String getStart() { return start; }
    public void setStart(String start) { this.start = start; }

    public String getEnd() { return end; }
    public void setEnd(String end) { this.end = end; }

    public String getDesc() { return desc; }
    public void setDesc(String desc) { this.desc = desc; }
}

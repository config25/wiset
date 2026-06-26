package com.example.wiset.dto;

/**
 * 경력 1건. (current-situation 경력 팝업 ↔ TN_RESUME_CAREER · 델타 없음)
 */
public class CareerDto {
    private Long   careerSn;       // TN_RESUME_CAREER.CAREER_SN (신규=null)
    private String companyName;    // 회사명
    private String deptName;       // 부서명
    private String startYm;        // 입사년월(YYYY.MM)
    private String endYm;          // 퇴사년월(YYYY.MM)
    private String position;       // 직급/직책
    private String jobField;       // 직무
    private String salary;         // 연봉(화면 표기 '40,000,000원' 등 원문)
    private String jobDescription; // 담당업무 서술

    public Long getCareerSn() { return careerSn; }
    public void setCareerSn(Long careerSn) { this.careerSn = careerSn; }
    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }
    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }
    public String getStartYm() { return startYm; }
    public void setStartYm(String startYm) { this.startYm = startYm; }
    public String getEndYm() { return endYm; }
    public void setEndYm(String endYm) { this.endYm = endYm; }
    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }
    public String getJobField() { return jobField; }
    public void setJobField(String jobField) { this.jobField = jobField; }
    public String getSalary() { return salary; }
    public void setSalary(String salary) { this.salary = salary; }
    public String getJobDescription() { return jobDescription; }
    public void setJobDescription(String jobDescription) { this.jobDescription = jobDescription; }
}

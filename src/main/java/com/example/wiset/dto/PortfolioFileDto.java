package com.example.wiset.dto;

/** 포트폴리오 첨부파일 1건. (TN_ATCH_FILE, FILE_ID = RESUME_SN 그룹) */
public class PortfolioFileDto {
    private Long   fileSn;    // TN_ATCH_FILE.FILE_SN (AUTO_INCREMENT)
    private String name;      // ORGINL_FILE_NM (원본 파일명, 화면 표시·다운로드명)
    private Long   size;      // FILE_SIZE (bytes)
    private String streName;  // STRE_FILE_NM (디스크 저장명, 내부용)
    private String path;      // FILE_PATH (업로드 하위 디렉터리, 내부용)

    public Long getFileSn() { return fileSn; }
    public void setFileSn(Long fileSn) { this.fileSn = fileSn; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Long getSize() { return size; }
    public void setSize(Long size) { this.size = size; }
    public String getStreName() { return streName; }
    public void setStreName(String streName) { this.streName = streName; }
    public String getPath() { return path; }
    public void setPath(String path) { this.path = path; }
}

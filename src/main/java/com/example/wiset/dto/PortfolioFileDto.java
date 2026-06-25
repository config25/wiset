package com.example.wiset.dto;

import lombok.Data;

/** 포트폴리오 첨부파일 1건. (TN_ATCH_FILE, FILE_ID = RESUME_SN 그룹) */
@Data
public class PortfolioFileDto {
    private Long   fileSn;    // TN_ATCH_FILE.FILE_SN (AUTO_INCREMENT)
    private String name;      // ORGINL_FILE_NM (원본 파일명, 화면 표시·다운로드명)
    private Long   size;      // FILE_SIZE (bytes)
    private String streName;  // STRE_FILE_NM (디스크 저장명, 내부용)
    private String path;      // FILE_PATH (업로드 하위 디렉터리, 내부용)
}

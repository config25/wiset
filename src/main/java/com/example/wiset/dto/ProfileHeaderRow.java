package com.example.wiset.dto;

import lombok.Data;

/**
 * 마이페이지 대시보드 상단 프로필 헤더 1행.
 *   계정/구직자정보 = TN_INDVDL_INFO, 학력 = TN_RESUME_ACDMCR, 경력 = TN_RESUME_CAREER,
 *   페르소나 = sys_user_profile. (USER_SN 조인, 조회 전용 — TN 스키마 불변)
 */
@Data
public class ProfileHeaderRow {
    private String  userNm;        // 이름        TN_INDVDL_INFO.USER_NM
    private String  email;         // 이메일(원본) TN_INDVDL_INFO.EMAIL
    private String  mbtlnum;       // 휴대폰(원본) TN_INDVDL_INFO.MBTLNUM
    private String  brthdy;        // 생년월일 YYYYMMDD → 나이 계산
    private Integer personaCode;   // 페르소나     sys_user_profile.persona_code
    private String  majorNm;       // 전공        TN_RESUME_ACDMCR.MAJOR_NM
    private String  degreeCode;    // 학위코드     TN_RESUME_ACDMCR.LAST_DGRI_SE_CODE
    private String  careerTitle;   // 현 직급/직무 TN_RESUME_CAREER.CLSF_NM
    private String  careerBeginDe; // 입사일       TN_RESUME_CAREER.CAREER_BEGIN_DE
}

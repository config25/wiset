package com.example.wiset.mapper;

import com.example.wiset.dto.ScrapDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/** 스크랩한 채용공고 + 희망 근무지 조회 (career-goal 용, 읽기 전용) */
@Mapper
public interface ScrapMapper {
    List<ScrapDto> listScraps(@Param("userSn") long userSn);

    /** 희망 근무지(복수) 라벨 목록 — sys_user_desired_region. 전국/해외는 시도만, 그 외 '시도 시군구'. */
    List<String> listDesiredRegions(@Param("userSn") long userSn);

    /** 희망 업종명 — sys_user_profile.desired_industry_code → sys_common_type(INDUSTRY). 미저장 시 null. */
    String findDesiredIndustry(@Param("userSn") long userSn);

    /** 희망 직무명 — sys_user_profile.desired_job_code → sys_common_type(JOB). 미저장 시 null. */
    String findDesiredJob(@Param("userSn") long userSn);

    /** 희망 고용형태(복수) 명 목록 — sys_user_type ⋈ sys_common_type(EMPLOYMENT_TYPE). */
    List<String> listDesiredEmployment(@Param("userSn") long userSn);

    /** 최신 세부 고민 자유서술 — sys_user_concern.content. 없으면 null. */
    String findLatestConcern(@Param("userSn") long userSn);

    /** 스크랩한 공고 수 — 리포트 헤더 캡션용. */
    int countScraps(@Param("userSn") long userSn);
}

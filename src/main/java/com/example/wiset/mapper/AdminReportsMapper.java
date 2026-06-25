package com.example.wiset.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 20_관리자 리포트 관리 조회 (조회 전용).
 *   KPI(전체/오늘/평균만족도/재진단) + 리포트 목록(페이지네이션).
 *   sys_ai_report ⋈ sys_competency_diagnosis(페르소나·직무·점수·코호트) ⋈ sys_ai_report_survey(만족도)
 */
@Mapper
public interface AdminReportsMapper {

    /** 상단 KPI: total / today / avgSatisfaction / rediagnosis (전체 기준, 필터 무관) */
    Map<String, Object> kpi();

    /** 리포트 목록 (생성일시 최신순, page + 필터) */
    List<Map<String, Object>> list(@Param("search") String search,
                                   @Param("personaGroup") String personaGroup,
                                   @Param("sat") String sat,
                                   @Param("days") Integer days,
                                   @Param("offset") int offset,
                                   @Param("limit") int limit);

    /** 필터 적용된 리포트 수 (페이지네이션) */
    long count(@Param("search") String search,
               @Param("personaGroup") String personaGroup,
               @Param("sat") String sat,
               @Param("days") Integer days);
}

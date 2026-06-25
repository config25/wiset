package com.example.wiset.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 19_관리자 AI 품질 관리 집계/조회 (조회 전용).
 *   품질 상세 지표(+전월대비) / 낮은 만족도 리포트 / 품질 저하 요인 분포
 *   / 직무·역량 가중치 / 가중치 변경 이력 / 프롬프트 목록.
 *   sys_ai_report_quality · sys_ai_report · sys_ai_report_survey · sys_user_profile
 *   · sys_current_weights · sys_weights_history · sys_prompt_template
 */
@Mapper
public interface AdminAiQualityMapper {

    /** 품질 4지표 전체 평균 + 최근30일/직전30일(전월 대비 델타) */
    Map<String, Object> qualityMetrics();

    /** 낮은 만족도(평균 ★≤3) 리포트 목록 */
    List<Map<String, Object>> lowReports();

    /** 낮은 만족도 리포트 건수(★≤3) */
    long lowReportCount();

    /** 품질 저하 요인 분포 (quality_issue) */
    List<Map<String, Object>> qualityFactors();

    /** 직무·역량 가중치 (전체 직무) */
    List<Map<String, Object>> weights();

    /** 가중치 변경 이력 (최신순) */
    List<Map<String, Object>> weightsHistory();

    /** 프롬프트 목록 (활성 버전) */
    List<Map<String, Object>> prompts();

    // ---- 가중치 저장(쓰기) ----
    /** 직무·역량 1건 가중치 갱신 */
    int updateWeight(@Param("jobName") String jobName,
                     @Param("competency") String competency,
                     @Param("weight") int weight);

    /** 최신 가중치 버전 코드 (없으면 null) */
    String latestWeightsVersion();

    /** 가중치 변경 이력 1건 기록 (history_id AUTO_INCREMENT, created_at 기본 NOW) */
    void insertWeightsHistory(@Param("version") String version,
                              @Param("jobName") String jobName,
                              @Param("reason") String reason,
                              @Param("modifier") String modifier,
                              @Param("weightsJson") String weightsJson);
}

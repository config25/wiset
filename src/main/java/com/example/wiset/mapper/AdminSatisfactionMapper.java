package com.example.wiset.mapper;

import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

/**
 * 18_관리자 만족도 관리 집계 조회 (조회 전용).
 *   만족도 평균/감성 분포 / 행동 연계 추이(만족도·액션) / 불만 요소 / 최근 피드백
 *   / 만족도 평가 내역 / 행동 로그 상세.
 *   sys_ai_report_survey (rating/opinion/sentiment/complaint_category) · sys_user_activity_log · sys_user_profile
 */
@Mapper
public interface AdminSatisfactionMapper {

    /** 만족도 평균(전체) + 최근 30일/직전 30일 평균(전월 대비 델타) */
    Map<String, Object> summary();

    /** 감성 분류 분포 (POSITIVE/NEUTRAL/NEGATIVE) */
    List<Map<String, Object>> sentimentCounts();

    /** 주별 만족도 (최근 7주, ISO week) */
    List<Map<String, Object>> weeklySatisfaction();

    /** 주별 행동(클릭/뷰) — 액션 실행률 계산용 */
    List<Map<String, Object>> weeklyAction();

    /** 불만 요소 TOP5 (부정 피드백 토픽) */
    List<Map<String, Object>> complaintsTop5();

    /** 최근 피드백 (의견 작성분) */
    List<Map<String, Object>> recentFeedback();

    /** 만족도 평가 내역 (리포트 제출 단위) */
    List<Map<String, Object>> evalHistory();

    /** 행동 로그 상세 (최신순) */
    List<Map<String, Object>> activityLog();
}

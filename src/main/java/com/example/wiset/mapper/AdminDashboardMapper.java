package com.example.wiset.mapper;

import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

/**
 * 17_관리자 통합 대시보드 집계 조회 (조회 전용).
 *   [DB 연결 항목만] 누적 진단 / 오늘 진단 시작 / 단계별 이탈률(퍼널)
 *   / 좋아요·싫어요(만족도 별점 기반) / 평균 만족도(별점) / 최근 데이터 배치.
 *   ※ MAU·동시접속·페르소나·응답속도·품질지표·시스템활용량·성능지표는 DB 미연동
 *      (AI/시스템 성능 측정 영역 → 추후 모니터링 연동). 서비스에서 정적값 제공.
 */
@Mapper
public interface AdminDashboardMapper {

    /** 누적 진단 건수 + 오늘 진단 시작(세션) */
    Map<String, Object> realtimeKpi();

    /** 페르소나(1~4)별 유입량 (sys_user_profile) */
    List<Map<String, Object>> personaInflow();

    /** 진단 플로우 단계 도달 인원 (s1>=… 누적 카운트) */
    Map<String, Object> funnelCounts();

    /** 답변 품질 지표 평균 (신뢰성/정확성/직무반영/관련성) — sys_ai_report_quality */
    Map<String, Object> quality();

    /** 좋아요/싫어요 — 만족도 별점 ≥4.0 = 좋아요, ≤2.0 = 싫어요 (sys_ai_report_survey) */
    Map<String, Object> thumbs();

    /** 평균 만족도 별점 분포 (rating 1~5, cnt) */
    List<Map<String, Object>> ratingDist();

    /** 최근 데이터 배치 5건 */
    List<Map<String, Object>> recentBatches();
}

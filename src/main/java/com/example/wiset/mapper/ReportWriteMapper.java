package com.example.wiset.mapper;

import com.example.wiset.dto.ReportCompetencyRow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/** AI 리포트 생성 시 쓰기(delete-rewrite) 전용 매퍼. */
@Mapper
public interface ReportWriteMapper {

    /** 사용자의 최신 진단 ID. 없으면 null. */
    Long findLatestDiagnosisId(@Param("userSn") long userSn);

    /** 최소 진단 행 생성 — holder(userSn 입력) 의 diagnosisId 에 생성 키 채움. */
    void insertDiagnosis(Map<String, Object> holder);

    /** (사용자, 탭) 최신 리포트 ID — 진단 무관(기존 시드 리포트 재사용). 없으면 null. */
    Long findReportId(@Param("userSn") long userSn,
                      @Param("reportType") String reportType);

    /** 리포트 행 생성 — holder(userSn/diagnosisId/reportType 입력) 의 reportId 에 생성 키 채움. */
    void insertReport(Map<String, Object> holder);

    /** 코칭 본문 교체(전체 덮어쓰기). */
    int updateReportContent(@Param("reportId") long reportId, @Param("content") String content);

    /** 코칭 배너(제목/부제목/키워드) 교체 — 프로필 기반 조립값. */
    int updateReportBanner(@Param("reportId") long reportId,
                           @Param("bannerTitle") String bannerTitle,
                           @Param("subtitle") String subtitle,
                           @Param("keywords") String keywords);

    /** 지정 fit_type 들의 근거 소스 삭제(역량 삭제 전 FK 정리). */
    int deleteCompetencySourcesByTypes(@Param("reportId") long reportId, @Param("types") List<String> types);

    /** 지정 fit_type 들의 역량 삭제. */
    int deleteCompetenciesByTypes(@Param("reportId") long reportId, @Param("types") List<String> types);

    /** 역량 1행 삽입. */
    void insertCompetency(@Param("reportId") long reportId, @Param("c") ReportCompetencyRow c);

    /** CFI(점수/제목/요약/배지) upsert — AI 역량 점수에서 파생한 값. criteria_summary 등은 보존. */
    void upsertActivityCfi(@Param("reportId") long reportId,
                           @Param("cfiScore") Integer cfiScore,
                           @Param("summaryTitle") String summaryTitle,
                           @Param("summaryText") String summaryText,
                           @Param("keywordBadges") String keywordBadges,
                           @Param("criteriaSummary") String criteriaSummary);
}

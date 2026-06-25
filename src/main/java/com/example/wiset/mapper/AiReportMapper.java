package com.example.wiset.mapper;

import com.example.wiset.dto.AiReportRow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/** AI 리포트 (sys_ai_report) — 생성 리포트 조회 */
@Mapper
public interface AiReportMapper {
    /**
     * 리포트 본문(JSON/TEXT 문자열) 조회 — 탭 종류(report_type) 기준.
     *   diagnosisId 지정 시 그 진단의 리포트, null 이면 최신 1건. 없으면 null.
     */
    String findContent(@Param("userSn") long userSn,
                       @Param("reportType") String reportType,
                       @Param("diagnosisId") Long diagnosisId);

    /**
     * 리포트 1행(제목/부제목/키워드/본문) 조회 — 코칭 화면 렌더용.
     *   diagnosisId 지정 시 그 진단의 리포트, null 이면 최신 1건. 없으면 null.
     */
    AiReportRow findReport(@Param("userSn") long userSn,
                           @Param("reportType") String reportType,
                           @Param("diagnosisId") Long diagnosisId);
}

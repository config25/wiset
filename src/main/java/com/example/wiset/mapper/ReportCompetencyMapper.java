package com.example.wiset.mapper;

import com.example.wiset.dto.ReportActivityRow;
import com.example.wiset.dto.ReportCompetencyRow;
import com.example.wiset.dto.ReportCompetencySource;
import com.example.wiset.dto.ReportJdMatchRow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/** 활동분석 점수/근거/요약/JD (sys_report_competency · _source · sys_report_activity · sys_report_jd_match) 조회. */
@Mapper
public interface ReportCompetencyMapper {

    /** 대상 리포트 ID — diagnosisId 지정 시 그 진단, null 이면 최신 1건. 없으면 null. */
    Long findReportId(@Param("userSn") long userSn,
                      @Param("reportType") String reportType,
                      @Param("diagnosisId") Long diagnosisId);

    /** 리포트의 모든 역량 행(기준/시장/하이라이트), sort_order 순. */
    List<ReportCompetencyRow> findCompetencies(@Param("reportId") long reportId);

    /** 리포트의 모든 역량 근거 소스(competency_id 포함), 역량별 그룹핑은 서비스에서. */
    List<ReportCompetencySource> findSources(@Param("reportId") long reportId);

    /** 활동분석 요약(CFI·종합해설·배지) 1행. 없으면 null. */
    ReportActivityRow findActivity(@Param("reportId") long reportId);

    /** 스크랩 JD 비교 목록(match_id 순). */
    List<ReportJdMatchRow> findJdMatches(@Param("reportId") long reportId);
}

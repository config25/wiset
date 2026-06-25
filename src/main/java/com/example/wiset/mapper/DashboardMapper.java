package com.example.wiset.mapper;

import com.example.wiset.dto.DiagnosisRow;
import com.example.wiset.dto.HistoryRow;
import com.example.wiset.dto.PlannerRow;
import com.example.wiset.dto.ProfileHeaderRow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/** 마이페이지 대시보드/이력 조회 (역량진단 + 액션플래너 + 프로필) */
@Mapper
public interface DashboardMapper {
    /** 진단 이력 — 시간 오름차순 */
    List<DiagnosisRow> listDiagnoses(@Param("userSn") long userSn);
    List<PlannerRow> listPlanner(@Param("userSn") long userSn);
    String getCurrentStatus(@Param("userSn") long userSn);
    /** 프로필 헤더(이름/연락처/전공/학위/현직) — TN 조인, 1행 */
    ProfileHeaderRow getProfileHeader(@Param("userSn") long userSn);
    /** 진단·코칭 이력 타임라인 — 최신순 (+액션수/만족도 파생) */
    List<HistoryRow> listHistory(@Param("userSn") long userSn);
}

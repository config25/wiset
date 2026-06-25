package com.example.wiset.mapper;

import com.example.wiset.dto.ActionPlannerItemDto;
import com.example.wiset.dto.PlannerAddReq;
import com.example.wiset.dto.RecommendationDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/** 마이페이지 액션 플래너 + 추천 활동 (sys_action_planner / sys_resource) */
@Mapper
public interface ActionPlannerMapper {

    List<ActionPlannerItemDto> listItems(@Param("userSn") long userSn);
    /** 담기 항목을 귀속시킬 사용자의 최신 진단 competency_id (없으면 null) */
    Long findLatestDiagnosisId(@Param("userSn") long userSn);
    void insertItem(@Param("userSn") long userSn, @Param("req") PlannerAddReq req,
                    @Param("diagnosisId") Long diagnosisId); // planner_id AUTO_INCREMENT
    void updateStatus(@Param("plannerId") long plannerId, @Param("status") String status);
    void deleteItem(@Param("plannerId") long plannerId);

    List<RecommendationDto> listRecommendations();
}

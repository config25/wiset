package com.example.wiset.mapper;

import com.example.wiset.dto.SurveyDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/** AI 리포트 만족도 조사 (sys_ai_report_survey) */
@Mapper
public interface SurveyMapper {
    /** 아직 리포트(report_id)가 없는 사용자의 기존 응답 제거(재제출 대비) */
    void deleteDraftByUser(@Param("userSn") long userSn);
    void insertSurvey(@Param("userSn") long userSn, @Param("d") SurveyDto d);
    /** 추천 의향(좋아요/싫어요) → sys_user_activity_log(action_type='thumbs') */
    void insertThumb(@Param("userSn") long userSn, @Param("value") String value);
}

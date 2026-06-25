package com.example.wiset.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 분석 시작 시 일괄 저장 (sessionStorage 선택값 → DB). AI 전송은 별도(미포함).
 *   프로필/근무지/다중선택(고용형태·우대)/고민/타깃공고/경력성장 목표.
 */
@Mapper
public interface AnalysisMapper {

    // 코드/ID 조회 (표시명 → 코드값/common_id)
    String codeByName(@Param("group") String group, @Param("name") String name);
    Long   commonIdByName(@Param("group") String group, @Param("name") String name);

    // 프로필 upsert (페르소나/신입·경력/희망업종/희망직무)
    void upsertUserProfile(@Param("userSn") long userSn,
                           @Param("personaCode") Integer personaCode,
                           @Param("careerLevelCode") Integer careerLevelCode,
                           @Param("careerLevelSel") Integer careerLevelSel,
                           @Param("industryCode") String industryCode,
                           @Param("jobCode") String jobCode);

    // 희망 근무지 (replace-all)
    void deleteDesiredRegions(@Param("userSn") long userSn);
    void insertDesiredRegion(@Param("userSn") long userSn,
                             @Param("sido") String sido, @Param("sigungu") String sigungu);

    // 다중선택(고용형태/취업우대) (replace-all)
    void deleteUserTypes(@Param("userSn") long userSn);
    void insertUserType(@Param("userSn") long userSn, @Param("typeId") long typeId);

    // 세부 고민 (insert)
    void insertConcern(@Param("userSn") long userSn, @Param("personaCode") Integer personaCode,
                       @Param("category") String category, @Param("content") String content);

    // 타깃 공고 (is_target 델타)
    void clearTargets(@Param("userSn") long userSn);
    void markTarget(@Param("userSn") long userSn, @Param("pblancSn") long pblancSn);

    // 경력성장 목표 (페르소나4) — replace
    void deleteGrowthSkillsByUser(@Param("userSn") long userSn);
    void deleteGrowthGoal(@Param("userSn") long userSn);
    void insertGrowthGoal(@Param("userSn") long userSn,
                          @Param("rankCode") String rankCode, @Param("years") Integer years,
                          @Param("duties") String duties, @Param("targetRole") String targetRole,
                          @Param("targetPay") String targetPay, @Param("evalCode") String evalCode);
    Long latestGrowthGoalId(@Param("userSn") long userSn);
    void insertGrowthSkill(@Param("goalId") long goalId, @Param("skillCode") String skillCode);
}

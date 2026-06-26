package com.example.wiset.dto;

import java.util.List;

/**
 * AI 리포트 만족도 조사 제출 묶음 (action-plan).
 *   recommend = 추천 의향(좋아요/싫어요) → sys_user_activity_log(thumbs)
 *   ratings   = 별점 문항(1~4)          → sys_ai_report_survey
 *   opinion   = 자유 서술 의견(문항 5)    → sys_ai_report_survey(question_no=5, rating NULL)
 */
public class SurveySubmitDto {
    private String         recommend; // "up" | "down" | null
    private List<SurveyDto> ratings;  // 별점 문항(questionNo 1~4, rating 1~5)
    private String         opinion;   // 자유 의견(선택)

    public String getRecommend() { return recommend; }
    public void setRecommend(String recommend) { this.recommend = recommend; }

    public List<SurveyDto> getRatings() { return ratings; }
    public void setRatings(List<SurveyDto> ratings) { this.ratings = ratings; }

    public String getOpinion() { return opinion; }
    public void setOpinion(String opinion) { this.opinion = opinion; }
}

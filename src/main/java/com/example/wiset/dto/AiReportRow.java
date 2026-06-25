package com.example.wiset.dto;

import lombok.Data;

/**
 * AI 리포트 1행(sys_ai_report) — 코칭 화면 렌더용.
 *   bannerTitle/subtitle/keywords 는 컬럼 분리 저장(AI 생성), content 는 본문(TEXT 또는 구조화 JSON).
 *   keywords 는 줄바꿈 구분, 각 줄 = "아이콘명|라벨" (예: flask|화학·바이오 산업).
 */
@Data
public class AiReportRow {
    private String bannerTitle;
    private String subtitle;
    private String keywords;
    private String content;
}

package com.example.wiset.dto.ai;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.Data;

/**
 * POST /api/generate 응답.
 *   response       : 모델이 생성한 최종 텍스트 (type1 은 이 안에 JSON 문자열이 담김)
 *   elapsedSeconds : 추론 소요(초)
 */
@Data
@JsonIgnoreProperties(ignoreUnknown = true)
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class GenerateResponse {
    private String response;
    private Double elapsedSeconds;
}

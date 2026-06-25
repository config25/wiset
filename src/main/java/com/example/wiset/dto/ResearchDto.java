package com.example.wiset.dto;

import lombok.Data;

/** 논문/연구내역 1건 → sys_user_research */
@Data
public class ResearchDto {
    private Long   researchId;
    private String content;
}

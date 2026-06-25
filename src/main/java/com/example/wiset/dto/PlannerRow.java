package com.example.wiset.dto;

import lombok.Data;

/** 액션 플래너 1건 (대시보드용) → sys_action_planner */
@Data
public class PlannerRow {
    private String title;   // custom_title 또는 연결 리소스 제목
    private String source;  // source_type_code (WBRIDGE/EXTERNAL_REC/AI/MANUAL …)
    private String term;    // term_code (SHORT/MID/LONG)
    private String status;  // status_code (TODO/IN_PROGRESS/DONE)
}

package com.example.wiset.dto;

import lombok.Data;

/** 액션 플래너 항목 (조회/상태변경) → sys_action_planner */
@Data
public class ActionPlannerItemDto {
    private Long   plannerId;
    private String title;
    private String source;  // source_type_code
    private String term;    // term_code (SHORT/MID/LONG)
    private String status;  // status_code (TODO/IN_PROGRESS/DONE)
}

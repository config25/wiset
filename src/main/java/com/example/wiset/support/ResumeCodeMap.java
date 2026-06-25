package com.example.wiset.support;

import java.util.HashMap;
import java.util.Map;

/**
 * 화면 라벨 ↔ 코드 매핑.
 *
 * [주의] 학력구분(ACDMCR_SE_CODE)은 레거시 TN_CODE 의 실제 코드값과 반드시 대조가 필요하다.
 *   현재는 임시 코드(01~09)이며, 실제 운영 TN_CODE 값으로 교체해야 한다.
 *   졸업상태(GRAD_STATUS)는 우리 sys_common_type(data.sql) 기준이라 그대로 사용 가능.
 */
public final class ResumeCodeMap {

    private ResumeCodeMap() {}

    // 학력구분 라벨 -> TN_RESUME_ACDMCR.ACDMCR_SE_CODE (※ 임시코드, TN_CODE 대조 필요)
    private static final Map<String, String> ACDMCR_SE = new HashMap<>();
    private static final Map<String, String> ACDMCR_SE_REV = new HashMap<>();
    // 졸업상태 라벨 -> sys_education.graduation_status (sys_common_type GRAD_STATUS code)
    private static final Map<String, String> GRAD = new HashMap<>();
    private static final Map<String, String> GRAD_REV = new HashMap<>();
    // 인턴·대외활동 구분 라벨 -> TN_RESUME_ACT.ACT_SE_CODE (※ 임시코드, TN_CODE 대조 필요)
    private static final Map<String, String> ACT_SE = new HashMap<>();
    private static final Map<String, String> ACT_SE_REV = new HashMap<>();
    // 회화능력 라벨 -> TN_RESUME_LSTCS.LSTCS_ABLTY_CODE (※ 임시코드, TN_CODE 대조 필요)
    private static final Map<String, String> SPEAK = new HashMap<>();
    private static final Map<String, String> SPEAK_REV = new HashMap<>();

    static {
        put(ACDMCR_SE, ACDMCR_SE_REV, "전문학사", "01");
        put(ACDMCR_SE, ACDMCR_SE_REV, "학사", "02");
        put(ACDMCR_SE, ACDMCR_SE_REV, "석사", "03");
        put(ACDMCR_SE, ACDMCR_SE_REV, "박사", "04");
        put(ACDMCR_SE, ACDMCR_SE_REV, "고등학교 졸업", "05");
        put(ACDMCR_SE, ACDMCR_SE_REV, "기타(대학 재학 등)", "09");

        put(GRAD, GRAD_REV, "졸업", "GRADUATED");
        put(GRAD, GRAD_REV, "졸업예정", "EXPECTED");
        put(GRAD, GRAD_REV, "재학중", "ENROLLED");
        put(GRAD, GRAD_REV, "중퇴", "DROPOUT");
        put(GRAD, GRAD_REV, "수료", "COMPLETED");

        put(ACT_SE, ACT_SE_REV, "인턴", "01");
        put(ACT_SE, ACT_SE_REV, "아르바이트", "02");
        put(ACT_SE, ACT_SE_REV, "동아리", "03");
        put(ACT_SE, ACT_SE_REV, "사회활동", "04");

        put(SPEAK, SPEAK_REV, "일상 회화 가능", "01");
        put(SPEAK, SPEAK_REV, "비즈니스 회화 가능", "02");
        put(SPEAK, SPEAK_REV, "원어민 수준", "03");
    }

    public static String actSeCode(String label)  { return label == null ? null : ACT_SE.get(label.trim()); }
    public static String actSeLabel(String code)   { return code == null ? null : ACT_SE_REV.get(code.trim()); }
    public static String speakCode(String label)   { return label == null ? null : SPEAK.get(label.trim()); }
    public static String speakLabel(String code)   { return code == null ? null : SPEAK_REV.get(code.trim()); }

    private static void put(Map<String, String> fwd, Map<String, String> rev, String label, String code) {
        fwd.put(label, code);
        rev.put(code, label);
    }

    public static String acdmcrSeCode(String label) {
        return label == null ? null : ACDMCR_SE.get(label.trim());
    }

    public static String acdmcrSeLabel(String code) {
        return code == null ? null : ACDMCR_SE_REV.get(code.trim());
    }

    public static String gradStatusCode(String label) {
        return label == null ? null : GRAD.get(label.trim());
    }

    public static String gradStatusLabel(String code) {
        return code == null ? null : GRAD_REV.get(code.trim());
    }
}

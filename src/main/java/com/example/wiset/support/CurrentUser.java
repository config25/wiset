package com.example.wiset.support;

/**
 * 현재 로그인 사용자 식별.
 *
 * [통합 지점] 이 프로젝트는 기존 W브릿지에 붙는 것이라, 실제로는 기존 프로젝트의
 *   인증 세션에서 USER_SN / USER_ID 를 가져온다. 로컬 개발에선 로그인이 없으므로
 *   아래 고정값을 사용하고, 실제 통합 시 이 클래스 두 메서드만 세션 조회로 교체하면 된다.
 */
public final class CurrentUser {

    private CurrentUser() {}

    /** [임시] 개발용 고정 사용자 순번 */
    public static final long DEV_USER_SN = 1L;
    /** [임시] 개발용 고정 사용자 ID (TN 의 REGISTER/UPDUSR 등록자 컬럼용) */
    public static final String DEV_USER_ID = "wb_dev";

    public static long userSn() {
        return DEV_USER_SN;
    }

    public static String userId() {
        return DEV_USER_ID;
    }
}

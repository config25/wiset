-- =====================================================================
-- WISET W브릿지 AI 경력개발 솔루션 - 스키마 DDL
-- DBMS : MySQL / MariaDB (InnoDB, utf8mb4)
-- 쿼리 : MyBatis 사용 (DB-level FK는 무결성 보조용)
-- ---------------------------------------------------------------------
-- [통합 방침] 기존 W브릿지(Tibero) 운영 프로젝트에 "추가"되는 테이블들.
--   · 레거시 테이블은 TN_ 접두사 / 이번 프로젝트 추가분은 sys_ 접두사로 구분.
--   · 사용자 계정은 기존 TN_USER_INFO 가 담당. sys_user_profile 는 프로필 전용.
--   · sys_user_profile.user_id = TN_USER_INFO.USER_SN (계정과 1:1, FK 연결).
--   · TN_USER_INFO 는 레거시 원본 정의를 로컬 실행용으로 함께 둠(원본은 Tibero,
--     여기선 MySQL 타입으로 옮김). 실제 통합 시엔 기존 운영 테이블을 그대로 사용.
-- =====================================================================

SET NAMES utf8mb4;

-- ---------------------------------------------------------------------
-- 기준/마스터 (의존성 없음)
-- ---------------------------------------------------------------------

-- [레거시] 이용자 메인 정보(계정) — 기존 운영 DB 소유. 원본 Tibero, 로컬용 MySQL 변환.
--   sys_user_profile 이 USER_SN 으로 1:1 참조하므로 FK 정렬을 위해 상단 배치.
CREATE TABLE IF NOT EXISTS TN_USER_INFO (
    USER_SN     BIGINT        NOT NULL AUTO_INCREMENT COMMENT '사용자 순번',
    USER_ID     VARCHAR(20)   NOT NULL               COMMENT '신청인ID',
    USER_PW     VARCHAR(50)   NOT NULL               COMMENT '사용자 비밀번호',
    PW_INITL_AT VARCHAR(1)    NOT NULL DEFAULT 'Y'   COMMENT '비밀번호 초기화 여부',
    USER_SE     CHAR(1)       NOT NULL               COMMENT '사용자 구분',
    USE_AT      VARCHAR(1)    NOT NULL DEFAULT 'Y'   COMMENT '사용여부',
    LAST_LOGIN  DATETIME                             COMMENT '최종 로그인',
    AGRE_DT     DATETIME      NOT NULL               COMMENT '동의 일시',
    PW_UPDDE    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '비밀번호 수정일',
    MEMO_CN     VARCHAR(4000)                        COMMENT '메모 내용',
    REGISTER    VARCHAR(20)   NOT NULL               COMMENT '등록자',
    RGSDE       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR      VARCHAR(20)   NOT NULL               COMMENT '수정자',
    UPDDE       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (USER_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이용자 메인 정보(레거시)';

-- 사용자 프로필 (AI 확장) — 계정=TN_USER_INFO / 구직자정보=TN_INDVDL_INFO, USER_SN 공유·1:1
--   ※ 이름·이메일·휴대폰·생년월일·성별은 TN_INDVDL_INFO 에 있으므로 여기서 제거(USER_SN 조인 조회).
--      TN_INDVDL_INFO: USER_NM / EMAIL / MBTLNUM / BRTHDY / SEXDSTN_SE_CODE
CREATE TABLE IF NOT EXISTS sys_user_profile (
    user_id              BIGINT       NOT NULL              COMMENT '사용자ID(=TN_USER_INFO.USER_SN, 계정과 1:1)',
    persona_code         INT          NOT NULL              COMMENT '사용자 유형 (신규취업, 이직 준비 등)',
    career_level_code    INT          NOT NULL              COMMENT '신입/경력 구분(분석용, NOT NULL·미선택 시 기본 2)',
    career_level_sel     INT                                COMMENT '신입/경력 사용자 실제 선택값(NULL=미선택, 1=신입, 2=경력)',
    desired_salary       TEXT                               COMMENT '희망 연봉',
    desired_joining_time INT                                COMMENT '입사 희망 시기',
    desired_industry_code INT                               COMMENT '희망 업종(단일선택, INDUSTRY)',
    desired_job_code     INT                                COMMENT '희망 직무(단일선택, JOB)',
    current_status       VARCHAR(255)                       COMMENT '현 상황 요약(대시보드 표시용)',
    -- 희망 근무지(복수)   -> sys_user_desired_region
    -- 희망 고용형태(복수)  -> sys_user_type(type_id -> sys_common_type EMPLOYMENT_TYPE)
    created_at           TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    updated_at           TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '수정 시각',
    PRIMARY KEY (user_id),
    CONSTRAINT fk_user_profile_info FOREIGN KEY (user_id) REFERENCES TN_USER_INFO (USER_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자 프로필(AI 확장)';

-- 공통 다중 선택지
--   ※ 레거시 TN_CODE(GROUP_CODE/CODE 각 VARCHAR(5))와 역할은 같으나 코드 길이체계가 달라
--      (우리: EMPLOYMENT_TYPE/COVER_LETTER 등 5자 초과) 통합 불가 → sys 자체 코드로 유지.
CREATE TABLE IF NOT EXISTS sys_common_type (
    common_id   INT          NOT NULL AUTO_INCREMENT COMMENT '유형 고유 ID',
    group_code  VARCHAR(50)  NOT NULL                COMMENT '유형 그룹',
    code        VARCHAR(100) NOT NULL                COMMENT '시스템 내부 코드',
    name        VARCHAR(100) NOT NULL                COMMENT '사용자 표시명',
    PRIMARY KEY (common_id),
    UNIQUE KEY uk_common_type (group_code, code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='공통 다중 선택지';

-- 통합 추천/지원 리소스 (JOB/EDUCATION/SUPPORT 를 resource_id 로 통일하는 허브)
--   [TN 이중저장 방지] source_type_code='WBRIDGE'(자체) 행은 본문을 복사하지 않고
--     source_ref_id 로 TN 원본을 가리킨다 → title/content/organization_name/location/
--     salary_min/salary_max/start_date/end_date 는 NULL, 조회 시 TN 에서 읽음.
--       · JOB      -> source_ref_id = TN_EMPMN_PBLANC.PBLANC_SN
--       · EDUCATION -> source_ref_id = TN_EDC_BSNS.EDC_BSNS_SN
--   EXTERNAL/COHORT/SUPPORT 는 TN 원본이 없으므로 위 컬럼을 직접 채운다(source_ref_id NULL).
--   대상 테이블이 둘이라(폴리모픽) TN 으로의 FK 는 설정하지 않음(TN 무변경).
CREATE TABLE IF NOT EXISTS sys_resource (
    resource_id        BIGINT      NOT NULL AUTO_INCREMENT COMMENT '리소스 ID',
    resource_type_code VARCHAR(30) NOT NULL                COMMENT 'JOB / EDUCATION / SUPPORT',
    source_type_code   VARCHAR(30)                         COMMENT '가져온 곳(WBRIDGE/EXTERNAL/COHORT)',
    source_ref_id      BIGINT                              COMMENT 'WBRIDGE 일 때 TN 원본 PK(JOB=PBLANC_SN/EDU=EDC_BSNS_SN), 폴리모픽·FK없음',
    title              VARCHAR(255)                        COMMENT '제목(WBRIDGE 는 NULL→TN)',
    content            TEXT                                COMMENT '상세 내용(WBRIDGE 는 NULL→TN)',
    organization_name  VARCHAR(255)                        COMMENT '주최 기관(WBRIDGE 는 NULL→TN)',
    location           VARCHAR(255)                        COMMENT '지역(WBRIDGE 는 NULL→TN)',
    salary_min         INT                                 COMMENT '최소 금액(WBRIDGE 는 NULL→TN)',
    salary_max         INT                                 COMMENT '최대 금액(WBRIDGE 는 NULL→TN)',
    start_date         DATE                                COMMENT '시작일(WBRIDGE 는 NULL→TN)',
    end_date           DATE                                COMMENT '종료일(WBRIDGE 는 NULL→TN)',
    created_at         TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성일',
    updated_at         TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '수정일',
    PRIMARY KEY (resource_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='통합 추천/지원 리소스';

-- 현재 직무별 역량 가중치
CREATE TABLE IF NOT EXISTS sys_current_weights (
    job_name        VARCHAR(100) NOT NULL COMMENT '직무명',
    competency_name VARCHAR(100) NOT NULL COMMENT '역량명',
    weight_percent  INT                   COMMENT '현재 가중치(30%)',
    default_percent INT                   COMMENT '기본 가중치(30%)',
    PRIMARY KEY (job_name, competency_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='현재 직무별 역량 가중치';

-- 가중치 변경 이력
CREATE TABLE IF NOT EXISTS sys_weights_history (
    history_id    BIGINT       NOT NULL AUTO_INCREMENT COMMENT '이력 ID',
    version_code  VARCHAR(20)  NOT NULL                COMMENT '버전 번호',
    job_name      VARCHAR(100)                         COMMENT '대상 직무',
    change_reason VARCHAR(500)                         COMMENT '변경 내용 요약',
    modifier_name VARCHAR(100)                         COMMENT '변경자',
    weights_json  JSON                                 COMMENT '변경 시점 가중치 스냅샷',
    created_at    TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (history_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='가중치 변경 이력';

-- 프롬프트 템플릿
CREATE TABLE IF NOT EXISTS sys_prompt_template (
    prompt_code    VARCHAR(20)  NOT NULL COMMENT '프롬프트 코드',
    version_code   VARCHAR(20)  NOT NULL COMMENT '버전 코드',
    title          VARCHAR(100)          COMMENT '프롬프트 이름',
    variables      VARCHAR(255)          COMMENT '사용 변수 목록',
    prompt_content TEXT                  COMMENT '프롬프트 본문',
    is_active      BOOLEAN               COMMENT '사용 여부',
    created_at     TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (prompt_code, version_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='프롬프트 템플릿';

-- 시스템 성능 지표
CREATE TABLE IF NOT EXISTS sys_system_metrics (
    metric_id            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '로그 ID',
    gpu_usage_percent    DECIMAL(5,2)                         COMMENT 'GPU 사용률',
    cpu_usage_percent    DECIMAL(5,2)                         COMMENT 'CPU 사용률',
    memory_usage_percent DECIMAL(5,2)                         COMMENT '메모리 사용률',
    created_at           TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (metric_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='시스템 성능 지표';

-- 데이터 배치 이력
CREATE TABLE IF NOT EXISTS sys_batch_history (
    batch_id         BIGINT       NOT NULL AUTO_INCREMENT COMMENT '배치 ID',
    batch_type       VARCHAR(100)                         COMMENT '배치 유형',
    executed_at      TIMESTAMP(6)                         COMMENT '실행 시각',
    processed_count  INT                                  COMMENT '처리 건수',
    duration_seconds INT                                  COMMENT '소요 시간(초)',
    status           VARCHAR(30)                          COMMENT '상태(SUCCESS, WARNING, FAILED)',
    created_at       TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (batch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='데이터 배치 이력';

-- 큐 상태 지표
CREATE TABLE IF NOT EXISTS sys_queue_metrics (
    queue_metric_id  BIGINT       NOT NULL AUTO_INCREMENT COMMENT '측정 ID',
    queue_name       VARCHAR(100)                         COMMENT '큐 이름',
    waiting_count    INT                                  COMMENT '대기 건수',
    processing_count INT                                  COMMENT '처리 중 건수',
    created_at       TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '측정 시각',
    PRIMARY KEY (queue_metric_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='큐 상태 지표';

-- ---------------------------------------------------------------------
-- 사용자 종속 / 리소스 종속
-- ---------------------------------------------------------------------

-- 채용공고 정보
CREATE TABLE IF NOT EXISTS sys_job_posting (
    post_id     BIGINT NOT NULL AUTO_INCREMENT COMMENT '채용공고 ID',
    resource_id BIGINT NOT NULL                COMMENT 'RESOURCE FK',
    job_type_id INT                            COMMENT '근무유형 타입 ID(WBRIDGE 는 NULL→TN_EMPMN_PBLANC.EMPLYM_STLE, 외부 공고만 직접 채움)',
    created_at  TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (post_id),
    CONSTRAINT fk_job_posting_resource FOREIGN KEY (resource_id) REFERENCES sys_resource (resource_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='채용공고 정보(JOB 서브타입)';

-- 학력 추가정보(델타) — TN_RESUME_ACDMCR 가 못 담는 항목만 sys 보관.
--   학교/전공/학점/기간/논문 등 본체는 TN_RESUME_ACDMCR 사용(여기 재저장 안 함).
--   TN 학력행(ACDMCR_SN)에 1:1 부착. FK 는 정의 순서상 파일 하단 ALTER.
CREATE TABLE IF NOT EXISTS sys_education (
    acdmcr_sn         BIGINT       NOT NULL              COMMENT 'TN_RESUME_ACDMCR.ACDMCR_SN (학력행 1:1)',
    minor_major       VARCHAR(100)                       COMMENT '부전공',
    graduation_status VARCHAR(20)                        COMMENT '졸업상태(졸업/졸업예정/재학중/중퇴/수료)',
    is_final          BOOLEAN                            COMMENT '최종학력 여부',
    created_at        TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (acdmcr_sn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='학력 추가정보(델타) - TN_RESUME_ACDMCR 확장';

-- =====================================================================
-- 사용자 추가 정보 (INFO_TYPE 1~9)
--   1 논문/연구내역 -> sys_user_research  (TN 에 다건 테이블 없어 sys 유지)
--   2~9 (인턴·대외활동/교육이수/자격증/수상/해외/어학/포트폴리오/자소서)
--       -> TN_RESUME_* 사용. TN 스키마 불변·데이터 입출력 허용 → sys 재저장 안 함.
-- =====================================================================

-- 1. 논문/연구내역 (행마다 1건, 여러 건 입력)
CREATE TABLE IF NOT EXISTS sys_user_research (
    research_id  BIGINT       NOT NULL AUTO_INCREMENT COMMENT '논문/연구 ID',
    user_id      BIGINT       NOT NULL                COMMENT '사용자 ID',
    content      TEXT                                 COMMENT '논문/연구내역',
    created_at   TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (research_id),
    CONSTRAINT fk_research_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자 논문/연구내역';

-- 2~9 항목은 TN_RESUME_* 에 동일 구조가 이미 존재 → sys 재저장 폐지(TN 사용).
--   (TN 스키마 불변, 데이터 INSERT/UPDATE/DELETE 허용 전제. 신규/수정도 TN 에 기록)
--   TN 매핑: 인턴·대외활동 TN_RESUME_ACT / 교육이수 TN_RESUME_EDC /
--            자격증 TN_RESUME_CRQFC / 수상 TN_RESUME_WNPZ / 해외 TN_RESUME_OVSEA /
--            어학 TN_RESUME_LSTCS / 포트폴리오 TN_RESUME_PRTFOLIO_URL /
--            자기소개서 TN_RESUME_SELF_INTRCN

-- 사용자의 고민 및 어려움
CREATE TABLE IF NOT EXISTS sys_user_concern (
    concern_id   BIGINT       NOT NULL AUTO_INCREMENT COMMENT '고민 정보 ID',
    user_id      BIGINT       NOT NULL                COMMENT '사용자 ID',
    persona_code INT                                  COMMENT '작성 시 페르소나(1~4)',
    category     VARCHAR(50)                          COMMENT '선택 고민 카테고리명(프론트 프리셋, 자유서술만 시 NULL)',
    content      TEXT                                 COMMENT '최종 자유서술',
    created_at   TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (concern_id),
    CONSTRAINT fk_concern_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자의 고민 및 어려움';

-- 경력 → TN_RESUME_CAREER 사용 (델타 없음, sys 재저장 폐지)

-- 사용자의 다중선택 항목
CREATE TABLE IF NOT EXISTS sys_user_type (
    common_id BIGINT NOT NULL AUTO_INCREMENT COMMENT '매핑 ID',
    user_id   BIGINT NOT NULL                COMMENT '사용자 ID',
    type_id   INT    NOT NULL                COMMENT 'COMMON_TYPE ID',
    PRIMARY KEY (common_id),
    CONSTRAINT fk_user_type_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id),
    CONSTRAINT fk_user_type_common FOREIGN KEY (type_id) REFERENCES sys_common_type (common_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자의 다중선택 항목';

-- 희망 근무지(복수선택, 시도/시군구 계층)
--   시도(sido): REGION_SIDO 코드값 / 시군구(sigungu): 프론트 매핑값 그대로 저장
--   '전체'=해당 시도 전역, 시도='전국'/'해외'는 sigungu 동일값
CREATE TABLE IF NOT EXISTS sys_user_desired_region (
    region_id BIGINT       NOT NULL AUTO_INCREMENT COMMENT '희망근무지 ID',
    user_id   BIGINT       NOT NULL                COMMENT '사용자 ID',
    sido      VARCHAR(20)  NOT NULL                COMMENT '시/도(REGION_SIDO)',
    sigungu   VARCHAR(30)                          COMMENT '시/군/구(전체 포함)',
    PRIMARY KEY (region_id),
    CONSTRAINT fk_desired_region_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자 희망 근무지';

-- 경력 성장 목표 (페르소나4 / 04b career-goal-growth)
--   ①직급/⑤역량/⑦평가요소: sys_common_type 코드값 / ②연차: INT(0=1년미만)
--   ③④⑥: 자유 입력. ①②③⑥은 career/user_info 에서 prefill 후 제출 스냅샷 저장
CREATE TABLE IF NOT EXISTS sys_career_growth_goal (
    goal_id           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '경력성장 목표 ID',
    user_id           BIGINT       NOT NULL                COMMENT '사용자 ID',
    current_rank_code INT                                  COMMENT '현재 직급(RANK, 작성 시 스냅샷)',
    current_years     INT                                  COMMENT '현재 연차(0=1년미만, 1~30)',
    current_duties    TEXT                                 COMMENT '현재 담당 업무',
    target_role       VARCHAR(100)                         COMMENT '목표 보직/직급(자유 입력)',
    target_pay        VARCHAR(50)                          COMMENT '목표 처우-기대 연봉(자유 입력)',
    eval_factor_code  INT                                  COMMENT '핵심 평가 반영 요소(EVAL_FACTOR, 단일)',
    created_at        TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    updated_at        TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '수정 시각',
    PRIMARY KEY (goal_id),
    CONSTRAINT fk_growth_goal_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='경력 성장 목표(승진·보직)';

-- 강화할 리더십·역량 (복수선택, 위 목표의 자식)
CREATE TABLE IF NOT EXISTS sys_career_growth_skill (
    skill_id   BIGINT NOT NULL AUTO_INCREMENT COMMENT '역량 매핑 ID',
    goal_id    BIGINT NOT NULL                COMMENT '경력성장 목표 ID',
    skill_code INT    NOT NULL                COMMENT '리더십 역량(LEADERSHIP_SKILL)',
    PRIMARY KEY (skill_id),
    CONSTRAINT fk_growth_skill_goal FOREIGN KEY (goal_id) REFERENCES sys_career_growth_goal (goal_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='경력 성장 목표 - 강화 역량';

-- 스크랩 타깃 지정(델타) — 스크랩 자체는 TN_INDVDL_PBLANC_SCRAP 사용.
--   AI 타깃 JD 지정 여부만 sys 보관. TN 스크랩행(복합키)에 1:1 부착.
--   FK 는 정의 순서상 파일 하단 ALTER.
CREATE TABLE IF NOT EXISTS sys_user_job_scrap (
    indvdl_user_sn BIGINT       NOT NULL              COMMENT 'TN_INDVDL_PBLANC_SCRAP.INDVDL_USER_SN',
    instt_user_sn  BIGINT       NOT NULL              COMMENT 'TN_INDVDL_PBLANC_SCRAP.INSTT_USER_SN',
    pblanc_sn      BIGINT       NOT NULL              COMMENT 'TN_INDVDL_PBLANC_SCRAP.PBLANC_SN',
    is_target      TINYINT(1)   NOT NULL DEFAULT 0    COMMENT '타깃 JD 지정 여부(AI 델타)',
    created_at     TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (indvdl_user_sn, instt_user_sn, pblanc_sn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='스크랩 타깃 지정(델타) - TN_INDVDL_PBLANC_SCRAP 확장';

-- 교육 및 멘토링 상세정보 (EDUCATION 서브타입)
--   교육 본체(명/내용/정원/기간 등)는 sys_resource.source_ref_id → TN_EDC_BSNS/TN_EDC_INFO 에서 읽음.
--   online_yn  : WBRIDGE 는 NULL→TN(TN_EDC_INFO.ONLINE_EDC_TY_CODE/SET_EDC_TY_CODE), 외부만 직접 채움
--   mentoring_yn: TN 에 대응 없음 → 모든 행 sys 보관(진짜 델타)
CREATE TABLE IF NOT EXISTS sys_education_program (
    education_id BIGINT  NOT NULL AUTO_INCREMENT COMMENT '교육 ID',
    resource_id  BIGINT  NOT NULL                COMMENT 'RESOURCE FK',
    online_yn    BOOLEAN                         COMMENT '온라인 여부(WBRIDGE 는 NULL→TN)',
    mentoring_yn BOOLEAN                         COMMENT '멘토링 여부(TN 없음·sys 델타)',
    created_at   TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성일',
    PRIMARY KEY (education_id),
    CONSTRAINT fk_edu_program_resource FOREIGN KEY (resource_id) REFERENCES sys_resource (resource_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='교육 및 멘토링 상세정보(EDUCATION 서브타입)';

-- 지원사업 상세 정보
CREATE TABLE IF NOT EXISTS sys_support_program (
    support_id  BIGINT NOT NULL AUTO_INCREMENT COMMENT '지원사업 ID',
    resource_id BIGINT NOT NULL                COMMENT 'RESOURCE FK',
    created_at  TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성일',
    PRIMARY KEY (support_id),
    CONSTRAINT fk_support_program_resource FOREIGN KEY (resource_id) REFERENCES sys_resource (resource_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='지원사업 상세 정보';

-- 지원한 공고
CREATE TABLE IF NOT EXISTS sys_application (
    application_id BIGINT       NOT NULL AUTO_INCREMENT COMMENT '지원 ID',
    user_id        BIGINT       NOT NULL                COMMENT '사용자 ID',
    resource_id    BIGINT       NOT NULL                COMMENT '지원 대상 리소스',
    applied_at     TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '지원 시각',
    PRIMARY KEY (application_id),
    CONSTRAINT fk_application_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id),
    CONSTRAINT fk_application_resource FOREIGN KEY (resource_id) REFERENCES sys_resource (resource_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='지원한 공고';

-- 역량 진단
CREATE TABLE IF NOT EXISTS sys_competency_diagnosis (
    competency_id        BIGINT NOT NULL AUTO_INCREMENT COMMENT '역량 ID',
    user_id              BIGINT NOT NULL                COMMENT '사용자 ID',
    version_code         VARCHAR(20)                    COMMENT '진단/리포트 버전 (예: v1.0, v3.2)',
    diagnosis_type       VARCHAR(30)                    COMMENT '진단 유형(LIGHT 라이트형/COMPREHENSIVE 종합형/AI_COACHING AI코칭)',
    persona_code         INT                            COMMENT '진단 시점 페르소나(스냅샷, 이력용)',
    desired_job          VARCHAR(100)                   COMMENT '진단 시점 희망 직무(스냅샷, 예: 바이오 R&D · 항체/공정)',
    concern_summary      VARCHAR(255)                   COMMENT '진단 시점 주요 고민 요약(스냅샷)',
    total_score          INT                            COMMENT '종합 점수(0~100 만점, 가중) · 대시보드/순위용',
    cohort_size          INT                            COMMENT '코호트 모수 인원(스냅샷, nullable)',
    cohort_percentile    INT                            COMMENT '코호트 내 상위 백분위(스냅샷, nullable)',
    professionalism_score INT                           COMMENT '전문성(0~100 만점)',
    digital_score        INT                            COMMENT '디지털(0~100 만점)',
    leadership_score     INT                            COMMENT '리더십(0~100 만점)',
    problem_solving_score INT                           COMMENT '문제해결(0~100 만점)',
    communication_score  INT                            COMMENT '커뮤니케이션(0~100 만점)',
    created_at           TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '진단 시각',
    PRIMARY KEY (competency_id),
    CONSTRAINT fk_competency_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='역량 진단';

-- 진단별 투입 타깃 JD (분석 입력 이력/재현용)
CREATE TABLE IF NOT EXISTS sys_diagnosis_target_jd (
    diagnosis_id   BIGINT NOT NULL                COMMENT '역량진단 FK',
    job_posting_id BIGINT NOT NULL                COMMENT '타깃 공고 ID(스냅샷 포인터·폴리모픽: TN 공고 PBLANC_SN 또는 sys 공고, FK 미설정)',
    jd_snapshot    TEXT                           COMMENT '분석 시점 JD 본문 스냅샷',
    created_at     TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (diagnosis_id, job_posting_id),
    CONSTRAINT fk_dtj_diagnosis FOREIGN KEY (diagnosis_id) REFERENCES sys_competency_diagnosis (competency_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='진단별 투입 타깃 JD';

-- 진단 세션
CREATE TABLE IF NOT EXISTS sys_diagnosis_session (
    session_id   BIGINT      NOT NULL AUTO_INCREMENT COMMENT '세션 ID',
    user_id      BIGINT      NOT NULL                COMMENT '사용자 ID',
    status       VARCHAR(30)                         COMMENT '상태(IN_PROGRESS, COMPLETED, ABANDONED)',
    current_step VARCHAR(30)                         COMMENT '현재 단계(step1~step6)',
    started_at   TIMESTAMP(6)                        COMMENT '시작 시각',
    completed_at TIMESTAMP(6)                        COMMENT '완료 시각',
    PRIMARY KEY (session_id),
    CONSTRAINT fk_diagnosis_session_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='진단 세션';

-- AI 코칭 의견  (diagnosis_id → sys_competency_diagnosis.competency_id FK 설정)
CREATE TABLE IF NOT EXISTS sys_ai_coaching_comment (
    coaching_id        BIGINT       NOT NULL AUTO_INCREMENT COMMENT '코칭 ID',
    diagnosis_id       BIGINT       NOT NULL                COMMENT '진단 FK',
    coaching_type_code VARCHAR(30)  NOT NULL                COMMENT '1.종합진단평 2.세부고민해석 3.강점활용 4.약점보완 5.당장 해야할일',
    content            TEXT                                 COMMENT '코칭 내용',
    created_at         TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성일',
    PRIMARY KEY (coaching_id),
    CONSTRAINT fk_coaching_diagnosis FOREIGN KEY (diagnosis_id) REFERENCES sys_competency_diagnosis (competency_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 코칭 의견';

-- 액션 플래너
CREATE TABLE IF NOT EXISTS sys_action_planner (
    planner_id       BIGINT      NOT NULL AUTO_INCREMENT COMMENT '플래너 ID',
    user_id          BIGINT      NOT NULL                COMMENT '사용자 ID',
    diagnosis_id     BIGINT                              COMMENT '담은 출처 진단(이력별 액션 카운트용, nullable)',
    resource_id      BIGINT                              COMMENT '연결 리소스(추천 항목; 자유입력 시 NULL)',
    custom_title     VARCHAR(255)                        COMMENT '직접 입력 활동명(자유입력 시)',
    source_type_code VARCHAR(30)                         COMMENT '추천 출처 (w브릿지 추천, 외부 연계, 외부 추천, 직접입력 등)',
    term_code        VARCHAR(20)                         COMMENT '기간 구분(SHORT/MID/LONG · 단기/중기/장기)',
    status_code      VARCHAR(20)  DEFAULT 'TODO'         COMMENT '진행 상태(TODO/IN_PROGRESS/DONE)',
    PRIMARY KEY (planner_id),
    CONSTRAINT fk_action_planner_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id),
    CONSTRAINT fk_action_planner_resource FOREIGN KEY (resource_id) REFERENCES sys_resource (resource_id),
    CONSTRAINT fk_action_planner_diagnosis FOREIGN KEY (diagnosis_id) REFERENCES sys_competency_diagnosis (competency_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='액션 플래너';

-- AI 리포트 조사
CREATE TABLE IF NOT EXISTS sys_ai_report_survey (
    survey_id   BIGINT       NOT NULL AUTO_INCREMENT COMMENT '설문 ID',
    user_id     BIGINT       NOT NULL                COMMENT '사용자 ID',
    report_id   BIGINT                               COMMENT '평가 대상 리포트 ID(sys_ai_report)',
    question_no INT                                  COMMENT '문항 번호(1~4)',
    rating      INT                                  COMMENT '별점(1~5)',
    opinion     TEXT                                 COMMENT '의견',
    sentiment          VARCHAR(10)                   COMMENT '감성 분류(POSITIVE/NEUTRAL/NEGATIVE, NLP 파생)',
    complaint_category VARCHAR(50)                   COMMENT '불만 요소 토픽(부정일 때, NLP 파생, nullable)',
    surveyed_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '조사일',
    PRIMARY KEY (survey_id),
    CONSTRAINT fk_report_survey_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 리포트 조사';

-- 사용자 행동 로그
CREATE TABLE IF NOT EXISTS sys_user_activity_log (
    activity_log_id BIGINT       NOT NULL AUTO_INCREMENT COMMENT '로그 고유 ID',
    user_id         BIGINT       NOT NULL                COMMENT '사용자 ID',
    action_type     VARCHAR(50)                          COMMENT '행동 유형(click, view, rate, submit, thumbs 등)',
    action_value    VARCHAR(100)                         COMMENT '행동 값(예: down, ★5, thumbs_up)',
    target_type     VARCHAR(100)                         COMMENT '대상 유형(diagnosis, report, recommendation 등)',
    target_id       BIGINT                               COMMENT '대상 ID',
    created_at      TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (activity_log_id),
    CONSTRAINT fk_activity_log_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='사용자 행동 로그';

-- AI 리포트  (diagnosis_id → sys_competency_diagnosis.competency_id FK 설정)
CREATE TABLE IF NOT EXISTS sys_ai_report (
    report_id        BIGINT    NOT NULL AUTO_INCREMENT COMMENT '리포트 ID',
    user_id          BIGINT    NOT NULL                COMMENT '사용자 ID',
    diagnosis_id     BIGINT    NOT NULL                COMMENT '진단 ID',
    report_type      VARCHAR(30) DEFAULT 'COACHING'    COMMENT '리포트 탭 구분(COACHING/ACTIVITY_ANALYSIS/ACTION_PLAN). 동일 진단에 탭별 1행',
    banner_title     VARCHAR(255)                      COMMENT 'AI 생성 환영 제목(…회원님, 환영합니다. 전체 문장)',
    subtitle         VARCHAR(255)                      COMMENT 'AI 생성 부제목(예: 화학·바이오 기술직 직무 전환 전략)',
    keywords         TEXT                              COMMENT 'AI 생성 키워드 칩, 줄바꿈(\\n) 구분. 줄 형식 = 아이콘명|라벨 (예: flask|화학·바이오 산업)',
    content          LONGTEXT                          COMMENT '생성 리포트 본문. 구조화 JSON 문서 또는 통짜 TEXT(공백·줄바꿈 그대로) 모두 허용 — 프론트가 자동 감지 렌더',
    response_time_ms INT                               COMMENT '응답 시간(ms)',
    created_at       TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (report_id),
    CONSTRAINT fk_ai_report_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id),
    CONSTRAINT fk_ai_report_diagnosis FOREIGN KEY (diagnosis_id) REFERENCES sys_competency_diagnosis (competency_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 리포트';

-- AI 답변 품질 지표
CREATE TABLE IF NOT EXISTS sys_ai_report_quality (
    quality_id           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '품질 측정 ID',
    report_id            BIGINT       NOT NULL                COMMENT '리포트 ID',
    faithfulness_score   DECIMAL(5,2)                         COMMENT '신뢰성 = 일치율',
    accuracy_score       DECIMAL(5,2)                         COMMENT '정확성 = 답변의 적절성',
    job_reflection_score DECIMAL(5,2)                         COMMENT '직무 반영도 = 직무 키워드 매칭도',
    relevance_score      DECIMAL(5,2)                         COMMENT '관련성',
    quality_issue        VARCHAR(50)                          COMMENT '품질 저하 사유 토픽(낮은 만족도 분석, nullable)',
    created_at           TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (quality_id),
    CONSTRAINT fk_report_quality_report FOREIGN KEY (report_id) REFERENCES sys_ai_report (report_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 답변 품질 지표';

-- =====================================================================
-- 저장 리포트 (AI 코칭 / 활동 분석 / 액션 플랜)
--     · AI 코칭   -> sys_report_coaching (AI 본문 텍스트 스냅샷)
--     · 활동 분석 -> (역량 점수/해설/JD비교 전용 테이블 · 추후)
--     · 액션 플랜 -> sys_action_planner 등 라이브 테이블 연결 · 추후
-- =====================================================================

-- AI 코칭 본문 (리포트 1건당 1행)
--   content = AI가 생성한 본문만 저장(배너/아이콘/색상 등 표현은 페르소나로 재렌더).
--   구조: { "intro":[...], "sections":[{ "no","title","paras"|"points" }], "closing":... }
CREATE TABLE IF NOT EXISTS sys_report_coaching (
    report_id  BIGINT       NOT NULL                COMMENT '리포트 ID(1:1)',
    content    JSON                                 COMMENT 'AI 코칭 본문 스냅샷(intro/sections/closing)',
    created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (report_id),
    CONSTRAINT fk_report_coaching_report FOREIGN KEY (report_id) REFERENCES sys_ai_report (report_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='리포트 - AI 코칭 본문';

-- =====================================================================
-- 리포트 - 활동 분석 (역량 진단 결과 스냅샷)
--   점수는 AI 산출. 차트(ring/radar)·아이콘·색상은 저장 안 하고 점수로 재렌더.
--   강점/보완 TOP3·12역량·역량별 해설은 모두 sys_report_competency 의 뷰.
-- =====================================================================

-- 활동분석 탭 요약 (리포트 1건당 1행)
CREATE TABLE IF NOT EXISTS sys_report_activity (
    report_id        BIGINT       NOT NULL                COMMENT '리포트 ID(1:1)',
    cfi_score        INT                                  COMMENT 'CFI 경력활동지수(0~100) · 비교용',
    cfi_delta        VARCHAR(30)                          COMMENT 'CFI 증감 표기(예: ↑ 평균 +8)',
    summary_title    VARCHAR(200)                         COMMENT 'CFI 요약 제목',
    summary_text     TEXT                                 COMMENT 'CFI 요약 본문(<b> 강조 허용)',
    keyword_badges   TEXT                                 COMMENT 'CFI 배지, 줄바꿈 구분. 줄 형식 = tone|라벨 (예: blue|강점 · 분자생물학 실험 설계)',
    criteria_summary TEXT                                 COMMENT '기준 정합도 종합 해설(<b> 강조 허용)',
    market_summary   TEXT                                 COMMENT '시장 정합도 종합 해설(<b> 강조 허용)',
    avg_fit_rate     INT                                  COMMENT '평균 JD 적합률(%) · 선택',
    created_at       TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (report_id),
    CONSTRAINT fk_report_activity_report FOREIGN KEY (report_id) REFERENCES sys_ai_report (report_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='리포트 - 활동분석 요약';

-- 역량별 점수/해설
CREATE TABLE IF NOT EXISTS sys_report_competency (
    competency_id  BIGINT       NOT NULL AUTO_INCREMENT COMMENT '역량 ID',
    report_id      BIGINT       NOT NULL                COMMENT '리포트 ID',
    fit_type       VARCHAR(20)                          COMMENT '정합도 구분(CRITERIA 기준정합도/MARKET 시장정합도/HIGHLIGHT 강점·보완 TOP)',
    group_code     VARCHAR(30)                          COMMENT '그룹(CRITERIA:공통/직무/리더십, MARKET:Knowledge/Skill/Attitude)',
    level_code     VARCHAR(10)                          COMMENT '요구 레벨(MARKET:기초/실무/심화)',
    name           VARCHAR(100) NOT NULL                COMMENT '역량명',
    my_score       INT                                  COMMENT '내 점수(0~100 만점, AI 산출) · 비교용',
    required_score INT                                  COMMENT '기준 수준(CRITERIA:집단평균, MARKET:레벨요구, HIGHLIGHT:목표) · 비교용',
    status         VARCHAR(10)                          COMMENT '구분(STRENGTH/GAP) · HIGHLIGHT 행에서 사용',
    icon           VARCHAR(30)                          COMMENT '칩 아이콘명(HIGHLIGHT TOP3 표시용)',
    comment        TEXT                                 COMMENT '역량별 해설(AI 평어)',
    sort_order     INT          DEFAULT 0               COMMENT '그룹 내 표시 순서',
    created_at     TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (competency_id),
    CONSTRAINT fk_report_competency_report FOREIGN KEY (report_id) REFERENCES sys_ai_report (report_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='리포트 - 역량별 점수/해설';

-- 역량별 근거 소스 (이력서/JD 요구/RAG 사례/시장 동향 등)
CREATE TABLE IF NOT EXISTS sys_report_competency_source (
    source_id     BIGINT       NOT NULL AUTO_INCREMENT COMMENT '근거 소스 ID',
    competency_id BIGINT       NOT NULL                COMMENT '역량 ID',
    source_type   VARCHAR(50)                          COMMENT '소스 구분(이력서/JD 요구/RAG 사례 등)',
    detail        VARCHAR(255)                         COMMENT '근거 내용',
    is_primary    TINYINT(1)   DEFAULT 0               COMMENT '대표(최선) 소스 여부',
    PRIMARY KEY (source_id),
    CONSTRAINT fk_competency_source_comp FOREIGN KEY (competency_id) REFERENCES sys_report_competency (competency_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='리포트 - 역량 근거 소스';

-- 스크랩 JD와 내 역량 비교
CREATE TABLE IF NOT EXISTS sys_report_jd_match (
    match_id       BIGINT       NOT NULL AUTO_INCREMENT COMMENT 'JD 비교 ID',
    report_id      BIGINT       NOT NULL                COMMENT '리포트 ID',
    job_posting_id BIGINT                               COMMENT '스크랩 공고 ID(스냅샷이라 FK 미설정)',
    company        VARCHAR(100)                         COMMENT '회사명',
    role           VARCHAR(150)                         COMMENT '직무',
    meta           VARCHAR(200)                         COMMENT '위치·연봉 등',
    fit_rate       INT                                  COMMENT 'JD 적합률(%) · 비교용',
    match_count    VARCHAR(20)                          COMMENT '충족 역량(예: 8 / 12)',
    recommendation VARCHAR(20)                          COMMENT '추천/도전/관심',
    gap_keywords   TEXT                                 COMMENT '부족 역량, 줄바꿈 구분',
    strengths      TEXT                                 COMMENT '충족 강점, 줄바꿈 구분',
    advices        TEXT                                 COMMENT '보완 제안, 줄바꿈 구분',
    created_at     TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (match_id),
    CONSTRAINT fk_report_jd_match_report FOREIGN KEY (report_id) REFERENCES sys_ai_report (report_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='리포트 - 스크랩 JD 역량 비교';

-- =====================================================================
-- 리포트 - 액션 플랜
--   플래너  -> sys_action_planner (resource_id/term_code/source_type_code/status_code) 재사용
--   추천활동 -> sys_resource (가져온 곳 = source_type_code) 재사용
--   평가     -> sys_ai_report_survey (report_id 연결) 재사용
--   교육·멘토링(부족역량 기반 추천)만 신규:
-- =====================================================================
CREATE TABLE IF NOT EXISTS sys_report_edu_mentoring (
    edu_id     BIGINT       NOT NULL AUTO_INCREMENT COMMENT '교육·멘토링 추천 ID(번호)',
    report_id  BIGINT       NOT NULL                COMMENT '리포트 ID',
    gap_name   VARCHAR(100)                         COMMENT '연계 부족 역량명',
    priority   VARCHAR(20)                          COMMENT '우선순위(최우선/높음/중간)',
    keywords   JSON                                 COMMENT '추천 키워드 목록',
    act_types  JSON                                 COMMENT '추천활동 유형 목록[{type,desc}]',
    created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (edu_id),
    CONSTRAINT fk_report_edu_report FOREIGN KEY (report_id) REFERENCES sys_ai_report (report_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='리포트 - 교육·멘토링 추천';

-- (리포트 통합) survey 정의가 sys_ai_report 보다 앞서므로 ALTER 로 FK 연결
ALTER TABLE sys_ai_report_survey ADD CONSTRAINT fk_report_survey_report FOREIGN KEY (report_id) REFERENCES sys_ai_report (report_id);

-- API 호출 로그
CREATE TABLE IF NOT EXISTS sys_api_logs (
    api_log_id       BIGINT       NOT NULL AUTO_INCREMENT COMMENT '로그 ID',
    user_id          BIGINT       NOT NULL                COMMENT '사용자 ID',
    endpoint         VARCHAR(255)                         COMMENT '호출 API',
    status_code      VARCHAR(10)                          COMMENT '응답 코드',
    response_time_ms INT                                  COMMENT '응답 시간(ms)',
    created_at       TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 시각',
    PRIMARY KEY (api_log_id),
    CONSTRAINT fk_api_logs_user FOREIGN KEY (user_id) REFERENCES sys_user_profile (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='API 호출 로그';

-- =====================================================================
-- 레거시 (기존 WISET 운영 테이블) — 원본 구조 그대로 추가. 타입만 MySQL 변환
--   (NUMBER->BIGINT, VARCHAR2->VARCHAR, DATE->DATETIME, SYSDATE->CURRENT_TIMESTAMP,
--    초대형 VARCHAR2(>=1000)->TEXT : MySQL 행 크기 제한 회피). 컬럼/제약은 불변.
-- =====================================================================

-- 교육사업
CREATE TABLE IF NOT EXISTS TN_EDC_BSNS (
    EDC_BSNS_SN      BIGINT       NOT NULL              COMMENT '교육사업순번',
    EDC_BSNS_SE_CODE VARCHAR(5)   NOT NULL              COMMENT '교육구분코드',
    NTCE_AT          VARCHAR(1)   NOT NULL DEFAULT 'N'  COMMENT '게시여부',
    NTCN_SN          BIGINT       NOT NULL              COMMENT '알림순번',
    RGSDE            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    REGISTER         VARCHAR(20)  NOT NULL              COMMENT '등록자',
    UPDDE            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    UPDUSR           VARCHAR(20)  NOT NULL              COMMENT '수정자',
    PRIMARY KEY (EDC_BSNS_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='교육사업';

-- 공통코드  (※ 우리 sys_common_type 와 역할 겹침 — 통합 정리 대상)
CREATE TABLE IF NOT EXISTS TN_CODE (
    GROUP_CODE VARCHAR(5)   NOT NULL              COMMENT '그룹코드',
    CODE       VARCHAR(5)   NOT NULL              COMMENT '코드',
    CODE_NM    VARCHAR(50)                        COMMENT '코드명',
    SORT       INT                                COMMENT '정렬',
    USE_AT     VARCHAR(1)   DEFAULT 'Y'           COMMENT '사용여부',
    CODE_DC    VARCHAR(200)                       COMMENT '코드설명',
    RGSDE      DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    REGISTER   VARCHAR(20)                        COMMENT '등록자',
    UPDDE      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    UPDUSR     VARCHAR(20)                        COMMENT '수정자',
    PRIMARY KEY (GROUP_CODE, CODE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='공통코드';

-- 구직자 정보  (※ TN_USER_INFO 의 1:1 확장. 우리 sys_user_profile 와 강하게 겹침 — 통합 정리 대상)
--   명세상 USER_SN 이 AI=Y(독립 시퀀스)·FK 미지정이라 그대로 둠. 1:1 이면 FK 추가 검토.
CREATE TABLE IF NOT EXISTS TN_INDVDL_INFO (
    USER_SN            BIGINT       NOT NULL AUTO_INCREMENT COMMENT '사용자 순번',
    USER_NM            VARCHAR(20)  NOT NULL              COMMENT '사용자 명',
    BRTHDY             VARCHAR(8)   NOT NULL              COMMENT '생년월일',
    MBTLNUM            VARCHAR(13)  NOT NULL              COMMENT '휴대폰번호',
    SMS_RECPTN_AT      VARCHAR(1)                         COMMENT 'SMS 수신 여부',
    EMAIL              VARCHAR(100)                       COMMENT '이메일',
    EMAIL_RECPTN_AT    VARCHAR(1)                         COMMENT '이메일 수신 여부',
    SEXDSTN_SE_CODE    VARCHAR(5)                         COMMENT '성별구분코드',
    DMSTC_AT           VARCHAR(1)                         COMMENT '국내여부',
    ZIP                VARCHAR(7)                         COMMENT '우편번호',
    ADRES              VARCHAR(100)                       COMMENT '주소명',
    DTL_ADRES          VARCHAR(100)                       COMMENT '상세 주소',
    INTRST_BSNS_CODE   VARCHAR(5)                         COMMENT '관심 사업 코드',
    JSSFC_SE_CODE      VARCHAR(5)                         COMMENT '직종구분코드',
    DTY_SE_CODE        VARCHAR(5)                         COMMENT '직무 구분 코드',
    TROBL_CODE         VARCHAR(5)                         COMMENT '장애 코드',
    PRTFOLIO_FILE_ID   INT                                COMMENT '포트폴리오 파일 ID',
    MTRSC_CODE         VARCHAR(5)                         COMMENT '병역 코드',
    LAST_ACDMCR_CODE   VARCHAR(5)                         COMMENT '최종 학력 코드',
    CAREER_PD          INT                                COMMENT '경력 기간',
    CAREER_AT          VARCHAR(1)                         COMMENT '경력 여부',
    EMPYMN_PVLTRT_CODE VARCHAR(5)                         COMMENT '취업 우대 코드',
    REGISTER           VARCHAR(20)                        COMMENT '등록자',
    RGSDE              DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR             VARCHAR(20)                        COMMENT '수정자',
    UPDDE              DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    USER_TY_CODE       VARCHAR(5)                         COMMENT '사용자 유형 코드',
    SBSCRB_RESN_CODE   VARCHAR(5)                         COMMENT '가입 사유 코드',
    SBSCRB_RESN        VARCHAR(200)                       COMMENT '가입 사유',
    PRIMARY KEY (USER_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='구직자 정보';

-- 첨부파일
--   ※ 원본은 FILE_SN, FILE_ID 둘 다 AI=Y 이나 MySQL은 테이블당 AUTO_INCREMENT 1개만 허용.
--      PK인 FILE_SN 만 AUTO_INCREMENT 로 두고 FILE_ID 는 일반 컬럼으로 둠(시퀀스 필요 시 별도 처리).
CREATE TABLE IF NOT EXISTS TN_ATCH_FILE (
    FILE_SN        BIGINT       NOT NULL AUTO_INCREMENT COMMENT '파일 순번',
    FILE_ID        BIGINT       NOT NULL                COMMENT '파일 ID',
    FILE_PATH      VARCHAR(50)  NOT NULL                COMMENT '파일 경로',
    ORGINL_FILE_NM VARCHAR(200) NOT NULL                COMMENT '원본 파일 명',
    STRE_FILE_NM   VARCHAR(100) NOT NULL                COMMENT '저장 파일 명',
    FILE_SIZE      BIGINT                               COMMENT '파일 사이즈',
    DWLD_CO        INT          DEFAULT 0               COMMENT '다운로드 수',
    REGISTER       VARCHAR(20)  NOT NULL                COMMENT '등록자',
    RGSDE          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    PRIMARY KEY (FILE_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='첨부파일';

-- 교육정보 (교육사업 1:1 상세)
CREATE TABLE IF NOT EXISTS TN_EDC_INFO (
    EDC_BSNS_SN        BIGINT       NOT NULL              COMMENT '교육사업순번',
    ONLINE_EDC_TY_CODE VARCHAR(5)                         COMMENT '온라인교육유형코드',
    SET_EDC_TY_CODE    VARCHAR(5)                         COMMENT '집합교육유형코드',
    EDC_NM             VARCHAR(100)                       COMMENT '교육명',
    EDC_PURPS_NM       VARCHAR(200)                       COMMENT '교육목적명',
    EDC_CN             LONGTEXT                           COMMENT '교육내용(원본 CLOB)',
    EDC_PSNCPA_CO      INT                                COMMENT '교육정원수',
    DAY1_EDC_TIME      DATETIME                           COMMENT '1일교육시간',
    RCEPT_BEGIN_DT     DATETIME                           COMMENT '접수시작일시',
    RCEPT_END_DT       DATETIME                           COMMENT '접수종료일시',
    PEPSPLMN_BEGIN_DT  DATETIME                           COMMENT '서류보완시작일시',
    PEPSPLMN_END_DT    DATETIME                           COMMENT '서류보완종료일시',
    EDC_BEGIN_DE       DATETIME                           COMMENT '교육시작일자',
    EDC_END_DE         DATETIME                           COMMENT '교육종료일자',
    COMPL_NO_FOM       VARCHAR(100)                       COMMENT '수료 번호 형식',
    RDCNT              INT          DEFAULT 0             COMMENT '조회수',
    RGSDE              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    REGISTER           VARCHAR(20)  NOT NULL              COMMENT '등록자',
    UPDDE              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    UPDUSR             VARCHAR(20)  NOT NULL              COMMENT '수정자',
    PRIMARY KEY (EDC_BSNS_SN),
    CONSTRAINT fk_edc_info_bsns FOREIGN KEY (EDC_BSNS_SN) REFERENCES TN_EDC_BSNS (EDC_BSNS_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='교육정보';

-- 이력서 학력
--   ※ FK RESUME_SN → TN_RESUME 이나 해당 테이블 미수신 → FK 보류(추후 추가).
CREATE TABLE IF NOT EXISTS TN_RESUME_ACDMCR (
    ACDMCR_SN         BIGINT       NOT NULL              COMMENT '학력 순번',
    RESUME_SN         BIGINT       NOT NULL              COMMENT '이력서순번',
    SCHUL_NM          VARCHAR(100) NOT NULL              COMMENT '학교 명',
    ACDMCR_BEGIN_DE   VARCHAR(12)                        COMMENT '학력 시작 일자',
    ACDMCR_END_DE     VARCHAR(12)                        COMMENT '학력 종료 일자',
    ACDMCR_SE_CODE    VARCHAR(5)                         COMMENT '학력 구분 코드',
    MAJOR_NM          VARCHAR(50)                        COMMENT '전공명',
    PNT               DECIMAL(5,2)                       COMMENT '학점',
    TOTALPNT          DECIMAL(5,2)                       COMMENT '총점',
    THESIS_CN         VARCHAR(200)                       COMMENT '논문 내용',
    REGISTER          VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR            VARCHAR(20)  NOT NULL              COMMENT '수정자',
    UPDDE             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    ACDMCR_CODE       VARCHAR(5)                         COMMENT '학력 코드',
    AREA_NM           VARCHAR(50)                        COMMENT '지역 명',
    LAST_DGRI_SE_CODE VARCHAR(5)                         COMMENT '최종학위구분코드',
    PRIMARY KEY (ACDMCR_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 학력';

-- 이력서 자기소개  (※ FK RESUME_SN → TN_RESUME 미수신 → FK 보류)
CREATE TABLE IF NOT EXISTS TN_RESUME_SELF_INTRCN (
    SELF_INTRCN_SN BIGINT       NOT NULL              COMMENT '자기 소개 순번',
    RESUME_SN      BIGINT       NOT NULL              COMMENT '이력서순번',
    SELF_INTRCN_SJ VARCHAR(200)                       COMMENT '자기 소개 제목',
    REGISTER       VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR         VARCHAR(20)  NOT NULL              COMMENT '수정자',
    UPDDE          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    SELF_INTRCN_CN TEXT                               COMMENT '자기 소개 내용(원본 VARCHAR2(4000))',
    PRIMARY KEY (SELF_INTRCN_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 자기소개';

-- 이력서 경력  (※ FK RESUME_SN → TN_RESUME 미수신 → FK 보류)
CREATE TABLE IF NOT EXISTS TN_RESUME_CAREER (
    CAREER_SN       BIGINT       NOT NULL              COMMENT '경력 순번',
    RESUME_SN       BIGINT       NOT NULL              COMMENT '이력서순번',
    CAREER_INSTT_NM VARCHAR(100)                       COMMENT '경력 기관 명',
    DEPT_NM         VARCHAR(50)                        COMMENT '부서 명',
    CLSF_NM         VARCHAR(100)                       COMMENT '직급명',
    DTY_NM          VARCHAR(100)                       COMMENT '직무 명',
    ANSLRY_AM       BIGINT                             COMMENT '연봉금액',
    CAREER_CN       TEXT                               COMMENT '경력내용(원본 VARCHAR2(4000))',
    CAREER_BEGIN_DE VARCHAR(10)                        COMMENT '경력 시작 일자',
    CAREER_END_DE   VARCHAR(12)                        COMMENT '경력 종료 일자',
    RETIRE_RESN_CN  VARCHAR(100)                       COMMENT '퇴직 사유 내용',
    REGISTER        VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR          VARCHAR(20)  NOT NULL              COMMENT '수정자',
    UPDDE           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (CAREER_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 경력';

-- 이력서 포트폴리오 URL  (※ FK RESUME_SN → TN_RESUME 미수신 → FK 보류)
CREATE TABLE IF NOT EXISTS TN_RESUME_PRTFOLIO_URL (
    PRTFOLIO_URL_SN BIGINT       NOT NULL              COMMENT '포트폴리오 URL 순번',
    RESUME_SN       BIGINT       NOT NULL              COMMENT '이력서순번',
    PRTFOLIO_URL    VARCHAR(100) NOT NULL              COMMENT '포트폴리오 URL',
    REGISTER        VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR          VARCHAR(20)  NOT NULL              COMMENT '수정자',
    UPDDE           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (PRTFOLIO_URL_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 포트폴리오 URL';

-- 이력서 자격증  (※ FK RESUME_SN → TN_RESUME 미수신 → FK 보류)
CREATE TABLE IF NOT EXISTS TN_RESUME_CRQFC (
    CRQFC_SN         BIGINT       NOT NULL              COMMENT '자격증 순번',
    RESUME_SN        BIGINT       NOT NULL              COMMENT '이력서순번',
    CRQFC_NM         VARCHAR(100) NOT NULL              COMMENT '자격증명',
    ACQS_DE          DATETIME                           COMMENT '취득 일자',
    MTD              VARCHAR(5)                         COMMENT '만기일',
    PBLICTE_INSTT_NM VARCHAR(50)                        COMMENT '발행기관명',
    REGISTER         VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR           VARCHAR(20)  NOT NULL              COMMENT '수정자',
    UPDDE            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (CRQFC_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 자격증';

-- 이력서 교육연수  (※ FK RESUME_SN → TN_RESUME 미수신 → FK 보류)
CREATE TABLE IF NOT EXISTS TN_RESUME_EDC (
    EDC_SN       BIGINT       NOT NULL              COMMENT '교육순번',
    RESUME_SN    BIGINT       NOT NULL              COMMENT '이력서순번',
    EDC_NM       VARCHAR(100)                       COMMENT '교육명',
    EDC_BEGIN_DE DATETIME                           COMMENT '교육시작일자',
    EDC_END_DE   DATETIME                           COMMENT '교육종료일자',
    EDC_INSTT_NM VARCHAR(50)                        COMMENT '교육기관명',
    EDC_CN       LONGTEXT                           COMMENT '교육내용(원본 CLOB)',
    REGISTER     VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR       VARCHAR(20)  NOT NULL              COMMENT '수정자',
    UPDDE        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (EDC_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 교육연수';

-- 이력서 활동  (※ FK RESUME_SN → TN_RESUME 미수신 → FK 보류)
CREATE TABLE IF NOT EXISTS TN_RESUME_ACT (
    ACT_SN       BIGINT       NOT NULL              COMMENT '활동 순번',
    RESUME_SN    BIGINT       NOT NULL              COMMENT '이력서순번',
    ACT_SE_CODE  VARCHAR(5)   NOT NULL              COMMENT '활동 구분 코드',
    ACT_INSTT_NM VARCHAR(100)                       COMMENT '활동 기관 명',
    ACT_BEGIN_DE DATETIME                           COMMENT '활동시작일자',
    ACT_END_DE   DATETIME                           COMMENT '활동종료일자',
    ACT_CN       TEXT                               COMMENT '활동 내용(원본 VARCHAR2(4000))',
    REGISTER     VARCHAR(20)                        COMMENT '등록자',
    RGSDE        DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR       VARCHAR(20)                        COMMENT '수정자',
    UPDDE        DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (ACT_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 활동';

-- 이력서 수상  (※ FK RESUME_SN → TN_RESUME 미수신 → FK 보류)
CREATE TABLE IF NOT EXISTS TN_RESUME_WNPZ (
    WNPZ_SN       BIGINT       NOT NULL              COMMENT '수상 순번',
    RESUME_SN     BIGINT       NOT NULL              COMMENT '이력서순번',
    WNPZ_NM       VARCHAR(100) NOT NULL              COMMENT '수상 명',
    WNPZ_INSTT_NM VARCHAR(100)                       COMMENT '수상 기관 명',
    WNPZ_YEAR     VARCHAR(4)                         COMMENT '수상 년도',
    WNPZ_CN       TEXT                               COMMENT '수상 내용(원본 VARCHAR2(4000))',
    RGSDE         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    REGISTER      VARCHAR(20)  NOT NULL              COMMENT '등록자',
    UPDUSR        VARCHAR(20)  NOT NULL              COMMENT '수정자',
    UPDDE         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (WNPZ_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 수상';

-- 이력서 해외경험  (※ FK RESUME_SN → TN_RESUME 미수신 → FK 보류)
CREATE TABLE IF NOT EXISTS TN_RESUME_OVSEA (
    OVSEA_SN       BIGINT       NOT NULL              COMMENT '해외 순번',
    RESUME_SN      BIGINT       NOT NULL              COMMENT '이력서순번',
    OVSEA_NM       VARCHAR(100)                       COMMENT '해외 명',
    OVSEA_BEGIN_DE VARCHAR(7)                         COMMENT '해외 시작 일자',
    OVSEA_END_DE   VARCHAR(7)                         COMMENT '해외 종료 일자',
    OVSEA_CN       TEXT                               COMMENT '해외 내용(원본 VARCHAR2(4000))',
    REGISTER       VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR         VARCHAR(20)  NOT NULL              COMMENT '수정자',
    UPDDE          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (OVSEA_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 해외경험';

-- 이력서 어학  (※ FK RESUME_SN → TN_RESUME 미수신 → FK 보류)
CREATE TABLE IF NOT EXISTS TN_RESUME_LSTCS (
    LSTCS_SN         BIGINT       NOT NULL              COMMENT '어학 순번',
    RESUME_SN        BIGINT       NOT NULL              COMMENT '이력서순번',
    LSTCS_CODE       VARCHAR(5)   NOT NULL              COMMENT '어학 코드',
    LSTCS_SE_CODE    VARCHAR(5)                         COMMENT '어학 구분 코드',
    LSTCS_NM         VARCHAR(50)                        COMMENT '어학 명',
    LSTCS_ABLTY_CODE VARCHAR(5)                         COMMENT '어학 능력 코드',
    REGISTER         VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR           VARCHAR(20)  NOT NULL              COMMENT '수정자',
    UPDDE            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    LSTCS_KIND       VARCHAR(200)                       COMMENT '어학 종류',
    LSTCS_POINT      VARCHAR(100)                       COMMENT '어학 점수',
    PRIMARY KEY (LSTCS_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 어학';

-- 지역 코드
CREATE TABLE IF NOT EXISTS TN_AREA_CODE (
    AREA_SN       BIGINT      NOT NULL AUTO_INCREMENT COMMENT '지역 순번',
    AREA_NM       VARCHAR(50)                         COMMENT '지역 명',
    UPPER_AREA_SN BIGINT                              COMMENT '상위 지역 순번',
    PRIMARY KEY (AREA_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='지역 코드';

-- 맞춤형교육
CREATE TABLE IF NOT EXISTS TN_EDC_CLTME (
    EDC_BSNS_SN         BIGINT       NOT NULL              COMMENT '교육사업순번',
    EDC_YEAR            VARCHAR(4)   NOT NULL              COMMENT '교육년도',
    CLTME_EDC_TRGT_CODE VARCHAR(5)   NOT NULL              COMMENT '맞춤형교육대상코드',
    CLTME_EDC_NM        VARCHAR(200) NOT NULL              COMMENT '맞춤형교육명',
    RCEPT_BEGIN_DT      DATETIME     NOT NULL              COMMENT '접수시작일시',
    RCEPT_END_DT        DATETIME     NOT NULL              COMMENT '접수종료일시',
    EDC_BEGIN_DT        DATETIME     NOT NULL              COMMENT '교육시작일시',
    EDC_END_DT          DATETIME     NOT NULL              COMMENT '교육종료일시',
    EDC_REQST_CND_CN    TEXT                               COMMENT '교육신청조건내용(원본 VARCHAR2(4000))',
    RGSDE               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    REGISTER            VARCHAR(20)  NOT NULL              COMMENT '등록자',
    UPDDE               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    UPDUSR              VARCHAR(20)  NOT NULL              COMMENT '수정자',
    PRIMARY KEY (EDC_BSNS_SN),
    CONSTRAINT fk_edc_cltme_bsns FOREIGN KEY (EDC_BSNS_SN) REFERENCES TN_EDC_BSNS (EDC_BSNS_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='맞춤형교육';

-- 역량 진단 (※ 우리 sys_competency_diagnosis 와 이름 동일 — 성격은 다름(레거시=진단 폼 정의))
CREATE TABLE IF NOT EXISTS TN_ABILITY_DGNSS (
    EXMNTIN_YEAR    VARCHAR(4)   NOT NULL              COMMENT '진단 년도',
    EXMNTIN_NM      VARCHAR(200) NOT NULL              COMMENT '진단 명',
    EXMNTIN_TOP_SCR INT          DEFAULT 5             COMMENT '진단 최고 점수',
    USE_AT          VARCHAR(1)   DEFAULT 'Y'           COMMENT '사용여부',
    DELETE_AT       CHAR(1)      DEFAULT 'N'           COMMENT '삭제 여부',
    REGISTER        VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR          VARCHAR(20)                        COMMENT '수정자',
    UPDDE           DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (EXMNTIN_YEAR)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='역량 진단';

-- 역량 진단 문항
CREATE TABLE IF NOT EXISTS TN_ABILITY_DGNSS_QESITM (
    EXMNTIN_YEAR     VARCHAR(4)    NOT NULL              COMMENT '진단 년도',
    QESITM_SN        BIGINT        NOT NULL              COMMENT '문항 순번',
    UPPER_QESITM_SN  BIGINT                              COMMENT '상위 문항 순번',
    QESITM_CN        VARCHAR(1000) NOT NULL              COMMENT '문항 내용',
    CAREER_STEP_CODE VARCHAR(5)    NOT NULL              COMMENT '경력 단계 코드',
    DFN_CN           VARCHAR(1000)                       COMMENT '정의 내용',
    DELETE_AT        CHAR(1)       DEFAULT 'N'           COMMENT '삭제 여부',
    REGISTER         VARCHAR(20)   NOT NULL              COMMENT '등록자',
    RGSDE            DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR           VARCHAR(20)                         COMMENT '수정자',
    UPDDE            DATETIME      DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (EXMNTIN_YEAR, QESITM_SN),
    CONSTRAINT fk_ability_dgnss_qesitm_dgnss FOREIGN KEY (EXMNTIN_YEAR) REFERENCES TN_ABILITY_DGNSS (EXMNTIN_YEAR)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='역량 진단 문항';

-- 역량 진단 내용
--   ※ FK QESITM_SN → TN_ABILITY_DGNSS_QESITM 이나 부모 PK가 복합(EXMNTIN_YEAR, QESITM_SN)
--      이라 단일컬럼 매칭 불가 → FK 보류(확인 필요).
CREATE TABLE IF NOT EXISTS TN_ABILITY_DGNSS_CN (
    QESITM_SN         BIGINT       NOT NULL              COMMENT '문항 순번',
    EXMNTIN_RSLT_CODE VARCHAR(5)   NOT NULL              COMMENT '진단 결과 코드',
    RSLT_SN           BIGINT       NOT NULL              COMMENT '결과 순번',
    EXMNTIN_RSLT_CN   TEXT                               COMMENT '진단 결과 내용(원본 VARCHAR2(4000))',
    DELETE_AT         CHAR(1)      DEFAULT 'N'           COMMENT '삭제 여부',
    REGISTER          VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR            VARCHAR(20)                        COMMENT '수정자',
    UPDDE             DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (QESITM_SN, EXMNTIN_RSLT_CODE, RSLT_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='역량 진단 내용';

-- 역량 진단 답변  (※ 위와 동일 사유로 FK 보류)
CREATE TABLE IF NOT EXISTS TN_ABILITY_DGNSS_ANSWER (
    QESITM_SN  BIGINT       NOT NULL              COMMENT '문항 순번',
    ANSWER_SN  BIGINT       NOT NULL              COMMENT '답변 순번',
    ANSWER_CN  TEXT                               COMMENT '답변내용(원본 VARCHAR2(4000))',
    ANSWER_SCR INT                                COMMENT '답변 점수',
    DELETE_AT  CHAR(1)      DEFAULT 'N'           COMMENT '삭제 여부',
    REGISTER   VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR     VARCHAR(20)                        COMMENT '수정자',
    UPDDE      DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (QESITM_SN, ANSWER_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='역량 진단 답변';

-- 역량 진단 참여자
CREATE TABLE IF NOT EXISTS TN_ABILITY_DGNSS_PRTCPNT (
    EXMNTIN_SN       BIGINT      NOT NULL              COMMENT '진단 순번',
    USER_SN          BIGINT      NOT NULL              COMMENT '사용자 순번',
    DTY_CODE         VARCHAR(5)  NOT NULL              COMMENT '직무 코드',
    CAREER_STEP_CODE VARCHAR(5)  NOT NULL              COMMENT '경력 단계 코드',
    EXMNTIN_COMPT_AT VARCHAR(1)  DEFAULT 'N'           COMMENT '진단 완료 여부',
    REGISTER         VARCHAR(20) NOT NULL              COMMENT '등록자',
    RGSDE            DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR           VARCHAR(20)                       COMMENT '수정자',
    UPDDE            DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (EXMNTIN_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='역량 진단 참여자';

-- 역량 진단 참여 이력
CREATE TABLE IF NOT EXISTS TH_ABILITY_DGNSS_PARTCPTN_HIST (
    EXMNTIN_SN              BIGINT      NOT NULL              COMMENT '진단 순번',
    EXMNTIN_HIST_SN         BIGINT      NOT NULL              COMMENT '진단 이력 순번',
    EXMNTIN_PRGRS_STTUS_CODE VARCHAR(5) NOT NULL              COMMENT '진단 진행 상태 코드',
    REGISTER               VARCHAR(20) NOT NULL              COMMENT '등록자',
    RGSDE                  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    PRIMARY KEY (EXMNTIN_SN, EXMNTIN_HIST_SN),
    CONSTRAINT fk_ability_dgnss_partcptn_hist_prtcpnt FOREIGN KEY (EXMNTIN_SN) REFERENCES TN_ABILITY_DGNSS_PRTCPNT (EXMNTIN_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='역량 진단 참여 이력';

-- 역량 진단 참여 내역  (※ QESITM_SN→TN_ABILITY_DGNSS_QESITM 은 부모 복합PK라 보류)
CREATE TABLE IF NOT EXISTS TN_ABILITY_DGNSS_PARTCPTN_DTLS (
    EXMNTIN_SN        BIGINT      NOT NULL              COMMENT '진단 순번',
    QESITM_SN         BIGINT      NOT NULL              COMMENT '문항 순번',
    CHOISE_ANSWER_SN  BIGINT      NOT NULL              COMMENT '선택 답변 순번',
    CHOISE_ANSWER_SCR INT         NOT NULL              COMMENT '선택 답변 점수',
    REGISTER          VARCHAR(20) NOT NULL              COMMENT '등록자',
    RGSDE             DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR            VARCHAR(20)                       COMMENT '수정자',
    UPDDE             DATETIME    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (EXMNTIN_SN, QESITM_SN),
    CONSTRAINT fk_ability_dgnss_dtls_prtcpnt FOREIGN KEY (EXMNTIN_SN) REFERENCES TN_ABILITY_DGNSS_PRTCPNT (EXMNTIN_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='역량 진단 참여 내역';

-- 역량 진단 참여 결과  (※ QESITM_SN→TN_ABILITY_DGNSS_QESITM 은 부모 복합PK라 보류)
CREATE TABLE IF NOT EXISTS TN_ABILITY_DGNSS_RESULT (
    EXMNTIN_SN        BIGINT       NOT NULL              COMMENT '진단 순번',
    QESITM_SN         BIGINT       NOT NULL              COMMENT '문항 순번',
    EXMNTIN_RSLT_CODE VARCHAR(5)   NOT NULL              COMMENT '진단 결과 코드',
    AVRG_SCR          DECIMAL(3,2) NOT NULL              COMMENT '평균 점수',
    REGISTER          VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE             DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR            VARCHAR(20)                        COMMENT '수정자',
    UPDDE             DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    PRIMARY KEY (EXMNTIN_SN, QESITM_SN),
    CONSTRAINT fk_ability_dgnss_result_prtcpnt FOREIGN KEY (EXMNTIN_SN) REFERENCES TN_ABILITY_DGNSS_PRTCPNT (EXMNTIN_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='역량 진단 참여 결과';

-- 개인 관심 기업
CREATE TABLE IF NOT EXISTS TN_INDVDL_INTRST_INSTT (
    INDVDL_USER_SN BIGINT      NOT NULL              COMMENT '개인 사용자 순번',
    INSTT_USER_SN  BIGINT      NOT NULL              COMMENT '기관 사용자 순번',
    RGSDE          DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    REGISTER       VARCHAR(20) NOT NULL              COMMENT '등록자',
    PRIMARY KEY (INDVDL_USER_SN, INSTT_USER_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='개인 관심 기업';

-- 개인 공고 스크랩
CREATE TABLE IF NOT EXISTS TN_INDVDL_PBLANC_SCRAP (
    INDVDL_USER_SN BIGINT       NOT NULL              COMMENT '개인 사용자 순번',
    INSTT_USER_SN  BIGINT       NOT NULL              COMMENT '기관 사용자 순번',
    PBLANC_SN      BIGINT       NOT NULL              COMMENT '공고 순번',
    PBLANC_NM      VARCHAR(200)                       COMMENT '공고 명',
    RGSDE          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    REGISTER       VARCHAR(20)  NOT NULL              COMMENT '등록자',
    PRIMARY KEY (INDVDL_USER_SN, INSTT_USER_SN, PBLANC_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='개인 공고 스크랩';

-- 구인기관정보 (채용공고 USER_SN → 기관, 회사명 등) — career-goal 스크랩 조회에 사용
CREATE TABLE IF NOT EXISTS TN_INSTT_INFO (
    USER_SN             BIGINT      NOT NULL              COMMENT '사용자 순번',
    INSTT_SE            VARCHAR(5)                        COMMENT '기관 구분',
    INSTT_NM            VARCHAR(50)                       COMMENT '소속기관명',
    RPRSNTV_NM          VARCHAR(50)                       COMMENT '대표자명',
    BIZRNO              VARCHAR(12)                       COMMENT '사업자번호',
    TELNO               VARCHAR(20)                       COMMENT '전화번호',
    ZIP                 VARCHAR(7)                        COMMENT '우편번호',
    ADRES               VARCHAR(100)                      COMMENT '주소',
    DTL_ADRES           VARCHAR(100)                      COMMENT '집상세주소',
    JURIRNO             VARCHAR(14)                       COMMENT '법인등록번호',
    FOND_DE             DATETIME                          COMMENT '설립일자',
    INDUTY_NM           VARCHAR(50)                       COMMENT '업종구분코드',
    JSSFC_SE_CODE       VARCHAR(5)                        COMMENT '직종구분코드',
    DTY_SE_CODE         VARCHAR(5)                        COMMENT '직무 구분 코드',
    EMPL_CO             INT                               COMMENT '사원 수',
    CAPL                BIGINT                            COMMENT '자본금',
    SELNG_AM            BIGINT                            COMMENT '매출금액',
    LST_TY_CODE         VARCHAR(5)                        COMMENT '상장 유형 코드',
    RWDMRT_TRGT_TY_CODE VARCHAR(5)                        COMMENT '보훈 대상 유형 코드',
    HMPG_URL            VARCHAR(50)                       COMMENT '홈페이지URL',
    REGISTER            VARCHAR(20)                       COMMENT '등록자',
    RGSDE               DATETIME                          COMMENT '등록일',
    UPDUSR              VARCHAR(20)                       COMMENT '수정자',
    UPDDE               DATETIME                          COMMENT '수정일',
    PRIMARY KEY (USER_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='구인기관정보';

-- 채용공고
CREATE TABLE IF NOT EXISTS TN_EMPMN_PBLANC (
    PBLANC_SN             BIGINT       NOT NULL              COMMENT '공고 순번',
    USER_SN               BIGINT       NOT NULL              COMMENT '사용자순번',
    PBLANC_NM             VARCHAR(200) NOT NULL              COMMENT '공고 명',
    JSSFC_SE_CODE         VARCHAR(5)                         COMMENT '직종구분코드',
    WORK_STLE             VARCHAR(50)                        COMMENT '업무 형태',
    EMPLYM_STLE           VARCHAR(200)                       COMMENT '근무 형태',
    ACDMCR_SE_CODE        VARCHAR(5)                         COMMENT '학력 구분 코드',
    CAREER_SE_CODE        VARCHAR(5)                         COMMENT '경력구분코드',
    SALARY_CND_SE_CODE    VARCHAR(5)                         COMMENT '급여조건구분코드',
    RCEPT_BEGIN_DT        DATETIME                           COMMENT '접수시작일시',
    RCEPT_END_DT          DATETIME                           COMMENT '접수종료일시',
    HOPE_WORK_AREA        VARCHAR(5)                         COMMENT '희망 근무 지역',
    ZIP                   VARCHAR(7)                         COMMENT '우편번호',
    ADRES                 VARCHAR(100)                       COMMENT '주소',
    DTL_ADRES             VARCHAR(100)                       COMMENT '상세 주소',
    FILE_ID               BIGINT                             COMMENT '파일 ID',
    PRSNTN_PAPERS_NM      VARCHAR(200)                       COMMENT '제출서류명',
    WLFARE_SE_CODE        VARCHAR(5)                         COMMENT '복리후생구분코드',
    PVLTRT_MATTER_SE_CODE VARCHAR(5)                         COMMENT '우대사항구분코드',
    MHRHDC_SYSTEM_SE_CODE VARCHAR(5)                         COMMENT '모성보호제도구분코드',
    HR_CHARGER_SN         BIGINT                             COMMENT '담당자 순번',
    INFO_EXPSR_AT         VARCHAR(1)                         COMMENT '정보노출여부',
    PBLANC_CN             LONGTEXT                           COMMENT '공고 내용(원본 CLOB)',
    REGISTER              VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE                 DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR                VARCHAR(20)  NOT NULL              COMMENT '수정자',
    UPDDE                 DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    RCRIT_NMPR            INT                                COMMENT '모집 인원',
    PICU_AGREE            VARCHAR(1)                         COMMENT '개인 정보 이용 동의',
    PITU_AGREE            VARCHAR(1)                         COMMENT '개인 정보 수집 동의',
    ORDTM_EMPMN_AT        VARCHAR(1)                         COMMENT '상시 채용 여부',
    INTRST_BSNS_CODE      VARCHAR(5)                         COMMENT '관심 사업 코드',
    PRIMARY KEY (PBLANC_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='채용공고';

-- 이력서 관리
CREATE TABLE IF NOT EXISTS TN_RESUME (
    RESUME_SN          BIGINT       NOT NULL              COMMENT '이력서순번',
    USER_SN            BIGINT                             COMMENT '사용자 순번',
    RESUME_SJ          VARCHAR(100)                       COMMENT '이력서 제목',
    LAST_DGRI_SE_CODE  VARCHAR(5)                         COMMENT '최종학위구분코드',
    HOPE_WORK_AREA     VARCHAR(5)                         COMMENT '희망 근무 지역',
    EMPLYM_TY_CODE     VARCHAR(5)                         COMMENT '고용 유형 코드',
    INFO_EXPSR_AT      VARCHAR(1)                         COMMENT '정보노출여부',
    BSNS_SE_CODE       VARCHAR(5)                         COMMENT '사업 구분 코드',
    REGISTER           VARCHAR(20)                        COMMENT '등록자',
    RGSDE              DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR             VARCHAR(20)                        COMMENT '수정자',
    UPDDE              DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    HOPE_SALARY        VARCHAR(5)                         COMMENT '희망 급여',
    EMPYMN_PVLTRT_CODE VARCHAR(5)                         COMMENT '취업 우대 코드',
    TROBL_CODE         VARCHAR(5)                         COMMENT '장애 코드',
    MTRSC_CODE         VARCHAR(5)                         COMMENT '병역 코드',
    JSSFC_SE_CODE      VARCHAR(5)                         COMMENT '직종구분코드',
    PRTFOLIO_FILE_ID   INT                                COMMENT '포트폴리오 파일 ID',
    CAREER_PD          INT                                COMMENT '경력 기간',
    PRIMARY KEY (RESUME_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이력서 관리';

-- (보류했던 FK 연결) 이력서 하위 테이블 → TN_RESUME
ALTER TABLE TN_RESUME_ACDMCR      ADD CONSTRAINT fk_resume_acdmcr_resume      FOREIGN KEY (RESUME_SN) REFERENCES TN_RESUME (RESUME_SN);
ALTER TABLE TN_RESUME_SELF_INTRCN ADD CONSTRAINT fk_resume_self_intrcn_resume FOREIGN KEY (RESUME_SN) REFERENCES TN_RESUME (RESUME_SN);
ALTER TABLE TN_RESUME_CAREER      ADD CONSTRAINT fk_resume_career_resume      FOREIGN KEY (RESUME_SN) REFERENCES TN_RESUME (RESUME_SN);
ALTER TABLE TN_RESUME_PRTFOLIO_URL ADD CONSTRAINT fk_resume_prtfolio_url_resume FOREIGN KEY (RESUME_SN) REFERENCES TN_RESUME (RESUME_SN);
ALTER TABLE TN_RESUME_CRQFC       ADD CONSTRAINT fk_resume_crqfc_resume       FOREIGN KEY (RESUME_SN) REFERENCES TN_RESUME (RESUME_SN);
ALTER TABLE TN_RESUME_EDC         ADD CONSTRAINT fk_resume_edc_resume         FOREIGN KEY (RESUME_SN) REFERENCES TN_RESUME (RESUME_SN);
ALTER TABLE TN_RESUME_ACT         ADD CONSTRAINT fk_resume_act_resume         FOREIGN KEY (RESUME_SN) REFERENCES TN_RESUME (RESUME_SN);
ALTER TABLE TN_RESUME_WNPZ        ADD CONSTRAINT fk_resume_wnpz_resume        FOREIGN KEY (RESUME_SN) REFERENCES TN_RESUME (RESUME_SN);
ALTER TABLE TN_RESUME_OVSEA       ADD CONSTRAINT fk_resume_ovsea_resume       FOREIGN KEY (RESUME_SN) REFERENCES TN_RESUME (RESUME_SN);
ALTER TABLE TN_RESUME_LSTCS       ADD CONSTRAINT fk_resume_lstcs_resume       FOREIGN KEY (RESUME_SN) REFERENCES TN_RESUME (RESUME_SN);

-- (학력 델타) sys_education → TN_RESUME_ACDMCR 학력행 1:1 부착
ALTER TABLE sys_education ADD CONSTRAINT fk_education_acdmcr FOREIGN KEY (acdmcr_sn) REFERENCES TN_RESUME_ACDMCR (ACDMCR_SN);

-- (스크랩 델타) sys_user_job_scrap → TN_INDVDL_PBLANC_SCRAP 스크랩행(복합키) 1:1 부착
ALTER TABLE sys_user_job_scrap ADD CONSTRAINT fk_scrap_tn FOREIGN KEY (indvdl_user_sn, instt_user_sn, pblanc_sn) REFERENCES TN_INDVDL_PBLANC_SCRAP (INDVDL_USER_SN, INSTT_USER_SN, PBLANC_SN);

-- 컨설팅 신청 정보 (1:1 커리어컨설팅 Q&A — AI 입력용)
--   1:1 컨설팅 export(신청자/방식/주제/분야/컨설턴트/날짜/상태/질문/답변)와 1행=1상담 매칭.
--   질문 = CNSL_REQST_CN(신청내용), 답변 = CNSL_RSLT_CN(결과내용) — 같은 행에 보관.
--   회원유형은 USER_SN → 사용자 테이블 조인, 컨설턴트명은 CNSTNT_SN → TN_CNSTNT_INFO 조인.
--   (※ FK USER_SN / CNSTNT_SN → 참조 테이블 로컬 미수신 → FK 보류)
CREATE TABLE IF NOT EXISTS TN_CNSL_REQST_INFO (
    CNSL_SN            BIGINT       NOT NULL              COMMENT '컨설팅 순번',
    USER_SN            BIGINT       NOT NULL              COMMENT '사용자 순번(신청자)',
    CNSL_MTHD_CODE     VARCHAR(5)   NOT NULL              COMMENT '컨설팅 방식 코드(전화/온라인)',
    CNSL_TOPIC_CODE    VARCHAR(5)   NOT NULL              COMMENT '컨설팅 주제 코드',
    CNSL_RLM_CODE      VARCHAR(5)   NOT NULL              COMMENT '컨설팅 분야 코드',
    RESUME_OTHBC_AT    VARCHAR(1)   NOT NULL DEFAULT 'N'  COMMENT '이력서 공개 여부',
    CNSL_REQST_CN      TEXT                               COMMENT '컨설팅 신청 내용=질문(원본 VARCHAR2(4000))',
    CNSTNT_SN          BIGINT       NOT NULL              COMMENT '컨설턴트 순번',
    RESVE_SN           BIGINT                             COMMENT '예약 순번',
    CANCL_RESN         VARCHAR(500)                       COMMENT '취소 사유',
    DCSN_AT            VARCHAR(1)                         COMMENT '확정 여부',
    CNSL_RQSTDT        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '컨설팅 신청일',
    CNSL_COMPT_AT      VARCHAR(1)            DEFAULT 'N'  COMMENT '컨설팅 완료 여부(상태)',
    CNSL_COMPT_DE      DATETIME                           COMMENT '컨설팅 완료 일자',
    CNSL_RSLT_CN       TEXT                               COMMENT '컨설팅 결과 내용=답변(원본 VARCHAR2(4000))',
    CNSL_REQST_FILE_ID BIGINT                             COMMENT '신청 파일 ID',
    CNSL_RSLT_FILE_ID  BIGINT                             COMMENT '결과 파일 ID',
    REGISTER           VARCHAR(20)  NOT NULL              COMMENT '등록자',
    RGSDE              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일',
    UPDUSR             VARCHAR(20)                        COMMENT '수정자',
    UPDDE              DATETIME                           COMMENT '수정일',
    INDVDLINFO_AGRE_AT VARCHAR(1)                         COMMENT '개인정보동의여부',
    PRIMARY KEY (CNSL_SN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='컨설팅 신청 정보(1:1 컨설팅 Q&A, AI 입력용)';

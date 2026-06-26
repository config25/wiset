-- =====================================================================
-- TN_CNSL_REQST_INFO (컨설팅 신청 정보) — 로컬(MariaDB) DDL + user_sn=1 시드
--   ★ Tibero 명세 그대로. 방언만 최소 변환:
--       NUMBER        -> DECIMAL(38,0)        (Tibero NUMBER 무정밀 등가)
--       VARCHAR2(n)   -> VARCHAR(n)           (크기 동일 유지 — TEXT 금지)
--       DATE          -> DATETIME             (Tibero DATE = 시분초 포함)
--       DEFAULT SYSDATE -> DEFAULT CURRENT_TIMESTAMP
--     컬럼명/순서/NULL여부/기본값은 명세와 1:1.
--   매퍼 indvdl.cnsl.selectCnslQnaListByUser 는 cnsl_compt_at='Y' AND cnsl_rslt_cn IS NOT NULL 만 조회.
-- =====================================================================

DROP TABLE IF EXISTS tn_cnsl_reqst_info;

CREATE TABLE tn_cnsl_reqst_info (
  cnsl_sn              DECIMAL(38,0)  NOT NULL  COMMENT '컨설팅 순번',          -- 1  PK NUMBER
  user_sn              DECIMAL(38,0)            COMMENT '사용자 순번',          -- 2  NUMBER
  cnsl_mthd_code       VARCHAR(5)               COMMENT '컨설팅 방식 코드',     -- 3  VARCHAR2(5)
  cnsl_topic_code      VARCHAR(5)               COMMENT '컨설팅 주제 코드',     -- 4  VARCHAR2(5)
  cnsl_rlm_code        VARCHAR(5)               COMMENT '컨설팅 분야 코드',     -- 5  VARCHAR2(5)
  resume_othbc_at      VARCHAR(1)     DEFAULT 'N' COMMENT '이력서 공개 여부',   -- 6  VARCHAR2(1) DEF N
  cnsl_reqst_cn        VARCHAR(4000)            COMMENT '컨설팅 신청 내용',     -- 7  VARCHAR2(4000)
  cnstnt_sn            DECIMAL(38,0)            COMMENT '컨설턴트 순번',        -- 8  NUMBER
  resve_sn             DECIMAL(38,0)            COMMENT '예약 순번',            -- 9  NUMBER NULL
  cancl_resn           VARCHAR(500)             COMMENT '취소 사유',            -- 10 VARCHAR2(500) NULL
  dcsn_at              VARCHAR(1)               COMMENT '확정 여부',            -- 11 VARCHAR2(1) NULL
  cnsl_rqstdt          DATETIME       DEFAULT CURRENT_TIMESTAMP COMMENT '컨설팅 신청일', -- 12 DATE DEF SYSDATE
  cnsl_compt_at        VARCHAR(1)     DEFAULT 'N' COMMENT '컨설팅 완료 여부',   -- 13 VARCHAR2(1) DEF N NULL
  cnsl_compt_de        DATETIME                 COMMENT '컨설팅 완료 일자',     -- 14 DATE NULL
  cnsl_rslt_cn         VARCHAR(4000)            COMMENT '컨설팅 결과 내용',     -- 15 VARCHAR2(4000) NULL
  cnsl_reqst_file_id   DECIMAL(38,0)            COMMENT '파일 ID',              -- 16 NUMBER NULL
  cnsl_rslt_file_id    DECIMAL(38,0)            COMMENT '결과 파일 ID',         -- 17 NUMBER NULL
  register             VARCHAR(20)              COMMENT '등록자',               -- 18 VARCHAR2(20)
  rgsde                DATETIME       DEFAULT CURRENT_TIMESTAMP COMMENT '등록일', -- 19 DATE DEF SYSDATE
  updusr               VARCHAR(20)              COMMENT '수정자',               -- 20 VARCHAR2(20) NULL
  updde                DATETIME                 COMMENT '수정일',               -- 21 DATE NULL
  indvdlinfo_agre_at   VARCHAR(1)               COMMENT '개인정보동의여부',     -- 22 VARCHAR2(1) NULL
  PRIMARY KEY (cnsl_sn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='컨설팅 신청 정보';

-- user_sn=1 시드 (완료+답변 3건 + 필터검증용 미완료 1건)
INSERT INTO tn_cnsl_reqst_info
  (cnsl_sn, user_sn, cnsl_mthd_code, cnsl_topic_code, cnsl_rlm_code,
   cnsl_reqst_cn, cnstnt_sn, cnsl_rqstdt, cnsl_compt_at, cnsl_compt_de, cnsl_rslt_cn, register, rgsde)
VALUES
  (5901, 1, 'PH', 'JOB', 'PHAR',
   '면접 준비 컨설팅 신청합니다. 직무PT와 인성PT 발표자료 피드백 부탁드립니다.',
   101, '2026-04-28 15:00:45', 'Y', '2026-04-29 07:01:06',
   '면접에서 직접 발화하는 연습이 중요합니다. 직무PT는 관심 계기와 해결 과제를 먼저 정리하고, 석사 연구주제에 시간을 더 배분하세요. 인성PT는 대표 경험 외 추가 소재도 준비해 두면 좋습니다. 발표 전 스크립트를 한 번 더 정리해 발화연습 해보세요. 파이팅!',
   'SYSTEM', '2026-04-28 15:00:45'),

  (5902, 1, 'PH', 'JOB', 'IT',
   '현대차증권 자기소개서 첨삭을 요청드립니다. 링크에 자소서 내용을 정리해 두었습니다.',
   102, '2026-04-26 21:02:21', 'Y', '2026-04-28 20:40:31',
   '요청하신 현대차증권 자소서에 대해 개선하면 좋을 부분을 코멘트로 남겼습니다. 직무 역량과 경험의 연결을 더 구체적으로 드러내면 좋겠습니다. 추가 궁금한 점 있으면 알려주세요. 감사합니다!',
   'SYSTEM', '2026-04-26 21:02:21'),

  (5903, 1, 'PH', 'JOB', 'IT',
   '인증 및 보안 주제로 사내 5분 발표를 맡았습니다. CSRF 주제가 적절한지, 보완 포인트가 궁금합니다.',
   103, '2026-04-25 21:15:47', 'Y', '2026-04-26 19:43:03',
   '5분 발표 주제로 CSRF는 다소 올드하게 느껴질 수 있어 추천드리지 않습니다. 새로 제시하신 주제로 스크립트를 작성해 공유해 주시면 검토 가능합니다. 참고 부탁드립니다. 감사합니다.',
   'SYSTEM', '2026-04-25 21:15:47'),

  -- 필터 검증용: 미완료(답변 없음) → 조회결과에서 제외되어야 함
  (5904, 1, 'ON', 'CARR', 'PHAR',
   '경력 전환 관련 상담 신청합니다. 아직 답변 전입니다.',
   104, '2026-04-30 10:00:00', 'N', NULL, NULL,
   'SYSTEM', '2026-04-30 10:00:00');

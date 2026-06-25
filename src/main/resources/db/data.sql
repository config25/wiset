-- =====================================================================
-- WISET 공통 코드 시드 (sys_common_type)
-- group_code: 코드 그룹 / code: 시스템 내부 코드 / name: 표시명
-- 단일 선택 코드 컬럼(persona_code 등)은 code 값으로, 다중 선택은
-- sys_user_type.type_id -> sys_common_type.common_id 로 참조.
-- 재실행 안전: uk_common_type(group_code, code) + INSERT IGNORE
-- =====================================================================
SET NAMES utf8mb4;

INSERT IGNORE INTO sys_common_type (group_code, code, name) VALUES
-- 페르소나 (sys_user_profile.persona_code)
('PERSONA', '1', '신규 취업'),
('PERSONA', '2', '이직 준비'),
('PERSONA', '3', '재취업'),
('PERSONA', '4', '승진 / 보직 희망'),
-- 신입/경력 (career_level_code)
('CAREER_LEVEL', '1', '신입'),
('CAREER_LEVEL', '2', '경력'),
-- 학력 구분 (education_level_code)
('EDU_LEVEL', '1', '전문학사'),
('EDU_LEVEL', '2', '학사'),
('EDU_LEVEL', '3', '석사'),
('EDU_LEVEL', '4', '박사'),
('EDU_LEVEL', '5', '고등학교 졸업'),
('EDU_LEVEL', '9', '기타'),
-- 졸업 상태 (sys_education.graduation_status)
('GRAD_STATUS', 'GRADUATED', '졸업'),
('GRAD_STATUS', 'EXPECTED', '졸업예정'),
('GRAD_STATUS', 'ENROLLED', '재학중'),
('GRAD_STATUS', 'DROPOUT', '중퇴'),
('GRAD_STATUS', 'COMPLETED', '수료'),
-- 추가 정보 유형 (화면 탭/메뉴 식별용 — 저장은 유형별 테이블로 분리)
('INFO_TYPE', '1', '논문/연구내역'),
('INFO_TYPE', '2', '인턴·대외활동'),
('INFO_TYPE', '3', '교육이수'),
('INFO_TYPE', '4', '자격증'),
('INFO_TYPE', '5', '수상'),
('INFO_TYPE', '6', '해외경험'),
('INFO_TYPE', '7', '어학'),
('INFO_TYPE', '8', '포트폴리오'),
('INFO_TYPE', '9', '자기소개서'),
-- (삭제) ACTIVITY_TYPE / SPEAKING_LEVEL / ATTACHMENT_TYPE
--   → 해당 sys 테이블(활동/어학/첨부) 폐지, TN_RESUME_* 코드 사용으로 고아화되어 제거
-- 희망 업종 (단일선택: sys_user_profile.desired_industry_code)
('INDUSTRY', '1', '바이오·생명공학'),
('INDUSTRY', '2', '제약'),
('INDUSTRY', '3', '의료기기'),
('INDUSTRY', '4', '화학·소재'),
('INDUSTRY', '5', '식품'),
('INDUSTRY', '6', 'IT·SW'),
('INDUSTRY', '7', '반도체'),
('INDUSTRY', '9', '기타'),
-- 희망 직무 (단일선택: sys_user_profile.desired_job_code)
('JOB', '1', 'R&D 연구원'),
('JOB', '2', '품질관리(QC)'),
('JOB', '3', '공정개발'),
('JOB', '4', '임상개발'),
('JOB', '5', '인허가(RA)'),
('JOB', '6', '기술마케팅'),
('JOB', '7', '사업개발(BD)'),
('JOB', '9', '기타'),
-- 희망 고용형태 (다중선택: sys_user_type -> common_id)
('EMPLOYMENT_TYPE', '1', '정규직'),
('EMPLOYMENT_TYPE', '2', '계약직'),
('EMPLOYMENT_TYPE', '3', '파견근로'),
('EMPLOYMENT_TYPE', '4', '대체인력'),
('EMPLOYMENT_TYPE', '5', '시간제'),
('EMPLOYMENT_TYPE', '6', '프리랜서'),
('EMPLOYMENT_TYPE', '7', '인턴직'),
('EMPLOYMENT_TYPE', '8', '무기계약직'),
-- 희망 근무지 시/도 (sys_user_desired_region.sido)
('REGION_SIDO', '강원', '강원'),
('REGION_SIDO', '경기', '경기'),
('REGION_SIDO', '경남', '경남'),
('REGION_SIDO', '경북', '경북'),
('REGION_SIDO', '광주', '광주'),
('REGION_SIDO', '대구', '대구'),
('REGION_SIDO', '대전', '대전'),
('REGION_SIDO', '부산', '부산'),
('REGION_SIDO', '서울', '서울'),
('REGION_SIDO', '울산', '울산'),
('REGION_SIDO', '인천', '인천'),
('REGION_SIDO', '전남', '전남'),
('REGION_SIDO', '전북', '전북'),
('REGION_SIDO', '제주', '제주'),
('REGION_SIDO', '충남', '충남'),
('REGION_SIDO', '충북', '충북'),
('REGION_SIDO', '세종', '세종'),
('REGION_SIDO', '전국', '전국'),
('REGION_SIDO', '해외', '해외'),
-- 희망 기업 규모 (다중선택: sys_user_type -> common_id)
('COMPANY_SIZE', '1', '스타트업'),
('COMPANY_SIZE', '2', '중소기업'),
('COMPANY_SIZE', '3', '중견기업'),
('COMPANY_SIZE', '4', '대기업'),
('COMPANY_SIZE', '5', '공공·연구소'),
-- 취업우대·병역 (다중선택: sys_user_type -> common_id)
('JOB_PREFERENCE', '1', '보훈대상'),
('JOB_PREFERENCE', '2', '장애'),
('JOB_PREFERENCE', '3', '병역'),
-- 현재 직급 (sys_career_growth_goal.current_rank_code)
('RANK', '1', '인턴'),
('RANK', '2', '사원'),
('RANK', '3', '주임급'),
('RANK', '4', '대리급'),
('RANK', '5', '과장급'),
('RANK', '6', '차장급'),
('RANK', '7', '부장급'),
-- 강화 리더십·역량 (다중선택: sys_career_growth_skill.skill_code)
('LEADERSHIP_SKILL', '1', '조직·인력 관리'),
('LEADERSHIP_SKILL', '2', '전략·기획'),
('LEADERSHIP_SKILL', '3', '의사결정'),
('LEADERSHIP_SKILL', '4', '성과관리'),
('LEADERSHIP_SKILL', '5', '협업·소통'),
('LEADERSHIP_SKILL', '6', '예산·자원 관리'),
('LEADERSHIP_SKILL', '7', '전문성 심화'),
-- 핵심 평가 반영 요소 (sys_career_growth_goal.eval_factor_code)
('EVAL_FACTOR', '1', '리더십 다면평가'),
('EVAL_FACTOR', '2', '성과(KPI)'),
('EVAL_FACTOR', '3', '전문성'),
-- 액션 플래너 출처 (sys_action_planner.source_type_code)
('PLANNER_SOURCE', 'WBRIDGE', 'W브릿지 추천'),
('PLANNER_SOURCE', 'EXTERNAL_LINK', '외부 연계'),
('PLANNER_SOURCE', 'EXTERNAL_REC', '외부 추천'),
('PLANNER_SOURCE', 'MANUAL', '직접 입력'),
('PLANNER_SOURCE', 'COHORT', '코호트 추천'),
('PLANNER_SOURCE', 'AI', 'AI 추천'),
-- 액션 플래너 기간 (sys_action_planner.term_code)
('PLANNER_TERM', 'SHORT', '단기'),
('PLANNER_TERM', 'MID', '중기'),
('PLANNER_TERM', 'LONG', '장기'),
-- 액션 플래너 상태 (sys_action_planner.status_code)
('PLANNER_STATUS', 'TODO', '대기'),
('PLANNER_STATUS', 'IN_PROGRESS', '진행중'),
('PLANNER_STATUS', 'DONE', '완료');

-- =====================================================================
-- [개발용] 로컬 테스트 계정 (USER_SN=1).
--   실제 통합 시엔 기존 W브릿지 TN_USER_INFO 계정을 쓰므로 불필요.
--   sys_user_profile.user_id 가 TN_USER_INFO(USER_SN) 를 FK 참조하기에 로컬 채움.
-- =====================================================================
INSERT IGNORE INTO TN_USER_INFO (USER_SN, USER_ID, USER_PW, USER_SE, AGRE_DT, REGISTER, UPDUSR)
VALUES (1, 'wb_dev', '!dev', 'I', NOW(), 'system', 'system');

-- [개발용] career-goal 타겟공고용 스크랩 시드 (기관 + 공고 + 개인 스크랩)
INSERT IGNORE INTO TN_INSTT_INFO (USER_SN, INSTT_NM) VALUES
  (101, '예시바이오'), (102, '셀라이프사이언스'), (103, '한국생명연구원');
INSERT IGNORE INTO TN_EMPMN_PBLANC (PBLANC_SN, USER_SN, PBLANC_NM, EMPLYM_STLE, ADRES, REGISTER, UPDUSR) VALUES
  (1001, 101, 'R&D 연구원 (항체 정제)',  '정규직',      '경기 판교',  'system', 'system'),
  (1002, 102, '바이오 공정 개발 연구원', '정규직',      '인천 송도',  'system', 'system'),
  (1003, 103, '박사후연구원 (Post-Doc)', '계약직 2년',  '대전',       'system', 'system');
INSERT IGNORE INTO TN_INDVDL_PBLANC_SCRAP (INDVDL_USER_SN, INSTT_USER_SN, PBLANC_SN, PBLANC_NM, RGSDE, REGISTER) VALUES
  (1, 101, 1001, 'R&D 연구원 (항체 정제)',  '2026-04-18', 'system'),
  (1, 102, 1002, '바이오 공정 개발 연구원', '2026-04-15', 'system'),
  (1, 103, 1003, '박사후연구원 (Post-Doc)', '2026-04-10', 'system');

-- [개발용] 마이페이지 대시보드 시드 (프로필 + 진단 3회 + 액션 5건)
INSERT IGNORE INTO sys_user_profile (user_id, persona_code, career_level_code, desired_job_code, current_status)
VALUES (1, 2, 2, 1, '학술 → 산업체 전환 준비 (GMP·산업 언어 학습 진행)');

-- [개발용] 프로필 헤더 시드 (이름/연락처/생년월일 = TN_INDVDL_INFO,
--   전공/학위 = TN_RESUME_ACDMCR, 현직/연차 = TN_RESUME_CAREER). USER_SN=1, TN 스키마 불변·데이터만.
INSERT IGNORE INTO TN_INDVDL_INFO (USER_SN, USER_NM, BRTHDY, MBTLNUM, EMAIL, REGISTER, UPDUSR)
VALUES (1, '김지수', '19940312', '010-2345-1234', 'kjs1234@gmail.com', 'system', 'system');
INSERT IGNORE INTO TN_RESUME (RESUME_SN, USER_SN, RESUME_SJ, REGISTER, UPDUSR)
VALUES (1, 1, '김지수 이력서', 'system', 'system');
INSERT IGNORE INTO TN_RESUME_ACDMCR (ACDMCR_SN, RESUME_SN, SCHUL_NM, MAJOR_NM, ACDMCR_END_DE, LAST_DGRI_SE_CODE, REGISTER, UPDUSR)
VALUES (1, 1, '○○대학교 대학원', '생명공학', '20200228', '04', 'system', 'system');  -- 04=석사
INSERT IGNORE INTO TN_RESUME_CAREER (CAREER_SN, RESUME_SN, CAREER_INSTT_NM, CLSF_NM, DTY_NM, CAREER_BEGIN_DE, CAREER_END_DE, REGISTER, UPDUSR)
VALUES (1, 1, '○○생명과학연구원', '학술연구원', '바이오 R&D', '2025-03-02', NULL, 'system', 'system');  -- 종료일 NULL=재직중

-- [개발용] career-goal 희망 근무지 시드 (sys_user_desired_region · USER_SN=1)
INSERT IGNORE INTO sys_user_desired_region (region_id, user_id, sido, sigungu) VALUES
  (1, 1, '서울', '전체'),
  (2, 1, '경기', '성남시'),
  (3, 1, '서울', '강남구');

-- [개발용] career-goal 희망 업종/직무 + 고용형태 (USER_SN=1) — 저장값 불러오기 데모
--   ※ 프로필 행이 placeholder 로 먼저 생길 수 있어 INSERT IGNORE 가 아닌 UPDATE 로 코드 보정.
UPDATE sys_user_profile SET desired_industry_code = 1, desired_job_code = 1 WHERE user_id = 1;
INSERT IGNORE INTO sys_user_type (common_id, user_id, type_id)
  SELECT 1, 1, common_id FROM sys_common_type WHERE group_code = 'EMPLOYMENT_TYPE' AND code = '1';
INSERT IGNORE INTO sys_user_type (common_id, user_id, type_id)
  SELECT 2, 1, common_id FROM sys_common_type WHERE group_code = 'EMPLOYMENT_TYPE' AND code = '2';
INSERT IGNORE INTO sys_competency_diagnosis
  (competency_id, user_id, version_code, diagnosis_type, persona_code, desired_job, concern_summary,
   cohort_size, cohort_percentile, total_score,
   professionalism_score, digital_score, leadership_score, problem_solving_score, communication_score, created_at) VALUES
  (1, 1, 'v2.1', 'LIGHT',         2, '미정 (탐색 단계)',        '시장 파악',                        384, 55, 60, 58, 55, 50, 62, 70, '2026-01-20 21:04:00'),
  (2, 1, 'v3.2', 'COMPREHENSIVE', 2, '바이오 R&D',             '직무 적합도 점검',                  384, 42, 66, 70, 65, 60, 62, 75, '2026-03-15 10:18:00'),
  (3, 1, 'v1.0', 'AI_COACHING',   2, '바이오 R&D · 항체/공정', 'GMP 적응 / 연봉 협상 / 산업체 문화', 384, 32, 74, 88, 60, 78, 55, 62, '2026-04-29 14:32:00');
INSERT IGNORE INTO sys_action_planner (planner_id, user_id, diagnosis_id, custom_title, source_type_code, term_code, status_code) VALUES
  (1, 1, 3, 'NCS GMP 기초 교육 신청',        'WBRIDGE',      'SHORT', 'IN_PROGRESS'),
  (2, 1, 3, '이력서 GMP 키워드 보강',         'MANUAL',       'SHORT', 'IN_PROGRESS'),
  (3, 1, 2, 'Python 데이터 분석 강좌 결제',   'EXTERNAL_REC', 'MID',   'DONE'),
  (4, 1, 3, '취업탐색 멘토링 신청',           'WBRIDGE',      'LONG',  'DONE'),
  (5, 1, 2, '연봉 협상 시나리오 정리',        'AI',           'LONG',  'DONE');

-- [개발용] 추천 활동 (sys_resource) — action-planner 추천 탭
INSERT IGNORE INTO sys_resource (resource_id, resource_type_code, source_type_code, title, content, organization_name, location, salary_min, salary_max) VALUES
  (1, 'JOB',       'WBRIDGE',  'R&D 연구원 (항체 정제)',          '신약 항체 정제 공정 R&D',  '예시바이오',       '경기 판교', 4500, 5500),
  (2, 'JOB',       'EXTERNAL', '바이오 공정 개발 연구원',         '세포배양·공정개발',        '셀라이프사이언스', '인천 송도', NULL, NULL),
  (3, 'EDUCATION', 'WBRIDGE',  'NCS 기반 GMP 기초 과정',          '2주 · 무료 · 5월 개강',    'W브릿지',          NULL,        NULL, NULL),
  (4, 'EDUCATION', 'EXTERNAL', 'Python for Bioscience 데이터 분석','8주 · 25% 할인',          '패스트캠퍼스',     NULL,        NULL, NULL),
  (5, 'SUPPORT',   'WBRIDGE',  '여성과학기술인 R&D 경력복귀 지원', '월 200만원 × 12개월',     'W브릿지',          NULL,        NULL, NULL),
  (6, 'SUPPORT',   'EXTERNAL', '한국연구재단 신진연구자 지원',     '연 5천만원 × 3년',         '한국연구재단',     NULL,        NULL, NULL);

-- =====================================================================
-- [개발용] 17_관리자 통합 대시보드 시드 (admin-dashboard API 검증용)
--   · 마이페이지(USER_SN=1) 데이터는 건드리지 않도록, 집계용 합성 사용자(2~15)와
--     별도 PK 대역(10만~60만)에만 적재. NOW() 기준 상대 시각 → 7일/30일/오늘 윈도우 유효.
--   · 재실행 안전: 명시 PK + INSERT IGNORE. CTE 깊이 < 500(MySQL/MariaDB 기본 한도 내).
-- =====================================================================

-- 합성 계정(2~15) + 프로필(페르소나 1~4 분포) — 페르소나 유입/MAU 모수
INSERT IGNORE INTO TN_USER_INFO (USER_SN, USER_ID, USER_PW, USER_SE, AGRE_DT, REGISTER, UPDUSR)
SELECT * FROM (
  WITH RECURSIVE seq(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 14)
  SELECT n+1 AS USER_SN, CONCAT('wb_user', n+1) AS USER_ID, '!dev' AS USER_PW,
         'I' AS USER_SE, NOW() AS AGRE_DT, 'system' AS REGISTER, 'system' AS UPDUSR
  FROM seq
) g;
INSERT IGNORE INTO sys_user_profile (user_id, persona_code, career_level_code)
SELECT * FROM (
  WITH RECURSIVE seq(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 14)
  SELECT n+1 AS user_id, 1 + (n % 4) AS persona_code, 1 + (n % 2) AS career_level_code
  FROM seq
) g;

-- 누적 진단 (합성 사용자 2~15) — '누적 진단 건수' KPI / 리포트 관리 목록(직무·점수·코호트)
INSERT IGNORE INTO sys_competency_diagnosis
  (competency_id, user_id, version_code, diagnosis_type, persona_code, desired_job, total_score, cohort_size, cohort_percentile, created_at)
SELECT * FROM (
  WITH RECURSIVE seq(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 500)
  SELECT 100000+n, 2+(n%14), 'v3.0',
         CASE WHEN n%3=0 THEN 'AI_COACHING' WHEN n%3=1 THEN 'COMPREHENSIVE' ELSE 'LIGHT' END,
         1+(n%4),
         ELT(1+(n%6), '연구개발 · BT', '품질관리 · 제약', 'IT·SW · 백엔드', '경영지원', '제조·생산', '연구개발 · 제약'),
         50+(n%50), 180+(n%800), 10+(n%80),
         DATE_SUB(NOW(), INTERVAL (n%90) DAY)
  FROM seq
) g;

-- 진단 세션 — 단계별 이탈률(funnel) / 실시간 동시(IN_PROGRESS) / 오늘 진단 시작
INSERT IGNORE INTO sys_diagnosis_session (session_id, user_id, status, current_step, started_at, completed_at)
SELECT * FROM (
  WITH RECURSIVE seq(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 500)
  SELECT 300000+n, 2+(n%14),
    CASE WHEN (n%100)<8 THEN 'ABANDONED' WHEN (n%100)<38 THEN 'IN_PROGRESS' ELSE 'COMPLETED' END,
    CASE WHEN (n%100)<8  THEN 'step1'
         WHEN (n%100)<14 THEN 'step2'
         WHEN (n%100)<26 THEN 'step3'
         WHEN (n%100)<32 THEN 'step4'
         WHEN (n%100)<38 THEN 'step5'
         ELSE 'step6' END,
    CASE WHEN (n%7)=0 THEN NOW() ELSE DATE_SUB(NOW(), INTERVAL (n%7) DAY) END,
    CASE WHEN (n%100)>=38 THEN DATE_SUB(NOW(), INTERVAL (n%7) DAY) ELSE NULL END
  FROM seq
) g;

-- [개발용] 마이페이지 사용자(USER_SN=1)의 AI 코칭 리포트 1건.
--   content = 렌더용 JSON 문서(ai-coaching.jsp 가 그대로 그림). 색/그라데이션 등 테마는 프론트가 페르소나로 입힘.
--   diagnosis 3 = USER_SN=1 의 AI_COACHING 진단. report_id=1 (합성 리포트 200001+ 와 비충돌).
INSERT IGNORE INTO sys_ai_report (report_id, user_id, diagnosis_id, report_type, content, response_time_ms, created_at) VALUES
  (1, 1, 3, 'COACHING', '{"subtitle":"화학·바이오 기술직 직무 전환 전략","title":"화학·바이오 기술직에서 새로운 직무로의 전환을 준비하시는 회원님, 환영합니다.","chips":[{"ic":"flask","t":"화학·바이오 산업"},{"ic":"layers","t":"기술직 (R&D·QC·공정)"},{"ic":"refresh","t":"직무 전환·이직 준비"}],"intro":["화학 및 바이오 산업에서 기술직(연구개발, QC, 공정 등)으로 재직하다가 다른 직무로의 전환(이직 및 전직)을 희망하시는 경우, 기존에 쌓은 기술적 전문성을 완전히 버리는 것이 아니라 새로운 직무에서 어떻게 시너지를 낼 수 있을지 ‘전용성 기술(Transferable Skills)’을 파악하고 어필하는 것이 가장 중요합니다. 제공된 컨설팅 사례들을 바탕으로, 성공적인 직무 전환을 위한 맞춤형 경력개발 조언을 다음과 같이 제안해 드립니다."],"sections":[{"no":"1","title":"기술적 백그라운드를 무기로 삼을 수 있는 타겟 직무 설정","lead":"화학/바이오 기술직의 경험은 비기술 직무에서 오히려 대체 불가능한 강력한 무기가 될 수 있습니다. 본인의 성향에 맞춰 다음의 직무들을 고려해 볼 수 있습니다.","points":[{"label":"사업개발(BD) 및 연구기획","text":"신약 파이프라인이나 새로운 기술의 가치를 1차적으로 평가하고 도입/수출을 논의하는 데 있어 연구 경험은 필수적인 자산입니다. 외부 기술을 검토하거나 유관부서와 소통할 때, 기초 생물학/화학에 대한 이해도와 실제 실험 경험을 갖춘 인재는 매우 유리합니다. 단, 글로벌 파트너링이 많으므로 비즈니스 영어 소통 능력을 반드시 갖추어야 합니다."},{"label":"인허가(RA) 및 품질보증(QA)","text":"실험실에서 원리를 이해하며 얻은 지식은 규제 기관의 가이드라인에 맞춰 문서를 작성하고 데이터를 검증하는 데 큰 도움이 됩니다. 화학/바이오 전공 지식을 살리되, 한국식약처(MFDS), FDA, EMA 등의 규정이나 GMP 가이드라인에 대한 추가적인 학습을 병행해야 합니다."},{"label":"기술영업 및 학술 마케팅","text":"사람들과 소통하고 설득하는 데 흥미가 있다면, 전문 지식을 바탕으로 고객에게 제품/솔루션을 설명하는 직무도 훌륭한 선택지입니다."}]},{"no":"2","title":"사내 직무 이동(Job Rotation) 선행 검토","paras":["다른 직무로 완전히 회사를 옮기는 것은 ‘이직’이 아닌 ‘전직’에 가깝기 때문에, 동일 직무 경력자들과 경쟁할 때 신입으로 평가받거나 연봉/처우 면에서 손해를 볼 수 있습니다.","따라서 가장 성공 확률이 높은 방법은 현재 재직 중인 회사 내부에서 먼저 원하는 부서(기획, 사업개발, RA 등)로 이동하여 1~2년 정도 실무 경력을 쌓은 뒤, 그 경력을 바탕으로 타 회사로 이직하는 것입니다."]},{"no":"3","title":"경력기술서의 전면적인 재구성 (Did List에서 성과 중심으로)","paras":["새로운 직무로 지원할 때, 기존 이력서에 “어떤 장비를 써봤고, 어떤 실험을 했다”는 식의 단순 나열(Did List)을 작성하는 것은 피해야 합니다. 타겟으로 하는 새로운 직무의 요구 역량에 맞춰 본인의 경험을 번역해야 합니다.","예를 들어, “A실험 수행”이 아니라 “문제 발생 시 데이터를 기반으로 원인을 분석하고, 조건 최적화를 통해 수율을 00% 향상시켰으며, 이 과정에서 유관 부서와의 소통을 주도함”과 같이, 문제해결력, 데이터 분석력, 기획력, 소통 능력이 돋보이도록 STAR 기법(상황-과제-행동-결과)으로 성과를 수치화하여 포장해야 합니다."]},{"no":"4","title":"‘준비된 솔직함’으로 직무 전환 사유 포장","paras":["면접 시 직무를 왜 바꾸려는지에 대한 질문은 반드시 나옵니다. 이때 “실험이 체력적으로 힘들어서”, “현재 직장 상사와의 불화 때문에”와 같은 부정적인 이유는 감점 요소가 됩니다.","대신, “기술적 실무를 수행하다 보니 개발된 기술이 시장에 어떻게 적용되고 사업화되는지에 더 큰 흥미를 느꼈다”거나 “연구 결과를 활용해 상용화와 전체 프로세스를 기획하는 일에 나의 강점이 있음을 깨달았다”는 등, 더 큰 시야로 성장하기 위한 능동적인 선택이었음을 어필해야 합니다."]},{"no":"5","title":"업계 트렌드 파악 및 추가 역량 개발","paras":["직무 전환을 결심했다면, 한국바이오협회, 안전성평가연구소 등에서 주관하는 RA, 임상, GMP 관련 직무 교육을 수강하여 직무에 대한 관심도와 기본 지식을 객관적으로 증명하는 것이 좋습니다. 또한, ‘바이오스펙테이터’ 등 전문 언론을 통해 해당 산업계의 최신 파이프라인 동향과 트렌드를 꾸준히 학습하여, 면접 시 산업에 대한 깊은 이해도를 보여주어야 합니다."]}]}', 24000, '2026-04-29 14:35:00');

-- [개발용] 활동 분석 리포트(USER_SN=1) — report_type=ACTIVITY_ANALYSIS. content=렌더용 JSON(차트/색은 프론트 계산).
INSERT IGNORE INTO sys_ai_report (report_id, user_id, diagnosis_id, report_type, content, response_time_ms, created_at) VALUES
  (2, 1, 3, 'ACTIVITY_ANALYSIS', '{"cfi":{"score":72,"delta":"↑ 평균 +8","title":"기술 전문성은 우수, 산업 응용 경험 보강이 필요합니다","summary":"12개 핵심 역량 중 <b>8개를 충족</b>하며, 학술 연구 역량은 집단 평균을 상회하는 상위권입니다. 다만 GMP 환경 경험과 협업 도구 숙련도에서 격차가 두드러집니다.","badges":[{"tone":"blue","t":"강점 · 분자생물학 실험 설계"},{"tone":"blue","t":"강점 · 학술 데이터 분석"},{"tone":"pink","t":"보완 · GMP 규제 이해"},{"tone":"pink","t":"보완 · Python·R 자동화"}]},"strengthsTop":[{"ic":"flask","n":"분자생물학 실험 설계","v":88},{"ic":"chart","n":"학술 데이터 분석 (R)","v":84},{"ic":"lightbulb","n":"문제 해결력","v":78}],"gapsTop":[{"ic":"code","n":"Python·R 자동화","v":60,"gap":"-25"},{"ic":"shield","n":"GMP 규제 이해","v":55,"gap":"-20"},{"ic":"users","n":"협업·커뮤니케이션","v":62,"gap":"-18"}],"rows":[{"l":"화학·바이오 산업 이해","g":"공통","v":82,"avg":70,"comment":"석사 연구 경험과 산업 키워드 매칭에서 화학·바이오 도메인 이해도가 높게 확인됩니다. 집단 평균(70점)을 상회하는 강점 영역입니다.","sources":[{"t":"이력서","d":"산업 키워드 9회 매칭"},{"t":"NCS 기준","d":"공통역량 충족"}]},{"l":"문서 이해·작성","g":"공통","v":78,"avg":72,"comment":"연구 보고서·논문 작성 경험으로 문서 역량은 양호합니다. 산업 문서 양식 경험을 보강하면 더 높일 수 있습니다.","sources":[{"t":"이력서","d":"보고서 산출물 다수"},{"t":"WISET 역량모델","d":"공통역량 평균 이상"}]},{"l":"정보 탐색","g":"공통","v":85,"avg":74,"comment":"문헌·데이터 탐색 능력이 우수합니다. 연구 과정에서 다양한 정보원을 활용한 이력이 확인됩니다.","sources":[{"t":"이력서","d":"문헌 활용 다수"},{"t":"진단 결과","d":"정보활용 85점"}]},{"l":"기술·문헌자료 조사","g":"직무","v":88,"avg":73,"comment":"기술 문헌 조사·분석 역량이 핵심 강점입니다. 직무 수행에 즉시 활용 가능한 수준입니다.","sources":[{"t":"이력서","d":"문헌조사 12회 매칭"},{"t":"NCS 기준","d":"직무역량 상위"}]},{"l":"연구·시험 데이터 정리","g":"직무","v":84,"avg":71,"comment":"실험·시험 데이터 정리 및 관리 경험이 풍부합니다. 데이터 기반 직무에 강점으로 작용합니다.","sources":[{"t":"이력서","d":"데이터 관리 경험"},{"t":"논문","d":"데이터 분석 포함"}]},{"l":"과제·일정 지원","g":"직무","v":66,"avg":68,"comment":"연구 과제 수행 경험은 있으나 일정·자원 관리 측면의 주도 경험이 제한적입니다. 집단 평균(68점)에 근접하나 보완이 필요합니다.","sources":[{"t":"이력서","d":"과제 참여 이력"},{"t":"WISET 역량모델","d":"관리역량 보완 권고"}]},{"l":"연구자 커뮤니케이션","g":"리더십","v":62,"avg":70,"comment":"개인 연구 중심 경력으로 협업·커뮤니케이션 경험이 상대적으로 적습니다. 집단 평균(70점)에 미치지 못합니다.","sources":[{"t":"이력서","d":"협업 키워드 2회"},{"t":"진단 결과","d":"커뮤니케이션 62점"}]},{"l":"지원업무 개선","g":"리더십","v":58,"avg":65,"comment":"업무 프로세스 개선·제안 경험이 식별되지 않습니다. 리더십 영역에서 집중 보완이 필요합니다.","sources":[{"t":"이력서","d":"개선 활동 0회"},{"t":"WISET 역량모델","d":"리더십 보완 우선"}]}],"ksa":[{"area":"Knowledge","sub":"지식 요건","l":"AI·정보보안 기초 이해 역량","lvl":"기초","v":64,"comment":"채용 공고에서 요구하는 AI·정보보안 기초 이해는 시장 요구(60점)를 충족하나 절대 수준은 보완 여지가 있습니다.","sources":[{"t":"채용공고","d":"기초 요구 다수"},{"t":"시장 동향","d":"AI 리터러시 +28%"}]},{"area":"Knowledge","sub":"지식 요건","l":"정보보안·데이터 처리 구조 이해 역량","lvl":"기초","v":70,"comment":"데이터 처리 구조에 대한 이해가 양호하며 시장 요구(60점)를 충족합니다.","sources":[{"t":"채용공고","d":"데이터 처리 요구"},{"t":"이력서","d":"데이터 경험 확인"}]},{"area":"Skill","sub":"기술 요건","l":"AI 모델 개발 및 활용 역량","lvl":"심화","v":52,"comment":"AI 모델 개발·활용 경험이 부족해 심화 요구(85점) 대비 격차가 큽니다. 시장 수요가 빠르게 증가하는 영역입니다.","sources":[{"t":"채용공고","d":"AI 역량 심화 요구"},{"t":"시장 동향","d":"AI 직무 +51%"}]},{"area":"Skill","sub":"기술 요건","l":"Python 기반 분석·자동화 수행 역량","lvl":"실무","v":60,"comment":"R 활용 경험은 있으나 Python 기반 자동화 경험이 부족해 실무 요구(75점)에 미흡합니다.","sources":[{"t":"이력서","d":"Python 0회 매칭"},{"t":"시장 동향","d":"Python 요구 +43%"}]},{"area":"Skill","sub":"기술 요건","l":"데이터 파이프라인 구축 및 운영 역량","lvl":"실무","v":58,"comment":"데이터 파이프라인 구축·운영 경험이 식별되지 않아 실무 요구(75점) 대비 집중 보완이 필요합니다.","sources":[{"t":"채용공고","d":"파이프라인 요구"},{"t":"시장 동향","d":"데이터 엔지니어링 수요↑"}]},{"area":"Skill","sub":"기술 요건","l":"로그 데이터 분석 및 문제해결 역량","lvl":"실무","v":68,"comment":"데이터 분석 기반은 갖추었으나 로그·운영 데이터 분석 경험은 부분적입니다. 실무 요구(75점)에 다소 미흡합니다.","sources":[{"t":"이력서","d":"분석 경험 일부"},{"t":"채용공고","d":"로그 분석 요구"}]},{"area":"Attitude","sub":"태도 요건","l":"협업 및 커뮤니케이션 기반 업무 수행 태도","lvl":"실무","v":72,"comment":"협업 태도는 양호하며 실무 요구(75점)에 근접합니다. 다부서 협업 경험을 더하면 충족 가능합니다.","sources":[{"t":"진단 결과","d":"태도 72점"},{"t":"채용공고","d":"협업 태도 중시"}]},{"area":"Attitude","sub":"태도 요건","l":"지속학습 및 자기개발 태도","lvl":"기초","v":82,"comment":"지속적 학습·자기개발 태도가 우수해 기초 요구(60점)를 크게 상회합니다. 면접에서 어필 가능한 강점입니다.","sources":[{"t":"이력서","d":"교육 이수 다수"},{"t":"진단 결과","d":"자기개발 82점"}]},{"area":"Attitude","sub":"태도 요건","l":"주도적 문제해결 및 실행 역량","lvl":"심화","v":76,"comment":"주도적 문제해결 역량이 양호하며 심화 요구(85점)에는 다소 미치지 못하나 잠재력이 확인됩니다.","sources":[{"t":"진단 결과","d":"문제해결 76점"},{"t":"RAG 사례","d":"유사 합격자 평균 수준"}]}],"criteriaSummary":"공통·직무 역량 전반이 집단 평균을 크게 상회하며, 특히 <b>문헌조사(88)·정보탐색(85)·산업이해(82)</b>에서 상위권 강점이 확인됩니다. 다만 <b>커뮤니케이션(62)·업무개선(58)</b> 등 리더십 영역은 집단 평균 수준에 머물러 보강이 필요합니다.","marketSummary":"태도 요건인 <b>지속학습(82)·주도성(76)·협업태도(72)</b>는 시장 요구를 충족·상회합니다. 반면 기술 요건의 <b>AI 모델링(52)·파이프라인(58)·Python 분석(60)</b>이 큰 격차를 보여 핵심 보완 과제입니다.","jds":[{"co":"예시바이오","role":"R&D 연구원 (항체 정제)","meta":"판교 · 4,500~5,500","fit":72,"match":"8 / 12","gap":["GMP 실무","Python 자동화"],"rec":"추천","tone":"brand","met":["항체 정제·단백질 분석 실무 경험","석사 연구 도메인 적합도 우수","실험 설계·데이터 해석 역량"],"advice":["GMP 규제 실무 교육(2주) 이수 권장","Python 기반 분석 자동화 포트폴리오 보강"]},{"co":"셀라이프사이언스","role":"바이오 공정 개발 연구원","meta":"인천 송도 · 협의","fit":65,"match":"7 / 12","gap":["공정 스케일업","품질 시스템","영문 보고서"],"rec":"도전","tone":"pink","met":["바이오 공정 기초 지식 보유","실험 설계·검증 역량","협업 기반 연구 수행 경험"],"advice":["파일럿 규모 공정 스케일업 경험 확보","품질 시스템(QMS)·영문 보고서 작성 역량 강화"]}]}', 26000, '2026-04-29 14:40:00');

-- [개발용] 액션 플랜 리포트 스냅샷(USER_SN=1) — report_type=ACTION_PLAN. planner+recommendations+gapRecs 동결.
INSERT IGNORE INTO sys_ai_report (report_id, user_id, diagnosis_id, report_type, content, response_time_ms, created_at) VALUES
  (3, 1, 3, 'ACTION_PLAN', '{"planner":{"SHORT":[{"t":"NCS GMP 기초 교육 신청","src":"W브릿지"},{"t":"이력서 GMP 키워드 보강","src":"직접 입력"}],"MID":[{"t":"Python 데이터 분석 강좌 결제","src":"외부 추천"}],"LONG":[{"t":"취업탐색 멘토링 신청","src":"W브릿지"},{"t":"연봉 협상 시나리오 정리","src":"AI 추천"}]},"recommendations":{"job":[{"type":"정규직","src":"W브릿지","t":"예시바이오 — R&D 연구원 (항체 정제)","region":"경기 판교","pay":"연봉 4,500~5,500만원","cta":"상세보기"},{"type":"정규직","src":"외부연계","t":"셀라이프사이언스 — 바이오 공정 개발 연구원","region":"인천 송도","pay":"회사 내규에 따름","cta":"상세보기"}],"support":[{"src":"W브릿지","status":"접수중","t":"여성과학기술인 R&D 경력복귀 지원","apply":"상시 모집","period":"월 200만원 × 12개월","cta":"상세보기"},{"src":"외부연계","status":"접수중","t":"한국연구재단 신진연구자 지원","apply":"상시 모집","period":"연 5천만원 × 3년","cta":"상세보기"}],"cohort":[]},"gapRecs":[{"gap":"GMP 규제 이해","score":-20,"priority":"최우선","tone":"brand","keywords":["GMP 기초","SOP 작성","QC 실무","품질 시스템","GMP 자격증"]},{"gap":"Python·R 자동화","score":-25,"priority":"높음","tone":"brand","keywords":["Python 기초","pandas","Bioconductor","Jupyter","데이터 시각화"]},{"gap":"협업·커뮤니케이션","score":-18,"priority":"중간","tone":"brand","keywords":["STAR 면접 화법","비전공자 설명","협업 사례 정리","학회 발표"]}]}', 22000, '2026-04-29 14:45:00');

-- AI 리포트 — 응답 속도(P95/P99) / 일별 활용량(최근 7일) / 리포트 관리 목록
--   diagnosis_id는 동일 n의 합성 진단(100000+n)을 가리켜 페르소나·직무·점수·코호트 노출
INSERT IGNORE INTO sys_ai_report (report_id, user_id, diagnosis_id, content, response_time_ms, created_at)
SELECT * FROM (
  WITH RECURSIVE seq(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 500)
  SELECT 200000+n, 2+(n%14), 100000+n, 'AI 리포트 본문(샘플)',
         18000 + (n*131 % 72000), DATE_SUB(NOW(), INTERVAL (n%7) DAY)
  FROM seq
) g;

-- 답변 품질 지표 (리포트 1:1) — 자동 평가 점수 + 품질 저하 사유(낮은 b일 때)
--   created_at은 60일 분산(전월 대비 델타 계산용) / quality_issue는 b<=3 리포트에 5종 분산
INSERT IGNORE INTO sys_ai_report_quality
  (quality_id, report_id, faithfulness_score, accuracy_score, job_reflection_score, relevance_score, quality_issue, created_at)
SELECT
  200000 + s.n AS quality_id, 200000 + s.n AS report_id,
  88+(s.n%8) AS faithfulness, 84+(s.n%9) AS accuracy, 80+(s.n%11) AS jobref, 86+(s.n%9) AS relevance,
  CASE WHEN s.b <= 3 THEN
       ELT(1 + ((s.n DIV 20) % 5), 'RAG 매칭 사례 부족', '액션 플랜 추천 0건', '컨설팅 평어 길이 과다', '코호트 매칭 정확도 저하', '직무 키워드 미매칭')
       ELSE NULL END AS quality_issue,
  DATE_SUB(NOW(), INTERVAL (s.n % 60) DAY) AS created_at
FROM (
  WITH RECURSIVE seq(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 500)
  SELECT n, CASE WHEN (n%20)<12 THEN 5 WHEN (n%20)<17 THEN 4 WHEN (n%20)<19 THEN 3 ELSE 2 END AS b FROM seq
) s;

-- 리포트 만족도 설문 — 리포트당 4문항(q1~q4) + 감성/의견/불만토픽(q1에만)
--   평균 만족도(5점)·별점 분포(대시보드) / 감성 분포·불만 TOP5·피드백 목록(만족도 관리)
--   별점 b: 5(60%)/4(25%)/3(10%)/2(5%). q3은 b-1로 변별. 감성=b기준.
INSERT IGNORE INTO sys_ai_report_survey
  (survey_id, user_id, report_id, question_no, rating, opinion, sentiment, complaint_category, surveyed_at)
SELECT
  400000 + s.n*4 + qs.q                                            AS survey_id,
  2 + (s.n % 14)                                                   AS user_id,
  200000 + s.n                                                     AS report_id,
  qs.q                                                             AS question_no,
  CASE WHEN qs.q = 3 THEN GREATEST(1, s.b - 1) ELSE s.b END        AS rating,
  CASE WHEN qs.q = 1 AND (s.n % 2) = 0 THEN
       CASE WHEN s.b >= 4 THEN 'AI 코칭 평어에 시장 데이터가 함께 제시되어 신뢰가 갔습니다.'
            WHEN s.b = 3  THEN '단계별 입력이 다소 길었지만 결과는 만족스럽습니다.'
            ELSE '추천 활동이 일반적이라 실제 도움이 부족했습니다.' END
       ELSE NULL END                                               AS opinion,
  CASE WHEN qs.q = 1 THEN
       CASE WHEN s.b >= 4 THEN 'POSITIVE' WHEN s.b = 3 THEN 'NEUTRAL' ELSE 'NEGATIVE' END
       ELSE NULL END                                               AS sentiment,
  CASE WHEN qs.q = 1 AND s.b <= 2 THEN
       ELT(1 + ((s.n DIV 20) % 5), '추천 활동 적합성 부족', '응답 속도 지연', '컨설팅 평어가 일반적', '코호트 매칭 정확도', '기타')
       ELSE NULL END                                               AS complaint_category,
  DATE_SUB(NOW(), INTERVAL (s.n % 60) DAY)                         AS surveyed_at
FROM (
  WITH RECURSIVE seq(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 500)
  SELECT n, CASE WHEN (n%20)<12 THEN 5 WHEN (n%20)<17 THEN 4 WHEN (n%20)<19 THEN 3 ELSE 2 END AS b FROM seq
) s
CROSS JOIN (SELECT 1 AS q UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) qs;

-- 행동 로그 — view/click/rate/submit/thumbs 혼합(최근 7주)
--   thumbs(20%, 87/13) → 대시보드 좋아요/싫어요 / click·view → 만족도 관리 액션실행률
--   view·click·rate·submit → 행동 로그 상세 / MAU(최근 30일 distinct user)
INSERT IGNORE INTO sys_user_activity_log (activity_log_id, user_id, action_type, action_value, target_type, target_id, created_at)
SELECT * FROM (
  WITH RECURSIVE seq(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 800)
  SELECT 500000+n, 2+(n%14),
    CASE (n%10) WHEN 4 THEN 'click' WHEN 5 THEN 'click' WHEN 6 THEN 'rate'
                WHEN 7 THEN 'submit' WHEN 8 THEN 'thumbs' WHEN 9 THEN 'thumbs' ELSE 'view' END AS action_type,
    CASE (n%10)
      WHEN 4 THEN CONCAT('action_card[edu_', LPAD(1+(n%9),2,'0'), ']')
      WHEN 5 THEN 'consult_apply_btn'
      WHEN 6 THEN CONCAT('★', 1+(n%5))
      WHEN 7 THEN 'survey_4q + comment'
      WHEN 8 THEN CASE WHEN (n%100)<87 THEN 'thumbs_up' ELSE 'thumbs_down' END
      WHEN 9 THEN CASE WHEN (n%100)<87 THEN 'thumbs_up' ELSE 'thumbs_down' END
      ELSE CONCAT('report:rep#scroll=', 10+(n%80), '%') END AS action_value,
    CASE (n%10) WHEN 4 THEN 'action' WHEN 5 THEN 'action' WHEN 7 THEN 'diagnosis' ELSE 'report' END AS target_type,
    200000 + (n%249) AS target_id,
    DATE_SUB(NOW(), INTERVAL (n%49) DAY) AS created_at
  FROM seq
) g;

-- API 호출 로그 — 가용성 / 에러율(5xx) / 평균 응답(DB 근사)
INSERT IGNORE INTO sys_api_logs (api_log_id, user_id, endpoint, status_code, response_time_ms, created_at)
SELECT * FROM (
  WITH RECURSIVE seq(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM seq WHERE n < 500)
  SELECT 600000+n, 1, '/api/ai/report',
         CASE WHEN n=1 THEN '500' WHEN n=2 THEN '503' ELSE '200' END,
         28 + (n%40), DATE_SUB(NOW(), INTERVAL (n%7) DAY)
  FROM seq
) g;

-- 시스템 성능 / 큐 (최신 1건) — 성능 지표 카드
INSERT IGNORE INTO sys_system_metrics (metric_id, gpu_usage_percent, cpu_usage_percent, memory_usage_percent, created_at)
VALUES (1, 64.0, 52.0, 71.0, NOW());
INSERT IGNORE INTO sys_queue_metrics (queue_metric_id, queue_name, waiting_count, processing_count, created_at)
VALUES (1, 'ai-report', 2, 5, NOW());

-- 최근 데이터 배치 — 최근 데이터 배치 테이블
INSERT IGNORE INTO sys_batch_history (batch_id, batch_type, executed_at, processed_count, duration_seconds, status) VALUES
  (1, '리포트 인덱싱',          DATE_SUB(NOW(), INTERVAL 12 HOUR),   186,    38, 'SUCCESS'),
  (2, 'JobKorea 통계 수집',     DATE_SUB(NOW(), INTERVAL 10 HOUR),   518,   161, 'WARNING'),
  (3, '코호트 매칭 재계산',     DATE_SUB(NOW(), INTERVAL  8 HOUR), 12847,   662, 'SUCCESS'),
  (4, '워크넷 RAG 인덱스 갱신', DATE_SUB(NOW(), INTERVAL  2 HOUR),  3891,   514, 'SUCCESS'),
  (5, 'WISET 채용 DB 동기화',   DATE_SUB(NOW(), INTERVAL 30 MINUTE),1247,   252, 'SUCCESS');

-- =====================================================================
-- [개발용] 19_관리자 AI 품질 관리 시드 (가중치 / 변경이력 / 프롬프트)
-- =====================================================================

-- 직무·역량 가중치 (6직무 × 6역량, 합계 100%) — default_percent는 역량별 고정 기준
INSERT IGNORE INTO sys_current_weights (job_name, competency_name, weight_percent, default_percent) VALUES
  ('전체',     '전공 적합성', 30, 30), ('전체',     '실무 경험', 20, 20), ('전체',     '디지털 역량', 20, 20),
  ('전체',     '커뮤니케이션', 12, 12), ('전체',     '리더십', 10, 10), ('전체',     '문제해결', 8, 8),
  ('연구개발', '전공 적합성', 35, 30), ('연구개발', '실무 경험', 25, 20), ('연구개발', '디지털 역량', 15, 20),
  ('연구개발', '커뮤니케이션', 10, 12), ('연구개발', '리더십', 8, 10), ('연구개발', '문제해결', 7, 8),
  ('제조·생산','전공 적합성', 30, 30), ('제조·생산','실무 경험', 28, 20), ('제조·생산','디지털 역량', 14, 20),
  ('제조·생산','커뮤니케이션', 10, 12), ('제조·생산','리더십', 10, 10), ('제조·생산','문제해결', 8, 8),
  ('품질관리', '전공 적합성', 32, 30), ('품질관리', '실무 경험', 22, 20), ('품질관리', '디지털 역량', 18, 20),
  ('품질관리', '커뮤니케이션', 10, 12), ('품질관리', '리더십', 10, 10), ('품질관리', '문제해결', 8, 8),
  ('IT·SW',    '전공 적합성', 25, 30), ('IT·SW',    '실무 경험', 18, 20), ('IT·SW',    '디지털 역량', 30, 20),
  ('IT·SW',    '커뮤니케이션', 12, 12), ('IT·SW',    '리더십', 8, 10), ('IT·SW',    '문제해결', 7, 8),
  ('경영지원', '전공 적합성', 28, 30), ('경영지원', '실무 경험', 20, 20), ('경영지원', '디지털 역량', 15, 20),
  ('경영지원', '커뮤니케이션', 17, 12), ('경영지원', '리더십', 12, 10), ('경영지원', '문제해결', 8, 8);

-- 가중치 변경 이력 (최신순=현재)
INSERT IGNORE INTO sys_weights_history (history_id, version_code, job_name, change_reason, modifier_name, created_at) VALUES
  (1, 'v3.2', '연구개발', '전공 적합성 30→35%',  '박관리', '2026-04-28 14:30:00'),
  (2, 'v3.1', 'IT·SW',    '디지털 역량 15→30%',  '김운영', '2026-04-20 11:15:00'),
  (3, 'v3.0', '전체',     '분기 정기 조정',       '시스템', '2026-04-10 09:00:00'),
  (4, 'v2.9', '경영지원', '리더십 8→12%',         '박관리', '2026-03-28 16:42:00'),
  (5, 'v2.8', '전체',     '초기 배포',            '시스템', '2026-03-15 10:00:00');

-- 프롬프트 템플릿 (활성 버전 1종/코드)
INSERT IGNORE INTO sys_prompt_template (prompt_code, version_code, title, variables, prompt_content, is_active, created_at) VALUES
  ('PRM-001', 'v2.4', '시장 현황 분석', '{{persona}} {{job_field}} {{sub_job}} {{years_experience}} {{cohort_size}} {{market_data}}',
   '# SYSTEM\n당신은 WISET 산하 여성과기인 커리어 코치입니다.\n# CONTEXT\n페르소나: {{persona}}\n직무: {{job_field}} / {{sub_job}}\n코호트: {{cohort_size}}명\n시장 데이터: {{market_data}}\n\n# TASK\n1. 채용 동향, 평균 연봉, 신규 진입자 비율을 자연어로 정리\n2. 데이터 출처는 인용 형식으로 표기 (예: WISET 채용 DB)', 1, NOW()),
  ('PRM-002', 'v2.1', '강점 활용 평어', '{{persona}} {{strength_top3}} {{job_field}}',
   '# SYSTEM\n사용자의 강점 TOP3를 직무 맥락에서 활용하는 방안을 제시합니다.\n# CONTEXT\n강점: {{strength_top3}}\n직무: {{job_field}}\n# TASK\n각 강점을 직무 성과로 연결하는 구체적 행동을 2~3개 제안', 1, NOW()),
  ('PRM-003', 'v3.0', '약점 보완 평어', '{{persona}} {{gap_top3}} {{job_field}}',
   '# SYSTEM\n부족 역량을 보완하는 학습/활동을 제안합니다.\n# CONTEXT\n부족 역량: {{gap_top3}}\n# TASK\n우선순위별 보완 로드맵을 단기/중기로 구분해 제시', 1, NOW()),
  ('PRM-004', 'v1.8', '액션 플랜 추천', '{{gap_top3}} {{cohort_size}} {{available_programs}}',
   '# SYSTEM\n부족 역량 기반 추천 활동을 큐레이션합니다.\n# CONTEXT\n추천 가능 프로그램: {{available_programs}}\n# TASK\n역량 갭과 매칭되는 활동을 우선순위로 정렬해 추천', 1, NOW()),
  ('PRM-005', 'v2.2', '코호트 매칭', '{{persona}} {{job_field}} {{years_experience}}',
   '# SYSTEM\n유사 코호트를 식별해 상대 위치를 산출합니다.\n# TASK\n동일 직무·연차 코호트 대비 백분위와 시사점 제시', 1, NOW()),
  ('PRM-006', 'v1.5', '컨설팅 종합 의견', '{{persona}} {{total_score}} {{strength_top3}} {{gap_top3}}',
   '# SYSTEM\n전체 진단 결과를 종합한 코칭 평어를 작성합니다.\n# TASK\n총평 → 핵심 강점 → 보완 과제 → 다음 단계 순으로 400자 내 요약', 1, NOW());

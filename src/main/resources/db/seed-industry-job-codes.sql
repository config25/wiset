-- =====================================================================
-- sys_common_type 의 INDUSTRY / JOB 코드를 프론트(career-goal.jsp) 희망업종/희망직무
-- 드롭다운 라벨과 1:1 일치시킨다.
--   이유: 분석 저장(AnalysisService)의 codeByName(group, name) 은 name 정확일치로 코드를 찾는데,
--         프론트가 보내는 라벨이 기존 코드표 name 과 달라서 desired_industry/job 이 NULL 로 저장됐다.
--   → 프론트 라벨을 그대로 코드표 name 으로 둔다(DB를 프론트에 맞춤).
-- =====================================================================

DELETE FROM sys_common_type WHERE group_code IN ('INDUSTRY','JOB');

-- 희망 업종 (career-goal.jsp #industry 옵션 순서 그대로)
INSERT INTO sys_common_type (group_code, code, name) VALUES
  ('INDUSTRY', '1',  '생명 및 자연과학 관련직'),
  ('INDUSTRY', '2',  '교육 관련직'),
  ('INDUSTRY', '3',  '보건의료 관련직'),
  ('INDUSTRY', '4',  '디자인/방송 관련직'),
  ('INDUSTRY', '5',  '운전/운송 관련직'),
  ('INDUSTRY', '6',  '건축/토목 공학 관련직'),
  ('INDUSTRY', '7',  '기계 관련직'),
  ('INDUSTRY', '8',  '재료 관련직'),
  ('INDUSTRY', '9',  '화학/식품가공 관련직'),
  ('INDUSTRY', '10', '전기/전자 관련직'),
  ('INDUSTRY', '11', '정보통신 관련직'),
  ('INDUSTRY', '12', '환경/에너지/안전 관련직'),
  ('INDUSTRY', '13', '기술영업/판매 관련직'),
  ('INDUSTRY', '14', '기타');

-- 희망 직무 (career-goal.jsp #job 옵션 순서 그대로)
INSERT INTO sys_common_type (group_code, code, name) VALUES
  ('JOB', '1', '연구개발직'),
  ('JOB', '2', '기술직'),
  ('JOB', '3', '연구지원직');

-- 진단 테스트 중 오염시킨 user_sn=1 의 옛 코드값 정리(프론트에서 다시 선택해 저장하도록)
UPDATE sys_user_profile SET desired_industry_code = NULL, desired_job_code = NULL WHERE user_id = 1;

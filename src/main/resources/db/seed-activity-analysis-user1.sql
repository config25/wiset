-- =====================================================================
-- 활동분석(ACTIVITY_ANALYSIS) 역량 점수/근거 시드 — user 1, report_id=2
--   activity-analysis.jsp 의 목업(rows/ksa/strengthsTop/gapsTop)을 관계형 테이블로 변환.
--   fit_type: CRITERIA(기준정합도) / MARKET(시장정합도) / HIGHLIGHT(강점·보완 TOP)
--   재실행 가능: 먼저 해당 리포트의 역량/근거를 비우고 다시 적재.
-- =====================================================================
SET @rid = 2;

-- 기존 적재분 정리(근거 → 역량 순, FK)
DELETE s FROM sys_report_competency_source s
  JOIN sys_report_competency c ON c.competency_id = s.competency_id
  WHERE c.report_id = @rid;
DELETE FROM sys_report_competency WHERE report_id = @rid;

-- 역량 점수/해설 (이름은 리포트 내 유일 → 근거 매핑 키로 사용)
INSERT INTO sys_report_competency
  (report_id, fit_type, group_code, level_code, name, my_score, required_score, status, icon, comment, sort_order)
VALUES
 -- 기준 정합도 (공통/직무/리더십) · required_score = 집단 평균
 (@rid,'CRITERIA','공통',NULL,'화학·바이오 산업 이해',82,70,NULL,NULL,'석사 연구 경험과 산업 키워드 매칭에서 화학·바이오 도메인 이해도가 높게 확인됩니다. 집단 평균(70점)을 상회하는 강점 영역입니다.',10),
 (@rid,'CRITERIA','공통',NULL,'문서 이해·작성',78,72,NULL,NULL,'연구 보고서·논문 작성 경험으로 문서 역량은 양호합니다. 산업 문서 양식 경험을 보강하면 더 높일 수 있습니다.',11),
 (@rid,'CRITERIA','공통',NULL,'정보 탐색',85,74,NULL,NULL,'문헌·데이터 탐색 능력이 우수합니다. 연구 과정에서 다양한 정보원을 활용한 이력이 확인됩니다.',12),
 (@rid,'CRITERIA','직무',NULL,'기술·문헌자료 조사',88,73,NULL,NULL,'기술 문헌 조사·분석 역량이 핵심 강점입니다. 직무 수행에 즉시 활용 가능한 수준입니다.',13),
 (@rid,'CRITERIA','직무',NULL,'연구·시험 데이터 정리',84,71,NULL,NULL,'실험·시험 데이터 정리 및 관리 경험이 풍부합니다. 데이터 기반 직무에 강점으로 작용합니다.',14),
 (@rid,'CRITERIA','직무',NULL,'과제·일정 지원',66,68,NULL,NULL,'연구 과제 수행 경험은 있으나 일정·자원 관리 측면의 주도 경험이 제한적입니다. 집단 평균(68점)에 근접하나 보완이 필요합니다.',15),
 (@rid,'CRITERIA','리더십',NULL,'연구자 커뮤니케이션',62,70,NULL,NULL,'개인 연구 중심 경력으로 협업·커뮤니케이션 경험이 상대적으로 적습니다. 집단 평균(70점)에 미치지 못합니다.',16),
 (@rid,'CRITERIA','리더십',NULL,'지원업무 개선',58,65,NULL,NULL,'업무 프로세스 개선·제안 경험이 식별되지 않습니다. 리더십 영역에서 집중 보완이 필요합니다.',17),
 -- 시장 정합도 (KSA) · required_score = 레벨 요구(기초60/실무75/심화85)
 (@rid,'MARKET','Knowledge','기초','AI·정보보안 기초 이해 역량',64,60,NULL,NULL,'채용 공고에서 요구하는 AI·정보보안 기초 이해는 시장 요구(60점)를 충족하나 절대 수준은 보완 여지가 있습니다.',20),
 (@rid,'MARKET','Knowledge','기초','정보보안·데이터 처리 구조 이해 역량',70,60,NULL,NULL,'데이터 처리 구조에 대한 이해가 양호하며 시장 요구(60점)를 충족합니다.',21),
 (@rid,'MARKET','Skill','심화','AI 모델 개발 및 활용 역량',52,85,NULL,NULL,'AI 모델 개발·활용 경험이 부족해 심화 요구(85점) 대비 격차가 큽니다. 시장 수요가 빠르게 증가하는 영역입니다.',22),
 (@rid,'MARKET','Skill','실무','Python 기반 분석·자동화 수행 역량',60,75,NULL,NULL,'R 활용 경험은 있으나 Python 기반 자동화 경험이 부족해 실무 요구(75점)에 미흡합니다.',23),
 (@rid,'MARKET','Skill','실무','데이터 파이프라인 구축 및 운영 역량',58,75,NULL,NULL,'데이터 파이프라인 구축·운영 경험이 식별되지 않아 실무 요구(75점) 대비 집중 보완이 필요합니다.',24),
 (@rid,'MARKET','Skill','실무','로그 데이터 분석 및 문제해결 역량',68,75,NULL,NULL,'데이터 분석 기반은 갖추었으나 로그·운영 데이터 분석 경험은 부분적입니다. 실무 요구(75점)에 다소 미흡합니다.',25),
 (@rid,'MARKET','Attitude','실무','협업 및 커뮤니케이션 기반 업무 수행 태도',72,75,NULL,NULL,'협업 태도는 양호하며 실무 요구(75점)에 근접합니다. 다부서 협업 경험을 더하면 충족 가능합니다.',26),
 (@rid,'MARKET','Attitude','기초','지속학습 및 자기개발 태도',82,60,NULL,NULL,'지속적 학습·자기개발 태도가 우수해 기초 요구(60점)를 크게 상회합니다. 면접에서 어필 가능한 강점입니다.',27),
 (@rid,'MARKET','Attitude','심화','주도적 문제해결 및 실행 역량',76,85,NULL,NULL,'주도적 문제해결 역량이 양호하며 심화 요구(85점)에는 다소 미치지 못하나 잠재력이 확인됩니다.',28),
 -- 강점 TOP3 (HIGHLIGHT/STRENGTH)
 (@rid,'HIGHLIGHT',NULL,NULL,'분자생물학 실험 설계',88,NULL,'STRENGTH','flask',NULL,30),
 (@rid,'HIGHLIGHT',NULL,NULL,'학술 데이터 분석 (R)',84,NULL,'STRENGTH','chart',NULL,31),
 (@rid,'HIGHLIGHT',NULL,NULL,'문제 해결력',78,NULL,'STRENGTH','lightbulb',NULL,32),
 -- 보완 TOP3 (HIGHLIGHT/GAP) · required_score = 목표(gap = my - required)
 (@rid,'HIGHLIGHT',NULL,NULL,'Python·R 자동화',60,85,'GAP','code',NULL,40),
 (@rid,'HIGHLIGHT',NULL,NULL,'GMP 규제 이해',55,75,'GAP','shield',NULL,41),
 (@rid,'HIGHLIGHT',NULL,NULL,'협업·커뮤니케이션',62,80,'GAP','users',NULL,42);

-- 역량별 근거 소스 (역량명으로 매핑, 첫 소스 is_primary=1)
INSERT INTO sys_report_competency_source (competency_id, source_type, detail, is_primary)
SELECT c.competency_id, x.source_type, x.detail, x.is_primary
FROM sys_report_competency c
JOIN (
            SELECT '화학·바이오 산업 이해' AS name, '이력서' AS source_type, '산업 키워드 9회 매칭' AS detail, 1 AS is_primary
  UNION ALL SELECT '화학·바이오 산업 이해','NCS 기준','공통역량 충족',0
  UNION ALL SELECT '문서 이해·작성','이력서','보고서 산출물 다수',1
  UNION ALL SELECT '문서 이해·작성','WISET 역량모델','공통역량 평균 이상',0
  UNION ALL SELECT '정보 탐색','이력서','문헌 활용 다수',1
  UNION ALL SELECT '정보 탐색','진단 결과','정보활용 85점',0
  UNION ALL SELECT '기술·문헌자료 조사','이력서','문헌조사 12회 매칭',1
  UNION ALL SELECT '기술·문헌자료 조사','NCS 기준','직무역량 상위',0
  UNION ALL SELECT '연구·시험 데이터 정리','이력서','데이터 관리 경험',1
  UNION ALL SELECT '연구·시험 데이터 정리','논문','데이터 분석 포함',0
  UNION ALL SELECT '과제·일정 지원','이력서','과제 참여 이력',1
  UNION ALL SELECT '과제·일정 지원','WISET 역량모델','관리역량 보완 권고',0
  UNION ALL SELECT '연구자 커뮤니케이션','이력서','협업 키워드 2회',1
  UNION ALL SELECT '연구자 커뮤니케이션','진단 결과','커뮤니케이션 62점',0
  UNION ALL SELECT '지원업무 개선','이력서','개선 활동 0회',1
  UNION ALL SELECT '지원업무 개선','WISET 역량모델','리더십 보완 우선',0
  UNION ALL SELECT 'AI·정보보안 기초 이해 역량','채용공고','기초 요구 다수',1
  UNION ALL SELECT 'AI·정보보안 기초 이해 역량','시장 동향','AI 리터러시 +28%',0
  UNION ALL SELECT '정보보안·데이터 처리 구조 이해 역량','채용공고','데이터 처리 요구',1
  UNION ALL SELECT '정보보안·데이터 처리 구조 이해 역량','이력서','데이터 경험 확인',0
  UNION ALL SELECT 'AI 모델 개발 및 활용 역량','채용공고','AI 역량 심화 요구',1
  UNION ALL SELECT 'AI 모델 개발 및 활용 역량','시장 동향','AI 직무 +51%',0
  UNION ALL SELECT 'Python 기반 분석·자동화 수행 역량','이력서','Python 0회 매칭',1
  UNION ALL SELECT 'Python 기반 분석·자동화 수행 역량','시장 동향','Python 요구 +43%',0
  UNION ALL SELECT '데이터 파이프라인 구축 및 운영 역량','채용공고','파이프라인 요구',1
  UNION ALL SELECT '데이터 파이프라인 구축 및 운영 역량','시장 동향','데이터 엔지니어링 수요↑',0
  UNION ALL SELECT '로그 데이터 분석 및 문제해결 역량','이력서','분석 경험 일부',1
  UNION ALL SELECT '로그 데이터 분석 및 문제해결 역량','채용공고','로그 분석 요구',0
  UNION ALL SELECT '협업 및 커뮤니케이션 기반 업무 수행 태도','진단 결과','태도 72점',1
  UNION ALL SELECT '협업 및 커뮤니케이션 기반 업무 수행 태도','채용공고','협업 태도 중시',0
  UNION ALL SELECT '지속학습 및 자기개발 태도','이력서','교육 이수 다수',1
  UNION ALL SELECT '지속학습 및 자기개발 태도','진단 결과','자기개발 82점',0
  UNION ALL SELECT '주도적 문제해결 및 실행 역량','진단 결과','문제해결 76점',1
  UNION ALL SELECT '주도적 문제해결 및 실행 역량','RAG 사례','유사 합격자 평균 수준',0
) x ON x.name = c.name
WHERE c.report_id = @rid;

-- =====================================================================
-- 활동분석 요약 (CFI · 종합해설 · 배지) — sys_report_activity (리포트 1:1)
-- =====================================================================
DELETE FROM sys_report_activity WHERE report_id = @rid;
INSERT INTO sys_report_activity
  (report_id, cfi_score, cfi_delta, summary_title, summary_text, keyword_badges, criteria_summary, market_summary)
VALUES (@rid, 72, '↑ 평균 +8',
  '기술 전문성은 우수, 산업 응용 경험 보강이 필요합니다',
  '12개 핵심 역량 중 <b>8개를 충족</b>하며, 학술 연구 역량은 집단 평균을 상회하는 상위권입니다. 다만 GMP 환경 경험과 협업 도구 숙련도에서 격차가 두드러집니다.',
  'blue|강점 · 분자생물학 실험 설계
blue|강점 · 학술 데이터 분석
pink|보완 · GMP 규제 이해
pink|보완 · Python·R 자동화',
  '공통·직무 역량 전반이 집단 평균을 크게 상회하며, 특히 <b>문헌조사(88)·정보탐색(85)·산업이해(82)</b>에서 상위권 강점이 확인됩니다. 다만 <b>커뮤니케이션(62)·업무개선(58)</b> 등 리더십 영역은 집단 평균 수준에 머물러 보강이 필요합니다.',
  '태도 요건인 <b>지속학습(82)·주도성(76)·협업태도(72)</b>는 시장 요구를 충족·상회합니다. 반면 기술 요건의 <b>AI 모델링(52)·파이프라인(58)·Python 분석(60)</b>이 큰 격차를 보여 핵심 보완 과제입니다.');

-- =====================================================================
-- 스크랩 JD 비교 — sys_report_jd_match (리스트는 줄바꿈 구분)
-- =====================================================================
DELETE FROM sys_report_jd_match WHERE report_id = @rid;
INSERT INTO sys_report_jd_match
  (report_id, company, role, meta, fit_rate, match_count, recommendation, gap_keywords, strengths, advices)
VALUES
 (@rid,'테크노바AI','AI 이상탐지 모델 개발 (연구개발)','서울 강남 · 5,000~6,500',70,'8 / 12','추천',
  '딥러닝 모델링
MLOps',
  'Python 데이터 분석 경험
데이터 파이프라인 이해
통계·문제해결 역량',
  'PyTorch 기반 모델 구현 포트폴리오 보강
MLOps(배포·모니터링) 학습'),
 (@rid,'클라우드웍스','데이터 엔지니어 (파이프라인 구축)','경기 판교 · 협의',64,'7 / 12','도전',
  '대용량 처리
클라우드(AWS/GCP)
실시간 스트리밍',
  'Python·SQL 활용
ETL 파이프라인 기초
데이터 정제 경험',
  'AWS/GCP 클라우드 실습
Airflow·Spark 경험 확보');

-- 확인
SELECT fit_type, COUNT(*) FROM sys_report_competency WHERE report_id=@rid GROUP BY fit_type;
SELECT COUNT(*) AS sources FROM sys_report_competency_source s
  JOIN sys_report_competency c ON c.competency_id=s.competency_id WHERE c.report_id=@rid;
SELECT cfi_score, summary_title FROM sys_report_activity WHERE report_id=@rid;
SELECT company, fit_rate, recommendation FROM sys_report_jd_match WHERE report_id=@rid;

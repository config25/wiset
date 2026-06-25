-- =====================================================================
-- user 1 스크랩 타겟 공고 3건을 바이오 → IT 로 교체 (제목/회사/지역/고용형태 + JD 본문)
--   TN_EMPMN_PBLANC(공고) + TN_INSTT_INFO(기관). PBLANC_SN 1001~1003 / INSTT USER_SN 101~103.
-- =====================================================================

-- 회사명
UPDATE TN_INSTT_INFO SET INSTT_NM = '테크노바AI'   WHERE USER_SN = 101;
UPDATE TN_INSTT_INFO SET INSTT_NM = '클라우드웍스'  WHERE USER_SN = 102;
UPDATE TN_INSTT_INFO SET INSTT_NM = '넥스트플랫폼'  WHERE USER_SN = 103;

-- 1001 · AI 이상탐지 모델 개발 (연구개발) · 서울 강남 · 정규직
UPDATE TN_EMPMN_PBLANC
SET PBLANC_NM   = 'AI 이상탐지 모델 개발 (연구개발)',
    EMPLYM_STLE = '정규직',
    ADRES       = '서울 강남',
    PBLANC_CN   = '[모집부문] AI 이상탐지 모델 개발 (연구개발)
[담당업무] 시계열·로그 데이터 기반 이상탐지(Anomaly Detection) 모델 연구·개발 및 서비스 적용
[자격요건] 머신러닝/딥러닝 이론 이해, Python 기반 데이터 분석, 데이터 파이프라인 구축 경험, 주도적 문제해결 능력
[우대사항] PyTorch/TensorFlow 활용, 논문 구현 경험, MLOps 이해
[근무지] 서울 강남 · 정규직'
WHERE PBLANC_SN = 1001;

-- 1002 · 데이터 엔지니어 (파이프라인 구축) · 경기 판교 · 정규직
UPDATE TN_EMPMN_PBLANC
SET PBLANC_NM   = '데이터 엔지니어 (파이프라인 구축)',
    EMPLYM_STLE = '정규직',
    ADRES       = '경기 판교',
    PBLANC_CN   = '[모집부문] 데이터 엔지니어 (데이터 파이프라인 구축)
[담당업무] 대용량 데이터 수집·정제 파이프라인 설계/운영, 데이터 웨어하우스 구축
[자격요건] Python·SQL 능숙, ETL/배치 파이프라인 경험, 클라우드(AWS/GCP) 환경 이해
[우대사항] Airflow·Spark 활용, 실시간 스트리밍(Kafka) 경험
[근무지] 경기 판교 · 정규직'
WHERE PBLANC_SN = 1002;

-- 1003 · 백엔드 개발자 (Python) · 대전 · 계약직 2년
UPDATE TN_EMPMN_PBLANC
SET PBLANC_NM   = '백엔드 개발자 (Python)',
    EMPLYM_STLE = '계약직 2년',
    ADRES       = '대전',
    PBLANC_CN   = '[모집부문] 백엔드 개발자 (Python)
[담당업무] REST API 설계·개발, 서비스 백엔드 운영 및 성능 개선
[자격요건] Python 웹 프레임워크(Django/FastAPI) 경험, RDB 설계·SQL, REST API 이해
[우대사항] 컨테이너(Docker)·CI/CD 경험, 클라우드 배포 경험
[근무지] 대전 · 계약직 2년'
WHERE PBLANC_SN = 1003;

-- 확인
SELECT s.PBLANC_SN, p.PBLANC_NM AS title, i.INSTT_NM AS org, p.EMPLYM_STLE AS emp, p.ADRES AS addr
FROM TN_INDVDL_PBLANC_SCRAP s
LEFT JOIN TN_EMPMN_PBLANC p ON p.PBLANC_SN = s.PBLANC_SN
LEFT JOIN TN_INSTT_INFO   i ON i.USER_SN   = s.INSTT_USER_SN
WHERE s.INDVDL_USER_SN = 1 ORDER BY s.PBLANC_SN;

# W브릿지 자동화 — /per3 · 재취업 · 반도체 · 연구지원직

> 이 파일 = **[⚡ 빠른 경로(프리셋)]** 또는 **[공통 실행 규칙 + DATA](수동 입력·삭제 없음)**. 크롬 확장에 붙여넣어 실행.
> (입력 JSON 없음 — 이 프롬프트에 데이터 전량 포함. max_new_tokens/temperature/top_p 무시.)
> **경로 선택**: 완전 자동이면 ⚡ 프리셋. 화면 채우는 과정을 보여줘야 하면 아래 수동 입력(사전에 폼을 비워둔 상태 전제).

## ⚡ 빠른 경로 (권장) — 시연 프리셋 API `/api/test`

> 서버에 **시연 프리셋**이 이미 있다(`TestPresetController`/`TestPresetService`). 호출하면 데모계정(user1)의 **현 상황을 DB에서 전량 삭제 후 이 페르소나로 재시딩**하고, 페르소나·희망목표·세부고민을 sessionStorage(`wb_*`)에 세팅한다. → **STEP1~3 수동 삭제·입력이 전부 불필요.**

**방법 A — 페이지 클릭 (가장 간단·권장)**
1. `http://localhost:8080/api/test` 로 이동.
2. **"페르소나 3"** 카드(반도체 · 재취업 · 연구지원직)에서 버튼 클릭:
   - **"리뷰로 이동"** → 폼이 전량 채워진 채 `/review`로 직행 (최속).
   - 또는 **"이 페르소나로 시연 시작"** → `/current-situation`부터 채워진 상태로 진행.
3. `/review`에서 **"AI 분석 시작하기"**(`#startBtn`) 클릭 → 로딩 뜨면 즉시 정지.

**방법 B — 한 호출 JS** (localhost:8080 오리진 페이지에서 실행: `/api/test` 또는 위저드 화면)
```javascript
const d = await (await fetch('/api/test/load/3', {method:'POST'})).json();
sessionStorage.setItem('wb_persona', d.persona);
sessionStorage.setItem('wb_currentSituation', JSON.stringify(d.currentSituation));
d.careerGoal   ? sessionStorage.setItem('wb_careerGoal',   JSON.stringify(d.careerGoal))   : sessionStorage.removeItem('wb_careerGoal');
d.careerGrowth ? sessionStorage.setItem('wb_careerGrowth', JSON.stringify(d.careerGrowth)) : sessionStorage.removeItem('wb_careerGrowth');
sessionStorage.setItem('wb_concern', d.concern);
location.href = '/review?persona=' + d.persona;   // 채우는 과정을 보이려면 '/current-situation?persona='+d.persona
`loaded persona ${d.persona}`;
```
→ 이후 `/review`에서 "AI 분석 시작하기" 클릭 → 정지.

---

════════════════════════════════════════
## 공통 실행 규칙 (DATA보다 먼저 읽어라) — 수동 입력 · 사전 초기화 가정 · 삭제 없음
════════════════════════════════════════
**전제**: 시작 전 폼이 **비어 있음**(프리셋/초기화로 미리 비워둠). 따라서 **기존 데이터 삭제 단계는 전부 생략**하고 **입력(추가)만** 한다. ⚠️ 폼이 안 비어 있으면 중복 입력되니, 비어있지 않으면 먼저 비울 것.
목표: `http://localhost:8080/persona-select`에서 시작해 5단계 폼을 채우고 "AI 분석 시작하기"까지 클릭 후 즉시 정지. **(속도 최우선)**

### 원칙
- **[R1] 스크린샷 금지.** career-goal·review는 빈 화면으로 렌더돼 30초 타임아웃난다. 상태확인은 `read_page(interactive)` 또는 `javascript_tool` 반환값으로만.
- **[R2] 좌표클릭 금지**(예외: 포트폴리오 URL X버튼만 좌표). 나머지 클릭은 전부 find→ref 또는 JS.
- **[R3] 라운드트립 최소화가 핵심.** 여러 칸 입력·연속 클릭은 묶고, 조작 JS가 결과 문자열을 반환하게 해 별도 검증 호출을 없앤다.
- **[R4] 예측 가능한 연속동작**(클릭→입력→Enter, 폼 여러 칸)은 `browser_batch`로 묶어라.
- **[R5] 삭제가 없으므로 중복 주의** — 이 경로는 빈 폼을 전제한다. 재시도할 땐 폼을 다시 비운 뒤 시작한다(추가만 반복하면 중복 입력됨).
- **[R6] persona=N URL 파라미터가 바뀌어도** 이전 STEP 데이터가 남아있으면 정상. 재입력·재검증 말고 진행.
- **[R7] 데이터 없는 섹션은 미입력으로 비움.** 컨설팅 이력은 손대지 말 것(DB 자동연동).

### 재사용 스니펫 (그대로 실행 — 즉흥 셀렉터 탐색 금지)

**[S1] 추가정보 모달 입력 (삭제 없음):**
모달 열기 → `data-f` 필드 form_input → **'추가하기'를 항목마다 클릭**(그때그때 저장) → **'완료'**로 닫기. (빈 상태 전제 — 기존 항목 삭제 단계 없음.)

**[S2] 근무지 추가:**
```javascript
// 도시마다: 시도→구군 순으로 셀렉트 값 세팅 후 '추가'(#regionAdd) 클릭
function addRegion(sido, gugun){
  const r1=document.querySelector('#region1'); r1.value=sido; r1.dispatchEvent(new Event('change'));
  const r2=document.querySelector('#region2'); r2.value=gugun;
  document.querySelector('#regionAdd').click();
}
// 예: addRegion('서울','전체'); addRegion('경기','성남시');
[...document.querySelectorAll('#regionChips')].length ? document.querySelector('#regionChips').textContent : 'no chips';
```

**[S3] 고용형태 토글 (한 호출·검증 · WANT=켤 항목 배열):**
```javascript
const WANT=[...];
const B=[...document.querySelectorAll('button')];
WANT.forEach(t=>{const b=B.find(x=>x.textContent.trim()===t);
  if(b && getComputedStyle(b).backgroundColor!=='rgb(242, 238, 249)') b.click();});
[...document.querySelectorAll('button')].filter(x=>WANT.includes(x.textContent.trim()))
 .map(x=>x.textContent.trim()+':'+(getComputedStyle(x).backgroundColor==='rgb(242, 238, 249)'?'ON':'off')).join(', ');
// ON=rgb(242,238,249)/보라 rgb(106,76,156), off=rgb(255,255,255). 빈 상태이므로 WANT만 켜기. WANT 외 항목은 건드리지 말 것.
```

### 스텝 골격 (DATA는 아래 [DATA] 섹션에서 주입)
- **STEP0 `/persona-select`** : 지정 페르소나 카드 클릭 → "다음 단계"(ref)
- **STEP1 `/current-situation`** : 학력(`#eduAdd`→모달 입력→저장, 행마다), 경력(`#carAdd`→모달 입력→저장), 추가정보 각 모달([S1]) → "다음 단계"
  - ⚠️ 학력 학교명 칸에 전공 넣지 말 것
- **STEP2 `/career-goal`** : 업종·직무(`#industry`/`#job` form_input), 근무지([S2]), 고용형태([S3]) → "다음 단계"(ref)
  - ⚠️ 페르소나에 따라 이 화면 구성이 다를 수 있음 → **필드·값·셀렉터는 [DATA] STEP2를 최우선**으로 따를 것
- **STEP3 `/concern`** : 고민 텍스트를 `#freeText`에 입력(빈 상태이므로 '지우기' 없이 바로 타이핑) → "다음 단계"(ref)
- **STEP4 `/review`** : read_page로 확인(스크린샷 금지) → "AI 분석 시작하기" 클릭 → 로딩 뜨면 즉시 정지

### 실행 후 · 개선 코멘트 (필수)
STEP4에서 정지한 뒤 브라우저 조작은 더 하지 말고, 이번 실행 회고를 남겨라 — **다음 실행을 더 빠르고 정확하게** 만들기 위한 코멘트:
- **느렸던 지점**: 불필요한 라운드트립·스크린샷·재렌더 대기 등 시간을 잡아먹은 부분.
- **부정확했던 지점**: 빗나간 셀렉터·값, 헤맨 입력/토글, 재시도한 동작.
- **개선 제안**: 위를 근거로 이 공통 규칙(원칙 R·스니펫 S)에 반영할 구체적 수정안.

════════════════════════════════════════
## [DATA] — /per3 · 재취업 · 반도체 · 연구지원직
════════════════════════════════════════

### STEP0 · 페르소나 카드
- **"재취업" 카드(3번)** 클릭 → "다음 단계".

### STEP1 · 현 상황  (빈 상태 전제 — 삭제 없이 추가만)
**학력/전공** (⚠️ 학교명 칸에 전공 넣지 말 것: "석사 · {학교} · {학부}({전공})" 형식 · 각 행 `#eduAdd`→모달 입력→저장)
- 석사 · 한양대학교 · 신소재공학과 (반도체 소자 전공) (2015.02 졸업)
- 고등학교 졸업 · 진선여자고등학교 · 자연계 (졸업)

**경력** (`#carAdd`→모달 입력→저장)
- 에스제이하이맥스 · 소자개발팀 · 선임연구원 (2015.03~2022.12, 총 7년 10개월): DRAM 소자 특성 평가 및 신뢰성 분석 데이터 관리, 공정-소자 상관 분석 리포트 작성, 측정 장비 운용 및 실험 데이터 표준화. 이후 약 3년 경력 공백(출산·육아, 2023.01~2026.05)

**추가정보 9종** (각 모달: [S1] — 입력 → '추가하기' → '완료')
- **논문/연구**:
  - SCI급 논문 2편 (제1저자 1편, 고유전율 게이트 절연막)
  - 특허 출원 1건 (소자 신뢰성 평가 방법)
- **인턴·대외활동**:
  - 사내 실험데이터 관리 표준화 프로젝트 리드 (2021)
- **교육이수**:
  - 여성과학기술인 경력복귀 R&D 재교육 과정 · WISET (2026)
  - 반도체 계측·분석 실무 재교육(수강 중) · 한국반도체산업협회
- **자격증**:
  - 반도체설계산업기사 · 한국산업인력공단 (2014.05)
  - 품질경영기사 · 한국산업인력공단 (2016.11)
- **수상**:
  - 사내 데이터 표준화 개선 우수상 (2021)
- **해외경험**:
  - 미국 반도체 학회 참가 (2019)
- **어학**:
  - 영어 · 비즈니스 회화 가능 · TOEIC 880
- **포트폴리오** — [연구 실적 요약]:
  - DRAM 소자 신뢰성 평가·데이터 표준화 리드 이력
  - 공정-소자 상관 분석 리포트 작성 경험
  - SCI 논문 2편(제1저자 1편), 소자 신뢰성 평가 특허 출원 1건
- **자기소개서** — 제목: 데이터로 소자를 읽어온 8년, 다시 실험실로 돌아갑니다
  소자개발팀에서 8년간 DRAM 소자의 특성 평가와 신뢰성 분석 데이터를 관리하며, 수많은 실험 데이터를 표준화하고 공정-소자 상관을 리포트로 엮는 일에 강점을 쌓았습니다. 측정 장비를 운용하고 데이터 품질을 책임지는 연구지원 실무가 연구의 신뢰성을 떠받친다는 것을 현장에서 배웠습니다.

  출산·육아로 인한 3년의 공백기에도 반도체 분야에서 손을 놓지 않았습니다. WISET 경력복귀 재교육과 계측·분석 실무 재교육을 이수하며 미세화된 공정과 최신 계측 기법을 따라잡았습니다.

  검증된 소자 평가·데이터 관리 역량 위에 최신 계측 감각을 더해, 시간선택제로도 실험 데이터 품질과 분석을 책임지는 연구지원직으로 즉시 기여할 준비가 되어 있습니다.

### STEP2 · 경력개발 목표
- **희망 업종**: `전기/전자 관련직`  (드롭다운 `#industry` 에서 선택)
- **희망 직무**: `연구지원직`  (`#job`)
- **희망 근무지**: 경기 이천시, 경기 용인시  ([S2]로 추가)
- **희망 고용형태**: 정규직, 시간제, 무기계약직  ([S3]로 토글 ON)
- 타겟 공고는 자동 선택분 그대로 둠.

### STEP3 · 세부 고민
출산과 육아로 3년간 현업을 떠나 있어, 그사이 미세화된 공정과 최신 계측·분석 장비 감각이 뒤처졌을까 두렵습니다. 이전 8년간 쌓은 소자 특성 평가와 실험 데이터 관리 역량을 어떻게 다시 전면에 내세워야 할지 막막합니다. 면접에서 3년 공백을 '단절'이 아닌 '재교육기'로 방어할 논리가 필요합니다. 육아를 병행해야 해서 시간선택제로도 반도체 연구지원직 복귀가 현실적인지 고민입니다.

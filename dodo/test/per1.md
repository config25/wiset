# W브릿지 자동화 — /per1 · 신규취업 · AI 정보보안 · 연구개발직

> 이 파일 = **[⚡ 빠른 경로(프리셋)]** 또는 **[공통 실행 규칙 + DATA](수동 입력·삭제 없음)**. 크롬 확장에 붙여넣어 실행.
> (입력 JSON 없음 — 이 프롬프트에 데이터 전량 포함. max_new_tokens/temperature/top_p 무시.)
> **경로 선택**: 완전 자동이면 ⚡ 프리셋. 화면 채우는 과정을 보여줘야 하면 아래 수동 입력(사전에 폼을 비워둔 상태 전제).

## ⚡ 빠른 경로 (권장) — 시연 프리셋 API `/api/test`

> 서버에 **시연 프리셋**이 이미 있다(`TestPresetController`/`TestPresetService`). 호출하면 데모계정(user1)의 **현 상황을 DB에서 전량 삭제 후 이 페르소나로 재시딩**하고, 페르소나·희망목표·세부고민을 sessionStorage(`wb_*`)에 세팅한다. → **STEP1~3 수동 삭제·입력이 전부 불필요.**

**방법 A — 페이지 클릭 (가장 간단·권장)**
1. `http://localhost:8080/api/test` 로 이동.
2. **"페르소나 1"** 카드(AI 정보보안 · 신규취업 · 연구개발직)에서 버튼 클릭:
   - **"리뷰로 이동"** → 폼이 전량 채워진 채 `/review`로 직행 (최속).
   - 또는 **"이 페르소나로 시연 시작"** → `/current-situation`부터 채워진 상태로 진행.
3. `/review`에서 **"AI 분석 시작하기"**(`#startBtn`) 클릭 → 로딩 뜨면 즉시 정지.

**방법 B — 한 호출 JS** (localhost:8080 오리진 페이지에서 실행: `/api/test` 또는 위저드 화면)
```javascript
const d = await (await fetch('/api/test/load/1', {method:'POST'})).json();
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
## [DATA] — /per1 · 신규취업 · AI 정보보안 · 연구개발직
════════════════════════════════════════

### STEP0 · 페르소나 카드
- **"신규 취업" 카드(1번)** 클릭 → "다음 단계".

### STEP1 · 현 상황  (빈 상태 전제 — 삭제 없이 추가만)
**학력/전공** (⚠️ 학교명 칸에 전공 넣지 말 것: "석사 · {학교} · {학부}({전공})" 형식 · 각 행 `#eduAdd`→모달 입력→저장)
- 석사 · 고려대학교 · 정보보호대학원 (AI보안·머신러닝 전공) (2026.08 졸업예정) · 논문: 적대적 공격에 강건한 악성코드 탐지 모델
- 학사 · 고려대학교 · 사이버국방학과 (2024.02 졸업)
- 고등학교 졸업 · 한영외국어고등학교 · 자연계 (졸업)

**경력** (`#carAdd`→모달 입력→저장)
- 시큐어링크 · 보안AI연구팀 · 연구 인턴 (2025.06~2026.02)

**추가정보 9종** (각 모달: [S1] — 입력 → '추가하기' → '완료')
- **논문/연구**:
  - 딥러닝 기반 네트워크 침입탐지(IDS)의 오탐 저감 연구 (석사 학위논문 진행)
  - 정보보호학회 학술대회 포스터 1편: 적대적 예제 기반 악성코드 분류기 강건성 평가
- **인턴·대외활동**:
  - 연구 인턴 · 시큐어링크 보안AI연구팀 (2025.06~2026.02): 악성코드 탐지 모델 학습·평가
  - 화이트해커 CTF 대회 · 국내 예선 상위 10% (2025)
- **교육이수**:
  - 취업탐색 멘토링 · WISET
  - AI 보안 전문인력 양성과정(수강 중) · KISA
- **자격증**:
  - 정보보안기사 · 한국인터넷진흥원 (2025.05)
  - 정보처리기사 · 한국산업인력공단 (2024.08)
- **수상**:
  - 글로벌 여성 사이버보안 해커톤 우수상 (2026)
- **해외경험**:
  - 싱가포르 국제 보안 컨퍼런스 참관 (2025)
- **어학**:
  - 영어 · 비즈니스 회화 가능 · TOEIC 915
- **포트폴리오**:
  - Github (적대적 공격 강건성 평가 도구, IDS 오탐 저감 실험 코드)
  - 기술블로그 (악성코드 탐지 모델 회피 공격 실험기, CTF 문제풀이)
- **자기소개서** — 제목: 공격자의 시선으로 방어를 설계하는 AI 보안 연구자
  사이버국방과 정보보호를 전공하며, 보안은 규칙을 쌓는 일이 아니라 끊임없이 진화하는 공격자와의 지적 대결임을 배웠습니다. 특히 머신러닝 모델 자체가 적대적 공격의 표적이 될 수 있다는 점에 매료되어 AI와 보안의 교집합을 연구 주제로 삼았습니다.

  시큐어링크 연구 인턴으로 악성코드 탐지 모델을 다루며, 탐지율만 높은 모델이 실제로는 회피 공격에 얼마나 취약한지 실험으로 확인했습니다. 오탐을 줄이면서도 적대적 예제에 강건한 모델을 만드는 것이 진짜 연구 과제임을 체감했습니다.

  단순히 최신 모델을 적용하는 것을 넘어, 위협 모델을 스스로 정의하고 방어 성능을 정직하게 평가할 줄 아는 연구개발자가 되고 싶습니다. 실제 위협 환경에서 신뢰할 수 있는 AI 보안 기술을 만드는 것이 목표입니다.

### STEP2 · 경력개발 목표
- **희망 업종**: `정보통신 관련직`  (드롭다운 `#industry` 에서 선택)
- **희망 직무**: `연구개발직`  (`#job`)
- **희망 근무지**: 서울 전체, 경기 성남시  ([S2]로 추가)
- **희망 고용형태**: 정규직, 계약직, 무기계약직, 인턴직  ([S3]로 토글 ON)
- 타겟 공고는 자동 선택분 그대로 둠.

### STEP3 · 세부 고민
AI와 보안을 함께 전공했지만, 신입으로 AI 보안 연구개발직에 지원할 때 보안 도메인 지식과 머신러닝 역량 중 어느 쪽을 전면에 내세워야 할지 확신이 서지 않습니다. 연구개발직은 석박사 논문 실적을 많이 보는데, 석사 신입으로서 연구 경험을 실무 역량으로 어떻게 번역해 어필할지 고민입니다. 주변에 여성 보안 연구자 롤모델이 적어 진로 방향을 잡기도 어렵습니다.

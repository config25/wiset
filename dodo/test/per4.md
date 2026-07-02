# W브릿지 자동화 — /per4 · 승진/보직 · 일반산업 · 연구개발직

> 이 파일 = **[⚡ 빠른 경로(프리셋)]** 또는 **[공통 실행 규칙 + DATA](수동 입력·삭제 없음)**. 크롬 확장에 붙여넣어 실행.
> (입력 JSON 없음 — 이 프롬프트에 데이터 전량 포함. max_new_tokens/temperature/top_p 무시.)
> **경로 선택**: 완전 자동이면 ⚡ 프리셋. 화면 채우는 과정을 보여줘야 하면 아래 수동 입력(사전에 폼을 비워둔 상태 전제).

## ⚡ 빠른 경로 (권장) — 시연 프리셋 API `/api/test`

> 서버에 **시연 프리셋**이 이미 있다(`TestPresetController`/`TestPresetService`). 호출하면 데모계정(user1)의 **현 상황을 DB에서 전량 삭제 후 이 페르소나로 재시딩**하고, 페르소나·희망목표·세부고민을 sessionStorage(`wb_*`)에 세팅한다. → **STEP1~3 수동 삭제·입력이 전부 불필요.** (페르소나 4는 careerGrowth 세션까지 세팅되어 승진 화면도 자동 채워짐.)

**방법 A — 페이지 클릭 (가장 간단·권장)**
1. `http://localhost:8080/api/test` 로 이동.
2. **"페르소나 4"** 카드(일반산업 · 승진/보직 · 연구개발 리더)에서 버튼 클릭:
   - **"리뷰로 이동"** → 폼이 전량 채워진 채 `/review`로 직행 (최속).
   - 또는 **"이 페르소나로 시연 시작"** → `/current-situation`부터 채워진 상태로 진행.
3. `/review`에서 **"AI 분석 시작하기"**(`#startBtn`) 클릭 → 로딩 뜨면 즉시 정지.

**방법 B — 한 호출 JS** (localhost:8080 오리진 페이지에서 실행: `/api/test` 또는 위저드 화면)
```javascript
const d = await (await fetch('/api/test/load/4', {method:'POST'})).json();
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
## [DATA] — /per4 · 승진/보직 · 일반산업 · 연구개발직
════════════════════════════════════════

### STEP0 · 페르소나 카드
- **"승진 / 보직 희망" 카드(4번)** 클릭 → "다음 단계".

### STEP1 · 현 상황  (빈 상태 전제 — 삭제 없이 추가만)
**학력/전공** (⚠️ 학교명 칸에 전공 넣지 말 것: "석사 · {학교} · {학부}({전공})" 형식 · 각 행 `#eduAdd`→모달 입력→저장)
- 박사 · 서울대학교 · 기계공학부 (열유체·설계 전공) (2015.02 졸업)
- 고등학교 졸업 · 창덕여자고등학교 · 자연계 (졸업)

**경력** (`#carAdd`→모달 입력→저장)
- 대성인더스트리 · 기술연구소 · 책임연구원/팀장 (2015.03~현재, 총 11년): 산업용 공조·열교환 시스템 R&D 총괄, 신제품 설계-검증-양산이관 프로세스 표준화, 연구 과제 일정·예산 관리, 타 부서 기술지원, 연구원 6인 직접 지도

**추가정보 9종** (각 모달: [S1] — 입력 → '추가하기' → '완료')
- **논문/연구**:
  - SCI급 논문 4편
  - 국내외 특허 5건 (등록 3, 출원 2)
- **인턴·대외활동**:
  - 사내 기술 세미나 분기 리드
  - 신입 연구원 온보딩 멘토 활동
- **교육이수**:
  - 여성 관리자 리더십 아카데미 · WISET (2026)
  - R&D 프로젝트 리더십 과정 · 한국산업기술진흥협회 (2024)
- **자격증**:
  - 기계기술사 · 한국산업인력공단 (2018.11)
  - PMP · PMI (2020)
- **수상**:
  - 사내 R&D 우수과제상 (2022)
  - 대한민국 기술대상 산업부문 수상 프로젝트 참여 (2023)
- **해외경험**:
  - 일본 산업기계 전시회 기술조사 출장 (2022)
- **어학**:
  - 영어 · 비즈니스 회화 가능 · TOEIC 900
- **포트폴리오** — [리더십·프로젝트 실적]:
  - 산업용 열교환 시스템 신제품 R&D 총괄(과제 KPI 달성)
  - 설계-검증-양산이관 프로세스 표준화로 개발 리드타임 단축
  - 연구원 6인 육성(승급·과제책임 확대), 사내 기술 세미나 분기 운영
  - 대한민국 기술대상 수상 프로젝트 참여
- **자기소개서** — [리더십 지원서] 제목: 뛰어난 연구자를 넘어, 팀의 성과를 만드는 R&D 리더
  11년간 산업용 공조·열교환 시스템의 R&D를 담당하며 설계·검증·양산이관 전 과정을 책임졌고, 논문과 특허로 전문성을 인정받았습니다. 최근 3년은 개인 성과를 넘어 연구 과제의 일정·예산을 관리하고 타 부서와의 기술 커뮤니케이션을 조율하는 역할을 해왔습니다.

  이제 연구소 상위 보직으로서, 제가 잘하던 '직접 설계하는 일'에서 '팀이 더 좋은 설계를 하게 하는 일'로 중심을 옮기려 합니다. 연구원들의 자율성과 과제 일정을 함께 지키고, 부드럽지만 결단력 있는 리더십으로 팀의 성과를 정량으로 증명하는 관리자가 되고자 합니다.

### STEP2 · 경력개발 목표 — ⚠️ per4 전용 화면 (`career-goal-growth`)
> **서버 분기**: `persona=4`면 `/career-goal`이 per1~3의 업종/직무/근무지/고용형태 폼이 아니라 **"경력 성장 목표(승진·보직)" 화면**으로 렌더된다(`CareerGoalController` → `career-goal-growth.jsp`).
> 따라서 **공통 블록 STEP2의 `#industry`·[S2]·[S3]는 이 파일에서 무시**하고 아래 7개 필드를 채운다.
> (참고: 프로필상 희망 업종 `기계 관련직`·직무 `연구개발직`·근무지 서울 전체·경기 안양시·고용형태 정규직 값이 있으나 **이 화면엔 대응 입력 필드가 없다 → 입력 안 함.**)

채울 값 (프리셋 `seed4`/`session4`의 정식 값과 동일 — 소스: `TestPresetService`):
- **① 현재 직급** `#rank` (select): `차장급`
- **② 현재 연차** `#years` (select): `11년`
- **③ 현재 담당 업무** `#duties` (textarea): 산업용 공조·열교환 R&D 총괄, 설계-검증-양산이관 프로세스 표준화, 연구 과제 일정·예산 관리, 연구원 6인 지도
- **④ 목표 보직/직급** `#targetRole` (input): 연구소 상위 보직 (연구소장/그룹장)
- **⑤ 강화할 리더십·역량** `#skillRow` (복수·span 칩): 조직·인력 관리, 전략·기획, 의사결정, 성과관리
- **⑥ 목표 처우** `#targetPay` (input): 성과급 포함 상향 협의
- **⑦ 핵심 평가 반영 요소** `#evalRow` (단일·span 칩): 리더십 다면평가
- → "다음 단계"(`#nextBtn`, ref)

**[S4] per4 STEP2 한 호출** (입력+칩 토글+검증, idempotent · ⑤⑦ 칩은 `<button>`이 아니라 `<span>`이라 공통 [S3] 대신 이걸 쓴다):
```javascript
document.querySelector('#rank').value='차장급';
document.querySelector('#years').value='11년';
document.querySelector('#duties').value='산업용 공조·열교환 R&D 총괄, 설계-검증-양산이관 프로세스 표준화, 연구 과제 일정·예산 관리, 연구원 6인 지도';
document.querySelector('#targetRole').value='연구소 상위 보직 (연구소장/그룹장)';
document.querySelector('#targetPay').value='성과급 포함 상향 협의';
const on=c=>getComputedStyle(c).backgroundColor==='rgb(242, 238, 249)';  // ON=연보라(brand-50)
// ⑤ 강화역량(복수) — 클릭 시 칩이 재렌더되므로 매번 재조회
const SKILL=['조직·인력 관리','전략·기획','의사결정','성과관리'];
const chips=()=>[...document.querySelectorAll('#skillRow > span')];
SKILL.forEach(t=>{const c=chips().find(x=>x.textContent.trim()===t); if(c&&!on(c)) c.click();});
chips().forEach(c=>{ if(!SKILL.includes(c.textContent.trim())&&on(c)) c.click(); });
// ⑦ 평가요소(단일)
[...document.querySelectorAll('#evalRow > span')].find(x=>x.textContent.trim()==='리더십 다면평가')?.click();
`rank:${document.querySelector('#rank').value} / years:${document.querySelector('#years').value} / skills:[${chips().filter(on).map(c=>c.textContent.trim()).join(', ')}] / eval:[${[...document.querySelectorAll('#evalRow > span')].filter(on).map(x=>x.textContent.trim()).join(', ')}]`;
```

### STEP3 · 세부 고민
지금까지는 설계 전문성과 연구 성과(논문·특허)로 인정받아 왔으나, 이번에 연구소 상위 보직 승진 대상자가 되었습니다. 뛰어난 실무자가 관리자로 넘어갈 때 흔히 겪는 '플레이어의 함정'에 빠져 설계를 계속 직접 붙잡을까 봐 걱정입니다. 남성 연구원이 다수인 조직에서 부드럽지만 결단력 있는 리더십을 어떻게 구축할지 막막합니다. 곧 있을 리더십 다면평가에서 저의 조직 관리 역량을 R&D 성과 지표로 어떻게 정량 증명할지 전략이 필요합니다.

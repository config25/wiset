# W브릿지 자동화 — /per2 · 이직 준비 · 화학 바이오 · 기술직

> 이 파일 = **[공통 실행 규칙]**(먼저) + **[DATA]**(페르소나 고유값). 크롬 확장에 그대로 붙여넣어 실행.
> (입력 JSON 없음 — 이 프롬프트에 데이터 전량 포함. max_new_tokens/temperature/top_p 무시.)

## ⚡ 빠른 경로 (권장) — 시연 프리셋 API `/api/test`

> 서버에 **시연 프리셋**이 이미 있다(`TestPresetController`/`TestPresetService`). 호출하면 데모계정(user1)의 **현 상황을 DB에서 전량 삭제 후 이 페르소나로 재시딩**하고, 페르소나·희망목표·세부고민을 sessionStorage(`wb_*`)에 세팅한다. → **STEP1~3 수동 삭제·입력이 전부 불필요.**

**방법 A — 페이지 클릭 (가장 간단·권장)**
1. `http://localhost:8080/api/test` 로 이동.
2. **"페르소나 2"** 카드(화학·바이오 · 이직 · 기술직)에서 버튼 클릭:
   - **"리뷰로 이동"** → 폼이 전량 채워진 채 `/review`로 직행 (최속).
   - 또는 **"이 페르소나로 시연 시작"** → `/current-situation`부터 채워진 상태로 진행.
3. `/review`에서 **"AI 분석 시작하기"**(`#startBtn`) 클릭 → 로딩 뜨면 즉시 정지.

**방법 B — 한 호출 JS** (localhost:8080 오리진 페이지에서 실행: `/api/test` 또는 위저드 화면)
```javascript
const d = await (await fetch('/api/test/load/2', {method:'POST'})).json();
sessionStorage.setItem('wb_persona', d.persona);
sessionStorage.setItem('wb_currentSituation', JSON.stringify(d.currentSituation));
d.careerGoal   ? sessionStorage.setItem('wb_careerGoal',   JSON.stringify(d.careerGoal))   : sessionStorage.removeItem('wb_careerGoal');
d.careerGrowth ? sessionStorage.setItem('wb_careerGrowth', JSON.stringify(d.careerGrowth)) : sessionStorage.removeItem('wb_careerGrowth');
sessionStorage.setItem('wb_concern', d.concern);
location.href = '/review?persona=' + d.persona;   // 채우는 과정을 보이려면 '/current-situation?persona='+d.persona
`loaded persona ${d.persona}`;
```
→ 이후 `/review`에서 "AI 분석 시작하기" 클릭 → 정지.

> ⚠️ 프리셋이 STEP1(DB)+STEP2/3(세션)을 모두 채우므로, **아래 [공통 실행 규칙]·[DATA]의 수동 삭제·입력은 프리셋을 못 쓰는 상황(엔드포인트 차단 등)에서만** 쓰는 fallback이다.

---

════════════════════════════════════════
## 공통 실행 규칙 (DATA보다 먼저 읽어라) — 수동 입력 fallback
════════════════════════════════════════
목표: `http://localhost:8080/persona-select` 에서 시작해 5단계 폼을 자동완성하고
"AI 분석 시작하기"까지 클릭 후 즉시 정지. **(속도 최우선)**

### 원칙
- **[R1] 스크린샷 금지.** career-goal·review는 빈 화면으로 렌더돼 30초 타임아웃난다. 상태확인은 `read_page(interactive)` 또는 `javascript_tool` 반환값으로만.
- **[R2] 좌표클릭 금지**(예외: 포트폴리오 URL X버튼만 좌표). 나머지 클릭은 전부 find→ref 또는 JS.
- **[R3] 라운드트립 최소화가 핵심.** 재렌더되는 리스트/토글은 "탐색+조작+검증"을 JS 한 호출로 처리하고 그 호출이 결과 문자열을 반환하게 하라. 별도 read_page 검증 호출을 만들지 마라(검증은 조작 JS 반환값에 포함).
- **[R4] 예측 가능한 연속동작**(클릭→입력→Enter, 폼 여러 칸)은 `browser_batch`로 묶어라.
- **[R5] 모든 조작 JS는 idempotent** — 재실행해도 안전(이미 된 건 스킵).
- **[R6] persona=N URL 파라미터가 바뀌어도** 이전 STEP 데이터가 남아있으면 정상. 재입력·재검증 말고 진행.
- **[R7] 기존 데이터는 반드시 전량삭제 후 입력.** 컨설팅 이력은 손대지 말 것(DB 자동연동). 데이터 없는 섹션은 미입력으로 비움.

### 재사용 스니펫 (그대로 실행 — 즉흥 셀렉터 탐색 금지)

**[S1] 모달 항목 전량삭제 + 확인 자동처리(한 호출):**
```javascript
const m=document.querySelector('.wb-modal-overlay');
let n=m.querySelectorAll('.wb-rec-x').length;
m.querySelectorAll('.wb-rec-x').forEach(x=>x.click());
[...document.querySelectorAll('button')].filter(b=>b.textContent.trim()==='확인').forEach(b=>b.click());
`deleted:${n}, remain:${document.querySelectorAll('.wb-rec-x').length}`;
```

**[S2] 학력/경력 행 삭제(TXT=삭제할 텍스트):**
```javascript
[...document.querySelectorAll('div.row.items-center.gap-12')]
 .filter(r=>r.textContent.includes(TXT))
 .forEach(r=>r.children[r.children.length-1].click());
// 이어서:
[...document.querySelectorAll('button')].filter(b=>b.textContent.trim()==='확인')[0]?.click();
```

**[S3] 근무지 태그 삭제(CITY=삭제할 도시):**
```javascript
[...document.querySelectorAll('span.row.items-center.gap-6')]
 .filter(s=>s.textContent.includes(CITY))
 .forEach(s=>{const q=s.querySelectorAll('span');q[q.length-1].click();});
```

**[S4] 토글 세팅+검증(한 호출·idempotent · WANT=켤 항목 배열):**
```javascript
const WANT=[...];
const B=[...document.querySelectorAll('button')];
WANT.forEach(t=>{const b=B.find(x=>x.textContent.trim()===t);
  if(b && getComputedStyle(b).backgroundColor!=='rgb(242, 238, 249)') b.click();});
[...document.querySelectorAll('button')].filter(x=>WANT.includes(x.textContent.trim()))
 .map(x=>x.textContent.trim()+':'+(getComputedStyle(x).backgroundColor==='rgb(242, 238, 249)'?'ON':'off')).join(', ');
// ON=rgb(242,238,249)/보라 rgb(106,76,156), off=rgb(255,255,255). WANT 외 항목은 건드리지 말 것.
```

### 스텝 골격 (DATA는 아래 [DATA] 섹션에서 주입)
- **STEP0 `/persona-select`** : 지정 페르소나 카드 클릭 → "다음 단계"(ref)
- **STEP1 `/current-situation`** : 학력·경력([S2]로 전량삭제 후 추가), 추가정보 각 모달([S1]삭제→입력→'추가하기'→'완료') → "다음 단계"
  - ⚠️ 학력 학교명 칸에 전공 넣지 말 것
- **STEP2 `/career-goal`** : 업종·직무(`#industry` 등 form_input), 근무지([S3]삭제 후 추가), 고용형태([S4]) → "다음 단계"(ref)
  - ⚠️ 페르소나에 따라 이 화면 구성이 다를 수 있음 → **필드·값·셀렉터는 [DATA] STEP2를 최우선**으로 따를 것
- **STEP3 `/concern`** : "지우기"로 삭제 후 고민 텍스트 입력 → "다음 단계"(ref)
- **STEP4 `/review`** : read_page로 확인(스크린샷 금지) → "AI 분석 시작하기" 클릭 → 로딩 뜨면 즉시 정지

### 실행 후 · 개선 코멘트 (필수)
STEP4에서 정지한 뒤 브라우저 조작은 더 하지 말고, 이번 실행 회고를 남겨라 — **다음 실행을 더 빠르고 정확하게** 만들기 위한 코멘트:
- **느렸던 지점**: 불필요한 라운드트립·스크린샷·재렌더 대기 등 시간을 잡아먹은 부분.
- **부정확했던 지점**: 빗나간 셀렉터·값, 헤맨 삭제/토글, 재시도한 동작.
- **개선 제안**: 위를 근거로 이 공통 규칙(원칙 R·스니펫 S)에 반영할 구체적 수정안.

════════════════════════════════════════
## [DATA] — /per2 · 이직 준비 · 화학 바이오 · 기술직
════════════════════════════════════════

### STEP0 · 페르소나 카드
- **"이직 준비" 카드(2번)** 클릭 → "다음 단계".

### STEP1 · 현 상황
**학력/전공** (전량삭제 후 · ⚠️ 학교명 칸에 전공 넣지 말 것: "석사 · {학교} · {학부}({전공})" 형식)
- 석사 · 성균관대학교 · 화학공학과 (고분자·소재 전공) (2019.02 졸업)
- 고등학교 졸업 · 대전과학고등학교 · 자연계 (졸업)

**경력** (전량삭제 후)
- 한울케미칼 · 생산기술팀 · 선임연구원 (2019.03~현재, 총 7년 4개월): 정밀화학 소재 스케일업 공정 개발, 반응 조건 최적화 및 수율 개선, 생산 라인 트러블슈팅 및 공정 표준화(SOP) 작성

**추가정보 9종** (각 모달: [S1]로 삭제 → 입력 → '추가하기' → '완료')
- **논문/연구**:
  - 특허 등록 2건 (연속 흐름 반응 공정, 촉매 재사용 공정)
  - SCI급 논문 1편 (친환경 용매 기반 합성 공정)
- **인턴·대외활동**:
  - 사내 공정안전(PSM) 개선 TF 참여 (2023)
- **교육이수**:
  - 여성과학기술인 커리어 전환 멘토링(수강 중) · WISET
  - GMP 및 바이오공정 실무 교육 · 한국바이오협회 (2025)
- **자격증**:
  - 화공기사 · 한국산업인력공단 (2018.05)
  - 위험물산업기사 · 한국산업인력공단 (2018.11)
- **수상**:
  - 사내 공정혁신 우수상 (2022)
- **해외경험**:
  - 독일 화학소재 파트너사 기술교류 출장 (2023)
- **어학**:
  - 영어 · 비즈니스 회화 가능 · TOEIC 850
- **포트폴리오**:
  - 공정 개선 실적 요약 (스케일업 수율 개선, 연속 흐름 공정 도입 사례)
  - 특허 2건·SCI 1편 목록
- **자기소개서** — 제목: 실험실의 반응식을 공장의 수율로 옮기는 공정 엔지니어
  7년간 정밀화학 소재의 생산기술을 담당하며, 좋은 반응식이 곧 좋은 공정은 아니라는 것을 현장에서 배웠습니다. 그램 단위 실험을 톤 단위 생산으로 옮기는 스케일업 과정에서 온도·체류시간·촉매 조건을 다투며 수율과 품질을 함께 끌어올리는 일에 강점을 쌓았습니다.

  최근 바이오 의약품 공정이 화학 합성 공정과 맞닿는 지점에 관심을 갖고 GMP·바이오공정 교육을 이수했습니다. 화학 공정에서 검증한 스케일업과 공정 최적화 역량이 바이오 소재·원료의약품(API) 생산기술로도 확장될 수 있다는 확신을 얻었습니다.

  정밀화학에서 쌓은 생산기술 역량 위에 바이오 공정 지식을 더해, 화학·바이오 소재의 안정적 양산을 책임지는 기술직 엔지니어로 커리어를 확장하고자 합니다.

### STEP2 · 경력개발 목표
- **희망 업종**: `화학/식품가공 관련직`  (드롭다운 `#industry` 에서 선택)
- **희망 직무**: `기술직`
- **희망 근무지**: 경기 화성시, 충북 청주시  ([S3]로 기존 태그 삭제 후 추가)
- **희망 고용형태**: 정규직  ([S4]로 토글 ON)
- 타겟 공고는 자동 선택분 그대로 둠.

### STEP3 · 세부 고민
정밀화학 생산기술 경력 7년을 쌓았지만, 화학에서 바이오 분야로 이직하려니 실무에서 바이오 공정(세포배양·정제)을 직접 다뤄본 경험이 없어 교육 수준에 머물러 있습니다. 화학 공정에서 쌓은 스케일업·수율 개선 역량을 바이오 시장이 요구하는 기술직 언어로 어떻게 재번역해야 할지 막막합니다. 화학 경력이 바이오 기술직에서 오히려 강점으로 읽히도록 이력을 어떻게 재구성해야 할지 고민입니다.

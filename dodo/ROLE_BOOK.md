# ROLE_BOOK.md — Wiset 코딩 컨벤션 & 역할 가이드 (참고 문서)

> 이 문서는 **매 세션 자동 로드되는 "절대 규칙"이 아니라**, 코드를 작성·리뷰할 때 펼쳐보는 **컨벤션 참고서**다.
> (이전 `.claude/CLAUDE.md`는 자동 로드돼 절대 규칙으로 작동했고, 내용이 실제 스택과 어긋나 오히려 위험 → ROLE_BOOK.md로 분리하고 사실관계를 교정함.)
>
> 🧭 **아키텍처·통합의 정본(正本)은 선배님 문서 [`WBRIDGE_PORT.md`](../WBRIDGE_PORT.md) 다.** 본 문서와 충돌하면 **WBRIDGE_PORT.md를 따른다.**
>
> **이 프로젝트의 정체:** Wiset는 **Spring Boot 2.7로 로컬 실행**하되, 운영 시스템 **wbridge(eGov 3.9 레거시)에 드롭인**되도록 코드를 미리 맞춰 둔 상태(**compatible-mirror** 전략). 실제 통합 시 할 일은 `WBRIDGE_PORT.md` [3. 통합 런북] 참고.

---

## 0. 실제 스택 사실관계 (가장 먼저 읽을 것 — 오해 방지)

| 영역 | 실제 (wbridge 타깃) | 자주 하는 오해 |
|------|---------------------|----------------|
| 영속성 | **MyBatis** — `sqlmap/<area>/<name>_mapper.xml` + **점 네임스페이스**(`report.write.*`) | ~~iBATIS~~ 아님 |
| DB 접근 | **`CommonDAO` 문자열 호출**: `commonDAO.selectOne("ns.id", map)`, `@Mapper` 없음 | ~~`EgovAbstractDAO` 상속~~ 아님 |
| 읽기 결과 | 읽기전용 DTO → **`Map`(LinkedHashMap)**, 소비처 `map.get("키")` | — |
| 도메인 객체 | **Lombok 미사용(delombok)** — 명시 getter/setter | ~~`@Data`~~ 아님 |
| 로깅 | **SLF4J + Logback** — `private static final Logger log = LoggerFactory.getLogger(...)` | ~~log4j~~ 아님 |
| 예외 | 데이터 계층~컨트롤러까지 **`throws Exception`** 전파 (wbridge CommonDAO 시그니처 정합) | — |
| 컨트롤러 | **현재 Boot `@RestController`** 유지 → 통합 시 `@Controller extends DefaultController` + `jsonView` 전환 | — |
| 트랜잭션 | 로컬은 `@Transactional` 동작 → **통합 시 wbridge XML 트랜잭션으로 전환** | — |
| DB 방언 | **MySQL 유지** (Tibero 전환 보류) | — |

> ⚠️ 과거에 참고하던 "eGov + iBATIS 표준 정의서"의 아키텍처 항목(iBATIS·EgovAbstractDAO·AbstractServiceImpl·log4j·XML AOP 트랜잭션)은 **이 프로젝트의 실제 타깃과 다르다.**
> 아래 컨벤션 중 **스택과 무관한 것(명명·주석·들여쓰기·SQL 포맷)** 만 그대로 적용하고, **아키텍처는 0절 + WBRIDGE_PORT.md**를 따른다.

---

## 1. 명명 컨벤션 (스택 무관 — 적용 OK)

> 기본적으로 '행정표준용어현황'을 준수. 단, **기존 코드의 실제 패턴이 우선**(예: 매퍼 queryId는 `find*`/`insert*`/`update*` 혼용).

- **파일**
  - JSP: `list.jsp`, `view.jsp`, `update.jsp`, `write.jsp` 등 정형 명칭.
  - 매퍼 XML: **`<name>_mapper.xml`** (wbridge idiom), `sqlmap/<area>/` 아래.
  - JS: `[기능명].js`, 공통은 `cmm_[기능명].js`.
- **클래스 (Java)** — PascalCase + 명사형. **Postfix 필수**: `Controller` / `Service` / `ServiceImpl`.
- **메서드 (Java)** — camelCase, 동사+목적어. Prefix 가이드:
  - 등록 `insert` · 조회 `select`(or 코드상 `find`) · 수정 `update` · 삭제 `delete` · 파일 `read`/`write` · 동시수행 `merge`(등록/수정)/`multi`(등록/수정/삭제).
  - 멀티건 조회는 Postfix `List` (예: `selectAccountList`).
  - 클래스 내 메소드 나열 순서: `private` → `default` → `protected` → `public`.
- **변수/상수** — 변수 camelCase(30자 이내), 상수 `UPPER_SNAKE_CASE`.

---

## 2. 코드 표준

### 2.1 주석
- **파일 헤더 주석**: 모든 소스 상단에 파일명·설명·수정이력. 포팅 대상 컨트롤러는 **`[wbridge 포팅 델타]`** 주석으로 통합 시 전환 내용 명시(기존 관례 유지).
- 클래스/메서드: **JavaDoc(`/** */`)** 을 선언부 바로 윗줄.
- 블럭(`/* */`)·Single-line 주석: **공백 라인 다음**에, 코드와 들여쓰기 맞춤.
- Trailing 주석 여러 개면 **동일 위치 정렬**.
- `//`(EOL): 복잡한 제어문 끝에 `// end if` 등. **연속 여러 라인 남발 금지**.

### 2.2 들여쓰기
- **Space 4칸**. Tab 금지(불가피하면 Space 4칸 치환).

### 2.3 줄 바꿈
- 길면 콤마/연산자 **다음**에서, 상위 레벨(괄호 밖)에서 분리. `if` 이어쓰기는 Space 2칸.
- 긴 삼항 연산자는 조건식 / `?` / `:` **3줄 분리** 허용·권장.

### 2.4 제어문
- 1줄 1 Statement. 중괄호 **K&R**(여는 `{` 같은 줄, 닫는 `}` 단독 줄).
- `switch` 의도적 fall-through 위치엔 **`/* falls through */`** 명시.

### 2.5 로깅 — **SLF4J + Logback** (log4j 아님)
- 로거: `private static final Logger log = LoggerFactory.getLogger(Xxx.class);`
- 레벨: INFO/DEBUG/WARN/ERROR. Unchecked Exception 시 **Stack Trace 로깅**.
- `log.debug` 앞 `if (log.isDebugEnabled())` 가드(문자열 연결 비용 방지).

### 2.6 트랜잭션
- **로컬(현재):** `@Transactional` 사용 가능 — 실제로 일부 서비스(예: `ReportPersistServiceImpl`)가 사용 중.
- **통합 시:** wbridge **XML 선언적 트랜잭션**으로 전환(런북). 신규 작성 시 이 전환을 염두에 둘 것.

---

## 3. UI 개발 표준
- **절대 경로** 사용. 인코딩 **UTF-8**.
- 뷰 경로(현행): JSP는 **`WEB-INF/jsp/wbro`**, 웹루트는 **`WebContents`**(wbridge 정식 웹루트).
  - 로컬 보정: `spring.mvc.view.prefix=/WEB-INF/jsp/wbro/`, `LocalWebContentsConfig`(docBase) — **로컬 전용, 통합 시 복사 안 함**.
- 디렉토리당 파일 **200개 이하**, 파일은 **최하위 디렉토리에만** 배치.
- 반응형: 기준 1220px(중앙 정렬), Breakpoint 760px, 최소 360px.

---

## 4. SQL / 매퍼 작성 규칙
- **방언: MySQL 유지** (`DATE_FORMAT`,`LIMIT…OFFSET`,`CURDATE`). Tibero 전환은 보류 — 전환 지점엔 `TODO(Tibero)`.
- 매퍼: `sqlmap/<area>/<name>_mapper.xml`, **점 네임스페이스**, `#{key}` 는 **Map 키**로 매핑.
- 대소문자: 예약어·FROM 테이블명 **대문자**, SELECT/UPDATE 컬럼 **소문자**.
- 정렬: `SELECT`/`FROM`/`WHERE` 시작점 수직 정렬, 콤마·등호 위치 맞춤.
  - SELECT/UPDATE 컬럼 1줄 1개(최대 3), FROM 1줄 1개(최대 2), WHERE 1줄 1조건.
  - `ORDER BY`/`GROUP BY` 는 `BY ` 다음 1칸 띄워 `SELECT` 기준선 정렬.
  - 괄호(인라인 뷰·스칼라 서브쿼리) 라인은 **줄바꿈 금지**.
- INSERT는 전체 컬럼 대상이라도 **컬럼명 명시**.
- 주석: SQL 내부 `--`, XML 내부 `<!-- -->`.
- ⚠️ 별칭 `AS reportId` 가 구 DTO 필드명과 일치 → 응답 JSON 무변경(화면 영향 없음). Tibero는 별칭 대문자화 주의.

```sql
SELECT account_id
     , COUNT(*) AS cnt
  FROM TN_ACCOUNT a
 WHERE use_yn = 'Y'
 GROUP BY account_id
 ORDER BY cnt DESC
```

---

## 5. 레이어별 개발 가이드 (wbridge idiom — WBRIDGE_PORT.md 기준)

> ⛔ eGov `EgovAbstractDAO`/`AbstractServiceImpl` 상속 방식은 **이 프로젝트에 해당 없음.** 아래가 실제다.

### 5.1 데이터 접근 (DAO 대체)
- **`@Mapper` 인터페이스 만들지 않는다.** `CommonDAO` 를 **생성자 주입**받아 문자열 호출.
  ```java
  Map<String,Object> row = commonDAO.selectOne("report.aiReport.findReport", param);
  long id = ((Number) commonDAO.selectOne("report.write.findReportId", p)).longValue();
  commonDAO.insert("report.write.insertReport", h);   // 감사컬럼(register/updusr) 자동 주입
  ```
  - 목록 for-each는 타입 위트니스: `for (Map<String,Object> r : commonDAO.<Map<String,Object>>selectList(id, p))`.
  - ⚠️ 이 제네릭 사용은 wiset CommonDAO 기준 — 통합 시 wbridge CommonDAO 제네릭화로 그대로 동작(런북 #3).

### 5.2 Service
- `<area>/service/impl/XxxServiceImpl` 에 `@Service`. **상속 없음**, CommonDAO 주입 + 비즈니스 로직.
- 데이터 호출은 `throws Exception` 전파(시그니처 정합).

### 5.3 Controller
- **현재:** Boot `@RestController` + `@GetMapping`/`@PostMapping` + `ResponseEntity`/`Map` 반환.
- **통합 시 전환(런북 #7):** `@Controller extends DefaultController`, `@Resource(name="xxxService")`,
  `@RequestMapping("/<area>/xxx.do|.json")`, `@RequestParam Map`+`ModelMap`, `return "jsonView"`.
  요청·응답 DTO도 이때 **Map**으로. → 각 컨트롤러 헤더 `[wbridge 포팅 델타]` 주석에 미리 기재돼 있음.

### 5.4 도메인/로깅
- Lombok 미사용 — getter/setter 명시, 로거 `LoggerFactory`.

---

## ✅ 자가 점검 체크리스트 (제출 전)

**스택 정합 (가장 중요)**
- [ ] DB 접근을 `CommonDAO` 문자열 호출로 했는가? (`@Mapper` 새로 만들지 않음)
- [ ] 읽기 결과를 `Map` 으로 받고 `map.get("키")` 로 소비하는가?
- [ ] Lombok 없이 명시 getter/setter + `LoggerFactory` 를 썼는가?
- [ ] 데이터 호출 경로에 `throws Exception` 을 전파했는가?
- [ ] 매퍼가 `<name>_mapper.xml` + 점 네임스페이스이며 SQL은 MySQL 방언인가?
- [ ] 컨트롤러를 새로 만들면 헤더에 `[wbridge 포팅 델타]` 주석을 달았는가?

**명명/스타일 (스택 무관)**
- [ ] 클래스 Postfix(`Controller`/`Service`/`ServiceImpl`), 메서드 Prefix가 맞는가?
- [ ] 상수 `UPPER_SNAKE_CASE`, 변수 30자 이내 `camelCase` 인가?
- [ ] 들여쓰기 Space 4칸, K&R 중괄호, 1줄 1 Statement 인가?
- [ ] 주석(파일 헤더·JavaDoc·Trailing 정렬·`//` 절제)을 지켰는가?
- [ ] 긴 삼항 3줄, `switch` fall-through `/* falls through */` 를 명시했는가?

**SQL**
- [ ] 예약어/테이블명 대문자, 컬럼명 소문자, 정렬·괄호 줄바꿈 금지를 지켰는가?
- [ ] INSERT에 컬럼명을 명시했는가?

**로깅**
- [ ] `log.debug` 앞 `isDebugEnabled()` 가드, Unchecked 예외 Stack Trace 로깅을 했는가?

---

## 📌 충돌 시 행동 원칙
1. **기존 파일 수정**: 그 파일의 실제 스택(MyBatis·CommonDAO·`@Transactional`·`@RestController`)을 **그대로 따른다**(surgical). 표준을 핑계로 갈아엎지 않는다.
2. **신규 파일**: wbridge idiom(0·5절)을 기본으로 하되 **모호하면 먼저 묻는다.**
3. **스택 무관 규칙**(명명·주석·들여쓰기·SQL 포맷)은 신·구 코드 모두에 **즉시 적용**.
4. 아키텍처·통합 관련 의문은 항상 **`WBRIDGE_PORT.md` 를 먼저 확인**한다.

> 회사 PC 전반의 일반 행동 규칙(파괴적 명령 금지 등)은 상위 `C:\dev\.claude\CLAUDE.md`에 있다. 중복 기재하지 않는다.

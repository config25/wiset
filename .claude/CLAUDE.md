# CLAUDE.md — Wiset 프로젝트 개발 표준 룰북

> 본 문서는 **전자정부 표준 프레임워크(eGovFrame) + iBATIS** 기반 개발 표준 정의서다.
> Claude(코딩 어시스턴트)는 이 프로젝트에서 코드를 **작성·수정·리뷰**할 때 아래 규칙을 **절대 규칙**으로 따른다.
> 코드를 내놓기 전 반드시 맨 끝의 **[자가 검증 체크리스트]** 로 스스로 점검한다.
>
> ⚠️ 현재 코드베이스는 이 표준과 일부 다르며, 본 표준은 코드가 **점진적으로 이행(migration)해 갈 목표**다.
> 현재 스택과의 차이·충돌 처리 원칙·이행 계획은 별도 문서 **`.claude/REFAC.md`** 를 따른다.

---

## 1. 프로그램 명명 표준 (Naming Conventions)

> **[공통 원칙] 모든 명명 규칙은 기본적으로 '행정표준용어현황'을 준수한다.**

### 1.1 파일 명명 (UI · XML · JS)
- **UI (JSP)**: 정형화된 명칭만 사용 — `list.jsp`, `view.jsp`, `update.jsp`, `write.jsp` 등.
- **DB XML**: `[기능명]_sql.xml`
  - 예: `applyRetirement_sql.xml`
- **JavaScript**: `[기능명].js`
  - 공통 JS는 `cmm_[기능명].js` (예: `cmm_board.js`)

### 1.2 패키지 명명 (Java)
- **모두 소문자**로 작성하며, 소스 파일 최상단에 **단 한 번만** 선언.
- 구조:
  ```
  [시스템명]/[서비스타입]/web/controller
  [시스템명]/[서비스타입]/service
  [시스템명]/[서비스타입]/service/impl
  ```

### 1.3 클래스 명명 (Java)
- **PascalCase**(대문자 시작) + **명사형**.
  - 예: `EgovLoginCheckController`
- **명명 기준(업무 단위)**:
  - **단위 업무** → **테이블명**으로 작성.
  - **복합 업무** → **기능명**으로 작성.
- **Postfix 규칙(필수)**: 성격을 명시하기 위해 반드시 붙인다.
  - `Controller`, `Service`, `ServiceImpl`

### 1.4 메서드 명명 (Java)
- **camelCase**(소문자 시작), **동사 + 목적어** 형태의 일반 용어.
  - 예: `selectAccountList()`
- **[중요] 메서드 Prefix(접두사) 동사 규칙**

  | 작업 | Prefix | 비고 |
  |------|--------|------|
  | 등록 | `insert` | |
  | 조회 (단건/멀티건) | `select` | 멀티건은 **Postfix `List`** 추가 (예: `selectAccountList`) |
  | 수정 | `update` | |
  | 삭제 | `delete` | |
  | 파일 관리 | `read` / `write` | |
  | Data 동시수행 (등록/수정) | `merge` | |
  | Data 동시수행 (등록/수정/삭제) | `multi` | |

- **[메소드 정렬 순서] 클래스 내 메소드를 나열할 때 접근 제어자 순서를 엄격히 지킨다:**
  `private` → `default` → `protected` → `public`

### 1.5 변수 및 상수 명명 (Java)
- **변수**: `camelCase`, **30자 이내**.
- **상수**: **대문자 + 단어 사이 `_`** 조합 (**UPPER_SNAKE_CASE**).
  - 예: `MAX_RETRY_COUNT`

---

## 2. 코드 표준 (Coding Standard)

### 2.1 주석 (Comments)
- **파일 헤더 주석(필수)**: 모든 소스 파일(JSP, JS, Java) 시작 부분에 작성.
  - 포함 항목: **파일명, 설명, 수정일 / 수정자 / 수정내용**
- **클래스/메서드 주석**: **JavaDoc** (`/** ... */`) 형태로 선언부 **바로 윗줄**에 작성.
- **블럭 주석(`/* ... */`) 및 Single-line 주석**: **반드시 공백 라인 다음**에 작성하며, 코드와 **들여쓰기를 맞춤**.
- **Trailing 주석 정렬**: 코드와 같은 라인의 주석이 **여러 개 등장하면 동일한 위치로 들여쓰기(Alignment)** 를 맞춰 가독성을 높인다.
- **변수 / End-Of-Line 주석**: `//` 사용.
  - 제어문이 복잡하면 블록 끝에 `// end switch`, `// end if` 등을 명시.
  - **[제한] 특정 코드 섹션 처리를 제외하고는 `//` 를 연속한 여러 라인에 사용하는 것을 금지**한다.

#### 파일 헤더 주석 예시 (Java)
```java
/**
 * @File Name   : EgovLoginCheckController.java
 * @Description : 로그인 검증 컨트롤러
 * @Modification Information
 *
 *     수정일         수정자        수정내용
 *   -----------    --------    ---------------------------
 *   2026.06.30     홍길동        최초 생성
 */
```

#### Trailing 주석 정렬 예시
```java
int    count   = 0;      // 처리 건수
String userId  = null;   // 로그인 사용자 ID
boolean isAdmin = false; // 관리자 여부
```

### 2.2 들여쓰기 (Indentation)
- **Space 4칸** 사용.
- **Tab 사용 금지** (불가피하면 Tab → Space 4칸으로 치환).

### 2.3 줄 바꿈 및 이어쓰기 (Line Wrapping)
- 라인이 길면 **Comma(`,`) 또는 연산자 다음**에서 분리.
- **상위 레벨(괄호 밖)** 에서 분리 (하위 레벨보다 우선).
- `if` 조건절 이어쓰기는 **Space 2칸**으로 들여쓰기.
- **삼항 연산자**가 길어지면 **조건식 / `?` / `:` 를 각각 분리해 3줄**로 작성하는 방식을 허용·권장한다.

```java
// 연산자 다음에서 분리, 상위 레벨에서 분리
int total = valueOne + valueTwo
          + valueThree + valueFour;

// if 조건절 이어쓰기 = Space 2칸
if (conditionOne
  && conditionTwo
  && conditionThree) {
    doSomething();
}

// 삼항 연산자가 길면 3줄로 분리
String grade = (score >= 90)
             ? "우수"
             : "보통";
```

### 2.4 제어문 포맷팅 (Statements)
- **1줄에 1개의 Statement**만 작성.
- 중괄호 `{}` 는 **K&R 스타일**:
  - 여는 `{` 는 제어문과 **같은 줄**.
  - 닫는 `}` 는 **새로운 줄에 단독**으로.

```java
if (isValid) {
    process();
} else {
    reject();
}
```

- **`switch` 문에서 의도적으로 `break;` 를 생략**할 경우, 반드시 해당 위치에 **`/* falls through */`** 주석을 명시한다.

```java
switch (type) {
    case "A":
    case "B":
        handleAandB();
        /* falls through */
    case "C":
        handleC();
        break;
    default:
        handleDefault();
} // end switch
```

### 2.5 로깅 (Logging)
- **`log4j`** 라이브러리 사용. 레벨: `INFO`, `DEBUG`, `WARN`, `ERROR`.
- **Unchecked Exception** 발생 시 반드시 **Stack Trace를 로그에 남김**.
- **[중요]** `log.debug` 사용 시 **반드시 레벨 체크를 먼저** 수행.

```java
if (log.isDebugEnabled()) {
    log.debug("조회 결과 건수 = " + resultList.size());
}
```

### 2.6 트랜잭션 (Transaction)
- **Annotation(`@Transactional`) 사용 금지.**
- **Spring AOP 기반 선언적 트랜잭션** 방식(`context-transaction.xml`)을 사용한다.

---

## 3. UI 개발 표준

### 3.1 경로 및 구조
- **절대 경로** 사용 원칙.
- 디렉토리 구조: `webapp` 하위에 `WEB-INF`, `css`, `images`, `js`, `html` 배치.
  - 하위 디렉토리는 **시스템명/서브시스템명(소문자)** 으로 **3-level 이하** 구성.
- **디렉토리당 파일 개수: 200개 이하**로 엄격히 제한.
- **물리적 파일 위치: 하위 폴더 구조 중 최하위 디렉토리에만** 위치해야 한다.
- **인코딩: UTF-8 기본** (불가피한 경우에만 `euc-kr`).

### 3.2 화면 디자인 (반응형)
- **기준 해상도: 1220px** (브라우저 중앙 정렬).
- **Breakpoint: 너비 760px** 기준 분기.
- **최소 너비: 360px.**

---

## 4. SQL 작성 규칙

### 4.1 예약어 및 대소문자
- **SQL 예약어** 및 **FROM 절의 테이블명**: **대문자**.
- **SELECT / UPDATE 되는 컬럼명**: **소문자**.

### 4.2 줄 바꿈 및 정렬
- **SELECT / UPDATE 컬럼**: 1줄당 1개 (많으면 최대 **3개**까지 허용).
- **FROM 테이블**: 1줄당 1개 (많으면 최대 **2개**까지 허용).
- **WHERE 조건**: 1줄당 **1개 조건**.
- **정렬(들여쓰기)**: `SELECT`/`UPDATE`/`DELETE`/`INSERT` 를 기준으로
  `FROM`/`WHERE`/`INTO`/`SET` 의 **시작점을 수직으로 정렬**.
  - 컬럼의 **콤마(`,`) / 등호(`=`)** 위치를 맞춰 가독성 확보.
- **`ORDER BY` / `GROUP BY` 들여쓰기**: `SELECT`(6자)와 기준선을 맞추기 위해 **`BY ` 다음 스페이스 1칸**을 띄우고 관련 내용을 기술해 정렬을 맞춘다.
- **괄호 라인 줄바꿈 금지**: 인라인 뷰·스칼라 서브쿼리 등 괄호를 사용할 경우, **괄호가 존재하는 라인은 절대 줄을 바꾸지 않는다.**

```sql
SELECT account_id
     , COUNT(*)                    AS cnt
     , ( SELECT dept_name FROM TN_DEPT WHERE dept_id = a.dept_id ) AS dept_name  -- 괄호 라인은 줄바꿈하지 않음
  FROM TN_ACCOUNT a
 WHERE use_yn = 'Y'
   AND del_yn = 'N'
 GROUP BY account_id
 ORDER BY cnt DESC
```

### 4.3 주석
- **SQL 내부 주석**: `--` 사용.
- **DB XML 내부 주석**: `<!-- ... -->` 사용.

### 4.4 기타
- **INSERT 문**은 전체 컬럼을 대상으로 하더라도 **반드시 컬럼명을 명시**한다.

```sql
INSERT INTO TN_ACCOUNT
            ( account_id
            , account_name
            , reg_date )
     VALUES ( #accountId#
            , #accountName#
            , SYSDATE )
```

---

## 5. 레이어별 개발 가이드 (Architecture Framework)

### 5.1 Annotation 가이드
- Spring 설정 정보 관리에 Annotation(`org.springframework.beans.factory.annotation`)을 **적극 활용**.

### 5.2 DAO 클래스
- **iBATIS 프레임워크** 기반.
- 반드시 **`EgovAbstractDAO`**(`SqlMapClientDaoSupport` 상속)를 **상속**받아 구현.
- 다음을 **직접 구현하지 않음**(스프링에 위임):
  - DataSource, Connection 생성
  - 자원 해제
  - Data 처리 오류 Exception 로직

### 5.3 Service 클래스
- **비즈니스 로직** 처리.
- `ServiceImpl` 클래스는 **`AbstractServiceImpl`** 을 상속.
- Exception 처리 시 상속받은 **`processException`** 메서드를 활용.

### 5.4 Controller 클래스
- **Spring MVC DispatcherServlet** 요청 처리 담당.

---

## ✅ 자가 검증 체크리스트 (코드 제출 전 필수 점검)

코드를 작성·수정·리뷰한 뒤, 아래 항목을 **스스로 검증**한 후에만 결과를 제출한다.

**명명**
- [ ] 명명이 '행정표준용어현황'을 준수하는가?
- [ ] 클래스에 `Controller`/`Service`/`ServiceImpl` Postfix가 정확히 붙었는가?
- [ ] 클래스명을 업무 단위(단위=테이블명 / 복합=기능명) 기준으로 지었는가?
- [ ] 메서드 Prefix가 작업 성격과 일치하는가? (`insert`/`select`/`update`/`delete`/`read`/`write`/`merge`/`multi`)
- [ ] 멀티건 조회 메서드에 `List` Postfix를 붙였는가?
- [ ] 클래스 내 메소드를 접근 제어자 순서(`private`→`default`→`protected`→`public`)로 나열했는가?
- [ ] 패키지는 전부 소문자이며 규정된 구조(`.../web/controller`, `.../service`, `.../service/impl`)를 따르는가?
- [ ] 상수는 `UPPER_SNAKE_CASE`, 변수는 30자 이내 `camelCase`인가?
- [ ] JSP/JS/XML 파일명이 명명 규칙(`list.jsp`, `[기능명]_sql.xml`, `cmm_[기능명].js`)을 따르는가?

**코드 스타일**
- [ ] 파일 헤더 주석(파일명/설명/수정이력)을 작성했는가?
- [ ] 클래스·메서드 주석을 JavaDoc(`/** */`)으로 선언부 윗줄에 달았는가?
- [ ] 블럭/Single-line 주석을 공백 라인 다음에 작성했는가?
- [ ] Trailing 주석이 여러 개일 때 동일 위치로 정렬했는가? / `//` 를 연속 여러 라인에 남발하지 않았는가?
- [ ] 들여쓰기가 Space 4칸인가? (Tab 없음)
- [ ] 1줄 1 Statement, K&R 중괄호 스타일을 지켰는가?
- [ ] 긴 삼항 연산자를 조건식/`?`/`:` 3줄로 분리했는가?
- [ ] `switch` 의 의도적 `break` 생략 위치에 `/* falls through */` 를 명시했는가?
- [ ] `log.debug` 앞에 `if (log.isDebugEnabled())` 체크를 넣었는가?
- [ ] Unchecked Exception 시 Stack Trace를 로그에 남기는가?
- [ ] `@Transactional`을 쓰지 않고 XML AOP 트랜잭션을 사용했는가? *(REFAC.md 확인)*

**SQL**
- [ ] 예약어·테이블명은 대문자, 컬럼명은 소문자인가?
- [ ] SELECT/FROM/WHERE 정렬(수직 정렬, 콤마·등호 정렬)을 맞췄는가?
- [ ] `ORDER BY`/`GROUP BY` 를 `SELECT` 기준선에 맞춰 정렬했는가?
- [ ] 괄호(인라인 뷰·스칼라 서브쿼리) 라인을 줄바꿈하지 않았는가?
- [ ] INSERT 문에 컬럼명을 명시했는가?
- [ ] SQL 주석 `--`, XML 주석 `<!-- -->` 을 올바르게 썼는가?

**아키텍처**
- [ ] DAO는 `EgovAbstractDAO`를 상속했는가? *(REFAC.md 확인)*
- [ ] `ServiceImpl`은 `AbstractServiceImpl`을 상속하고 `processException`을 활용하는가? *(REFAC.md 확인)*

---

## 📌 현행 스택과의 차이 · 이행 계획

> 본 표준은 **eGovFrame + iBATIS** 기준이며, 현재 Wiset 코드베이스의 실제 스택(MyBatis·CommonDAO·`@Transactional`·`@RestController`·Logback)과 다르다.
> 표준은 코드가 **점진적으로 이행해 갈 목표**이며, **현행 대조표 · 충돌 처리 원칙 · 선결 과제**는 별도 문서 **`.claude/REFAC.md`** 에 정리되어 있다.
> 표준과 현행이 충돌하는 코드를 만질 때는 **반드시 `REFAC.md` 를 확인**하고, 모호하면 임의로 강행하지 말고 담당자(팀장/선배)에게 확인한다.

---
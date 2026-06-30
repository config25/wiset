# REFAC.md — 현행 스택 vs 개발 표준 · 리팩토링/이행 계획

> `.claude/CLAUDE.md` 의 개발 표준(**eGovFrame + iBATIS**)은 이 프로젝트가 **점진적으로 이행(migration)해 갈 목표**다.
> 현재 코드베이스의 실제 스택은 아래와 같이 다르며, 본 문서는 그 **차이와 이행 방향**을 기록한다.
> Claude 는 코드를 작성·수정할 때 이 문서를 참조해, 표준과 현행이 충돌하는 지점을 인지하고 처리한다.

---

## 1. 현행 스택 vs 표준 대조표

| 항목 | 표준 (목표, CLAUDE.md) | 현재 Wiset 실제 코드 | 이행 상태 |
|------|------------------------|----------------------|-----------|
| 영속성 | iBATIS, `[기능명]_sql.xml` | **MyBatis** (mybatis-spring-boot-starter) | ☐ TODO |
| DAO | `EgovAbstractDAO` 상속 | **`CommonDAO`** + `Map`("즉석 DTO") 패턴 | ☐ TODO |
| Service | `AbstractServiceImpl` 상속 / `processException` | 평범한 `@Service` 빈 (상속 없음) | ☐ TODO |
| 트랜잭션 | XML AOP(`context-transaction.xml`), `@Transactional` **금지** | **`@Transactional` 사용** (예: `ReportPersistServiceImpl`) | ☐ TODO |
| Controller | DispatcherServlet + JSP(list/view/update/write) | **`@RestController`** + JSON, 프론트 `fetch`+JS 렌더 | ☐ TODO |
| 로깅 | `log4j` | **SLF4J + Logback** (`LoggerFactory`) | ☐ TODO |
| 패키지 | `[시스템명]/[서비스타입]/web/controller` | `com.example.wiset.report.controller` 등 | ☐ TODO |
| 빌드/런타임 | (eGov 레거시 WAR) | **Spring Boot 2.7.18 / Java 8 / Gradle** | — |

---

## 2. 작업 시 충돌 처리 원칙

1. **기존 파일 수정**: 현재 그 파일의 실제 스택(MyBatis·CommonDAO·`@Transactional`·`@RestController`)을 **그대로 따른다**(surgical). 표준을 이유로 멀쩡한 코드를 갈아엎지 않는다.
2. **신규 파일 작성**: 표준(목표 스택)으로 갈지 현행 스택에 맞출지 **모호하면 먼저 묻는다.**
3. **스택 무관 규칙**(명명·주석·들여쓰기·SQL 포맷 등 CLAUDE.md **1·2·4장 대부분**)은 신구 코드 모두에 적용해도 안전 → **즉시 적용**.

---

## 3. 선결 과제 (이행 전 합의 필요)

- **의존성 교체**: `build.gradle` 에 iBATIS·log4j 없음 → MyBatis/Logback 에서 전환하려면 **빌드 의존성부터 합의·교체** 필요.
- **베이스 클래스 도입**: `EgovAbstractDAO` / `AbstractServiceImpl` / `processException` 등 eGov 런타임 베이스 도입 여부 결정.
- **트랜잭션 방식 전환**: `@Transactional` → XML AOP 전환은 **전 서비스에 영향** → 별도 스파이크 후 결정.

> 위 과제들은 **팀장/선배 확인이 필요한 사안**이다. 임의로 진행하지 않는다.

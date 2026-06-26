# wiset → wbridge 통합 가이드

> **한 줄 요약**: 새 Boot 앱(`wiset`)을 운영 시스템(`wbridge`, eGov 3.9 레거시)에 합치는 작업.
> 지금은 **로컬에서 wiset를 그대로 실행**하면서, 코드를 wbridge에 **드롭인 가능한 형태로 미리 맞춰 둔** 상태다.
> 실제 합치기(=통합)는 **아직 안 했다.** 통합 시 할 일은 아래 **[3. 통합 런북]** 참고.

---

## 0. 두 프로젝트

| | wiset (이 프로젝트) | wbridge (운영 대상) |
|---|---|---|
| 위치 | `Impact_design/wiset` | `Downloads/wbridge_moblie/wbridge_moblie` |
| 빌드/런타임 | Gradle + **Spring Boot 2.7** (내장 톰캣) | Maven + **eGov 3.9 / Spring 4.3** (외부 톰캣 WAR) |
| 패키지 루트 | `com.example.wiset` | `nurim`, `wbridge` |
| DB | MySQL/MariaDB (로컬) | Tibero (운영) |
| 웹 루트 / 뷰 | `webapp` / `WEB-INF/jsp/wbro` | `WebContents` / `WEB-INF/jsp` + SiteMesh |

**전략 (compatible-mirror)**: wbridge 관례에 맞추되 **wiset는 계속 Boot로 실행**되게 유지한다.
양쪽을 동시에 만족할 수 없는 부분(부트스트랩·뷰·설정·DB 방언)은 **wiset에서 건드리지 않고**, 통합하는 날 wbridge 트리에서 한 번에 처리한다.

---

## 1. 현재 상태 한눈에

| 구분 | 상태 |
|---|---|
| 데이터/매퍼/서비스 계층 (전 모듈) | ✅ wbridge idiom 이식 완료 |
| 읽기전용 DTO → Map | ✅ 완료 (12종 삭제) |
| Lombok 제거 (delombok) | ✅ 완료 |
| 예외 정합 (`throws Exception`) | ✅ 완료 |
| 컨트롤러 전환 / 요청·응답 DTO → Map | ⏳ 통합 시 (런북 #7) |
| 부트스트랩·뷰·설정·패키지 이전 | ⏳ 통합 시 (런북 #2~#6) |
| DB Tibero 전환 | ⏸ 의도적 보류 ([4번](#4-의도적-보류)) |

> 핵심: **"로컬 실행 + 통합 호환"을 동시에 만족하는 준비는 모두 끝났다.**
> 남은 건 전부 "로컬이 그 위에서 돌고 있어서 지금 바꾸면 로컬이 깨지는" 골격 작업 → **통합하는 날** 처리.

---

## 2. 완료된 작업 (✅)

### 2-1. 데이터 계층 — 전 모듈 wbridge idiom 이식
- 매퍼 XML: `sqlmap/<area>/<name>_mapper.xml` + **점 네임스페이스**(`mngr.adminReports`, `mypage.resume`, `report.write`, `stage.analysis` 등)
  → wbridge `classpath:sqlmap/**/*_mapper.xml` 에 그대로 적재됨.
- `@Mapper` 인터페이스 **전부 제거** → `commonDAO.selectList/One/insert/update("ns.queryId", map)` 문자열 호출.
- 서비스 `<area>/service/impl/XxxServiceImpl` 로 분리.
- 대상: admin(Reports/Dashboard/Satisfaction/AiQuality) · cnsl · report · mypage · stage.

### 2-2. 읽기전용 DTO → Map (12종 삭제)
- DiagnosisRow, PlannerRow, ProfileHeaderRow, HistoryRow, ActionPlannerItemDto, RecommendationDto,
  ScrapDto, AiReportRow, ReportActivityRow, ReportJdMatchRow, ReportCompetencyRow, ReportCompetencySource
- 매퍼 resultType → `java.util.LinkedHashMap`, 소비처는 `map.get("키")` 접근.
- **별칭(AS …)이 구 DTO 필드명과 동일** → 응답 JSON 무변경(화면 영향 없음).

### 2-3. Lombok 제거 (delombok)
- `@Data`(DTO 18) → 명시 getter/setter, `@Slf4j`(10) → `private static final Logger log = LoggerFactory.getLogger(…)`.
- 소스 lombok 사용 0 → wbridge(pom에 lombok 없음)에서도 컴파일 가능.

### 2-4. 예외 정합 (`throws Exception`)
- `support/CommonDAO` 10개 메서드 + 호출 서비스/컨트롤러 전체에 `throws Exception` 전파.
- wbridge CommonDAO 시그니처(`throws Exception`)와 일치 → **서비스 코드 수정 없이 이식**.
- 로컬 영향 없음(실제 던지는 건 런타임 예외 → 동작·트랜잭션 롤백 무변동).

### 2-5. (로컬 실행 보정) 뷰 경로 — webapp → WebContents
- JSP가 `WEB-INF/views` → `WEB-INF/jsp/wbro`, 웹루트 `webapp` → **`WebContents`**(wbridge 정식 웹루트명)로 이동됨.
- 조치 ① `spring.mvc.view.prefix=/WEB-INF/jsp/wbro/` (컨트롤러는 폴더 없는 뷰명 반환, JSP include는 `../common-w/` 상대경로).
- 조치 ② Boot는 JSP를 `src/main/webapp` 에서만 서빙 → `config/LocalWebContentsConfig` (WebServerFactoryCustomizer로 docBase=`src/main/WebContents`) 추가로 보정. **[로컬 전용 — 통합 시 복사 안 함]** (wbridge는 WebContents가 정식 웹루트).
- 결과: `bootRun` 시 뷰/API 모두 200 확인.

---

## 3. 통합 런북 (옮기는 날 할 일 — 순서대로)

> 전부 **wbridge 트리에서** 수행한다. 로컬 wiset 원본은 그대로 둔다.

1. **폴더 복사** — `src/main/java/com/example/wiset/**`, `src/main/resources/sqlmap/**`, JSP 를 wbridge 트리로.
2. **#4 패키지 리네임** — IDE Refactor로 `com.example.wiset.*` → `wbridge.wbro.*` (71파일 자동).
   - 이유: wbridge는 `nurim`,`wbridge` 만 스캔 → 안 바꾸면 빈 등록 0.
3. **#3-잔여 CommonDAO 정리**
   - wiset `support/CommonDAO` **삭제** (wbridge에 이미 `wbridge.common.dao.CommonDAO` 존재 → 빈 이름 `commonDAO` 중복 방지).
   - wbridge CommonDAO를 **제네릭화**(`<T> T selectOne`, `<E> List<E> selectList`) — 하위호환이라 기존 wbridge 코드 안 깨지고, wiset 코드의 캐스팅/타입위트니스도 그대로 컴파일.
4. **#2 부트스트랩**
   - `WisetApplication`(@SpringBootApplication) → **복사 안 함** (wbridge는 web.xml + dispatcher XML).
   - `config/AiClientConfig`(@Configuration) → wbridge `context-*.xml` 의 **XML 빈**으로 전환 (RestTemplate, WisetAiClient).
5. **#6 설정** — `application.properties` 항목을 wbridge `globals.properties` + `context-*.xml` 로:
   - 데이터소스(**MySQL 유지**), mybatis 설정, 업로드 경로(`app.upload.dir`), AI 서버 URL(`wiset.ai.*`).
6. **#5 뷰/JSP** — JSP를 `WebContents/WEB-INF/jsp` 로 이동, dispatcher viewResolver prefix 조정,
   SiteMesh 데코레이터 + 공용 `common-w` jspf 경로 정리.
7. **#7 컨트롤러 전환** (가장 큰 작업)
   - `@RestController`/`ResponseEntity`/`@GetMapping` → `@Controller extends DefaultController`,
     `@Resource(name="xxxService")`, `@RequestMapping("/<area>/xxx.do|.json")`, `@RequestParam Map`+`ModelMap`, `return "jsonView"`.
   - **요청·응답 DTO → Map**: resume 입력 DTO(EducationDto/CareerDto/… + 저장·라벨변환 로직), ai 패키지(GenerateRequest/Response/GenerationInputs), PlannerAddReq, SurveyDto/SurveySubmitDto.
   - `resume_mapper` 의 남은 12개 resultType(DTO)도 이때 함께 Map 으로.
8. **DB 연결** — wbridge `pom.xml` 에 MySQL 커넥터 + MySQL 데이터소스 빈 추가 (Tibero 전환은 보류).
9. **확인** — 매퍼는 `_mapper.xml`+점ns라 자동 적재됨. 기동 후 화면/엔드포인트 점검.

> 각 컨트롤러 파일 헤더에 `[wbridge 포팅 델타]` 주석으로 위 전환 내용을 이미 명시해 둠.

---

## 4. 의도적 보류

| 항목 | 내용 |
|---|---|
| **DB 방언** | MySQL(`DATE_FORMAT`,`LIMIT…OFFSET`,`CURDATE`) ↔ Tibero(`to_char`,`ROWNUM`,`SYSDATE`). 전환 시 매퍼별 `TODO(Tibero)`. |
| **결과키 대소문자** | Tibero는 대문자 컬럼키. 현재 `AS reportId` 별칭으로 맞춤 — Tibero 별칭 대문자화 주의. |
| **세션/감사컬럼** | `CommonDAO` 감사값이 현재 `"SYSTEM"` 고정 → 포팅 시 `nurim.util.SessionUtil` 연동. |

---

## 5. 부록: 모듈 변환 절차 (참고)

신규 모듈을 idiom으로 옮길 때 쓰는 절차 (이미 전 모듈 적용 완료).

1. **매퍼 XML** → `sqlmap/<area>/<name>_mapper.xml`, namespace 점표기, `#{key}` 는 Map 키로 그대로. SQL 방언은 MySQL 유지.
2. **`@Mapper` 인터페이스 삭제** (wbridge엔 `@Mapper`/`@MapperScan` 없음 — 순수 SqlSession). 삭제 전 잔존 참조 grep.
3. **서비스** → CommonDAO 생성자 주입, `commonDAO.xxx("ns.id", map)`. 비즈니스 로직 그대로.
4. **컨트롤러** → Boot 유지 + `[wbridge 포팅 델타]` 주석(통합 시 전환 내용 명시).
5. **검증** → `./gradlew compileJava` + 매퍼 wellformed + 잔존 참조 0.

### CommonDAO 사용 팁 (제네릭 반환)
- 단건: `Map<String,Object> m = commonDAO.selectOne(id);`, 숫자는 `((Number) commonDAO.selectOne(id)).longValue()`.
- 목록 for-each: 타입 위트니스 `for (Map<String,Object> r : commonDAO.<Map<String,Object>>selectList(id))`.
- 쓰기: `commonDAO.insert/update(id, map)` — `#{key}` 자리를 Map 키로. 감사값(register/updusr) 자동 주입.
- ⚠️ 위 제네릭 사용은 wiset CommonDAO 기준. 통합 시 wbridge CommonDAO를 제네릭화하면 그대로 동작(런북 #3).

package com.example.wiset.devtest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.Map;

/**
 * [개발용] 시연 프리셋 스위처.
 *   GET  /api/test              → 페르소나 4버튼 페이지(HTML).
 *   POST /api/test/load/{1~4}   → 해당 페르소나를 데모 계정(user 1)에 시딩 + sessionStorage 페이로드(JSON) 반환.
 * 버튼 클릭 → load 호출 → 응답으로 wb_* sessionStorage 세팅 → 위저드로 이동(수동 입력 불필요).
 * ※ 로그인/시큐리티가 없어 누구나 접근 가능한 개발 전용 도구. 운영 배포 시 제거/차단 필요.
 */
@RestController
public class TestPresetController {

    private static final Logger log = LoggerFactory.getLogger(TestPresetController.class);

    private final TestPresetService service;

    public TestPresetController(TestPresetService service) {
        this.service = service;
    }

    @GetMapping(value = "/test", produces = MediaType.TEXT_HTML_VALUE + ";charset=UTF-8")
    public String page() {
        return PAGE;
    }

    @PostMapping(value = "/api/test/load/{persona}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> load(@PathVariable int persona) {
        try {
            return ResponseEntity.ok(service.load(persona));
        } catch (Exception e) {
            log.error("[api/test] 프리셋 로드 실패 persona={}", persona, e);
            return ResponseEntity.status(500)
                    .body(Collections.singletonMap("message", "프리셋 로드 실패: " + e.getMessage()));
        }
    }

    // 단일 인용부호만 사용(Java 문자열 이스케이프 최소화).
    private static final String PAGE = ""
            + "<!DOCTYPE html><html lang='ko'><head><meta charset='UTF-8'>"
            + "<meta name='viewport' content='width=device-width, initial-scale=1'>"
            + "<title>시연 프리셋 · /api/test</title><style>"
            + ":root{--blue:#0066cc;--ink:#1d1d1f;--muted:#6e6e73;--parch:#f5f5f7;--hair:#e0e0e0;--tile:#1d1d1f;}"
            + "*{box-sizing:border-box;}"
            + "body{margin:0;font-family:-apple-system,system-ui,'Segoe UI','Malgun Gothic',sans-serif;color:var(--ink);background:#fff;letter-spacing:-0.01em;}"
            + ".hero{background:var(--tile);color:#fff;padding:40px 32px 34px;}"
            + ".hero .k{font-size:11px;letter-spacing:2.4px;text-transform:uppercase;color:#a1a1a6;font-weight:600;}"
            + ".hero h1{margin:10px 0 6px;font-size:26px;font-weight:600;letter-spacing:-0.5px;}"
            + ".hero p{margin:0;color:#d2d2d7;font-size:14px;}"
            + ".wrap{max-width:760px;margin:0 auto;padding:26px 24px 60px;}"
            + ".grid{display:grid;grid-template-columns:1fr 1fr;gap:16px;}"
            + ".card{border:1px solid var(--hair);border-radius:18px;padding:20px;background:#fff;}"
            + ".card .tag{display:inline-block;font-size:12px;font-weight:700;color:var(--blue);background:#eef4ff;border-radius:9999px;padding:3px 11px;}"
            + ".card h2{margin:12px 0 4px;font-size:18px;font-weight:600;letter-spacing:-0.3px;}"
            + ".card .sub{margin:0 0 16px;color:var(--muted);font-size:13px;}"
            + ".btn{display:block;width:100%;border:none;border-radius:9999px;padding:12px 16px;font-size:14px;font-weight:600;cursor:pointer;font-family:inherit;letter-spacing:-0.2px;}"
            + ".btn.primary{background:var(--blue);color:#fff;margin-bottom:8px;}"
            + ".btn.primary:active{transform:scale(0.98);}"
            + ".btn.ghost{background:#fff;color:var(--blue);border:1px solid var(--blue);}"
            + ".note{margin-top:22px;color:var(--muted);font-size:12px;line-height:1.6;background:var(--parch);border-radius:14px;padding:14px 16px;}"
            + "#toast{position:fixed;left:50%;bottom:28px;transform:translateX(-50%);background:var(--ink);color:#fff;padding:11px 18px;border-radius:9999px;font-size:13px;opacity:0;transition:opacity .2s;pointer-events:none;}"
            + "#toast.on{opacity:1;}"
            + "</style></head><body>"
            + "<div class='hero'><div class='k'>W-BRIDGE · DEV · 시연 프리셋 스위처</div>"
            + "<h1>페르소나를 선택하면 세션이 미리 채워집니다</h1>"
            + "<p>버튼 클릭 → 데모 계정(user 1)에 해당 페르소나 데이터 로드 → 수동 입력 없이 위저드 바로 진행.</p></div>"
            + "<div class='wrap'><div class='grid'>"
            + card("1", "AI 정보보안", "신규취업 · 연구개발직")
            + card("2", "화학·바이오", "이직 · 기술직")
            + card("3", "반도체", "재취업 · 연구지원직")
            + card("4", "일반산업", "승진/보직 · 연구개발 리더")
            + "</div>"
            + "<div class='note'>· <b>시연 시작</b>: 현 상황 입력 화면(/current-situation)부터 채워진 상태로 진행합니다.<br>"
            + "· <b>리뷰로</b>: 입력 확인 화면(/review)으로 바로 이동합니다.<br>"
            + "· 현 상황(학력·경력·부가정보)은 DB(user 1)에, 페르소나·희망목표·고민은 브라우저 세션에 저장됩니다. 재클릭 시 기존 현 상황은 교체됩니다.<br>"
            + "· 결과 리포트는 이번 범위가 아니며 기존 시드가 표시됩니다(필요 시 별도 작업).</div>"
            + "</div><div id='toast'></div>"
            + "<script>"
            + "function toast(m){var t=document.getElementById('toast');t.textContent=m;t.classList.add('on');setTimeout(function(){t.classList.remove('on');},2200);}"
            + "function go(n,dest){"
            + "var btns=document.querySelectorAll('button');btns.forEach(function(b){b.disabled=true;});"
            + "toast('페르소나 '+n+' 로딩 중...');"
            + "fetch('/api/test/load/'+n,{method:'POST'})"
            + ".then(function(r){if(!r.ok)return r.json().then(function(e){throw new Error(e.message||('HTTP '+r.status));});return r.json();})"
            + ".then(function(d){"
            + "sessionStorage.setItem('wb_persona',d.persona);"
            + "sessionStorage.setItem('wb_currentSituation',JSON.stringify(d.currentSituation));"
            + "if(d.careerGoal){sessionStorage.setItem('wb_careerGoal',JSON.stringify(d.careerGoal));}else{sessionStorage.removeItem('wb_careerGoal');}"
            + "if(d.careerGrowth){sessionStorage.setItem('wb_careerGrowth',JSON.stringify(d.careerGrowth));}else{sessionStorage.removeItem('wb_careerGrowth');}"
            + "sessionStorage.setItem('wb_concern',d.concern);"
            + "location.href=dest+'?persona='+d.persona;"
            + "})"
            + ".catch(function(e){btns.forEach(function(b){b.disabled=false;});toast('실패: '+e.message);});"
            + "}"
            + "window.addEventListener('pageshow',function(e){document.querySelectorAll('button').forEach(function(b){b.disabled=false;});});"
            + "</script></body></html>";

    private static String card(String n, String industry, String sub) {
        return "<div class='card'><span class='tag'>페르소나 " + n + "</span>"
                + "<h2>" + industry + "</h2><p class='sub'>" + sub + "</p>"
                + "<button class='btn primary' onclick=\"go('" + n + "','/current-situation')\">이 페르소나로 시연 시작</button>"
                + "<button class='btn ghost' onclick=\"go('" + n + "','/review')\">리뷰로 이동</button>"
                + "</div>";
    }
}

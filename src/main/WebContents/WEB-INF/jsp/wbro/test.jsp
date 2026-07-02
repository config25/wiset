<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>시연 테스트 콘솔 · W브릿지 (DEV)</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">

<div class="wb wb-frame" style="background:#F4F6F8; min-height:100vh;">
  <main style="max-width:1080px; margin:0 auto; padding:36px 24px 64px;">

    <div class="mb-24">
      <h1 style="font-size:22px; font-weight:800; margin:0;">시연 테스트 콘솔</h1>
      <div class="caption mt-4">TEST ONLY · 데모 계정(user 1) 세션 관리</div>
    </div>

    <%-- 1. 현재 세션 정보 --%>
    <div class="row items-center gap-8 mb-12">
      <span class="badge badge-blue">1</span>
      <h2 style="font-size:16px; font-weight:700; margin:0;">현재 세션 정보</h2>
      <button type="button" class="btn btn-ghost btn-sm" style="margin-left:auto;" onclick="refresh()">새로고침 ⟳</button>
    </div>
    <div class="row gap-16 mb-24">
      <div class="card flex-1">
        <div class="h3 mb-16">브라우저 세션 (sessionStorage)</div>
        <div id="sessBox" class="col"></div>
      </div>
      <div class="card flex-1">
        <div class="h3 mb-16">DB 현 상황 (user 1)</div>
        <div id="dbBox" class="col"></div>
      </div>
    </div>

    <%-- 2. 세션 비우기 --%>
    <div class="row items-center gap-8 mb-12">
      <span class="badge badge-ai">2</span>
      <h2 style="font-size:16px; font-weight:700; margin:0;">세션 비우기</h2>
    </div>
    <div class="card mb-24" style="border:1px dashed var(--accent); background:linear-gradient(135deg, #FDF2F8, var(--bg-soft));">
      <div class="row items-center gap-16">
        <div style="flex:1;">
          <div class="fw-700" style="font-size:15px;">세션 · 현 상황 비우기</div>
          <div class="caption mt-4">브라우저 세션(wb_*) + 데모 계정(user 1) 현 상황(학력·경력·부가정보 9종·자기소개서)을 전량 삭제합니다.</div>
        </div>
        <button type="button" id="clearBtn" class="btn btn-brand btn-sm" onclick="clearAll()">세션 비우기</button>
      </div>
    </div>

    <%-- 3. 세션 채우기 (4가지) --%>
    <div class="row items-center gap-8 mb-12">
      <span class="badge badge-green">3</span>
      <h2 style="font-size:16px; font-weight:700; margin:0;">세션 채우기 (4가지)</h2>
      <span class="caption">클릭 시 user 1에 시딩 + 세션 세팅 후 시연 화면으로 이동</span>
    </div>
    <div class="row gap-16">
      <div class="card flex-1">
        <span class="badge badge-blue">페르소나 1</span>
        <div class="h3 mt-8" style="margin-bottom:2px;">AI 정보보안</div>
        <div class="caption mb-16">신규취업 · 연구개발직</div>
        <button type="button" class="btn btn-brand btn-sm" style="width:100%;" onclick="go('1')">세션 채우기 ▶</button>
      </div>
      <div class="card flex-1">
        <span class="badge badge-ai">페르소나 2</span>
        <div class="h3 mt-8" style="margin-bottom:2px;">화학·바이오</div>
        <div class="caption mb-16">이직 · 기술직</div>
        <button type="button" class="btn btn-brand btn-sm" style="width:100%;" onclick="go('2')">세션 채우기 ▶</button>
      </div>
      <div class="card flex-1">
        <span class="badge badge-green">페르소나 3</span>
        <div class="h3 mt-8" style="margin-bottom:2px;">반도체</div>
        <div class="caption mb-16">재취업 · 연구지원직</div>
        <button type="button" class="btn btn-brand btn-sm" style="width:100%;" onclick="go('3')">세션 채우기 ▶</button>
      </div>
      <div class="card flex-1">
        <span class="badge badge-gray">페르소나 4</span>
        <div class="h3 mt-8" style="margin-bottom:2px;">일반산업</div>
        <div class="caption mb-16">승진·보직 · R&D 리더</div>
        <button type="button" class="btn btn-brand btn-sm" style="width:100%;" onclick="go('4')">세션 채우기 ▶</button>
      </div>
    </div>

  </main>
</div>

<div id="toast" style="position:fixed; left:50%; bottom:28px; transform:translateX(-50%); background:#1B1B1F; color:#fff; padding:11px 18px; border-radius:9999px; font-size:13px; opacity:0; transition:opacity .2s; pointer-events:none; z-index:9999;"></div>

<script>
(function () {
  var ctx = '${ctx}';
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function toast(m){ var t=document.getElementById('toast'); t.textContent=m; t.style.opacity='1'; setTimeout(function(){ t.style.opacity='0'; }, 2200); }

  // 세션 채우기 → 시딩 + 세션 세팅 → 시연(현 상황) 화면으로 이동
  window.go = function(n){
    document.querySelectorAll('button').forEach(function(b){ b.disabled=true; });
    toast('페르소나 ' + n + ' 채우는 중...');
    fetch(ctx + '/api/test/load/' + n, { method:'POST' })
      .then(function(r){ if(!r.ok) return r.json().then(function(e){ throw new Error(e.message||('HTTP '+r.status)); }); return r.json(); })
      .then(function(d){
        sessionStorage.setItem('wb_persona', d.persona);
        sessionStorage.setItem('wb_currentSituation', JSON.stringify(d.currentSituation));
        if(d.careerGoal){ sessionStorage.setItem('wb_careerGoal', JSON.stringify(d.careerGoal)); } else { sessionStorage.removeItem('wb_careerGoal'); }
        if(d.careerGrowth){ sessionStorage.setItem('wb_careerGrowth', JSON.stringify(d.careerGrowth)); } else { sessionStorage.removeItem('wb_careerGrowth'); }
        sessionStorage.setItem('wb_concern', d.concern);
        location.href = ctx + '/current-situation?persona=' + d.persona;
      })
      .catch(function(e){ document.querySelectorAll('button').forEach(function(b){ b.disabled=false; }); toast('실패: ' + e.message); });
  };

  // 세션 · 현 상황 비우기
  window.clearAll = function(){
    if(!confirm('브라우저 세션과 데모 계정(user 1)의 현 상황을 모두 비웁니다. 진행할까요?')) return;
    var b=document.getElementById('clearBtn'); b.disabled=true;
    fetch(ctx + '/api/test/clear', { method:'POST' })
      .then(function(r){ if(!r.ok) return r.json().then(function(e){ throw new Error(e.message||('HTTP '+r.status)); }); return r.json(); })
      .then(function(){
        ['wb_persona','wb_currentSituation','wb_careerGoal','wb_careerGrowth','wb_concern'].forEach(function(k){ sessionStorage.removeItem(k); });
        b.disabled=false; toast('비움 완료'); refresh();
      })
      .catch(function(e){ b.disabled=false; toast('실패: ' + e.message); });
  };

  function kvrow(k, v){
    return '<div class="row justify-between items-center" style="border-bottom:1px solid var(--line); padding:6px 0;">'
      + '<span class="caption fw-700">' + esc(k) + '</span>'
      + '<span class="caption" style="max-width:62%; text-align:right; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;" title="' + esc(v) + '">' + esc(v) + '</span></div>';
  }

  window.refresh = function(){
    var keys=['wb_persona','wb_currentSituation','wb_careerGoal','wb_careerGrowth','wb_concern'];
    var sb=document.getElementById('sessBox'); sb.innerHTML='';
    keys.forEach(function(k){ var v=sessionStorage.getItem(k); sb.innerHTML += kvrow(k, (v==null||v==='')?'(비어있음)':v); });
    var db=document.getElementById('dbBox'); db.innerHTML='<div class="caption" style="color:var(--ink-400);">불러오는 중...</div>';
    fetch(ctx + '/api/test/state').then(function(r){ return r.json(); }).then(function(s){
      db.innerHTML='';
      db.innerHTML += kvrow('최종학력(식별)', s.identity || '(없음)');
      db.innerHTML += kvrow('학력', s.education + '건');
      db.innerHTML += kvrow('경력', s.career + '건');
      db.innerHTML += kvrow('논문/연구', s.research + '건');
      db.innerHTML += kvrow('인턴·대외활동', s.activity + '건');
      db.innerHTML += kvrow('교육이수', s.training + '건');
      db.innerHTML += kvrow('자격증', s.certificate + '건');
      db.innerHTML += kvrow('수상', s.award + '건');
      db.innerHTML += kvrow('해외경험', s.overseas + '건');
      db.innerHTML += kvrow('어학', s.language + '건');
      db.innerHTML += kvrow('포트폴리오', s.portfolio + '건');
      db.innerHTML += kvrow('자기소개서', s.coverTitle || '(없음)');
    }).catch(function(e){ db.innerHTML='<div class="caption">상태 조회 실패: ' + esc(e.message) + '</div>'; });
  };

  window.addEventListener('pageshow', function(){
    document.querySelectorAll('button').forEach(function(b){ b.disabled=false; });
    refresh();
  });
})();
</script>
</body>
</html>

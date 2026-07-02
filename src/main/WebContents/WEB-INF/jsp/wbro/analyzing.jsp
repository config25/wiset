<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="wb" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="activeNav" value="consult" scope="request" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>07 분석 진행 · W브릿지 AI 커리어 코칭</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">
<div class="wb wb-frame">

  <%@ include file="../common-w/header-ds.jspf" %>

  <%-- Breadcrumb --%>
  <div style="border-bottom:1px solid var(--line);">
    <div class="wb-breadcrumb">
      <span class="row items-center gap-4"><wb:icon-ds name="home" size="13" color="#9AA0A8" /> Home</span>
      <span class="sep">›</span><span>진단·컨설팅</span>
      <span class="sep">›</span><span>AI 커리어 코칭</span>
      <span class="sep">›</span><span class="current">분석 진행</span>
    </div>
  </div>

  <div class="section" style="padding:72px 40px; min-height:580px;">
    <div class="text-center" style="max-width:720px; margin:0 auto;">

      <%-- Spinner --%>
      <div style="position:relative; width:120px; height:120px; margin:0 auto 24px;">
        <div class="pulse" id="hexWrap" style="position:absolute; inset:12px; border-radius:50%; background:var(--brand-grad); display:flex; align-items:center; justify-content:center; box-shadow:0 12px 36px -8px rgba(106,76,156,0.5);"></div>
        <div class="spin" style="position:absolute; inset:0; border:3px solid var(--brand-100); border-top-color:var(--brand); border-radius:50%;"></div>
      </div>

      <span class="badge badge-brand mb-16">AI 분석 중</span>
      <h1 class="display mb-12" style="margin-top:8px;">김지수 님의 커리어를 분석하고 있어요</h1>
      <p class="body-lg" style="margin-bottom:28px;">예상 소요 시간 <b class="t-brand">약 30 ~ 60초</b> · 페이지를 닫지 마세요</p>

      <div class="progress" style="height:12px; margin-bottom:10px;"><i id="progFill" style="width:8%;"></i></div>
      <div class="row justify-between caption mb-32"><span>분석 진행률</span><span class="fw-700 t-brand" id="progPct">8%</span></div>

      <div class="card" style="padding:0; overflow:hidden; text-align:left;" id="stepCard"></div>

      <p class="caption mt-24">분석이 60초 이상 소요될 경우 자동으로 백그라운드 처리되며 완료 시 푸시 알림으로 안내됩니다.</p>
    </div>
  </div>

  <%@ include file="../common-w/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  function qp(n){ var m=new RegExp('[?&]'+n+'=([^&]*)').exec(location.search); return m?decodeURIComponent(m[1]):''; }
  function svg(p,sz,c,sw){ return '<svg width="'+sz+'" height="'+sz+'" viewBox="0 0 24 24" fill="none" stroke="'+(c||'currentColor')+'" stroke-width="'+(sw||1.7)+'" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">'+p+'</svg>'; }
  var CHK = '<path d="M4.5 12.5l4.5 4.5L19.5 6.5"/>';

  // HexFlower 모티프 (6색 육각 꽃)
  function hexFlower(size){
    var cx=50, cy=50, R=30;
    var cols=['#7C5CC0','#4E78C8','#3FA98C','#7CB342','#F0A33E','#D24E84'];
    function pt(a,r){ var rad=a*Math.PI/180; return [cx+r*Math.cos(rad), cy+r*Math.sin(rad)]; }
    var paths='';
    for(var i=0;i<6;i++){ var a0=-90+i*60, a1=a0+60; var p0=pt(a0,R), p1=pt(a1,R);
      paths += '<path d="M'+cx+' '+cy+' L'+p0[0].toFixed(2)+' '+p0[1].toFixed(2)+' L'+p1[0].toFixed(2)+' '+p1[1].toFixed(2)+' Z" fill="'+cols[i]+'" stroke="#fff" stroke-width="2.5" stroke-linejoin="round"/>'; }
    return '<svg width="'+size+'" height="'+size+'" viewBox="0 0 100 100"><circle cx="50" cy="50" r="'+(R+9)+'" fill="#fff"/>'+paths+'<circle cx="50" cy="50" r="5.5" fill="#fff"/></svg>';
  }
  document.getElementById('hexWrap').innerHTML = hexFlower(56);

  // 분석 단계
  var steps = [
    { n:'01', t:'이력서 및 진단 결과 임베딩', doing:'비식별화 처리 후 역량 앵커와 매핑 중...', done:'비식별화 처리 후 역량 앵커와 매핑 완료' },
    { n:'02', t:'타깃 JD 파싱', doing:'요구 역량 추출 · 가중치 산정 중...', done:'12개 요구 역량 추출 · 가중치 산정 완료' },
    { n:'03', t:'컨설팅 패턴 RAG 검색', doing:'유사 컨설팅 사례 36건 중 8건 매칭 중...', done:'유사 컨설팅 사례 36건 매칭 완료' },
    { n:'04', t:'협업 필터링 코호트 분석', doing:'동일 직무 코호트 비교 분석 중...', done:'동일 직무 코호트 분석 완료' },
    { n:'05', t:'컨설팅형 진단평 생성', doing:'강점·보완점 평어 및 액션 생성 중...', done:'평어 및 액션 플랜 생성 완료' }
  ];
  var state = steps.map(function(){ return 'wait'; });
  var card = document.getElementById('stepCard');

  function render(){
    card.innerHTML = '';
    steps.forEach(function(s,i){
      var st = state[i];
      var bg = st==='done' ? 'var(--brand)' : st==='doing' ? '#fff' : 'var(--bg-soft)';
      var fg = st==='done' ? '#fff' : st==='doing' ? 'var(--brand)' : 'var(--ink-400)';
      var bd = st==='doing' ? '2px solid var(--brand)' : 'none';
      var desc = st==='done' ? s.done : st==='doing' ? s.doing : '대기 중';
      var row = document.createElement('div'); row.className='row items-center gap-16';
      row.style.cssText = 'padding:18px 24px;' + (i<steps.length-1?'border-bottom:1px solid var(--line);':'') + 'background:'+(st==='doing'?'var(--brand-50)':'#fff')+';';
      row.innerHTML =
        '<div style="width:32px; height:32px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:12px; background:'+bg+'; color:'+fg+'; border:'+bd+';">'+(st==='done'?svg(CHK,15,'#fff'):s.n)+'</div>'+
        '<div style="flex:1;"><div class="fw-700" style="color:'+(st==='wait'?'var(--ink-400)':'var(--ink)')+';">'+s.t+'</div><div class="caption mt-4">'+desc+'</div></div>'+
        (st==='doing'?'<span class="badge badge-brand-solid">진행 중</span>':'')+
        (st==='done'?'<span class="badge badge-blue">완료</span>':'');
      card.appendChild(row);
    });
  }
  function setProgress(p){
    var v = Math.min(100, Math.round(p));
    document.getElementById('progFill').style.width = v+'%';
    document.getElementById('progPct').textContent = v+'%';
  }

  // 실제 AI 리포트 생성 — 비동기. /generate 는 백그라운드 잡만 띄우고 즉시 반환하므로(느린 AI 서버로 수 분 소요),
  // /status 를 짧게 폴링해 실제 완료를 확인한다. (동기 호출 시 수 분 연결 유지 → 브라우저/프록시 타임아웃으로 끊김 방지)
  var genDone = false, genFailed = false, genErr = '';
  var pollStart = Date.now(), POLL_MAX_MS = 12*60*1000; // 12분 초과 시 포기(직전 데이터로 진행)
  fetch(ctx + '/api/report/generate', { method:'POST', headers:{'Content-Type':'application/json'}, body:'{}' })
    .then(function(r){ if(!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
    .then(function(){ pollStatus(); })
    .catch(function(e){ genFailed = true; genErr = e.message; console.error('AI 생성 시작 실패', e); });

  function pollStatus(){
    if(Date.now() - pollStart > POLL_MAX_MS){ genFailed = true; genErr = 'timeout'; console.warn('생성 폴링 12분 초과 — 직전 데이터로 진행'); return; }
    fetch(ctx + '/api/report/status')
      .then(function(r){ return r.ok ? r.json() : null; })
      .then(function(s){
        if(s && s.status === 'done'){ genDone = true; }
        else if(s && s.status === 'failed'){ genFailed = true; genErr = s.error || '생성 실패'; }
        else { setTimeout(pollStatus, 3000); } // running/idle → 계속 폴링
      })
      .catch(function(){ setTimeout(pollStatus, 3000); });
  }

  // 단계 진행 — 마지막 단계는 실제 생성이 끝날 때까지 대기
  var idx = 0; state[0] = 'doing'; render(); setProgress(8);
  function goComplete(){
    var suf = qp('persona') ? ('?persona='+encodeURIComponent(qp('persona'))) : '';
    location.href = ctx + '/analysis-complete' + suf;
  }
  var timer = setInterval(function(){
    if(idx < steps.length - 1){
      state[idx] = 'done'; idx++; state[idx] = 'doing';
      setProgress(8 + (idx/steps.length)*82); // 마지막 단계 전까지 ~90%
      render();
    } else if(genDone || genFailed){
      // 생성 완료(또는 실패) → 마지막 단계 닫고 결과로
      state[idx] = 'done'; setProgress(100); render();
      clearInterval(timer);
      if(genFailed) { /* 실패해도 결과 화면(시드/직전값)으로 진행 */ console.warn('생성 실패, 직전 데이터로 표시:', genErr); }
      setTimeout(goComplete, 600);
    } else {
      setProgress(92); // 대기 중: 마지막 단계에서 멈춰 생성 기다림
    }
  }, 1400);
})();
</script>
</body>
</html>

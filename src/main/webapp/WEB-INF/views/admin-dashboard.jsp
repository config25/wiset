<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="wb" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>관리자 · 통합 대시보드 · W브릿지</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">

<wb:admin active="dash" title="통합 대시보드" sub="자동 새로고침 5분">

  <%-- SECTION 1 --%>
  <div class="row items-center gap-8 mb-12">
    <span class="badge badge-blue">SECTION 1</span>
    <h2 style="font-size:16px; font-weight:700; margin:0;">실시간 지표</h2>
    <span class="caption">페르소나별 유입 · 단계별 이탈률 · 누적진단</span>
    <span class="caption" id="liveStamp" style="margin-left:auto; color:#10B981;">● LIVE</span>
  </div>
  <div class="row gap-16 mb-16">
    <div class="card flex-1" style="padding:18px;"><div class="caption">누적 진단 건수</div><div class="row items-end gap-4 mt-8 mb-4"><span id="kCumulative" style="font-size:22px; font-weight:800; color:var(--primary); line-height:1;">–</span></div><div class="caption" style="color:var(--ink-500);">전체 기간</div></div>
    <div class="card flex-1" style="padding:18px;"><div class="caption">MAU</div><div class="row items-end gap-4 mt-8 mb-4"><span id="kMau" style="font-size:22px; font-weight:800; color:var(--primary); line-height:1;">–</span></div><div class="caption" style="color:var(--ink-500);">최근 30일 활성</div></div>
    <div class="card flex-1" style="padding:18px;"><div class="caption">실시간 동시접속</div><div class="row items-end gap-4 mt-8 mb-4"><span id="kLive" style="font-size:22px; font-weight:800; color:var(--blue); line-height:1;">–</span><span class="caption">건</span></div><div class="caption" style="color:var(--ink-500);">진행중 세션</div></div>
    <div class="card flex-1" style="padding:18px;"><div class="caption">오늘 진단 시작</div><div class="row items-end gap-4 mt-8 mb-4"><span id="kToday" style="font-size:22px; font-weight:800; color:var(--blue); line-height:1;">–</span><span class="caption">건</span></div><div class="caption" style="color:var(--ink-500);">오늘 세션 시작</div></div>
    <div class="card flex-1" style="padding:18px;"><div class="caption">단계별 최대 이탈률</div><div class="row items-end gap-4 mt-8 mb-4"><span id="kMaxDrop" style="font-size:22px; font-weight:800; color:var(--accent); line-height:1;">–</span><span class="caption">%</span></div><div class="caption" id="kMaxDropStep" style="color:var(--ink-500);">–</div></div>
  </div>

  <div class="row gap-16 mb-24">
    <div class="card flex-1">
      <div class="h3 mb-16">페르소나별 유입량</div>
      <div class="row justify-center mb-16" id="personaRing"></div>
      <div class="col gap-8" id="personaList"></div>
    </div>

    <div class="card" style="flex:2;">
      <div class="h3 mb-16">진단 플로우 단계별 이탈률</div>
      <div class="col gap-8" id="funnel"></div>
    </div>
  </div>

  <%-- SECTION 2 --%>
  <div class="row items-center gap-8 mb-12">
    <span class="badge badge-ai">SECTION 2</span>
    <h2 style="font-size:16px; font-weight:700; margin:0;">답변 통계</h2>
    <span class="caption">AI 답변 만족도 · 응답 속도 · 품질 지표</span>
  </div>
  <div class="row gap-16 mb-16">
    <div class="card flex-1" style="padding:18px;">
      <div class="caption mb-8">사용자 만족도 (좋아요 / 싫어요)</div>
      <div class="row items-baseline gap-8 mb-12"><span id="satUp" style="font-size:24px; font-weight:800; color:#10B981;">👍 –</span><span class="caption" style="color:var(--ink-500);">·</span><span id="satDown" style="font-size:16px; font-weight:700; color:#EF4444;">👎 –</span></div>
      <div style="height:8px; background:#FEE2E2; border-radius:4px; overflow:hidden;"><div id="satBar" style="width:0; height:100%; background:#10B981;"></div></div>
      <div class="caption mt-8" id="satDetail" style="color:var(--ink-500);">–</div>
    </div>
    <div class="card flex-1" style="padding:18px;">
      <div class="caption mb-8">평균 응답 속도</div>
      <div class="row items-baseline gap-4 mb-12"><span id="spdAvg" style="font-size:24px; font-weight:800; color:var(--primary);">–</span><span class="caption">초</span><span id="spdBadge" class="badge badge-green" style="margin-left:auto;">목표 60초</span></div>
      <div class="caption" id="spdDetail" style="color:var(--ink-500);">–</div>
    </div>
    <div class="card flex-1" style="padding:18px;">
      <div class="caption mb-8">평균 만족도 (5점 척도)</div>
      <div class="row items-baseline gap-4 mb-8"><span id="ratAvg" style="font-size:24px; font-weight:800; color:var(--accent);">–</span><span class="caption">/ 5.0</span><span id="ratCount" class="badge badge-green" style="margin-left:auto; color:#10B981;">–</span></div>
      <div class="row gap-4" id="ratBars"></div>
    </div>
  </div>

  <div class="card mb-24">
    <div class="h3 mb-16">답변 품질 지표 (자동 평가)</div>
    <div class="row gap-16" id="quality"></div>
  </div>

  <%-- SECTION 3 --%>
  <div class="row items-center gap-8 mb-12">
    <span class="badge" style="background:var(--blue-50); color:var(--blue);">SECTION 3</span>
    <h2 style="font-size:16px; font-weight:700; margin:0;">시스템 통계</h2>
    <span class="caption">활용량 · 성능 · 데이터 배치</span>
  </div>
  <div class="row gap-16 mb-16">
    <div class="card" style="flex:2;">
      <div class="row justify-between items-center mb-12"><div class="h3">시스템 활용량 (일별)</div><div class="caption" id="usageSummary">–</div></div>
      <div id="adminBar"></div>
    </div>
    <div class="card flex-1">
      <div class="h3 mb-16">성능 지표</div>
      <div class="col gap-12">
        <div class="row justify-between items-center" style="padding:6px 0; border-bottom:1px solid var(--line);"><span class="caption">API 가용성</span><span id="pfApi" class="fw-700" style="font-size:13px; color:#10B981;">–</span></div>
        <div class="row justify-between items-center" style="padding:6px 0; border-bottom:1px solid var(--line);"><span class="caption">GPU 사용률</span><span id="pfGpu" class="fw-700" style="font-size:13px; color:#10B981;">–</span></div>
        <div class="row justify-between items-center" style="padding:6px 0; border-bottom:1px solid var(--line);"><span class="caption">DB 응답 시간</span><span id="pfDb" class="fw-700" style="font-size:13px; color:#10B981;">–</span></div>
        <div class="row justify-between items-center" style="padding:6px 0; border-bottom:1px solid var(--line);"><span class="caption">에러율 (5xx)</span><span id="pfErr" class="fw-700" style="font-size:13px; color:#FB923C;">–</span></div>
        <div class="row justify-between items-center" style="padding:6px 0;"><span class="caption">큐 대기</span><span id="pfQueue" class="fw-700" style="font-size:13px; color:#10B981;">–</span></div>
      </div>
    </div>
  </div>

  <div class="card">
    <div class="row justify-between items-center mb-16"><div class="h3">최근 데이터 배치</div><button type="button" class="btn btn-ghost btn-sm">배치 이력 →</button></div>
    <table style="width:100%; border-collapse:collapse; font-size:13px;">
      <thead>
        <tr style="text-align:left; color:var(--ink-500); border-bottom:1px solid var(--line);">
          <th style="padding:10px 8px; font-weight:600;">배치 ID</th><th style="padding:10px 8px; font-weight:600;">유형</th><th style="padding:10px 8px; font-weight:600;">실행 시각</th><th style="padding:10px 8px; font-weight:600;">처리 건수</th><th style="padding:10px 8px; font-weight:600;">소요 시간</th><th style="padding:10px 8px; font-weight:600;">상태</th>
        </tr>
      </thead>
      <tbody id="batch"></tbody>
    </table>
  </div>

  <div class="card mt-24" style="background:linear-gradient(135deg, var(--brand-50), var(--bg-soft)); border:1px dashed var(--primary);">
    <div class="row items-center gap-16">
      <wb:icon-ds name="download" size="32" color="#6A4C9C" />
      <div style="flex:1;">
        <div class="fw-700" style="font-size:15px;">전체 서비스 현황 데이터 내보내기</div>
        <div class="caption mt-4">실시간 지표 + 답변 통계 + 시스템 통계를 단일 CSV로 다운로드합니다</div>
      </div>
      <div class="row gap-8">
        <select id="exportScope" class="select" style="width:auto; padding:6px 12px; font-size:13px;">
          <option value="all">전체 데이터</option>
          <option value="realtime">실시간 지표만</option>
          <option value="answer">답변 통계만</option>
          <option value="system">시스템 통계만</option>
        </select>
        <button type="button" id="exportBtn" class="btn btn-brand btn-sm">CSV 내보내기</button>
      </div>
    </div>
  </div>

</wb:admin>

<script>
(function () {
  var ctx = '${ctx}';
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  function setT(id, v){ var el=document.getElementById(id); if(el) el.textContent = (v==null?'-':v); }
  function nf(n){ return (n==null?0:n).toLocaleString('ko-KR'); }

  // CSV 내보내기
  var btn = document.getElementById('exportBtn');
  if (btn) btn.addEventListener('click', function(){
    var scope = (document.getElementById('exportScope')||{}).value || 'all';
    window.location.href = ctx + '/api/admin/dashboard/export?scope=' + encodeURIComponent(scope);
  });

  function renderRealtime(r, funnel){
    setT('kCumulative', nf(r.cumulative));
    setT('kMau', nf(r.mau));
    setT('kLive', nf(r.live));
    setT('kToday', nf(r.todayStarted));
    setT('kMaxDrop', funnel.maxDrop);
    setT('kMaxDropStep', funnel.maxDropStep ? (funnel.maxDropStep + ' 최대') : '—');
  }

  function renderPersona(list){
    list = list || [];
    var ring = document.getElementById('personaRing');
    var top = list[0];
    if (top){
      var r=62, c=2*Math.PI*r, on=c*(top.percent/100), off=c-on;
      ring.innerHTML =
        '<svg width="160" height="160" viewBox="0 0 160 160">'+
        '<circle cx="80" cy="80" r="62" fill="none" stroke="#F2EEF9" stroke-width="20"/>'+
        '<circle cx="80" cy="80" r="62" fill="none" stroke="#8B57AC" stroke-width="20" stroke-dasharray="'+on.toFixed(1)+' '+off.toFixed(1)+'" transform="rotate(-90 80 80)" stroke-linecap="round"/>'+
        '<text x="80" y="78" text-anchor="middle" font-size="22" font-weight="800" fill="#6A4C9C">'+top.percent+'%</text>'+
        '<text x="80" y="96" text-anchor="middle" font-size="10" fill="#6B7280">'+esc(top.label)+'</text></svg>';
    } else { ring.innerHTML = '<div class="caption" style="color:var(--ink-400); padding:40px 0;">유입 데이터 없음</div>'; }
    var colors = ['var(--primary)','var(--accent)','var(--blue)','#10B981'];
    document.getElementById('personaList').innerHTML = list.map(function(p,i){
      return '<div class="row justify-between caption"><span style="color:'+colors[i%colors.length]+';">● '+esc(p.label)+'</span><span class="fw-700">'+nf(p.count)+'명 ('+p.percent+'%)</span></div>';
    }).join('') || '';
  }

  function renderFunnel(funnel){
    var steps = (funnel && funnel.steps) || [];
    document.getElementById('funnel').innerHTML = steps.map(function(s){
      var bar = s.drop>=10 ? 'var(--accent)' : s.drop>=5 ? '#FB923C' : 'var(--primary)';
      var dc = s.drop>=10 ? 'var(--accent)' : 'var(--ink-500)';
      return '<div class="row items-center gap-12"><div class="caption fw-700" style="width:130px;">'+esc(s.step)+'</div>'+
        '<div style="flex:1; height:24px; background:#F0F0F2; border-radius:4px; position:relative;"><div style="width:'+s.pct+'%; height:100%; background:'+bar+'; border-radius:4px;"></div><span style="position:absolute; right:8px; top:3px; font-size:11px; font-weight:700; color:#fff;">'+nf(s.count)+'건</span></div>'+
        '<div class="caption" style="width:60px; text-align:right; color:'+dc+'; font-weight:'+(s.drop>=10?700:500)+';">'+(s.drop>0?'−'+s.drop+'%':'—')+'</div></div>';
    }).join('');
  }

  function renderAnswer(a){
    var sat=a.satisfaction||{}, sp=a.speed||{}, rt=a.rating||{};
    setT('satUp', '👍 '+sat.upPercent+'%');
    setT('satDown', '👎 '+sat.downPercent+'%');
    document.getElementById('satBar').style.width = (sat.upPercent||0)+'%';
    setT('satDetail', '응답 '+nf(sat.total)+'건 · 좋아요 '+nf(sat.up)+' · 싫어요 '+nf(sat.down));

    setT('spdAvg', sp.avgSec);
    var sb=document.getElementById('spdBadge');
    if(sb){ var ok=(sp.avgSec||0)<=60; sb.textContent='목표 60초 '+(ok?'✓':'✗'); sb.className='badge '+(ok?'badge-green':'badge-gray'); }
    setT('spdDetail', 'P95: '+sp.p95Sec+'초 · P99: '+sp.p99Sec+'초 · 최대: '+sp.maxSec+'초');

    setT('ratAvg', rt.avg);
    setT('ratCount', '응답 '+nf(rt.total)+'건');
    document.getElementById('ratBars').innerHTML = (rt.stars||[]).map(function(s){
      return '<div class="col gap-2 items-center" style="flex:1;"><div style="height:32px; background:#E8EAEE; border-radius:2px; position:relative; width:100%;"><div style="position:absolute; bottom:0; left:0; right:0; height:'+(s.percent)+'%; background:var(--primary);"></div></div><div class="caption" style="font-size:10px;">★'+s.star+'</div></div>';
    }).join('');
  }

  function renderQuality(list){
    var colors=['var(--primary)','var(--primary)','var(--accent)','var(--blue)'];
    document.getElementById('quality').innerHTML = (list||[]).map(function(m,i){
      var c=colors[i%colors.length];
      return '<div style="flex:1;"><div class="row justify-between mb-4"><span class="caption">'+esc(m.label)+'</span><span class="caption fw-700" style="color:'+c+';">'+m.value+'%</span></div>'+
        '<div style="height:6px; background:#F0F0F2; border-radius:3px;"><div style="width:'+m.value+'%; height:100%; background:'+c+'; border-radius:3px;"></div></div></div>';
    }).join('');
  }

  function renderSystem(sys){
    var usage=sys.usage||{}, perf=sys.performance||{};
    setT('usageSummary', '총 '+nf(usage.total)+'건 · 7일 평균 '+usage.avg+'건');
    var days=usage.days||[], vals=days.map(function(d){return d.value;});
    var maxV=Math.max(1, Math.max.apply(null, vals.length?vals:[1]));
    var s='<svg width="100%" height="160" viewBox="0 0 600 160"><defs><linearGradient id="g1d" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#8B57AC"/><stop offset="100%" stop-color="#C8336B"/></linearGradient></defs>';
    for(var i=0;i<5;i++){ s+='<line x1="40" y1="'+(20+i*28)+'" x2="590" y2="'+(20+i*28)+'" stroke="#E8EAEE"/>'; }
    days.forEach(function(d,i){ var x=70+i*75, h=(d.value/maxV)*110; s+='<rect x="'+(x-18)+'" y="'+(130-h).toFixed(1)+'" width="36" height="'+h.toFixed(1)+'" fill="url(#g1d)" rx="4"/><text x="'+x+'" y="148" text-anchor="middle" font-size="10" fill="#6B7280">'+esc(d.day)+'</text><text x="'+x+'" y="'+(130-h-6).toFixed(1)+'" text-anchor="middle" font-size="10" fill="#3A3D44" font-weight="600">'+d.value+'</text>'; });
    s+='</svg>';
    document.getElementById('adminBar').innerHTML=s;

    setT('pfApi', '● '+perf.apiAvailability+'%');
    setT('pfGpu', '● '+perf.gpuUsage+'%');
    setT('pfDb', '● '+perf.dbResponseMs+'ms');
    setT('pfErr', '● '+perf.errorRate+'%');
    setT('pfQueue', '● '+perf.queueWaiting+'건');

    document.getElementById('batch').innerHTML = (sys.batches||[]).map(function(r){
      var bg = r.status==='성공'?'#D1FAE5':(r.status==='실패'?'#FEE2E2':'#FEF3C7'), col = r.status==='성공'?'#065F46':(r.status==='실패'?'#991B1B':'#92400E');
      return '<tr style="border-bottom:1px solid var(--line);">'+
        '<td style="padding:12px 8px; font-family:\'JetBrains Mono\',monospace; color:var(--primary);">'+esc(r.id)+'</td>'+
        '<td style="padding:12px 8px;">'+esc(r.type)+'</td><td style="padding:12px 8px; color:var(--ink-500);">'+esc(r.ts)+'</td>'+
        '<td style="padding:12px 8px;">'+nf(r.count)+'건</td><td style="padding:12px 8px; color:var(--ink-500);">'+esc(r.duration)+'</td>'+
        '<td style="padding:12px 8px;"><span class="badge" style="background:'+bg+'; color:'+col+';">● '+esc(r.status)+'</span></td></tr>';
    }).join('') || '<tr><td colspan="6" style="padding:16px 8px; color:var(--ink-400);">배치 이력이 없습니다.</td></tr>';
  }

  function load(){
    fetch(ctx + '/api/admin/dashboard').then(function(r){ return r.ok ? r.json() : null; }).then(function(d){
      if(!d) return;
      renderRealtime(d.realtime||{}, d.funnel||{});
      renderPersona(d.persona||[]);
      renderFunnel(d.funnel||{});
      renderAnswer(d.answer||{});
      renderQuality(d.quality||[]);
      renderSystem(d.system||{});
      var stamp=document.getElementById('liveStamp');
      if(stamp){ var t=new Date(); stamp.textContent='● LIVE · '+t.toLocaleTimeString('ko-KR')+' 갱신'; }
    }).catch(function(e){ console.error('대시보드 로드 실패', e); });
  }

  load();
  setInterval(load, 5 * 60 * 1000); // 자동 새로고침 5분
})();
</script>
</body>
</html>

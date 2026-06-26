<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="wb" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="activeNav" value="" scope="request" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>마이페이지 · 대시보드 · W브릿지</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">
<div class="wb wb-frame" style="background:#fff;">

  <%@ include file="../common-w/header-ds.jspf" %>

  <wb:mypage active="dash">

    <%-- 회원 프로파일 --%>
    <div class="card mb-24" style="padding:0; overflow:hidden;">
      <div style="background:linear-gradient(110deg,#F2EDFA 0%,#EFEAF7 100%); padding:20px 24px; border-bottom:1px solid var(--line);">
        <div class="row items-center gap-16">
          <div id="dAvatar" style="width:64px; height:64px; border-radius:50%; background:var(--brand-grad); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:800; font-size:24px; flex-shrink:0;">-</div>
          <div style="flex:1;">
            <div class="row items-center gap-8 mb-4">
              <span class="fw-700" id="dName" style="font-size:18px;">-</span>
              <span class="caption" id="dContact" style="color:var(--ink-500);">-</span>
            </div>
            <div class="row items-center gap-6">
              <span class="badge badge-blue" id="dPersona" style="display:none;"></span>
              <span class="badge badge-gray" id="dEduLine" style="display:none;"></span>
              <span class="badge badge-gray" id="dCareerLine" style="display:none;"></span>
            </div>
          </div>
          <a href="${ctx}/service-intro" class="btn btn-brand btn-sm">재진단 시작 <wb:icon-ds name="plus" size="12" color="#fff" /></a>
        </div>
      </div>
      <div class="row" style="border-top:1px solid var(--line);">
        <div class="flex-1" style="padding:18px 20px; border-right:1px solid var(--line);">
          <div class="caption mb-4" style="color:var(--ink-500);">커리어 목표</div>
          <div class="fw-700" id="dCareerGoal" style="font-size:14px; line-height:1.4; margin-bottom:4px;">-</div>
          <div class="caption">항체/공정 연구원 · 1순위</div>
        </div>
        <div class="flex-1" style="padding:18px 20px; border-right:1px solid var(--line);">
          <div class="caption mb-4" style="color:var(--ink-500);">현 상황</div>
          <div class="fw-700" id="dCurrentStatus" style="font-size:14px; line-height:1.4; margin-bottom:4px;">-</div>
          <div class="caption">GMP·산업 언어 학습 진행</div>
        </div>
        <div class="flex-1" style="padding:18px 20px; border-right:1px solid var(--line);">
          <div class="caption mb-4" style="color:var(--ink-500);">소속 코호트</div>
          <div class="fw-700" style="font-size:14px; line-height:1.4; margin-bottom:4px;">석사·30대·바이오 R&D</div>
          <div class="caption" id="dCohort">-</div>
        </div>
        <div class="flex-1" style="padding:18px 20px;">
          <div class="caption mb-4" style="color:var(--ink-500);">최근 진단</div>
          <div class="fw-700" id="dRecentDate" style="font-size:14px; line-height:1.4; margin-bottom:4px;">-</div>
          <div class="caption" id="dRecentName">-</div>
          <a href="${ctx}/ai-coaching" class="btn btn-ghost btn-sm mt-8" style="padding:4px 10px;">최근 리포트 보기 →</a>
        </div>
      </div>
    </div>

    <%-- KPI cards --%>
    <div class="row gap-16 mb-24">
      <div class="card flex-1"><div class="caption">누적 진단</div><div class="row items-end gap-4 mt-8"><span id="dTotalCount" style="font-size:28px; font-weight:800; color:var(--primary); line-height:1;">-</span><span class="caption" style="margin-bottom:4px;">회</span></div></div>
      <div class="card flex-1"><div class="caption">코호트 내 위치</div><div class="row items-end gap-4 mt-8"><span id="dPercentile" style="font-size:28px; font-weight:800; color:var(--accent); line-height:1;">-</span><span class="caption" style="margin-bottom:4px;">%</span></div></div>
      <div class="card flex-1"><div class="caption">최근 역량 점수</div><div class="row items-end gap-4 mt-8"><span id="dRecentScore" style="font-size:28px; font-weight:800; color:var(--blue); line-height:1;">-</span><span class="caption" style="margin-bottom:4px;">점</span><span id="dScoreDelta" class="badge badge-green" style="margin-left:auto; display:none;"></span></div></div>
      <div class="card flex-1"><div class="caption">실행한 액션</div><div class="row items-end gap-4 mt-8"><span id="dActionsDone" style="font-size:28px; font-weight:800; color:var(--primary); line-height:1;">-</span><span class="caption" style="margin-bottom:4px;">/ <span id="dActionsTotal">-</span></span></div></div>
    </div>

    <%-- Growth chart --%>
    <div class="card mb-24">
      <div class="row justify-between items-center mb-16">
        <div><div class="h3">시계열 역량 성장 추이</div><div class="caption mt-4">최근 3회 진단 결과 비교</div></div>
        <div class="row gap-8"><span class="badge badge-gray">최근 6개월</span><span class="badge badge-gray">전체</span><a href="${ctx}/mypage-history" class="btn btn-ghost btn-sm">전체 이력 보기 →</a></div>
      </div>
      <div id="growthChart"></div>
      <div class="row gap-16 mt-16 caption" id="dChartLegend"></div>
    </div>

    <%-- My Planner 요약 --%>
    <div class="card mb-24" style="background:linear-gradient(180deg, #FAF7FC 0%, #fff 100%);">
      <div class="row items-center justify-between mb-16">
        <div><span class="badge badge-ai mb-8">My Planner</span><div class="h3 mt-8" style="margin-bottom:4px;">나의 액션 플래너</div><div class="caption" id="dPlannerSummary">-</div></div>
        <a href="${ctx}/mypage-action-planner" class="btn btn-ghost btn-sm">액션 플래너로 →</a>
      </div>
      <div class="row gap-12" id="dPlannerCols"></div>
    </div>

    <%-- 진단 이력 --%>
    <div class="card">
      <div class="row justify-between items-center mb-16">
        <div class="h3">진단 이력</div>
        <a href="${ctx}/mypage-history" class="btn btn-ghost btn-sm">전체 보기 →</a>
      </div>
      <div class="col gap-0" id="dHistory"></div>
    </div>

  </wb:mypage>

  <%@ include file="../common-w/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function setT(id,v){ var e=document.getElementById(id); if(e) e.textContent=(v==null||v==='')?'-':v; }

  var xs = [120,280,440,600,720];
  var compLabels = ['전문성','리더십','커뮤니케이션','문제해결','디지털'];
  var compKeys = ['professionalism','leadership','communication','problemSolving','digital'];
  var COLORS = ['#8B57AC','#3A5BA5','#C8336B','#1F9D8A','#D98A2B'];
  function y(v){ return (220-20-((v||0)/100)*160).toFixed(1); }

  function renderChart(trend){
    var el=document.getElementById('growthChart'); if(!el) return;
    var s = '<svg width="100%" height="220" viewBox="0 0 800 220">';
    for(var i=0;i<5;i++){ s += '<line x1="50" y1="'+(20+i*40)+'" x2="780" y2="'+(20+i*40)+'" stroke="#E8EAEE"/>'; s += '<text x="40" y="'+(24+i*40)+'" text-anchor="end" font-size="10" fill="#9AA0AA">'+(100-i*20)+'</text>'; }
    (trend||[]).forEach(function(d,si){
      var color=COLORS[si%COLORS.length];
      var pts = compKeys.map(function(k,i){ return xs[i]+','+y(d[k]); }).join(' ');
      s += '<polyline points="'+pts+'" fill="none" stroke="'+color+'" stroke-width="2"'+(si===1?' stroke-dasharray="5 4"':'')+'/>';
      compKeys.forEach(function(k,i){ s += '<circle cx="'+xs[i]+'" cy="'+y(d[k])+'" r="4" fill="'+color+'"/>'; });
    });
    compLabels.forEach(function(l,i){ s += '<text x="'+xs[i]+'" y="210" text-anchor="middle" font-size="11" fill="#3A3D44" font-weight="600">'+l+'</text>'; });
    el.innerHTML = s + '</svg>';
    var leg=document.getElementById('dChartLegend');
    if(leg) leg.innerHTML = (trend||[]).map(function(d,si){ return '<span><span style="display:inline-block;width:14px;height:2px;background:'+COLORS[si%COLORS.length]+';vertical-align:middle;margin-right:6px;"></span>'+esc(d.ym)+' · '+esc(d.typeLabel)+'</span>'; }).join('');
  }

  function renderPlanner(planner){
    var el=document.getElementById('dPlannerCols'); if(!el) return;
    var terms=[{t:'단기',sub:'1~2주',dot:'var(--accent)'},{t:'중기',sub:'1~2개월',dot:'var(--primary)'},{t:'장기',sub:'3~6개월',dot:'var(--blue)'}];
    el.innerHTML = terms.map(function(tm){
      var items=(planner||[]).filter(function(p){ return p.term===tm.t; });
      var cards = items.map(function(p){
        var done = p.status==='완료';
        var bs = done ? 'background:var(--brand-50); color:var(--primary);' : 'background:var(--pink-50); color:var(--accent);';
        return '<div class="card" style="padding:10px;"><div class="row items-center justify-between mb-4"><span class="caption fw-700" style="color:var(--ink-500);">'+esc(p.source)+'</span><span class="badge" style="'+bs+' font-size:10px;">'+esc(p.status)+'</span></div><div class="fw-600" style="font-size:13px;">'+esc(p.title)+'</div></div>';
      }).join('') || '<div class="caption" style="color:var(--ink-400);">없음</div>';
      return '<div class="flex-1" style="border:1.5px dashed var(--line); border-radius:12px; padding:14px; background:#fff;">'+
        '<div class="row items-center gap-8 mb-12"><span style="width:8px;height:8px;border-radius:50%;background:'+tm.dot+';"></span><span class="fw-700" style="font-size:13px;">'+tm.t+'</span><span class="caption" style="color:var(--ink-500);">· '+tm.sub+'</span><span class="caption" style="margin-left:auto;">'+items.length+'건</span></div>'+
        '<div class="col gap-8">'+cards+'</div></div>';
    }).join('');
  }

  function renderHistory(history){
    var el=document.getElementById('dHistory'); if(!el) return;
    var bc={'AI':'badge-ai','종합':'badge-blue','라이트':'badge-green'};
    el.innerHTML = (history||[]).map(function(h,i){
      var border = i < history.length-1 ? 'border-bottom:1px solid var(--line);' : '';
      var delta = (h.delta!=null && h.delta!==0) ? '<div class="badge badge-green">↑ +'+h.delta+'</div>' : '';
      return '<div class="row items-center gap-16" style="padding:16px 0; '+border+'">'+
        '<div class="caption fw-700" style="width:92px;">'+esc(h.date)+'</div>'+
        '<div class="badge '+(bc[h.badge]||'badge-gray')+'">'+esc(h.badge)+'</div>'+
        '<div class="fw-600" style="flex:1; font-size:14px;">'+esc(h.name)+'</div>'+
        '<div class="fw-700" style="color:var(--primary);">'+(h.totalScore!=null?h.totalScore+'점':'-')+'</div>'+
        delta+'<button type="button" class="btn btn-ghost btn-sm">리포트 보기</button></div>';
    }).join('') || '<div class="caption" style="color:var(--ink-400); padding:16px 0;">진단 이력이 없습니다.</div>';
  }

  fetch(ctx + '/api/mypage/dashboard').then(function(r){ return r.ok ? r.json() : null; }).then(function(d){
    if(!d) return;
    var s=d.summary||{};
    // 회원 프로필 헤더
    setT('dName', s.name);
    var av=document.getElementById('dAvatar'); if(av) av.textContent = s.name ? s.name.charAt(0) : '-';
    var contact=[s.email, s.phone].filter(Boolean).join(' · ');
    setT('dContact', contact);
    function badge(id, txt){ var e=document.getElementById(id); if(!e) return; if(txt){ e.textContent=txt; e.style.display=''; } else { e.style.display='none'; } }
    badge('dPersona', s.persona);
    badge('dEduLine', [s.major, s.degree, (s.age!=null? s.age+'세':null)].filter(Boolean).join(' · '));
    badge('dCareerLine', (s.careerTitle ? '현 '+s.careerTitle : '') + (s.careerYear!=null ? ' '+s.careerYear+'년차' : '') || null);
    setT('dCareerGoal', s.careerGoal);
    setT('dCurrentStatus', s.currentStatus);
    setT('dCohort', (s.cohortSize!=null? '코호트 '+s.cohortSize+'명 중 ':'') + (s.cohortPercentile!=null? '상위 '+s.cohortPercentile+'%':''));
    setT('dRecentDate', s.recentDate);
    setT('dRecentName', s.recentName);
    setT('dTotalCount', s.totalCount);
    setT('dPercentile', s.cohortPercentile!=null? ('상위 '+s.cohortPercentile) : '-');
    setT('dRecentScore', s.recentScore);
    var db=document.getElementById('dScoreDelta'); if(db && s.scoreDelta!=null && s.scoreDelta!==0){ db.textContent='↑ +'+s.scoreDelta; db.style.display=''; }
    setT('dActionsDone', s.actionsDone);
    setT('dActionsTotal', s.actionsTotal);
    setT('dPlannerSummary', '담은 활동 '+(s.actionsTotal||0)+'건 · 완료 '+(s.actionsDone||0)+'건');
    renderChart(d.trend);
    renderPlanner(d.planner);
    renderHistory(d.history);
  }).catch(function(e){ console.error('대시보드 로드 실패', e); });
})();
</script>
</body>
</html>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="wb" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>관리자 · 리포트 관리 · W브릿지</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">

<wb:admin active="rep" title="리포트 관리" sub="생성된 리포트 내역 및 상세 조회">

  <%-- 검색 필터 (UI) --%>
  <div class="card mb-16">
    <div class="row gap-12 items-center">
      <input class="input" id="repSearch" placeholder="🔍 리포트 ID, 사용자 ID, 키워드 검색" style="flex:1; padding:8px 14px; font-size:13px;">
      <select id="fPersona" class="select" style="width:auto; padding:8px 12px; font-size:13px;"><option value="">전체 페르소나</option><option value="취업희망">취업희망</option><option value="경력성장">경력성장</option></select>
      <select id="fSat" class="select" style="width:auto; padding:8px 12px; font-size:13px;"><option value="">만족도 전체</option><option value="gte4">★ 4.0 이상</option><option value="3to4">★ 3.0 ~ 4.0</option><option value="lt3">★ 3.0 미만</option></select>
      <select id="fPeriod" class="select" style="width:auto; padding:8px 12px; font-size:13px;"><option value="">전체 기간</option><option value="7">최근 7일</option><option value="30">최근 30일</option></select>
      <button type="button" id="repSearchBtn" class="btn btn-brand btn-sm">검색</button>
    </div>
  </div>

  <%-- KPI --%>
  <div class="row gap-16 mb-16">
    <div class="card flex-1" style="padding:14px;"><div class="caption">전체 리포트</div><div class="row items-baseline gap-4 mt-4"><span id="kTotal" style="font-size:20px; font-weight:800; color:var(--primary);">–</span></div></div>
    <div class="card flex-1" style="padding:14px;"><div class="caption">오늘 생성</div><div class="row items-baseline gap-4 mt-4"><span id="kToday" style="font-size:20px; font-weight:800; color:var(--blue);">–</span></div></div>
    <div class="card flex-1" style="padding:14px;"><div class="caption">평균 만족도</div><div class="row items-baseline gap-4 mt-4"><span id="kSat" style="font-size:20px; font-weight:800; color:var(--accent);">–</span><span class="caption">/ 5</span></div></div>
    <div class="card flex-1" style="padding:14px;"><div class="caption">재진단 완료</div><div class="row items-baseline gap-4 mt-4"><span id="kRediag" style="font-size:20px; font-weight:800; color:var(--primary);">–</span></div></div>
  </div>

  <%-- 리포트 목록 --%>
  <div class="card">
    <div class="row justify-between items-center mb-16">
      <div class="h3">리포트 목록</div>
      <div class="row gap-8"><span class="caption" id="repRange">–</span><button type="button" class="btn btn-ghost btn-sm">컬럼 설정</button><button type="button" class="btn btn-ghost btn-sm"><wb:icon-ds name="download" size="12" color="#3D4048" /> 내보내기</button></div>
    </div>
    <table style="width:100%; border-collapse:collapse; font-size:12px;">
      <thead>
        <tr style="text-align:left; color:var(--ink-500); border-bottom:2px solid var(--line); background:var(--bg-soft);">
          <th style="padding:12px 8px; font-weight:700;">리포트 ID</th><th style="padding:12px 8px; font-weight:700;">사용자</th><th style="padding:12px 8px; font-weight:700;">페르소나</th><th style="padding:12px 8px; font-weight:700;">직무</th><th style="padding:12px 8px; font-weight:700;">역량점수</th><th style="padding:12px 8px; font-weight:700;">코호트</th><th style="padding:12px 8px; font-weight:700;">만족도</th><th style="padding:12px 8px; font-weight:700;">응답속도</th><th style="padding:12px 8px; font-weight:700;">생성일시</th><th style="padding:12px 8px; font-weight:700;">액션</th>
        </tr>
      </thead>
      <tbody id="repBody"></tbody>
    </table>
    <div class="row justify-between items-center mt-16">
      <span class="caption">페이지당 20건 표시</span>
      <div class="row gap-4" id="pager"></div>
    </div>
  </div>

</wb:admin>

<script>
(function () {
  var ctx = '${ctx}';
  var SIZE = 20, page = 1, totalPages = 1;
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  function nf(n){ return (n==null?0:n).toLocaleString('ko-KR'); }
  function satStyle(v){ return v>=4?['#D1FAE5','#065F46']:v>=3?['#FEF3C7','#92400E']:['#FEE2E2','#B91C1C']; }

  function renderRows(rows){
    document.getElementById('repBody').innerHTML = (rows||[]).map(function(r){
      var grp = r.persona==='경력성장', pBg = grp?'var(--pink-50)':'var(--brand-50)', pCol = grp?'var(--accent)':'var(--primary)';
      var sat = r.satisfaction;
      var satCell = (sat==null) ? '<span class="caption" style="color:var(--ink-400);">–</span>'
        : (function(){ var ss=satStyle(sat); return '<span class="badge" style="background:'+ss[0]+'; color:'+ss[1]+'; font-size:10px;">★ '+sat.toFixed(1)+'</span>'; })();
      return '<tr style="border-bottom:1px solid var(--line); background:'+(r.flag?'#FEF7F7':'transparent')+';">'+
        '<td style="padding:12px 8px; font-family:\'JetBrains Mono\',monospace; color:var(--primary); font-size:11px;">'+esc(r.reportId)+'</td>'+
        '<td style="padding:12px 8px; font-size:11px; color:var(--ink-500);">'+esc(r.user)+'</td>'+
        '<td style="padding:12px 8px;"><span class="badge" style="background:'+pBg+'; color:'+pCol+'; font-size:10px;">'+esc(r.persona)+'</span></td>'+
        '<td style="padding:12px 8px;">'+esc(r.job)+'</td>'+
        '<td style="padding:12px 8px; font-weight:700; color:var(--primary);">'+(r.score!=null?r.score:'-')+'</td>'+
        '<td style="padding:12px 8px; color:var(--ink-500);">'+(r.cohort!=null?nf(r.cohort)+'명':'-')+'</td>'+
        '<td style="padding:12px 8px;">'+satCell+'</td>'+
        '<td style="padding:12px 8px; color:var(--ink-500);">'+esc(r.speed)+'</td>'+
        '<td style="padding:12px 8px; color:var(--ink-500);">'+esc(r.createdAt)+'</td>'+
        '<td style="padding:12px 8px;"><button type="button" class="btn btn-ghost btn-sm" style="font-size:11px; padding:4px 10px; color:var(--primary); font-weight:700;">상세 보기 →</button></td></tr>';
    }).join('') || '<tr><td colspan="10" style="padding:20px 8px; color:var(--ink-400);">리포트가 없습니다.</td></tr>';
  }

  function renderPager(){
    var btns = [], win = 5;
    var start = Math.max(1, page - Math.floor(win/2));
    var end = Math.min(totalPages, start + win - 1);
    start = Math.max(1, Math.min(start, end - win + 1));
    function btn(label, target, on, disabled){
      return '<button type="button" class="repPage btn btn-ghost btn-sm" data-pg="'+target+'" '+(disabled?'disabled':'')+
        ' style="min-width:32px; padding:6px 10px; background:'+(on?'var(--primary)':'transparent')+'; color:'+(on?'#fff':'var(--ink-700)')+'; font-weight:'+(on?700:500)+'; opacity:'+(disabled?0.4:1)+';">'+label+'</button>';
    }
    btns.push(btn('‹', page-1, false, page<=1));
    if(start>1){ btns.push(btn('1',1,false,false)); if(start>2) btns.push('<span class="caption" style="padding:0 4px;">…</span>'); }
    for(var p=start;p<=end;p++) btns.push(btn(String(p), p, p===page, false));
    if(end<totalPages){ if(end<totalPages-1) btns.push('<span class="caption" style="padding:0 4px;">…</span>'); btns.push(btn(String(totalPages),totalPages,false,false)); }
    btns.push(btn('›', page+1, false, page>=totalPages));
    document.getElementById('pager').innerHTML = btns.join('');
    document.querySelectorAll('#pager .repPage').forEach(function(b){
      b.addEventListener('click', function(){ var t=parseInt(b.getAttribute('data-pg'),10); if(t>=1 && t<=totalPages && t!==page){ page=t; load(); } });
    });
  }

  // 현재 필터 UI → 쿼리스트링
  function filterQS(){
    var v = function(id){ var e=document.getElementById(id); return e ? (e.value||'').trim() : ''; };
    var qs = '';
    var s=v('repSearch'); if(s) qs += '&search='+encodeURIComponent(s);
    var p=v('fPersona'); if(p) qs += '&persona='+encodeURIComponent(p);
    var sa=v('fSat'); if(sa) qs += '&sat='+encodeURIComponent(sa);
    var pe=v('fPeriod'); if(pe) qs += '&period='+encodeURIComponent(pe);
    return qs;
  }

  function load(){
    fetch(ctx + '/api/admin/reports?page=' + page + '&size=' + SIZE + filterQS()).then(function(r){ return r.ok ? r.json() : null; }).then(function(d){
      if(!d){ document.getElementById('repBody').innerHTML = '<tr><td colspan="10" style="padding:20px 8px; color:var(--accent);">데이터를 불러오지 못했습니다.</td></tr>'; return; }
      var k = d.kpi||{};
      document.getElementById('kTotal').textContent = nf(k.total);
      document.getElementById('kToday').textContent = nf(k.today);
      document.getElementById('kSat').textContent = (k.avgSatisfaction!=null?k.avgSatisfaction:'-');
      document.getElementById('kRediag').textContent = nf(k.rediagnosis);
      totalPages = d.totalPages||1; page = d.page||1;
      var from = (page-1)*d.size + 1, to = Math.min(d.total, page*d.size);
      document.getElementById('repRange').textContent = '전체 '+nf(d.total)+'건 중 '+nf(from)+'-'+nf(to);
      renderRows(d.rows);
      renderPager();
    }).catch(function(e){ console.error('리포트 로드 실패', e); });
  }

  // 검색: 1페이지부터 다시 조회
  function applyFilter(){ page = 1; load(); }
  document.getElementById('repSearchBtn').addEventListener('click', applyFilter);
  document.getElementById('repSearch').addEventListener('keydown', function(e){ if(e.key==='Enter'){ e.preventDefault(); applyFilter(); } });
  ['fPersona','fSat','fPeriod'].forEach(function(id){ document.getElementById(id).addEventListener('change', applyFilter); });

  load();
})();
</script>
</body>
</html>

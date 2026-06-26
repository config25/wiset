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
  <title>마이페이지 · 코칭 이력 · W브릿지</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">
<div class="wb wb-frame" style="background:#fff;">

  <%@ include file="../common-w/header-ds.jspf" %>

  <wb:mypage active="history">

    <div class="row items-center justify-between mb-24">
      <div><h2 class="h2" style="margin-bottom:4px;">코칭 이력</h2><div class="caption">지금까지 진행한 진단·코칭 3건의 전체 이력입니다</div></div>
      <div class="row gap-8">
        <div class="select" style="width:130px; display:flex; align-items:center; justify-content:space-between;"><span>전체</span><span style="color:var(--ink-400);">▾</span></div>
        <div class="select" style="width:130px; display:flex; align-items:center; justify-content:space-between;"><span>최근 6개월</span><span style="color:var(--ink-400);">▾</span></div>
      </div>
    </div>

    <%-- 타임라인 --%>
    <div style="position:relative; padding-left:32px;">
      <div style="position:absolute; left:11px; top:12px; bottom:12px; width:2px; background:linear-gradient(180deg, var(--accent) 0%, var(--primary) 50%, var(--blue) 100%);"></div>
      <div class="col gap-20" id="timeline"></div>
    </div>

  </wb:mypage>

  <%@ include file="../common-w/footer-ds.jspf" %>

</div>

<script>
(function () {
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  var ctx = '${ctx}';
  var ARROW = '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0"><path d="M4 12h15M13 5l7 7-7 7"/></svg>';
  function dotColor(c){ return c==='accent'?'var(--accent)':c==='primary'?'var(--primary)':'var(--blue)'; }
  function dotBg(c){ return c==='accent'?'var(--pink-50)':c==='primary'?'var(--brand-50)':'var(--blue-50)'; }
  function tagBadge(c){ return c==='accent'?'badge-ai':c==='primary'?'badge-blue':'badge-green'; }

  function renderTimeline(items){
  var html = items.map(function(it){
    var dc = dotColor(it.tagC), db = dotBg(it.tagC);
    return '<div style="position:relative;">'+
      '<div style="position:absolute; left:-32px; top:18px; width:24px; height:24px; border-radius:50%; background:#fff; border:3px solid '+dc+'; display:flex; align-items:center; justify-content:center;"><div style="width:8px; height:8px; border-radius:50%; background:'+dc+';"></div></div>'+
      '<div class="card" style="padding:0; overflow:hidden;">'+
        '<div style="padding:16px 20px; background:'+db+'; border-bottom:1px solid var(--line);">'+
          '<div class="row items-center justify-between"><div class="row items-center gap-12">'+
            '<div class="fw-700" style="font-size:16px; color:'+dc+';">'+esc(it.d)+'</div>'+
            '<span class="caption" style="color:var(--ink-500);">'+esc(it.tm)+'</span>'+
            '<span class="badge '+tagBadge(it.tagC)+'">'+esc(it.tag)+'</span>'+
            '<span class="fw-700" style="font-size:15px;">'+esc(it.title)+'</span>'+
            '<span class="caption mono" style="color:var(--ink-400);">'+esc(it.ver)+'</span>'+
          '</div><span class="caption mono" style="color:var(--ink-500);">#'+esc(it.id)+'</span></div>'+
        '</div>'+
        '<div class="row" style="padding:18px 20px; align-items:stretch;">'+
          '<div style="width:120px; padding-right:20px; border-right:1px solid var(--line); display:flex; flex-direction:column; justify-content:center; align-items:center;">'+
            '<div class="caption mb-4">역량 점수</div><div class="row items-end gap-4"><span style="font-size:36px; font-weight:800; color:'+dc+'; line-height:1;">'+it.score+'</span><span class="caption" style="margin-bottom:6px;">점</span></div>'+
            (it.delta?'<div class="badge badge-green mt-8">↑ '+esc(it.delta)+'점</div>':'')+
          '</div>'+
          '<div style="flex:1; padding:0 20px;">'+
            '<div class="row gap-24 mb-12">'+
              '<div><div class="caption mb-4" style="color:var(--ink-500);">페르소나</div><div class="fw-600" style="font-size:13px;">'+esc(it.persona)+'</div></div>'+
              '<div><div class="caption mb-4" style="color:var(--ink-500);">희망 직무</div><div class="fw-600" style="font-size:13px;">'+esc(it.job)+'</div></div>'+
              '<div><div class="caption mb-4" style="color:var(--ink-500);">액션 진행</div><div class="fw-600" style="font-size:13px;">'+it.actions+'건 담음</div></div>'+
              '<div><div class="caption mb-4" style="color:var(--ink-500);">만족도</div><div class="fw-600" style="font-size:13px;">★ '+(it.satisfaction!=null?Number(it.satisfaction).toFixed(1):'-')+'</div></div>'+
            '</div>'+
            '<div><div class="caption mb-4" style="color:var(--ink-500);">주요 고민</div><div class="fw-600" style="font-size:13px; line-height:1.6;">'+esc(it.concerns)+'</div></div>'+
          '</div>'+
          '<div style="width:160px; padding-left:20px; border-left:1px solid var(--line); display:flex; flex-direction:column; justify-content:center; gap:8px;">'+
            '<a href="'+ctx+'/ai-coaching'+(it.diagnosisId!=null?('?diagnosisId='+encodeURIComponent(it.diagnosisId)):'')+'" class="btn btn-brand btn-sm" style="justify-content:center;">상세보기 '+ARROW+'</a>'+
            '<button type="button" class="btn btn-ghost btn-sm" style="justify-content:center;" disabled title="준비 중입니다">PDF 다운로드</button>'+
          '</div>'+
        '</div>'+
      '</div>'+
    '</div>';
  }).join('');
  html += '<div style="position:relative; padding-top:8px;">'+
    '<div style="position:absolute; left:-32px; top:8px; width:24px; height:24px; border-radius:50%; background:var(--bg-soft); border:2px dashed var(--line); display:flex; align-items:center; justify-content:center; font-size:12px; color:var(--ink-400);">○</div>'+
    '<div class="caption" style="color:var(--ink-400); padding-top:4px;">회원가입 · 2025.11.08 — 첫 진단을 시작하세요</div></div>';
  document.getElementById('timeline').innerHTML = html;
  }
  fetch(ctx + '/api/mypage/history').then(function(r){ return r.ok ? r.json() : []; }).then(function(rows){ renderTimeline(rows || []); }).catch(function(e){ console.error('이력 로드 실패', e); });
})();
</script>
</body>
</html>

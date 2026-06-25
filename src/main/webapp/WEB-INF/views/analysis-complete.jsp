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
  <title>07b 분석 완료 · W브릿지 AI 커리어 코칭</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">
<div class="wb wb-frame">

  <%@ include file="common/header-ds.jspf" %>

  <%-- Breadcrumb --%>
  <div style="border-bottom:1px solid var(--line);">
    <div class="wb-breadcrumb">
      <span class="row items-center gap-4"><wb:icon-ds name="home" size="13" color="#9AA0A8" /> Home</span>
      <span class="sep">›</span><span>진단·컨설팅</span>
      <span class="sep">›</span><span>AI 커리어 코칭</span>
      <span class="sep">›</span><span class="current">분석 완료</span>
    </div>
  </div>

  <div class="section" style="padding:72px 40px; min-height:580px;">
    <div class="text-center" style="max-width:720px; margin:0 auto;">

      <%-- 완료 체크 --%>
      <div style="position:relative; width:120px; height:120px; margin:0 auto 24px;">
        <div style="position:absolute; inset:12px; border-radius:50%; background:var(--brand-grad); display:flex; align-items:center; justify-content:center; box-shadow:0 12px 36px -8px rgba(106,76,156,0.5);"><wb:icon-ds name="check" size="56" color="#fff" /></div>
        <div style="position:absolute; inset:0; border:3px solid var(--brand); border-radius:50%;"></div>
      </div>

      <span class="badge badge-blue mb-16">분석 완료</span>
      <h1 class="display mb-12" style="margin-top:8px;">김지수 님의 커리어 분석이 완료되었어요</h1>
      <p class="body-lg" style="margin-bottom:28px;">맞춤형 역량 분석과 액션 플랜이 담긴 <b class="t-brand">AI 리포트</b>가 준비되었습니다</p>

      <div class="progress" style="height:12px; margin-bottom:10px;"><i style="width:100%;"></i></div>
      <div class="row justify-between caption mb-32"><span>분석 진행률</span><span class="fw-700 t-brand">100%</span></div>

      <div class="card" style="padding:0; overflow:hidden; text-align:left;" id="stepCard"></div>

      <div class="row justify-center mt-32">
        <a id="reportBtn" href="${ctx}/ai-coaching" class="btn btn-brand btn-pill btn-lg" style="text-decoration:none;">보고서 확인하기 <wb:icon-ds name="arrow" size="15" color="#fff" /></a>
      </div>
    </div>
  </div>

  <%@ include file="common/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  function qp(n){ var m=new RegExp('[?&]'+n+'=([^&]*)').exec(location.search); return m?decodeURIComponent(m[1]):''; }
  var suf = qp('persona') ? ('?persona='+encodeURIComponent(qp('persona'))) : '';
  document.getElementById('reportBtn').href = ctx + '/ai-coaching' + suf;

  var CHK = '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M4.5 12.5l4.5 4.5L19.5 6.5"/></svg>';
  var steps = [
    { n:'01', t:'이력서 및 진단 결과 임베딩', d:'비식별화 처리 후 역량 앵커와 매핑 완료' },
    { n:'02', t:'타깃 JD 파싱', d:'12개 요구 역량 추출 · 가중치 산정 완료' },
    { n:'03', t:'컨설팅 패턴 RAG 검색', d:'유사 컨설팅 사례 36건 중 8건 매칭 완료' },
    { n:'04', t:'협업 필터링 코호트 분석', d:'동일 직군 1,240명 코호트 비교 완료' },
    { n:'05', t:'컨설팅형 진단평 생성', d:'역량별 진단평 및 액션 플랜 생성 완료' }
  ];
  document.getElementById('stepCard').innerHTML = steps.map(function(s,i){
    return '<div class="row items-center gap-16" style="padding:18px 24px;'+(i<steps.length-1?'border-bottom:1px solid var(--line);':'')+'background:#fff;">'+
      '<div style="width:32px; height:32px; border-radius:50%; display:flex; align-items:center; justify-content:center; background:var(--brand);">'+CHK+'</div>'+
      '<div style="flex:1;"><div class="fw-700">'+s.t+'</div><div class="caption mt-4">'+s.d+'</div></div>'+
      '<span class="badge badge-blue">완료</span></div>';
  }).join('');
})();
</script>
</body>
</html>

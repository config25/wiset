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
  <title>02 페르소나 선택 · W브릿지 AI 커리어 코칭</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
  <style>
    /* hover 하이라이트 지연 방지: box-shadow(무거운 repaint)는 즉시 적용, 뜨는 효과(transform)만 트랜지션 */
    .persona-card { cursor: pointer; outline: 3px solid transparent; outline-offset: 3px; transition: transform .15s ease-out; }
    .persona-card.is-selected { outline-color: var(--brand); transform: translateY(-4px); }
    .persona-card .persona-label::after { content: '선택하기'; }
    .persona-card.is-selected .persona-label::after { content: '선택됨'; }
    .persona-card .persona-dot { background: rgba(255,255,255,0.25); }
    .persona-card.is-selected .persona-dot { background: #fff; }
    .persona-card .persona-check { display: none; }
    .persona-card.is-selected .persona-check { display: inline-flex; }
  </style>
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
      <span class="sep">›</span><span class="current">AI 경력개발 진단</span>
    </div>
  </div>

  <div class="section" style="padding:20px 40px 56px;">

    <%-- Stepper (STEP 1 / 5) --%>
    <div class="row justify-center">
      <div class="stepper" style="padding:22px 0;">
        <div class="step active"><div class="step-num">1</div><span>페르소나 선택</span></div>
        <div class="step-line"></div>
        <div class="step"><div class="step-num">2</div><span>현 상황 입력</span></div>
        <div class="step-line"></div>
        <div class="step"><div class="step-num">3</div><span>경력개발 목표</span></div>
        <div class="step-line"></div>
        <div class="step"><div class="step-num">4</div><span>세부 고민</span></div>
        <div class="step-line"></div>
        <div class="step"><div class="step-num">5</div><span>입력 데이터 확인</span></div>
      </div>
    </div>

    <%-- Heading --%>
    <div class="text-center mt-16">
      <span class="badge badge-brand mb-12" style="letter-spacing:0.1em;">STEP 1 / 5</span>
      <h1 class="display mt-12" style="margin-bottom:10px;">당신의 경력 여정을 알려주세요</h1>
      <p class="body-lg">선택에 따라 맞춤형 입력 폼과 결과 시나리오가 달라집니다.</p>
    </div>

    <%-- Selection panel --%>
    <div class="panel mt-32" style="padding:28px; border-color:var(--brand-100);">
      <div class="pill-title" style="background:var(--brand-50); color:var(--brand); max-width:360px; margin:0 auto 8px;">4가지 페르소나</div>
      <p class="body text-center mb-24">현재 나의 경력 단계에 가장 가까운 유형을 선택해 주세요.</p>

      <div class="row gap-16">

        <%-- Persona 01 · 신규 취업 --%>
        <div class="theme-card flex-1 tc-green persona-card" data-code="1" style="align-items:stretch; text-align:left; padding:22px 20px;">
          <div class="row items-center justify-between" style="margin-bottom:12px;">
            <span style="width:44px; height:44px; border-radius:12px; background:rgba(255,255,255,0.22); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="rocket" size="22" color="#fff" sw="1.9" /></span>
            <span class="mono fw-700" style="font-size:12px; opacity:0.85;">01</span>
          </div>
          <div class="tc-title" style="font-size:18px;">신규 취업</div>
          <div class="tc-sub" style="margin-top:4px; margin-bottom:14px;">대학(원) 졸업 후 첫 취업을 준비하는 분</div>
          <div class="col gap-6" style="margin-top:auto;">
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>전공·연구 경험을 직무 역량으로 변환</span></div>
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>신입 공고 타깃 분석</span></div>
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>서류·면접 기본기 코칭</span></div>
          </div>
          <div class="row items-center justify-between" style="margin-top:16px; padding-top:14px; border-top:1px solid rgba(255,255,255,0.25);">
            <span class="persona-label" style="font-size:12.5px; font-weight:700;"></span>
            <span class="persona-dot" style="width:24px; height:24px; border-radius:50%; display:flex; align-items:center; justify-content:center;"><span class="persona-check"><wb:icon-ds name="check" size="14" color="var(--brand)" /></span></span>
          </div>
        </div>

        <%-- Persona 02 · 이직 준비 --%>
        <div class="theme-card flex-1 tc-blue persona-card" data-code="2" style="align-items:stretch; text-align:left; padding:22px 20px;">
          <div class="row items-center justify-between" style="margin-bottom:12px;">
            <span style="width:44px; height:44px; border-radius:12px; background:rgba(255,255,255,0.22); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="trending" size="22" color="#fff" sw="1.9" /></span>
            <span class="mono fw-700" style="font-size:12px; opacity:0.85;">02</span>
          </div>
          <div class="tc-title" style="font-size:18px;">이직 준비</div>
          <div class="tc-sub" style="margin-top:4px; margin-bottom:14px;">재직 중 더 나은 조건·직무로의 이동을 준비</div>
          <div class="col gap-6" style="margin-top:auto;">
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>현 역량의 시장가치 진단</span></div>
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>타깃 기업·직무 핏 분석</span></div>
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>경력 정리 및 협상 전략</span></div>
          </div>
          <div class="row items-center justify-between" style="margin-top:16px; padding-top:14px; border-top:1px solid rgba(255,255,255,0.25);">
            <span class="persona-label" style="font-size:12.5px; font-weight:700;"></span>
            <span class="persona-dot" style="width:24px; height:24px; border-radius:50%; display:flex; align-items:center; justify-content:center;"><span class="persona-check"><wb:icon-ds name="check" size="14" color="var(--brand)" /></span></span>
          </div>
        </div>

        <%-- Persona 03 · 재취업 --%>
        <div class="theme-card flex-1 tc-pink persona-card" data-code="3" style="align-items:stretch; text-align:left; padding:22px 20px;">
          <div class="row items-center justify-between" style="margin-bottom:12px;">
            <span style="width:44px; height:44px; border-radius:12px; background:rgba(255,255,255,0.22); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="refresh" size="22" color="#fff" sw="1.9" /></span>
            <span class="mono fw-700" style="font-size:12px; opacity:0.85;">03</span>
          </div>
          <div class="tc-title" style="font-size:18px;">재취업</div>
          <div class="tc-sub" style="margin-top:4px; margin-bottom:14px;">경력 단절 후 다시 일터로 복귀를 준비</div>
          <div class="col gap-6" style="margin-top:auto;">
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>공백기 극복 내러티브 설계</span></div>
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>재진입 가능 직무 추천</span></div>
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>단계적 워밍업 액션</span></div>
          </div>
          <div class="row items-center justify-between" style="margin-top:16px; padding-top:14px; border-top:1px solid rgba(255,255,255,0.25);">
            <span class="persona-label" style="font-size:12.5px; font-weight:700;"></span>
            <span class="persona-dot" style="width:24px; height:24px; border-radius:50%; display:flex; align-items:center; justify-content:center;"><span class="persona-check"><wb:icon-ds name="check" size="14" color="var(--brand)" /></span></span>
          </div>
        </div>

        <%-- Persona 04 · 승진 / 보직 희망 --%>
        <div class="theme-card flex-1 tc-violet persona-card" data-code="4" style="align-items:stretch; text-align:left; padding:22px 20px;">
          <div class="row items-center justify-between" style="margin-bottom:12px;">
            <span style="width:44px; height:44px; border-radius:12px; background:rgba(255,255,255,0.22); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="award" size="22" color="#fff" sw="1.9" /></span>
            <span class="mono fw-700" style="font-size:12px; opacity:0.85;">04</span>
          </div>
          <div class="tc-title" style="font-size:18px;">승진 / 보직 희망</div>
          <div class="tc-sub" style="margin-top:4px; margin-bottom:14px;">현 직장에서 상위 직급·보직을 목표</div>
          <div class="col gap-6" style="margin-top:auto;">
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>목표 직급까지 거리 진단</span></div>
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>리더십·전문성 강화 로드맵</span></div>
            <div class="row gap-6 items-start" style="font-size:12px; line-height:1.4; color:rgba(255,255,255,0.94);"><wb:icon-ds name="check" size="13" color="rgba(255,255,255,0.9)" /> <span>사내 가시성 확보 전략</span></div>
          </div>
          <div class="row items-center justify-between" style="margin-top:16px; padding-top:14px; border-top:1px solid rgba(255,255,255,0.25);">
            <span class="persona-label" style="font-size:12.5px; font-weight:700;"></span>
            <span class="persona-dot" style="width:24px; height:24px; border-radius:50%; display:flex; align-items:center; justify-content:center;"><span class="persona-check"><wb:icon-ds name="check" size="14" color="var(--brand)" /></span></span>
          </div>
        </div>

      </div>
    </div>

    <div class="row justify-between mt-32">
      <a href="${ctx}/service-intro" class="btn btn-ghost btn-pill">이전</a>
      <button type="button" class="btn btn-brand btn-pill btn-lg" id="nextBtn">다음 단계 <wb:icon-ds name="arrow" size="15" color="#fff" /></button>
    </div>

  </div>

  <%@ include file="../common-w/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  var cards = document.querySelectorAll('.persona-card');
  function select(target) {
    cards.forEach(function (c) { c.classList.toggle('is-selected', c === target); });
  }
  cards.forEach(function (card) {
    card.addEventListener('click', function () { select(card); });
  });
  // 복원: sessionStorage(또는 URL) 의 페르소나 카드 선택, 없으면 첫 번째
  if (cards.length) {
    var savedP = sessionStorage.getItem('wb_persona') || (new RegExp('[?&]persona=([^&]*)').exec(location.search)||[])[1];
    var pcard = savedP ? document.querySelector('.persona-card[data-code="'+savedP+'"]') : null;
    select(pcard || cards[0]);
  }

  document.getElementById('nextBtn').addEventListener('click', function () {
    var sel = document.querySelector('.persona-card.is-selected');
    var code = sel ? sel.getAttribute('data-code') : '';
    // 페르소나 코드: URL 전달 + 로컬 보관(최종 단계서 일괄 저장)
    if (code) sessionStorage.setItem('wb_persona', code);
    location.href = ctx + '/current-situation' + (code ? ('?persona=' + code) : '');
  });
})();
</script>
</body>
</html>

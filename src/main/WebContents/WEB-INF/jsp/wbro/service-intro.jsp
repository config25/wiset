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
  <title>01 서비스 소개 · W브릿지 AI 커리어 코칭</title>
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
      <span class="sep">›</span><span class="current">서비스 소개</span>
    </div>
  </div>

  <div class="section" style="padding:8px 40px 56px;">

    <%-- Page title --%>
    <div class="text-center" style="padding:38px 0 8px;">
      <h1 class="display" style="margin:0;">AI 커리어 코칭</h1>
      <p class="body-lg" style="max-width:680px; margin:14px auto 0;">
        역량 진단부터 격차 분석, 맞춤형 Next Step까지 — AI가 동반하는 나만의 경력 여정을 시작하세요.
      </p>
    </div>

    <%-- HERO (full-bleed image + scrim) --%>
    <div class="hero-banner hb-image mt-24">
      <div style="flex:1; position:relative; z-index:2; max-width:540px;">
        <span class="badge badge-brand-solid mb-16">AI POWERED</span>
        <h2 class="kr-heavy" style="font-size:33px; line-height:1.25; margin:0 0 16px; color:#fff; text-shadow:0 2px 14px rgba(40,24,80,0.45);">
          막연한 고민을<br/><span class="t-brand">구체적 행동 계획</span>으로
        </h2>
        <p class="body" style="font-size:15px; max-width:440px; margin-bottom:22px; color:rgba(255,255,255,0.95); text-shadow:0 1px 10px rgba(40,24,80,0.4);">
          64,680명 회원의 컨설팅 패턴을 학습한 AI가<br/>지금 당신에게 가장 필요한 다음 단계를 제시합니다.
        </p>
        <div class="row gap-12">
          <a href="${ctx}/persona-select" class="btn btn-brand btn-pill btn-lg">AI 경력개발 시작하기 <wb:icon-ds name="arrow" size="15" color="#fff" /></a>
          <button type="button" class="btn btn-pill btn-lg" style="background:rgba(255,255,255,0.92); color:var(--brand); font-weight:700;">서비스 소개 영상</button>
        </div>
      </div>
    </div>

    <%-- STAT BAND --%>
    <div class="row gap-16 mt-24">
      <div class="card flex-1 row items-center gap-20" style="padding:18px 22px;">
        <wb:iconchip name="users" tone="brand" size="46" icon="22" radius="13" />
        <div><div class="h2" style="font-size:24px; color:var(--brand);">64,680</div><div class="caption" style="margin-top:3px;">누적 회원 컨설팅 데이터</div></div>
      </div>
      <div class="card flex-1 row items-center gap-20" style="padding:18px 22px;">
        <wb:iconchip name="target" tone="blue" size="46" icon="22" radius="13" />
        <div><div class="h2" style="font-size:24px; color:var(--blue);">12개</div><div class="caption" style="margin-top:3px;">AI가 진단하는 핵심 역량</div></div>
      </div>
      <div class="card flex-1 row items-center gap-20" style="padding:18px 22px;">
        <wb:iconchip name="clock" tone="green" size="46" icon="22" radius="13" />
        <div><div class="h2" style="font-size:24px; color:var(--green-deep);">약 8분</div><div class="caption" style="margin-top:3px;">입력부터 리포트까지</div></div>
      </div>
      <div class="card flex-1 row items-center gap-20" style="padding:18px 22px;">
        <wb:iconchip name="shield" tone="pink" size="46" icon="22" radius="13" />
        <div><div class="h2" style="font-size:24px; color:var(--pink);">100%</div><div class="caption" style="margin-top:3px;">비식별 안전 처리</div></div>
      </div>
    </div>

    <%-- INTRO LINE --%>
    <p class="body-lg mt-32 mb-4">
      <span class="t-brand fw-800">AI 커리어 코칭</span>은 4단계 정보 입력과 AI 분석을 거쳐 리포트로 완성됩니다.
    </p>
    <p class="body-lg" style="margin-top:2px;">입력부터 액션 플랜까지, 약 8분 내에 완료됩니다.</p>

    <%-- WHAT YOU GET --%>
    <div class="mt-32">
      <div class="eyebrow">What you get</div>
      <h2 class="h2 mt-12 mb-24">AI 커리어 코칭으로 얻을 수 있는 3가지</h2>
      <div class="row gap-20">
        <div class="card card-lift card-shadow flex-1">
          <div class="row items-center justify-between mb-16">
            <wb:iconchip name="chart" tone="blue" size="50" icon="25" />
            <span class="h1 mono" style="color:var(--ink-200);">01</span>
          </div>
          <div class="h3 mb-8">활동 분석</div>
          <div class="body">이력서·진단 결과·타깃 JD를 기반으로 현재 역량과 목표 사이의 격차를 수치화합니다.</div>
        </div>
        <div class="card card-lift card-shadow flex-1">
          <div class="row items-center justify-between mb-16">
            <wb:iconchip name="message" tone="pink" size="50" icon="25" />
            <span class="h1 mono" style="color:var(--ink-200);">02</span>
          </div>
          <div class="h3 mb-8">컨설팅형 진단평</div>
          <div class="body">WISET 전문가의 컨설팅 패턴을 학습한 AI가 강점·보완점·경력 경로에 대한 상세 평어를 생성합니다.</div>
        </div>
        <div class="card card-lift card-shadow flex-1">
          <div class="row items-center justify-between mb-16">
            <wb:iconchip name="flag" tone="green" size="50" icon="25" />
            <span class="h1 mono" style="color:var(--ink-200);">03</span>
          </div>
          <div class="h3 mb-8">맞춤 액션 플랜</div>
          <div class="body">지금 / 이번 주 / 1개월 내 단위로 우선순위가 매겨진 추천 활동을 받아보세요.</div>
        </div>
      </div>
    </div>

    <%-- HOW IT WORKS --%>
    <div class="mt-40">
      <div class="eyebrow">How it works</div>
      <h2 class="h2 mt-12 mb-8">경력개발 진단 진행 프로세스</h2>
      <div class="card card-shadow" style="padding:32px; margin-top:16px; background:linear-gradient(180deg,#FAF8FD 0%,#fff 100%);">
        <div class="row items-start">

          <%-- STEP 01 --%>
          <div style="flex:1;">
            <div class="caption text-center" style="font-weight:800; font-size:10px; letter-spacing:0.12em; color:var(--brand); margin-bottom:8px;">INPUT</div>
            <div class="row justify-center" style="margin-bottom:12px; position:relative;">
              <div style="position:relative;">
                <wb:iconchip name="user" tone="brand" size="58" icon="26" radius="16" />
                <span style="position:absolute; top:-6px; right:-6px; width:22px; height:22px; border-radius:50%; background:#fff; border:1.5px solid var(--brand); display:flex; align-items:center; justify-content:center;"><span class="mono fw-700" style="font-size:10px; color:var(--brand);">01</span></span>
              </div>
            </div>
            <div class="text-center fw-700" style="font-size:13.5px; margin-bottom:6px;">페르소나 선택</div>
            <div class="text-center mono" style="font-size:10px; color:var(--brand); font-weight:600;">⏱ 약 1분</div>
          </div>
          <div style="flex:0 0 20px; display:flex; align-items:center; justify-content:center; padding-top:40px; color:var(--ink-300); font-size:18px;">→</div>

          <%-- STEP 02 --%>
          <div style="flex:1;">
            <div class="caption text-center" style="font-weight:800; font-size:10px; letter-spacing:0.12em; color:var(--brand); margin-bottom:8px;">INPUT</div>
            <div class="row justify-center" style="margin-bottom:12px; position:relative;">
              <div style="position:relative;">
                <wb:iconchip name="doc" tone="brand" size="58" icon="26" radius="16" />
                <span style="position:absolute; top:-6px; right:-6px; width:22px; height:22px; border-radius:50%; background:#fff; border:1.5px solid var(--brand); display:flex; align-items:center; justify-content:center;"><span class="mono fw-700" style="font-size:10px; color:var(--brand);">02</span></span>
              </div>
            </div>
            <div class="text-center fw-700" style="font-size:13.5px; margin-bottom:6px;">현 상황 입력</div>
            <div class="text-center mono" style="font-size:10px; color:var(--brand); font-weight:600;">⏱ 약 2분</div>
          </div>
          <div style="flex:0 0 20px; display:flex; align-items:center; justify-content:center; padding-top:40px; color:var(--ink-300); font-size:18px;">→</div>

          <%-- STEP 03 --%>
          <div style="flex:1;">
            <div class="caption text-center" style="font-weight:800; font-size:10px; letter-spacing:0.12em; color:var(--brand); margin-bottom:8px;">INPUT</div>
            <div class="row justify-center" style="margin-bottom:12px; position:relative;">
              <div style="position:relative;">
                <wb:iconchip name="target" tone="brand" size="58" icon="26" radius="16" />
                <span style="position:absolute; top:-6px; right:-6px; width:22px; height:22px; border-radius:50%; background:#fff; border:1.5px solid var(--brand); display:flex; align-items:center; justify-content:center;"><span class="mono fw-700" style="font-size:10px; color:var(--brand);">03</span></span>
              </div>
            </div>
            <div class="text-center fw-700" style="font-size:13.5px; margin-bottom:6px;">경력개발 목표</div>
            <div class="text-center mono" style="font-size:10px; color:var(--brand); font-weight:600;">⏱ 약 3분</div>
          </div>
          <div style="flex:0 0 20px; display:flex; align-items:center; justify-content:center; padding-top:40px; color:var(--ink-300); font-size:18px;">→</div>

          <%-- STEP 04 --%>
          <div style="flex:1;">
            <div class="caption text-center" style="font-weight:800; font-size:10px; letter-spacing:0.12em; color:var(--brand); margin-bottom:8px;">INPUT</div>
            <div class="row justify-center" style="margin-bottom:12px; position:relative;">
              <div style="position:relative;">
                <wb:iconchip name="chat" tone="brand" size="58" icon="26" radius="16" />
                <span style="position:absolute; top:-6px; right:-6px; width:22px; height:22px; border-radius:50%; background:#fff; border:1.5px solid var(--brand); display:flex; align-items:center; justify-content:center;"><span class="mono fw-700" style="font-size:10px; color:var(--brand);">04</span></span>
              </div>
            </div>
            <div class="text-center fw-700" style="font-size:13.5px; margin-bottom:6px;">세부 고민</div>
            <div class="text-center mono" style="font-size:10px; color:var(--brand); font-weight:600;">⏱ 약 1분</div>
          </div>
          <div style="flex:0 0 20px; display:flex; align-items:center; justify-content:center; padding-top:40px; color:var(--ink-300); font-size:18px;">→</div>

          <%-- STEP 05 (AI) --%>
          <div style="flex:1;">
            <div class="caption text-center" style="font-weight:800; font-size:10px; letter-spacing:0.12em; color:var(--pink); margin-bottom:8px;">AI</div>
            <div class="row justify-center" style="margin-bottom:12px; position:relative;">
              <div style="position:relative;">
                <wb:iconchip name="sparkle" tone="pink" size="58" icon="26" radius="16" />
                <span style="position:absolute; top:-6px; right:-6px; width:22px; height:22px; border-radius:50%; background:#fff; border:1.5px solid var(--pink); display:flex; align-items:center; justify-content:center;"><span class="mono fw-700" style="font-size:10px; color:var(--pink);">05</span></span>
              </div>
            </div>
            <div class="text-center fw-700" style="font-size:13.5px; margin-bottom:6px;">AI 분석 실행</div>
            <div class="text-center mono" style="font-size:10px; color:var(--pink); font-weight:600;">⏱ 약 1분</div>
          </div>
          <div style="flex:0 0 20px; display:flex; align-items:center; justify-content:center; padding-top:40px; color:var(--ink-300); font-size:18px;">→</div>

          <%-- STEP 06 (OUTPUT) --%>
          <div style="flex:1;">
            <div class="caption text-center" style="font-weight:800; font-size:10px; letter-spacing:0.12em; color:var(--green-deep); margin-bottom:8px;">OUTPUT</div>
            <div class="row justify-center" style="margin-bottom:12px; position:relative;">
              <div style="position:relative;">
                <wb:iconchip name="check" tone="green" size="58" icon="26" radius="16" />
                <span style="position:absolute; top:-6px; right:-6px; width:22px; height:22px; border-radius:50%; background:#fff; border:1.5px solid var(--green); display:flex; align-items:center; justify-content:center;"><span class="mono fw-700" style="font-size:10px; color:var(--green-deep);">06</span></span>
              </div>
            </div>
            <div class="text-center fw-700" style="font-size:13.5px; margin-bottom:6px;">리포트 &amp; 액션</div>
            <div class="text-center mono" style="font-size:10px; color:var(--green-deep); font-weight:600;">⏱ 바로 확인</div>
          </div>

        </div>

        <%-- legend --%>
        <div class="row gap-24 justify-center mt-32" style="padding-top:20px; border-top:1px dashed var(--line);">
          <span class="row items-center gap-8 caption fw-600"><span style="width:12px; height:12px; border-radius:3px; background:var(--brand);"></span> 정보 입력 (4단계)</span>
          <span class="row items-center gap-8 caption fw-600"><span style="width:12px; height:12px; border-radius:3px; background:var(--pink);"></span> AI 분석</span>
          <span class="row items-center gap-8 caption fw-600"><span style="width:12px; height:12px; border-radius:3px; background:var(--green);"></span> 리포트 &amp; 액션</span>
          <span style="border-left:1px solid var(--line); height:16px;"></span>
          <span class="caption">총 소요 시간 <b class="t-ink700">약 7~8분</b></span>
        </div>
      </div>
    </div>

  </div>

  <%@ include file="../common-w/footer-ds.jspf" %>

</div>
</body>
</html>

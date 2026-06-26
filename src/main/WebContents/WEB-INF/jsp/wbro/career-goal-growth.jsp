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
  <title>04b 경력 성장 목표 · W브릿지 AI 커리어 코칭</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
  <style>
    .gsel { width:100%; padding:12px 14px; border:1px solid var(--ink-200); border-radius:8px; font-size:14px; color:var(--ink); background:#fff; font-family:inherit; cursor:pointer; }
    .gsel:focus { outline:none; border-color:var(--brand); box-shadow:0 0 0 3px var(--brand-50); }
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

    <%-- Stepper (STEP 3 / 5) --%>
    <div class="row justify-center">
      <div class="stepper" style="padding:22px 0;">
        <div class="step done"><div class="step-num"><wb:icon-ds name="check" size="14" color="#fff" /></div><span>페르소나 선택</span></div>
        <div class="step-line active"></div>
        <div class="step done"><div class="step-num"><wb:icon-ds name="check" size="14" color="#fff" /></div><span>현 상황 입력</span></div>
        <div class="step-line active"></div>
        <div class="step active"><div class="step-num">3</div><span>경력개발 목표</span></div>
        <div class="step-line"></div>
        <div class="step"><div class="step-num">4</div><span>세부 고민</span></div>
        <div class="step-line"></div>
        <div class="step"><div class="step-num">5</div><span>입력 데이터 확인</span></div>
      </div>
    </div>

    <div style="max-width:800px; margin:16px auto 0;">
      <div class="text-center">
        <span class="badge badge-brand mb-12" style="letter-spacing:0.1em;">STEP 3 / 5 · 경력 성장 (승진·보직)</span>
        <h1 class="display mt-12 mb-8">경력 성장 목표를 알려주세요</h1>
        <p class="body-lg mb-24">목표 보직과 강화할 리더십 역량을 입력하면 AI가 사내 승진·평가 기준과의 격차를 분석합니다.</p>
      </div>

      <div class="card" style="padding:32px;">

        <%-- ①·② 현재 직급 / 연차 --%>
        <div class="row gap-16 mb-24">
          <div class="flex-1">
            <label class="label">① 현재 직급<span class="req">*</span></label>
            <select class="gsel" id="rank">
              <option>인턴</option><option>사원</option><option>주임급</option><option selected>대리급</option><option>과장급</option><option>차장급</option><option>부장급</option>
            </select>
          </div>
          <div class="flex-1">
            <label class="label">② 현재 연차<span class="req">*</span></label>
            <select class="gsel" id="years"></select>
          </div>
        </div>

        <%-- ③ 현재 담당 업무 --%>
        <div class="mb-24">
          <label class="label">③ 현재 담당 업무<span class="req">*</span></label>
          <textarea class="input" id="duties" placeholder="예: 연구 데이터 관리·보고, 장비·시약 운영, 부서 간 일정 조율 등 현재 맡고 계신 핵심 업무를 적어주세요" style="height:92px; resize:vertical; line-height:1.6;">연구개발팀 실험 데이터 관리·분석 보고, 시약·장비 구매 및 재고 관리, 연구 일정·문서 취합, 부서 간 커뮤니케이션 지원</textarea>
        </div>

        <%-- ④ 목표 보직 / 직급 --%>
        <div class="mb-24">
          <label class="label">④ 목표 보직 / 직급<span class="req">*</span></label>
          <input class="input" id="targetRole" value="연구개발팀 팀장 (PL)" placeholder="예: 연구개발팀 팀장(PL), 수석연구원, 본부장 등">
        </div>

        <%-- ⑤ 강화할 리더십·역량 영역 --%>
        <div class="mb-24">
          <label class="label">⑤ 강화할 리더십·역량 영역 <span class="caption" style="font-weight:400;">(복수 선택)</span></label>
          <div class="row gap-8 flex-wrap" id="skillRow"></div>
        </div>

        <%-- ⑥·⑦ 목표 처우 / 핵심 평가 반영 요소 --%>
        <div class="row gap-16">
          <div class="flex-1">
            <label class="label">⑥ 목표 처우 <span class="caption" style="font-weight:400;">(승진 시 기대 연봉)</span></label>
            <input class="input" id="targetPay" value="6,500 ~ 7,500만원">
          </div>
          <div class="flex-1">
            <label class="label">⑦ 핵심 평가 반영 요소</label>
            <div class="row gap-6" id="evalRow"></div>
          </div>
        </div>

      </div>
    </div>

    <div class="row justify-between" style="max-width:800px; margin:32px auto 0;">
      <button type="button" class="btn btn-ghost btn-pill" id="prevBtn">이전 단계</button>
      <button type="button" class="btn btn-brand btn-pill btn-lg" id="nextBtn">다음 단계 <wb:icon-ds name="arrow" size="15" color="#fff" /></button>
    </div>

  </div>

  <%@ include file="../common-w/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  var $ = function (id) { return document.getElementById(id); };
  function qp(n){ var m=new RegExp('[?&]'+n+'=([^&]*)').exec(location.search); return m?decodeURIComponent(m[1]):''; }
  function svg(p,sz,c,sw){ return '<svg width="'+sz+'" height="'+sz+'" viewBox="0 0 24 24" fill="none" stroke="'+(c||'currentColor')+'" stroke-width="'+(sw||1.7)+'" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">'+p+'</svg>'; }
  var CHK = '<path d="M4.5 12.5l4.5 4.5L19.5 6.5"/>';

  // ② 연차 옵션 (1년미만 + 1~30년, 기본 5년)
  (function(){
    var opts = ['1년미만']; for(var i=1;i<=30;i++) opts.push(i+'년');
    $('years').innerHTML = opts.map(function(o){ return '<option'+(o==='5년'?' selected':'')+'>'+o+'</option>'; }).join('');
  })();

  // ⑤ 강화할 리더십·역량 (복수 선택, 기본: 조직·인력 관리 / 전략·기획 / 성과관리)
  var skills = ['조직·인력 관리','전략·기획','의사결정','성과관리','협업·소통','예산·자원 관리','전문성 심화'];
  var skillOn = { '조직·인력 관리':true, '전략·기획':true, '성과관리':true };
  function chipStyle(on){ return 'display:inline-flex; align-items:center; gap:6px; padding:8px 14px; border-radius:8px; font-size:13px; cursor:pointer; border:1.5px solid '+(on?'var(--brand-200)':'var(--line)')+'; background:'+(on?'var(--brand-50)':'#fff')+'; color:'+(on?'var(--brand)':'var(--ink-700)')+'; font-weight:'+(on?'700':'500')+';'; }
  function renderSkills(){
    var el=$('skillRow'); el.innerHTML='';
    skills.forEach(function(s){
      var on=!!skillOn[s];
      var b=document.createElement('span'); b.style.cssText=chipStyle(on);
      b.innerHTML=(on?svg(CHK,13,'var(--brand)'):'')+'<span>'+s+'</span>';
      b.addEventListener('click', function(){ skillOn[s]=!skillOn[s]; renderSkills(); });
      el.appendChild(b);
    });
  }

  // ⑦ 핵심 평가 반영 요소 (단일 선택, 기본: 리더십 다면평가)
  var evals = ['리더십 다면평가','성과(KPI)','전문성'];
  var evalSel = '리더십 다면평가';
  function renderEvals(){
    var el=$('evalRow'); el.innerHTML='';
    evals.forEach(function(e){
      var on=evalSel===e;
      var b=document.createElement('span');
      b.style.cssText='flex:1; text-align:center; justify-content:center; display:inline-flex; align-items:center; padding:8px 0; border-radius:8px; font-size:13px; cursor:pointer; border:1.5px solid '+(on?'var(--brand-200)':'var(--line)')+'; background:'+(on?'var(--brand-50)':'#fff')+'; color:'+(on?'var(--brand)':'var(--ink-700)')+'; font-weight:'+(on?'700':'500')+';';
      b.textContent=e;
      b.addEventListener('click', function(){ evalSel=e; renderEvals(); });
      el.appendChild(b);
    });
  }

  // nav (persona 파라미터 유지)
  var pq = qp('persona'); var suf = pq ? ('?persona='+encodeURIComponent(pq)) : '';
  $('prevBtn').addEventListener('click', function(){ location.href = ctx + '/current-situation' + suf; });
  $('nextBtn').addEventListener('click', function(){
    // DB 저장 없이 로컬(sessionStorage)에만 보관 → 최종 단계(분석 시작)에서 일괄 저장
    var data = {
      rank: $('rank').value,
      years: $('years').value,
      duties: $('duties').value.trim(),
      targetRole: $('targetRole').value.trim(),
      skills: Object.keys(skillOn).filter(function(k){ return skillOn[k]; }),
      targetPay: $('targetPay').value.trim(),
      evalFactor: evalSel
    };
    sessionStorage.setItem('wb_careerGrowth', JSON.stringify(data));
    location.href = ctx + '/concern' + suf;
  });

  // 복원: sessionStorage 의 이전 입력값
  (function(){ try{ var s=JSON.parse(sessionStorage.getItem('wb_careerGrowth')); if(s){
    if(s.rank) $('rank').value=s.rank;
    if(s.years) $('years').value=s.years;
    if(s.duties!=null) $('duties').value=s.duties;
    if(s.targetRole!=null) $('targetRole').value=s.targetRole;
    if(s.targetPay!=null) $('targetPay').value=s.targetPay;
    if(Array.isArray(s.skills)){ Object.keys(skillOn).forEach(function(k){ delete skillOn[k]; }); s.skills.forEach(function(k){ skillOn[k]=true; }); }
    if(s.evalFactor) evalSel=s.evalFactor;
  } }catch(e){} })();
  renderSkills(); renderEvals();
})();
</script>
</body>
</html>

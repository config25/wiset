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
  <title>05 세부 고민 · W브릿지 AI 커리어 코칭</title>
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
      <span class="sep">›</span><span class="current">AI 경력개발 진단</span>
    </div>
  </div>

  <div class="section" style="padding:20px 40px 56px;">

    <%-- Stepper (STEP 4 / 5) --%>
    <div class="row justify-center">
      <div class="stepper" style="padding:22px 0;">
        <div class="step done"><div class="step-num"><wb:icon-ds name="check" size="14" color="#fff" /></div><span>페르소나 선택</span></div>
        <div class="step-line active"></div>
        <div class="step done"><div class="step-num"><wb:icon-ds name="check" size="14" color="#fff" /></div><span>현 상황 입력</span></div>
        <div class="step-line active"></div>
        <div class="step done"><div class="step-num"><wb:icon-ds name="check" size="14" color="#fff" /></div><span>경력개발 목표</span></div>
        <div class="step-line active"></div>
        <div class="step active"><div class="step-num">4</div><span>세부 고민</span></div>
        <div class="step-line"></div>
        <div class="step"><div class="step-num">5</div><span>입력 데이터 확인</span></div>
      </div>
    </div>

    <div style="max-width:800px; margin:16px auto 0;">
      <div class="text-center">
        <span class="badge badge-brand mb-12" id="tagBadge" style="letter-spacing:0.1em;">STEP 4 / 5</span>
        <h1 class="display mt-12 mb-8">가장 답답한 고민이 무엇인가요?</h1>
        <p class="body-lg mb-24">선택하신 고민에 따라 컨설팅 평어와 액션 플랜의 강조 포인트가 달라집니다.</p>
      </div>

      <div class="card" style="padding:28px;">
        <%-- 키워드별 고민 예시 --%>
        <div class="row items-center justify-between mb-12">
          <label class="label" style="margin-bottom:0;">키워드별 고민 예시</label>
          <span class="caption" style="color:var(--ink-500);">예시를 클릭하면 아래 <span class="fw-700 t-brand">자유 서술</span>란에 자동 입력됩니다</span>
        </div>

        <%-- Tabs --%>
        <div class="row gap-8 flex-wrap" id="tabRow"></div>

        <%-- Example chips --%>
        <div class="col gap-8" id="chipCol" style="margin-top:16px;"></div>

        <div class="divider mt-24 mb-16"></div>

        <%-- 자유 서술 --%>
        <div class="row items-center justify-between mb-8">
          <label class="label" style="margin-bottom:0;">자유 서술 <span class="caption" style="font-weight:400;">(선택 · AI가 평어 작성 시 참고)</span></label>
          <button type="button" id="clearBtn" class="btn btn-ghost btn-sm" style="font-size:12px; padding:4px 10px; display:none;">지우기</button>
        </div>
        <textarea id="freeText" style="width:100%; min-height:100px; max-height:320px; overflow-y:auto; padding:12px; font-size:13px; line-height:1.6; font-family:inherit; color:var(--ink); resize:none; border:1px solid var(--line); border-radius:8px; background:#fff; box-sizing:border-box;"></textarea>
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
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function qp(n){ var m=new RegExp('[?&]'+n+'=([^&]*)').exec(location.search); return m?decodeURIComponent(m[1]):''; }
  function svg(p,sz,c,sw){ return '<svg width="'+sz+'" height="'+sz+'" viewBox="0 0 24 24" fill="none" stroke="'+(c||'currentColor')+'" stroke-width="'+(sw||1.7)+'" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">'+p+'</svg>'; }
  var CHK = '<path d="M4.5 12.5l4.5 4.5L19.5 6.5"/>';

  // ---------- 산업별 데이터셋 (persona 1~4 = 산업 1:1 매핑) ----------
  //   1: AI 정보보안 · 2: 화학·바이오 · 3: 반도체 · 4: 일반산업
  var DATA = {
    '1': { tag:'AI 정보보안',
      placeholder:'예: AI보안(적대적 공격) 분야로 석사 연구를 했지만, 신입으로 지원할 때 보안 도메인 지식과 머신러닝 역량 중 무엇을 앞세워야 할지, 연구 경험을 실무 역량으로 어떻게 번역할지 막막합니다.',
      cats:[
        { cat:'직무 방향 (공격 vs 방어)', items:[
          "모의해킹·취약점 진단(공격)과 보안관제·침해대응(방어) 중 신입으로 어디서 시작하는 게 좋을까요?",
          "보안 도메인으로 갈지, 데이터·AI 엔지니어로 갈지 사이에서 커리어 방향을 못 정했어요.",
          "정보보호 컨설팅(GRC)과 실무 기술직(관제·대응) 중 제 성향에 무엇이 맞을지 조언받고 싶어요." ] },
        { cat:'AI·보안 융합 역량', items:[
          "AI 보안(적대적 공격·악성코드 탐지) 연구 경험을 채용 시장이 원하는 실무 역량으로 어떻게 번역하죠?",
          "머신러닝 역량과 보안 지식 중 지원할 때 무엇을 전면에 내세워야 유리한지 모르겠어요.",
          "논문·연구 중심으로 커왔는데 보안 실무(관제·대응) 경험이 없어 지원이 망설여집니다." ] },
        { cat:'자격증·스펙 전략', items:[
          "정보보안기사에 더해 CISSP·OSCP 같은 자격증을 신입 때 준비하는 게 실제로 도움이 될까요?",
          "CTF 수상·버그바운티 이력이 정규 채용에서 어느 정도 인정받는지 궁금해요.",
          "석사 학위가 보안 연구개발직 신입 지원에 실제로 얼마나 가점이 되는지 알고 싶어요." ] },
        { cat:'실무·포트폴리오', items:[
          "실무 경험이 없어 GitHub·기술블로그로 보안 프로젝트를 어떻게 채워야 어필이 될지 막막해요.",
          "취약점 분석·침해대응 실습 경험을 포트폴리오로 정리하는 방법을 모르겠어요.",
          "보안 신입 면접에서 나올 기술 꼬리질문과 예상 질문을 제 이력 기준으로 뽑아주세요." ] } ] },
    '2': { tag:'화학·바이오',
      placeholder:'예: 정밀화학 생산기술 7년 경력인데, 바이오 분야로 이직하려니 세포배양·정제 실무 경험이 없어 교육 수준에 머물러 있습니다. 화학 스케일업·수율 역량을 바이오 기술직 언어로 어떻게 재번역할지 막막합니다.',
      cats:[
        { cat:'산업·직무 전환 (화학↔바이오)', items:[
          "정밀화학 공정 경력을 바이오 의약품(원료의약품·바이오공정)으로 확장하려면 무엇을 강조해야 하나요?",
          "R&D(연구개발)에서 생산기술·공정개발(기술직)로 넘어가려는데 어떤 경험을 부각해야 할까요?",
          "품질관리(QC)에서 품질보증(QA)이나 인허가(RA)로 직무를 넓히려면 무엇을 준비해야 하나요?" ] },
        { cat:'전이 가능 역량 어필', items:[
          "화학 공정에서 쌓은 스케일업·수율 개선 역량을 바이오 기술직 언어로 어떻게 재번역하죠?",
          "특허·SCI 논문 실적을 산업체 기술직 채용에서 강점으로 보이게 하는 방법이 궁금해요.",
          "바이오 실무(세포배양·정제) 경험이 교육 수준에 머물러 있는데 이걸 어떻게 보완·소명할까요?" ] },
        { cat:'GMP·인허가(RA/QA) 준비', items:[
          "GMP·바이오공정 교육은 이수했는데, 실무 경험 없이 GMP 현장 직무 지원이 현실적인지 궁금해요.",
          "인허가(RA)나 QA로 전환하려면 어떤 규정(식약처·FDA·GMP) 지식을 먼저 갖춰야 하나요?",
          "화공기사·위험물 자격 외에 바이오 직무 전환에 도움이 되는 자격·교육이 있을까요?" ] },
        { cat:'이력 재구성·면접', items:[
          "화학 경력이 바이오 기술직에서 오히려 강점으로 읽히도록 이력서를 어떻게 재구성할까요?",
          "경력기술서를 단순 업무 나열이 아니라 성과 중심(수율 개선 등 수치)으로 바꾸고 싶어요.",
          "직무·산업을 바꾸는 이유를 면접에서 설득력 있게 설명하는 방법이 궁금해요." ] } ] },
    '3': { tag:'반도체',
      placeholder:'예: 반도체 소자개발팀에서 8년 근무 후 육아로 3년 공백이 있습니다. 소자 평가·데이터 관리 경력을 살려 연구지원직으로 복귀하고 싶은데, 공백기와 시간선택제 근무 가능성 때문에 현실적인 조언을 원합니다.',
      cats:[
        { cat:'직무 방향 (소자·공정·계측)', items:[
          "소자 개발·평가와 공정 통합(PIE), 계측·분석 중 제 경력에 맞는 직무가 무엇일지 조언받고 싶어요.",
          "연구개발(소자)에서 데이터·장비 중심의 연구지원직으로 방향을 잡으려는데 괜찮은 선택일까요?",
          "회로설계·수율(YE)·품질 등 여러 직무에 지원 중인데 한 분야로 타겟팅해야 할까요?" ] },
        { cat:'공백기 복귀·최신 공정 적응', items:[
          "육아로 3년 공백이 생겼는데, 그사이 미세화된 공정·최신 계측 장비 감각이 뒤처졌을까 두렵습니다.",
          "면접에서 경력 공백을 단절이 아니라 재교육기로 설득력 있게 방어하는 방법이 궁금해요.",
          "예전 8년간의 소자 평가·데이터 관리 경력을 복귀 시 어떻게 다시 전면에 내세워야 할까요?" ] },
        { cat:'근무형태·지역 (교대/시간선택제)', items:[
          "육아를 병행해야 해서 시간선택제로도 반도체 연구지원직 복귀가 현실적인지 궁금합니다.",
          "교대 근무가 많은 공정 직무 대신 정규 시간 근무가 가능한 직무는 어떤 것이 있을까요?",
          "이천·용인 등 특정 지역으로 근무지를 제한하면 취업 성공 확률이 많이 낮아질까요?" ] },
        { cat:'경력 활용·재교육', items:[
          "DRAM 신뢰성 평가·실험 데이터 표준화 경력을 살릴 수 있는 유망 직무 전환이 가능할까요?",
          "WISET 경력복귀 재교육·계측 분석 재교육 이수 경험을 이력에 어떻게 반영해야 플러스가 될까요?",
          "복귀를 위해 추가로 들으면 좋은 반도체 계측·분석 관련 교육이나 자격이 있을까요?" ] } ] },
    '4': { tag:'일반산업',
      placeholder:'예: R&D 책임연구원으로 연구소 상위 보직 승진 대상자가 되었습니다. 뛰어난 실무자가 관리자로 넘어갈 때의 함정을 넘어 팀 성과를 만드는 리더로 전환하고, 다면평가에서 관리 역량을 성과 지표로 증명할 전략을 얻고 싶습니다.',
      cats:[
        { cat:'관리자 전환 (플레이어→리더)', items:[
          "뛰어난 실무자가 관리자로 넘어갈 때 겪는 플레이어의 함정에 빠질까 봐 걱정입니다.",
          "후임들이 늘면서 실무와 멀어지고 제 역할이 모호해졌는데 어떤 포지셔닝을 가져야 할까요?",
          "사수 공백으로 갑자기 팀 리더를 맡게 되었는데 피플 매니지먼트 팁이 궁금해요." ] },
        { cat:'리더십·조직 관리', items:[
          "남성 연구원이 다수인 조직에서 부드럽지만 결단력 있는 리더십을 어떻게 구축할까요?",
          "성과는 좋지만 지식이 부족한 팀원을 이끌 때 자꾸 언성을 높이게 되어 리더 자질이 고민입니다.",
          "타 부서와의 기술 커뮤니케이션·과제 일정 조율을 원활히 하는 방법이 궁금해요." ] },
        { cat:'전문성 심화 vs 확장', items:[
          "석사 연구직으로서 성장 한계를 느끼는데, 박사 진학이 커리어에 도움이 될까요?",
          "기존 R&D 외에 전략기획·사업개발로 직무 이동(Job Rotation)을 하려면 어떻게 접근할까요?",
          "설계 전문성을 더 깊게 갈지, 관리자로 폭을 넓힐지 사이에서 방향을 정하고 싶어요." ] },
        { cat:'성과 증명·자기 PR', items:[
          "곧 있을 리더십 다면평가에서 조직 관리 역량을 R&D 성과 지표로 어떻게 정량 증명할까요?",
          "임원에게 자기 PR을 하라는 말을 들었는데, 사내에서 성과를 효과적으로 포장하는 방법은요?",
          "논문·특허 중심 성과를 넘어 팀 성과·리더십 성과를 어떻게 가시화해 어필할 수 있을까요?" ] } ] }
  };

  var persona = qp('persona');
  var d = DATA[persona] || DATA['1'];
  var cats = d.cats;
  var activeTab = 0;
  var pickedKey = null;

  $('tagBadge').textContent = 'STEP 4 / 5 · ' + d.tag;
  $('freeText').placeholder = d.placeholder;

  function renderTabs(){
    var el=$('tabRow'); el.innerHTML='';
    cats.forEach(function(c,i){
      var on=activeTab===i;
      var b=document.createElement('button'); b.type='button'; b.className='btn btn-pill'; b.textContent=c.cat;
      b.style.cssText='border-color:'+(on?'var(--brand)':'var(--line)')+'; background:'+(on?'var(--brand-50)':'#fff')+'; color:'+(on?'var(--brand)':'var(--ink-700)')+'; font-weight:'+(on?'700':'500')+'; font-size:13px; padding:8px 18px;';
      b.addEventListener('click', function(){ activeTab=i; renderTabs(); renderChips(); });
      el.appendChild(b);
    });
  }
  function renderChips(){
    var el=$('chipCol'); el.innerHTML='';
    cats[activeTab].items.forEach(function(t,j){
      var key=activeTab+':'+j;
      var on=pickedKey===key;
      var b=document.createElement('button'); b.type='button';
      b.style.cssText='border-radius:12px; cursor:pointer; text-align:left; border:1.5px solid '+(on?'var(--brand)':'var(--line)')+'; background:'+(on?'var(--brand-50)':'#fff')+'; color:'+(on?'var(--brand)':'var(--ink-700)')+'; font-weight:'+(on?'600':'400')+'; font-size:13.5px; line-height:1.55; padding:13px 16px; display:flex; gap:10px; align-items:flex-start;';
      b.innerHTML='<span style="width:18px; height:18px; border-radius:50%; flex-shrink:0; margin-top:1px; background:'+(on?'var(--brand)':'var(--bg-soft)')+'; border:'+(on?'none':'1px solid var(--line)')+'; display:flex; align-items:center; justify-content:center;">'+(on?svg(CHK,11,'#fff'):'')+'</span><span>'+esc(t)+'</span>';
      b.addEventListener('click', function(){ $('freeText').value=t; pickedKey=key; renderChips(); updateClear(); autosize(); });
      el.appendChild(b);
    });
  }
  function updateClear(){ $('clearBtn').style.display = $('freeText').value ? '' : 'none'; }
  // 내용에 맞춰 높이 자동 확장(최대치 초과 시 내부 스크롤) → 박스 밖으로 안 넘침
  function autosize(){ var t=$('freeText'); t.style.height='auto'; t.style.height=Math.min(t.scrollHeight, 320)+'px'; }

  $('freeText').addEventListener('input', function(){ pickedKey=null; renderChips(); updateClear(); autosize(); });
  $('clearBtn').addEventListener('click', function(){ $('freeText').value=''; pickedKey=null; renderChips(); updateClear(); autosize(); });

  // nav (persona 유지)
  var suf = persona ? ('?persona='+encodeURIComponent(persona)) : '';
  $('prevBtn').addEventListener('click', function(){ location.href = ctx + '/career-goal' + suf; });
  $('nextBtn').addEventListener('click', function(){
    // DB 저장 없이 자유서술만 로컬(sessionStorage) 보관 → 최종 단계서 일괄 저장
    sessionStorage.setItem('wb_concern', $('freeText').value.trim());
    location.href = ctx + '/review' + suf;
  });

  var __savedConcern = sessionStorage.getItem('wb_concern'); if(__savedConcern){ $('freeText').value = __savedConcern; }
  renderTabs(); renderChips(); updateClear(); autosize();
})();
</script>
</body>
</html>

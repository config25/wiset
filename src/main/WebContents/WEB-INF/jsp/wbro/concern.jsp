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

  // ---------- 페르소나별 데이터셋 ----------
  var DATA = {
    '1': { tag:'신규 취업',
      placeholder:'예: 개발 프로젝트 경험은 있지만 기획 직무에도 관심이 많아 첫 커리어 방향을 못 정했습니다. 학점은 3.2로 낮은 편이라 서류 탈락이 잦은데, 제 자소서 소재가 적절한지 점검받고 싶습니다.',
      cats:[
        { cat:'직무 방향성', items:[
          "개발 경험이 있지만, 전체 과정을 좋아해서 개발자와 서비스 기획/PM 중 어디로 시작할지 모르겠어요.",
          "전공에 애착이 없어 직무 선택에 갈피를 못 잡고 있는데, 당장 무엇을 해야 할지 조언을 듣고 싶어요.",
          "반도체, 이차전지, 정밀화학 등 여러 공정/품질 직무에 지원 중인데 한 분야로 타겟팅해야 할까요?" ] },
        { cat:'서류 탈락/자소서', items:[
          "계속되는 서류 탈락에 제 경험을 어떻게 설득력 있게 연결하고 포장해야 할지 막막해요.",
          "작년부터 수십 곳에 떨어졌는데, 제가 쓴 자소서가 질문 의도와 소재 면에서 적절한지 평가받고 싶어요.",
          "대외활동이나 교내활동이 적어서 자소서에 갈등, 도전, 성공 경험을 어떻게 채워야 할지 어려워요." ] },
        { cat:'스펙 부족 불안', items:[
          "전공 학점이 3점대 초반으로 낮은 편인데, 이 성적으로 대기업 신입 입사가 가능할지 궁금해요.",
          "스펙과 인턴 경험이 다소 부족한데, 더 보완해서 내년에 지원할지 지금 당장 지원해 볼지 고민입니다.",
          "대외 활동이나 인턴 경험이 없는데, 국비 지원 교육이나 부트캠프를 듣는 것이 도움이 될까요?" ] },
        { cat:'면접 준비 전략', items:[
          "예상치 못한 질문에 말이 길어지고, 한 번의 실수로 면접 자신감이 크게 떨어지는데 어떻게 고치죠?",
          "제 이력서와 자소서를 바탕으로, 면접관 입장에서 나올 만한 꼬리 질문과 예상 질문을 뽑아주세요.",
          "석사 졸업 논문과 공동 연구 프로젝트 중 어떤 것을 선택해 발표해야 기술적 어필에 좋을까요?" ] } ] },
    '2': { tag:'이직 준비',
      placeholder:'예: 현재 중소기업에서 2년째 잡무성 업무만 맡아 물경력 불안감이 큽니다. 반도체 산업군 중고신입이나 경력직 이직을 고려 중인데, 이 짧은 연차를 어떻게 포지셔닝해야 할지 고민입니다.',
      cats:[
        { cat:'경력/산업 전환', items:[
          "제조업을 다니고 있는데 더 비전이 좋은 반도체 산업으로 이직할 때 어떤 경력을 강조해야 할까요?",
          "품질관리(QC)에서 전망이 좋은 품질보증(QA)이나 연구기획 직무로 넘어가려면 무엇을 준비해야 하나요?",
          "문과 출신 영업관리 직무인데, 데이터 기술을 훈련해 서비스 기획이나 PM 분야로 확장하고 싶어요." ] },
        { cat:'물경력/연봉 불만', items:[
          "팀에서 잡무만 맡고 있어 물경력이 될까 두려운데, 일찍 다른 곳으로 이직하는 게 맞을까요?",
          "중소기업에서 잡무로 4년을 채웠는데, 연봉을 크게 올릴 수 있도록 대기업 신입/중고신입 이직이 가능할까요?",
          "현 직장의 워라밸은 만족스럽지만 연봉과 자기계발 측면 불만으로 사기업 이직을 고민 중입니다." ] },
        { cat:'포지셔닝 고민', items:[
          "경력이 3년 넘는데 중고신입은 나이로 잘리는 느낌이고, 경력직은 장비 지식이 부족해 고민입니다.",
          "전 회사에서 6개월, 이직 후 2개월 일하다 퇴사했는데 이 짧은 경력을 이력서에 안 쓰는 게 나을까요?",
          "경력이라기엔 애매한 1년 6개월 연차인데, 신입 지원 시 이 경력과 공백기를 어떻게 설명해야 할까요?" ] },
        { cat:'퇴사 사유 방어', items:[
          "4~5개월 단위로 이직을 세 번 하게 되었는데, 면접관에게 단점으로만 보일까 봐 걱정됩니다.",
          "직장 내 괴롭힘과 강한 업무 강도로 퇴사했는데, 면접에서 퇴사 사유를 솔직하게 말해도 될까요?",
          "계약 기간 만료로 퇴사 후 다른 경험을 해보고 싶어 지원했다고 답변해도 될지 방어 전략이 궁금합니다." ] } ] },
    '3': { tag:'재취업',
      placeholder:'예: 육아로 인해 5년간 경력이 단절된 상태입니다. 과거 제약회사에서 근무했던 경력을 살려 복귀하고 싶지만, 30대 후반이라는 나이와 공백기 때문에 자존감이 많이 떨어져서 현실적인 조언을 원합니다.',
      cats:[
        { cat:'공백기 소명', items:[
          "시험 준비 때문에 3년간 경력 단절이 되었는데, 이 공백기를 자소서에 적극적으로 어필해도 될까요?",
          "건강 문제로 6년을 쉬고 소기업에 있는데, 이 긴 공백을 안고 대기업 반도체 업계로 복귀가 가능할까요?",
          "퇴사 후 1년 반 동안의 공무원 준비 기간을 '실무 역량을 강화한 시간'으로 설득력 있게 전달하고 싶어요." ] },
        { cat:'나이/자존감 저하', items:[
          "나이 많은 학사 여성이자 경단녀라 지원조차 두려운데, 현재 제 상황에서 재취업이 가능할까요?",
          "AI, 디지털 전환 등 최신 트렌드에 뒤처진 느낌이 들고, 40대가 다 되어가니 자신감이 많이 떨어집니다.",
          "30대 중반이라 재취업이 쉽지 않은 나이인데, 새로운 분야로 국비 교육을 받고 재취업이 가능할지 궁금해요." ] },
        { cat:'과거 경력 활용', items:[
          "제약 QA 부서 7년 경력 후 육아 퇴사했는데, 나이 상관없이 전문성을 가질 유망 직종 전환이 가능할까요?",
          "과거 병원 연구실과 제약사 학술 지원 12년 경력을 살리려면 어떤 부분을 드러내야 플러스가 될까요?",
          "신호처리 전공 후 8년 경단인데, 과거 전공을 살려 데이터 분석이나 AI 분야로 진출할 루트가 있을까요?" ] },
        { cat:'일·가정 양립', items:[
          "초등 자녀가 있어서 현실적으로 아이 하교 전까지만 유연하게 일할 수 있는 직장을 구하고 싶어요.",
          "7년을 쉬다가 다시 일을 시작하게 되었는데, 일과 육아, 집안일의 밸런스를 잡기가 두렵고 막막합니다.",
          "출퇴근 거리가 가장 중요해서 집 근처 연구단지 내로만 제한하면 취업 성공 확률이 많이 낮아질까요?" ] } ] },
    '4': { tag:'경력 성장',
      placeholder:'예: 학사 출신으로 연구직 수년 차가 되니 커리어 성장에 한계가 느껴져 대학원 진학을 고민 중입니다. 또한, 최근 후배들이 들어오면서 중간 관리자로서의 리더십과 성과 어필 방식에 대해서도 조언을 얻고 싶습니다.',
      cats:[
        { cat:'대학원/커리어 확장', items:[
          "학사 연구직으로서 승진과 전문성에 한계를 느끼는데, 국내 박사나 해외 석사를 시작하는 게 도움 될까요?",
          "중소기업 재직 중 박사를 취득했는데, 학위 취득 후 더 나은 연구 환경으로 이직하려면 어떻게 어필하죠?",
          "MBA 학위를 살려 기획/전략으로 잡 포지셔닝을 하고 싶은데, 연구직에서 이직한 사례가 흔한가요?" ] },
        { cat:'사내 소통/갈등', items:[
          "최근 이직해 PM을 맡았는데 말주변이 없다 보니 과제 참여자들과 소통하는 것이 너무 힘들고 스트레스예요.",
          "나이 어린 선임자나 학생들과 원만하게 잘 지내고 싶은데, 대인관계 소통 비법이 있을까요?",
          "상사의 잦은 화풀이와 수직적인 문화 때문에 위축되는데, 직장 내 스트레스를 어떻게 이겨내야 할까요?" ] },
        { cat:'중간 관리자 리더십', items:[
          "사수들의 휴직으로 갑자기 리더를 맡게 되었는데, 타 팀과의 소통이나 피플 매니지먼트 팁이 궁금해요.",
          "후임들이 들어오면서 실무와 멀어지고 제 역할이 모호해졌는데, 어떤 포지셔닝을 가져야 할까요?",
          "업무 성과는 좋은데 지식이 부족한 팀원들을 이끌 때 자꾸 언성을 높이게 되어 리더 자질이 고민입니다." ] },
        { cat:'직무 순환/성과 PR', items:[
          "임원으로부터 자기 PR을 좀 하라는 말을 들었는데, 회사 내에서 제 성과를 효과적으로 포장하는 방법은요?",
          "기존 업무 외에 사내 전략기획이나 사업개발 부서로 직무 이동(Job Rotation)을 하고 싶은데 방법이 있을까요?",
          "자발적으로 컴플라이언스 리서치를 하고 있으나 왜 하냐는 반응을 얻는데, 사내 성과 설득 공유법이 궁금해요." ] } ] }
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

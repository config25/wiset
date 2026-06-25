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
  <title>04 경력개발 목표 · W브릿지 AI 커리어 코칭</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
  <style>
    .gsel { width:100%; padding:13px 14px; border:1px solid var(--line); border-radius:8px; font-size:14px; color:var(--ink); background:#fff; font-family:inherit; cursor:pointer; }
  </style>
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

    <div style="max-width:880px; margin:16px auto 0;">
      <div class="text-center">
        <span class="badge badge-brand mb-12" style="letter-spacing:0.1em;">STEP 3 / 5</span>
        <h1 class="display mt-12 mb-8">경력개발 목표를 설정해 주세요</h1>
        <p class="body-lg mb-24">목표가 구체적일수록 AI의 역량 격차 분석과 액션 플랜이 정교해집니다.</p>
      </div>

      <div class="card" style="padding:32px;">

        <%-- 1·2 희망 업종 / 직무 --%>
        <div class="row gap-24">
          <div class="flex-1">
            <div class="row items-center gap-8" style="margin-bottom:14px;">
              <span style="width:22px; height:22px; border-radius:50%; background:var(--brand); color:#fff; display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; flex-shrink:0;">1</span>
              <label class="label" style="margin-bottom:0;">희망 업종<span class="req"> *</span></label>
            </div>
            <select id="industry" class="gsel">
              <option value="" selected>선택</option>
              <option>바이오·생명공학</option><option>제약</option><option>의료기기</option><option>화학·소재</option><option>식품</option><option>IT·SW</option><option>반도체</option><option>기타</option>
            </select>
          </div>
          <div class="flex-1">
            <div class="row items-center gap-8" style="margin-bottom:14px;">
              <span style="width:22px; height:22px; border-radius:50%; background:var(--brand); color:#fff; display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; flex-shrink:0;">2</span>
              <label class="label" style="margin-bottom:0;">희망 직무<span class="req"> *</span></label>
            </div>
            <select id="job" class="gsel">
              <option value="" selected>선택</option>
              <option>R&D 연구원</option><option>품질관리(QC)</option><option>공정개발</option><option>임상개발</option><option>인허가(RA)</option><option>기술마케팅</option><option>사업개발(BD)</option><option>기타</option>
            </select>
          </div>
        </div>

        <%-- 3 희망 근무지 --%>
        <div style="margin-top:28px;">
          <div class="row items-center gap-8" style="margin-bottom:14px;">
            <span style="width:22px; height:22px; border-radius:50%; background:var(--brand); color:#fff; display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; flex-shrink:0;">3</span>
            <label class="label" style="margin-bottom:0;">희망 근무지 <span class="caption" style="font-weight:400;">(복수 선택)</span><span class="req"> *</span></label>
          </div>
          <div class="row gap-12" style="max-width:460px;">
            <select id="region1" class="gsel" style="flex:1;"></select>
            <select id="region2" class="gsel" style="flex:1;"></select>
            <button type="button" id="regionAdd" class="btn btn-ghost" style="flex-shrink:0; padding:0 18px;">추가 <wb:icon-ds name="plus" size="13" color="#6A4C9C" /></button>
          </div>
          <div class="row gap-8 flex-wrap" id="regionChips" style="margin-top:12px;"></div>
        </div>

        <%-- 4 희망 고용 형태 --%>
        <div style="margin-top:28px;">
          <div class="row items-center gap-8" style="margin-bottom:14px;">
            <span style="width:22px; height:22px; border-radius:50%; background:var(--brand); color:#fff; display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; flex-shrink:0;">4</span>
            <label class="label" style="margin-bottom:0;">희망 고용 형태 <span class="caption" style="font-weight:400;">(복수 선택)</span></label>
          </div>
          <div class="row gap-8 flex-wrap" id="empRow"></div>
        </div>

        <%-- 5 타겟 공고 --%>
        <div style="margin-top:28px;">
          <div class="row items-center justify-between mb-10">
            <div class="row items-center gap-8">
              <span style="width:22px; height:22px; border-radius:50%; background:var(--brand); color:#fff; display:flex; align-items:center; justify-content:center; font-size:12px; font-weight:700; flex-shrink:0;">5</span>
              <label class="label" style="margin-bottom:0;">타겟 공고 선택</label>
            </div>
            <span class="caption">선택 <b class="t-brand" id="pickCount">0</b> / 3</span>
          </div>
          <div class="caption mb-12" style="margin-left:30px;">스크랩한 채용공고에서 타겟을 선택하세요 (최대 3개)</div>
          <div class="col gap-10" id="targetList"></div>
          <div class="caption text-center mt-12" id="scrapTotal" style="color:var(--ink-400);"></div>
        </div>

      </div>
    </div>

    <div class="row justify-between" style="max-width:880px; margin:32px auto 0;">
      <button type="button" class="btn btn-ghost btn-pill" id="prevBtn">이전 단계</button>
      <button type="button" class="btn btn-brand btn-pill btn-lg" id="nextBtn">다음 단계 <wb:icon-ds name="arrow" size="15" color="#fff" /></button>
    </div>

  </div>

  <%@ include file="common/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  var $ = function (id) { return document.getElementById(id); };
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function svg(p,sz,c,sw){ return '<svg width="'+sz+'" height="'+sz+'" viewBox="0 0 24 24" fill="none" stroke="'+(c||'currentColor')+'" stroke-width="'+(sw||1.7)+'" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">'+p+'</svg>'; }
  var P = { x:'<path d="M6 6l12 12M18 6L6 18"/>', check:'<path d="M4.5 12.5l4.5 4.5L19.5 6.5"/>' };

  // ---------- 희망 근무지 ----------
  var sido = ['강원','경기','경남','경북','광주','대구','대전','부산','서울','울산','인천','전남','전북','제주','충남','충북','세종','전국','해외'];
  var GUGUN = {
    '강원':['전체','춘천시','원주시','강릉시','동해시','태백시','속초시','삼척시','홍천군','횡성군','영월군','평창군','정선군','철원군','화천군','양구군','인제군','고성군','양양군'],
    '경기':['전체','수원시','성남시','의정부시','안양시','부천시','광명시','평택시','동두천시','안산시','고양시','과천시','구리시','남양주시','오산시','시흥시','군포시','의왕시','하남시','용인시','파주시','이천시','안성시','김포시','화성시','광주시','양주시','포천시','여주시','연천군','가평군','양평군'],
    '경남':['전체','창원시','진주시','통영시','사천시','김해시','밀양시','거제시','양산시','의령군','함안군','창녕군','고성군','남해군','하동군','산청군','함양군','거창군','합천군'],
    '경북':['전체','포항시','경주시','김천시','안동시','구미시','영주시','영천시','상주시','문경시','경산시','의성군','청송군','영양군','영덕군','청도군','고령군','성주군','칠곡군','예천군','봉화군','울진군','울릉군'],
    '광주':['전체','동구','서구','남구','북구','광산구'],
    '대구':['전체','중구','동구','서구','남구','북구','수성구','달서구','달성군','군위군'],
    '대전':['전체','동구','중구','서구','유성구','대덕구'],
    '부산':['전체','중구','서구','동구','영도구','부산진구','동래구','남구','북구','해운대구','사하구','금정구','강서구','연제구','수영구','사상구','기장군'],
    '서울':['전체','종로구','중구','용산구','성동구','광진구','동대문구','중랑구','성북구','강북구','도봉구','노원구','은평구','서대문구','마포구','양천구','강서구','구로구','금천구','영등포구','동작구','관악구','서초구','강남구','송파구','강동구'],
    '울산':['전체','중구','남구','동구','북구','울주군'],
    '인천':['전체','중구','동구','미추홀구','연수구','남동구','부평구','계양구','서구','강화군','옹진군'],
    '전남':['전체','목포시','여수시','순천시','나주시','광양시','담양군','곡성군','구례군','고흥군','보성군','화순군','장흥군','강진군','해남군','영암군','무안군','함평군','영광군','장성군','완도군','진도군','신안군'],
    '전북':['전체','전주시','군산시','익산시','정읍시','남원시','김제시','완주군','진안군','무주군','장수군','임실군','순창군','고창군','부안군'],
    '제주':['전체','제주시','서귀포시'],
    '충남':['전체','천안시','공주시','보령시','아산시','서산시','논산시','계룡시','당진시','금산군','부여군','서천군','청양군','홍성군','예산군','태안군','연기군'],
    '충북':['전체','청주시','충주시','제천시','보은군','옥천군','영동군','증평군','진천군','괴산군','음성군','단양군'],
    '세종':['전체'], '전국':['전국'], '해외':['해외']
  };
  var regions = [];   // 희망 근무지: DB(sys_user_desired_region)에서 로드

  function fillSido(){ $('region1').innerHTML = sido.map(function(s){ return '<option'+(s==='서울'?' selected':'')+'>'+s+'</option>'; }).join(''); }
  function fillGugun(sel){ var g = GUGUN[$('region1').value] || ['전체']; $('region2').innerHTML = g.map(function(o){ return '<option'+(o===sel?' selected':'')+'>'+o+'</option>'; }).join(''); }
  function regionLabel(){ var r1=$('region1').value; if(r1==='전국'||r1==='해외') return r1; return r1+' '+$('region2').value; }
  function renderChips(){
    var el=$('regionChips'); el.innerHTML='';
    regions.forEach(function(r){
      var s=document.createElement('span'); s.className='row items-center gap-6';
      s.style.cssText='padding:7px 8px 7px 14px; border-radius:999px; background:var(--brand-50); color:var(--brand); font-size:13px; font-weight:600; white-space:nowrap;';
      s.innerHTML=esc(r)+'<span data-rm style="cursor:pointer; display:inline-flex; width:18px; height:18px; border-radius:50%; align-items:center; justify-content:center; background:rgba(106,76,156,0.12);">'+svg(P.x,11,'#6A4C9C')+'</span>';
      s.querySelector('[data-rm]').addEventListener('click', function(){ regions=regions.filter(function(x){return x!==r;}); renderChips(); });
      el.appendChild(s);
    });
  }
  $('region1').addEventListener('change', function(){ fillGugun(); });
  $('regionAdd').addEventListener('click', function(){ var l=regionLabel(); if(regions.indexOf(l)<0){ regions.push(l); renderChips(); } });

  // ---------- 희망 고용 형태 ----------
  var empTypes = ['정규직','계약직','파견근로','대체인력','시간제','프리랜서','인턴직','무기계약직'];
  var emp = [];   // 희망 고용형태: DB(sys_user_type)에서 로드, 없으면 미선택
  function renderEmp(){
    var el=$('empRow'); el.innerHTML='';
    empTypes.forEach(function(t){
      var on=emp.indexOf(t)>=0;
      var b=document.createElement('button'); b.type='button'; b.textContent=t;
      b.style.cssText='padding:11px 22px; border-radius:999px; font-size:13.5px; cursor:pointer; border:1.5px solid '+(on?'var(--brand)':'var(--line)')+'; background:'+(on?'var(--brand-50)':'#fff')+'; color:'+(on?'var(--brand)':'var(--ink-700)')+'; font-weight:'+(on?'700':'500')+';';
      b.addEventListener('click', function(){ var k=emp.indexOf(t); if(k>=0)emp.splice(k,1); else emp.push(t); renderEmp(); });
      el.appendChild(b);
    });
  }

  // ---------- 타겟 공고 ----------
  // 스크랩 공고는 서버에서 로드(조회 전용). 선택(picked)은 로컬 보관.
  var scrapped = [];
  var picked = [];
  function renderTargets(){
    var el=$('targetList'); el.innerHTML='';
    scrapped.forEach(function(j){
      var on=picked.indexOf(j.id)>=0;
      var disabled=!on && picked.length>=3;
      var row=document.createElement('div'); row.className='row items-center gap-14';
      row.style.cssText='padding:14px 16px; border-radius:12px; cursor:'+(disabled?'not-allowed':'pointer')+'; border:1.5px solid '+(on?'var(--brand)':'var(--line)')+'; background:'+(on?'var(--brand-50)':'#fff')+'; opacity:'+(disabled?'0.5':'1')+';';
      row.innerHTML=
        '<span style="width:22px; height:22px; border-radius:6px; flex-shrink:0; display:flex; align-items:center; justify-content:center; background:'+(on?'var(--brand)':'#fff')+'; border:1.5px solid '+(on?'var(--brand)':'var(--ink-300)')+';">'+(on?svg(P.check,13,'#fff'):'')+'</span>'+
        '<span style="width:44px; height:44px; border-radius:9px; flex-shrink:0; border:1px solid var(--line); background:var(--bg-soft); display:flex; align-items:center; justify-content:center; font-family:\'JetBrains Mono\',monospace; font-size:10px; color:var(--ink-400); font-weight:600;">LOGO</span>'+
        '<div style="flex:1; min-width:0;"><div class="fw-700" style="font-size:14.5px; margin-bottom:3px;">'+esc(j.title)+'</div><div class="caption">'+esc(j.meta)+'</div></div>'+
        '<div style="text-align:right; flex-shrink:0;"><div class="caption" style="font-size:11px; color:var(--ink-400);">스크랩</div><div class="caption mono fw-600" style="margin-top:2px;">'+esc(j.date)+'</div></div>';
      if(!disabled){ row.addEventListener('click', function(){ var k=picked.indexOf(j.id); if(k>=0) picked.splice(k,1); else if(picked.length<3) picked.push(j.id); renderTargets(); }); }
      el.appendChild(row);
    });
    $('pickCount').textContent = picked.length;
    $('scrapTotal').textContent = '총 '+scrapped.length+'건 스크랩 · 최근 30일 내';
  }

  // ---------- nav ----------
  function qp(n){ var m=new RegExp('[?&]'+n+'=([^&]*)').exec(location.search); return m?decodeURIComponent(m[1]):''; }
  var personaSuf = qp('persona') ? ('?persona='+encodeURIComponent(qp('persona'))) : '';
  $('prevBtn').addEventListener('click', function(){ location.href = ctx + '/current-situation' + personaSuf; });
  $('nextBtn').addEventListener('click', function(){
    // DB 저장 없이 선택값만 로컬(sessionStorage) 보관 → 최종 단계(분석 시작)에서 일괄 저장
    var data = {
      industry: $('industry').value,   // 희망 업종
      job: $('job').value,             // 희망 직무
      regions: regions,                // 희망 근무지(복수)
      employment: emp,                 // 희망 고용형태(복수)
      targets: picked                  // 타깃 공고(PBLANC_SN 배열, 최대 3)
    };
    sessionStorage.setItem('wb_careerGoal', JSON.stringify(data));
    location.href = ctx + '/concern' + personaSuf;
  });

  // ---------- init ----------
  // 복원: sessionStorage 의 이전 선택값
  var __savedTargets = null;
  var __sessionHad = false;
  (function(){ try{ var s=JSON.parse(sessionStorage.getItem('wb_careerGoal')); if(s){ __sessionHad=true;
    if(s.industry!=null) $('industry').value=s.industry;
    if(s.job!=null) $('job').value=s.job;
    if(Array.isArray(s.regions)) regions=s.regions;
    if(Array.isArray(s.employment)) emp=s.employment;
    if(Array.isArray(s.targets)) __savedTargets=s.targets;
  } }catch(e){} })();
  fillSido(); fillGugun('전체'); renderChips(); renderEmp();
  // 세션 보관값이 없으면(첫 진입) 저장된 선택값을 DB에서 로드.
  //   미저장 항목은 디폴트 유지(업종/직무=선택, 근무지=빈칩, 고용형태=미선택).
  if(!__sessionHad){
    fetch(ctx + '/api/career-goal/saved').then(function(r){ return r.ok ? r.json() : null; }).then(function(d){
      if(!d) return;
      if(d.industry) $('industry').value = d.industry;
      if(d.job) $('job').value = d.job;
      regions = d.regions || []; renderChips();
      emp = d.employment || []; renderEmp();
    }).catch(function(){});
  }
  fetch(ctx + '/api/career-goal/scraps').then(function(r){ return r.ok ? r.json() : []; }).then(function(rows){
    scrapped = rows || [];
    picked = __savedTargets != null ? __savedTargets : scrapped.filter(function(s){ return s.isTarget; }).map(function(s){ return s.id; });
    renderTargets();
  }).catch(function(){ renderTargets(); });
})();
</script>
</body>
</html>

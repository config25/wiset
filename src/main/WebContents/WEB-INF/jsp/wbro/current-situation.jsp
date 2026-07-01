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
  <title>03 현 상황 입력 · W브릿지 AI 커리어 코칭</title>
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

    <%-- Stepper (STEP 2 / 5) --%>
    <div class="row justify-center">
      <div class="stepper" style="padding:22px 0;">
        <div class="step done"><div class="step-num"><wb:icon-ds name="check" size="14" color="#fff" /></div><span>페르소나 선택</span></div>
        <div class="step-line active"></div>
        <div class="step active"><div class="step-num">2</div><span>현 상황 입력</span></div>
        <div class="step-line"></div>
        <div class="step"><div class="step-num">3</div><span>경력개발 목표</span></div>
        <div class="step-line"></div>
        <div class="step"><div class="step-num">4</div><span>세부 고민</span></div>
        <div class="step-line"></div>
        <div class="step"><div class="step-num">5</div><span>입력 데이터 확인</span></div>
      </div>
    </div>

    <div style="max-width:860px; margin:16px auto 0;">

      <div class="text-center">
        <span class="badge badge-brand mb-12" style="letter-spacing:0.1em;">STEP 2 / 5</span>
        <h1 class="display mt-12 mb-8">현재 상황을 알려주세요</h1>
        <p class="body-lg mb-24">인재정보·이력서에서 자동으로 채워졌어요. 변경이 필요한 항목만 수정하세요.</p>
      </div>

      <%-- auto-fill banner --%>
      <div class="row items-center justify-center gap-10" style="padding:16px 20px; background:var(--brand-50); border:1px solid var(--brand-200); border-radius:12px; margin-bottom:16px;">
        <wb:icon-ds name="sparkle" size="18" color="#6A4C9C" />
        <span class="fw-700" style="color:var(--brand-deep); font-size:14px;">W브릿지에서 발견한 <span class="t-brand">5개</span> 데이터 항목이 자동 입력되었습니다.</span>
      </div>

      <%-- main card --%>
      <div class="card" style="padding:28px;">
        <div class="mb-24">
          <label class="label">학력 / 전공<span class="req">*</span></label>
          <div class="col gap-8" id="eduList"></div>
          <button type="button" id="eduAdd" class="row items-center justify-center gap-6 mt-12" style="width:100%; padding:12px 0; border:1.5px dashed var(--brand-200); border-radius:10px; background:#fff; color:var(--brand); font-weight:700; cursor:pointer; font-size:13px;">학력/전공 추가하기 <wb:icon-ds name="plus" size="14" color="#6A4C9C" /></button>
        </div>

        <div class="row gap-16 mb-24">
          <div class="flex-1">
            <label class="label">신입 / 경력<span class="req">*</span></label>
            <div class="seg" id="empSeg"></div>
          </div>
          <div class="flex-1">
            <label class="label">취업우대 · 병역 <span class="caption" style="font-weight:400;">(복수 선택)</span></label>
            <div class="row gap-8" id="prefRow"></div>
          </div>
        </div>

        <div>
          <div class="row items-center gap-8 mb-8">
            <label class="label" style="margin-bottom:0;">경력 사항</label>
            <span class="caption fw-700 t-brand" id="carTotal"></span>
          </div>
          <div class="col gap-8" id="carList"></div>
          <button type="button" id="carAdd" class="row items-center justify-center gap-6 mt-12" style="width:100%; padding:12px 0; border:1.5px dashed var(--brand-200); border-radius:10px; background:#fff; color:var(--brand); font-weight:700; cursor:pointer; font-size:13px;">경력 추가하기 <wb:icon-ds name="plus" size="14" color="#6A4C9C" /></button>
        </div>
      </div>

      <%-- consulting link (1:1 커리어컨설팅 Q&A — TN_CNSL_REQST_INFO 연동) --%>
      <div class="card mt-16" style="padding:22px;">
        <label class="label">컨설팅 결과 연동</label>
        <div class="row items-center gap-12" id="cnslBanner" style="padding:14px 16px; border:1px solid var(--pink-100); border-radius:10px; background:linear-gradient(90deg, var(--pink-50) 0%, #fff 100%);">
          <wb:iconchip name="sparkle" tone="pink" size="38" icon="18" radius="9" />
          <div style="flex:1;">
            <div class="fw-700" id="cnslHead" style="font-size:13px;">컨설팅 데이터를 불러오는 중…</div>
          </div>
        </div>
      </div>

      <%-- extra info --%>
      <div class="card mt-16" style="padding:22px;">
        <div class="row items-center justify-between mb-12">
          <div class="row items-center gap-8">
            <label class="label" style="margin-bottom:0;">추가 정보 입력</label>
            <span class="badge badge-brand">총 <span class="t-brand" id="extraTotal">0</span>건 입력</span>
          </div>
          <span class="caption">입력 항목 <b class="t-brand" id="extraFilled">0</b> / 9</span>
        </div>
        <div style="display:grid; grid-template-columns:repeat(3,1fr); gap:10px;">

          <button type="button" data-modal="paper" class="row items-center justify-between gap-8" style="padding:14px; border-radius:10px; cursor:pointer; border:1.5px solid var(--line); background:#fff;">
            <span class="row items-center gap-10"><span style="width:34px; height:34px; border-radius:9px; background:var(--bg-soft); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="file" size="18" color="#6A4C9C" sw="1.8" /></span><span class="fw-600" style="font-size:12.5px; color:var(--ink);">논문/연구내역</span></span>
            <span class="badge" style="background:#FCEAEA; color:#C0392B; font-size:10px;">미입력</span>
          </button>

          <button type="button" data-modal="intern" class="row items-center justify-between gap-8" style="padding:14px; border-radius:10px; cursor:pointer; border:1.5px solid var(--line); background:#fff;">
            <span class="row items-center gap-10"><span style="width:34px; height:34px; border-radius:9px; background:var(--bg-soft); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="users" size="18" color="#6A4C9C" sw="1.8" /></span><span class="fw-600" style="font-size:12.5px; color:var(--ink);">인턴·대외활동</span></span>
            <span class="badge" style="background:#FCEAEA; color:#C0392B; font-size:10px;">미입력</span>
          </button>

          <button type="button" data-modal="edu2" class="row items-center justify-between gap-8" style="padding:14px; border-radius:10px; cursor:pointer; border:1.5px solid var(--line); background:#fff;">
            <span class="row items-center gap-10"><span style="width:34px; height:34px; border-radius:9px; background:var(--bg-soft); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="graduation" size="18" color="#6A4C9C" sw="1.8" /></span><span class="fw-600" style="font-size:12.5px; color:var(--ink);">교육이수</span></span>
            <span class="badge" style="background:#FCEAEA; color:#C0392B; font-size:10px;">미입력</span>
          </button>

          <button type="button" data-modal="cert" class="row items-center justify-between gap-8" style="padding:14px; border-radius:10px; cursor:pointer; border:1.5px solid var(--line); background:#fff;">
            <span class="row items-center gap-10"><span style="width:34px; height:34px; border-radius:9px; background:var(--bg-soft); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="award" size="18" color="#6A4C9C" sw="1.8" /></span><span class="fw-600" style="font-size:12.5px; color:var(--ink);">자격증</span></span>
            <span class="badge" style="background:#FCEAEA; color:#C0392B; font-size:10px;">미입력</span>
          </button>

          <button type="button" data-modal="award" class="row items-center justify-between gap-8" style="padding:14px; border-radius:10px; cursor:pointer; border:1.5px solid var(--line); background:#fff;">
            <span class="row items-center gap-10"><span style="width:34px; height:34px; border-radius:9px; background:var(--bg-soft); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="trophy" size="18" color="#6A4C9C" sw="1.8" /></span><span class="fw-600" style="font-size:12.5px; color:var(--ink);">수상</span></span>
            <span class="badge" style="background:#FCEAEA; color:#C0392B; font-size:10px;">미입력</span>
          </button>

          <button type="button" data-modal="overseas" class="row items-center justify-between gap-8" style="padding:14px; border-radius:10px; cursor:pointer; border:1.5px solid var(--line); background:#fff;">
            <span class="row items-center gap-10"><span style="width:34px; height:34px; border-radius:9px; background:var(--bg-soft); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="plane" size="18" color="#6A4C9C" sw="1.8" /></span><span class="fw-600" style="font-size:12.5px; color:var(--ink);">해외경험</span></span>
            <span class="badge" style="background:#FCEAEA; color:#C0392B; font-size:10px;">미입력</span>
          </button>

          <button type="button" data-modal="lang" class="row items-center justify-between gap-8" style="padding:14px; border-radius:10px; cursor:pointer; border:1.5px solid var(--line); background:#fff;">
            <span class="row items-center gap-10"><span style="width:34px; height:34px; border-radius:9px; background:var(--bg-soft); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="mic" size="18" color="#6A4C9C" sw="1.8" /></span><span class="fw-600" style="font-size:12.5px; color:var(--ink);">어학</span></span>
            <span class="badge" style="background:#FCEAEA; color:#C0392B; font-size:10px;">미입력</span>
          </button>

          <button type="button" data-modal="portfolio" class="row items-center justify-between gap-8" style="padding:14px; border-radius:10px; cursor:pointer; border:1.5px solid var(--line); background:#fff;">
            <span class="row items-center gap-10"><span style="width:34px; height:34px; border-radius:9px; background:var(--bg-soft); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="briefcase" size="18" color="#6A4C9C" sw="1.8" /></span><span class="fw-600" style="font-size:12.5px; color:var(--ink);">포트폴리오</span></span>
            <span class="badge" style="background:#FCEAEA; color:#C0392B; font-size:10px;">미입력</span>
          </button>

          <button type="button" data-modal="cover" class="row items-center justify-between gap-8" style="padding:14px; border-radius:10px; cursor:pointer; border:1.5px solid var(--line); background:#fff;">
            <span class="row items-center gap-10"><span style="width:34px; height:34px; border-radius:9px; background:var(--bg-soft); display:flex; align-items:center; justify-content:center;"><wb:icon-ds name="pen" size="18" color="#6A4C9C" sw="1.8" /></span><span class="fw-600" style="font-size:12.5px; color:var(--ink);">자기소개서</span></span>
            <span class="badge" style="background:#FCEAEA; color:#C0392B; font-size:10px;">미입력</span>
          </button>

        </div>
      </div>

    </div>

    <div class="row justify-between" style="max-width:860px; margin:32px auto 0;">
      <button type="button" class="btn btn-ghost btn-pill" id="prevBtn">이전 단계</button>
      <button type="button" class="btn btn-brand btn-pill btn-lg" id="nextBtn">다음 단계 <wb:icon-ds name="arrow" size="15" color="#fff" /></button>
    </div>

  </div>

  <%@ include file="../common-w/footer-ds.jspf" %>

</div>

<div id="modalRoot"></div>
<div id="confirmRoot"></div>

<script>
(function () {
  var ctx = '${ctx}';
  var $ = function (id) { return document.getElementById(id); };
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function svg(p,sz,c,sw){ return '<svg width="'+sz+'" height="'+sz+'" viewBox="0 0 24 24" fill="none" stroke="'+(c||'currentColor')+'" stroke-width="'+(sw||1.7)+'" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">'+p+'</svg>'; }
  var P = {
    x:'<path d="M6 6l12 12M18 6L6 18"/>',
    plus:'<path d="M12 5v14M5 12h14"/>',
    search:'<circle cx="11" cy="11" r="6.5"/><path d="M20 20l-4-4"/>',
    file:'<path d="M14 3H7a2 2 0 00-2 2v14a2 2 0 002 2h10a2 2 0 002-2V8z"/><path d="M14 3v5h5"/>',
    check:'<path d="M4.5 12.5l4.5 4.5L19.5 6.5"/>'
  };

  // ---------- api ----------
  function api(method, path, body){
    return fetch(ctx + '/api/current-situation' + path, { method:method, headers:{'Content-Type':'application/json'}, body: body!=null ? JSON.stringify(body) : undefined })
      .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.text(); })
      .then(function(t){ return t ? JSON.parse(t) : null; });
  }
  function reloadEdu(){ return api('GET','/education').then(function(l){ education = l || []; renderEdu(); }); }
  function reloadCar(){ return api('GET','/career').then(function(l){ career = l || []; renderCar(); }); }

  // 1:1 커리어컨설팅 Q&A 연동 — 건수만 표시(목록은 비노출). 실제 Q&A 는 분석 시 백엔드가 AI 입력(consultingLog)으로 조립.
  function reloadCnsl(){
    var head=$('cnslHead'), banner=$('cnslBanner');
    return fetch(ctx + '/indvdl/cnsl/selectCnslQnaList.do').then(function(r){ return r.ok? r.json():[]; }).then(function(rows){
      rows = rows || [];
      if(!rows.length){
        if(head) head.innerHTML = '연동된 1:1 커리어컨설팅 데이터가 없습니다.';
        if(banner){ banner.style.background='var(--bg-soft)'; banner.style.borderColor='var(--line)'; }
        return;
      }
      if(head) head.innerHTML = '1:1 커리어컨설팅 데이터 <span class="t-pink">'+rows.length+'건</span> 발견 — 분석 시 AI 입력에 자동 반영';
    }).catch(function(){ if(head) head.innerHTML='컨설팅 데이터를 불러오지 못했습니다.'; });
  }
  function selVal(b,n){ var v = fv(b,n); return v==='선택' ? '' : v; }

  // 추가정보: data-modal 키 ↔ API 타입, 타입 ↔ PK 필드, 뱃지 갱신
  var TYPE_BY_MODAL = { paper:'research', intern:'activity', edu2:'training', cert:'certificate', award:'award', overseas:'overseas', lang:'language' };
  var ID_KEYS = { research:'researchId', activity:'actSn', training:'edcSn', certificate:'crqfcSn', award:'wnpzSn', overseas:'ovseaSn', language:'lstcsSn' };
  // 버튼(data-modal) 하나의 채움/비움 시각 상태 토글
  function applyBadge(btn, n){
    if(!btn) return;
    var filled = n>0;
    btn.style.border = '1.5px solid '+(filled?'var(--brand)':'var(--line)');
    btn.style.background = filled?'var(--brand-50)':'#fff';
    var chip=btn.querySelector('span span'); if(chip) chip.style.background = filled?'var(--brand)':'var(--bg-soft)';
    var ico=btn.querySelector('svg'); if(ico) ico.setAttribute('stroke', filled?'#fff':'#6A4C9C');
    var b=btn.querySelector('.badge');
    if(b){ b.textContent = filled?(n+'건'):'미입력';
      b.className = 'badge'+(filled?' badge-brand-solid':'');
      b.style.cssText = filled?'font-size:10px;':'background:#FCEAEA; color:#C0392B; font-size:10px;'; }
    refreshExtraSummary();
  }
  function badgeByKey(key, n){ applyBadge(document.querySelector('[data-modal="'+key+'"]'), n); }
  function setExtraBadge(type, n){
    var key=null; for(var k in TYPE_BY_MODAL){ if(TYPE_BY_MODAL[k]===type){ key=k; break; } }
    if(key) badgeByKey(key, n);
  }
  // 요약(총 N건 / X / 9)을 현재 뱃지 상태에서 재집계
  function refreshExtraSummary(){
    var total=0, filled=0;
    Array.prototype.forEach.call(document.querySelectorAll('[data-modal] .badge'), function(b){
      var m=/^(\d+)건$/.exec((b.textContent||'').trim());
      if(m){ total += parseInt(m[1],10); filled++; }
    });
    var tEl=$('extraTotal'); if(tEl) tEl.textContent=total;
    var fEl=$('extraFilled'); if(fEl) fEl.textContent=filled;
  }
  function refreshExtraBadges(){
    Object.keys(TYPE_BY_MODAL).forEach(function(k){ var t=TYPE_BY_MODAL[k];
      api('GET','/'+t).then(function(rows){ setExtraBadge(t,(rows||[]).length); }).catch(function(){ setExtraBadge(t,0); });
    });
    // 포트폴리오(URL+파일) — TYPE_BY_MODAL 외 별도 집계
    api('GET','/portfolio').then(function(d){ badgeByKey('portfolio', ((d&&d.urls||[]).length)+((d&&d.files||[]).length)); }).catch(function(){ badgeByKey('portfolio',0); });
    // 자기소개서(텍스트 유무 + 파일)
    api('GET','/cover').then(function(d){ badgeByKey('cover', ((d&&(d.title||d.content))?1:0)+((d&&d.files||[]).length)); }).catch(function(){ badgeByKey('cover',0); });
  }
  // 경력 기간 합산용: 'YYYY.MM' -> 절대 개월수
  function ymToMonths(s){
    if(!s) return null;
    var p=String(s).replace(/[^0-9]/g,' ').trim().split(/\s+/);
    if(p.length<2) return null;
    var y=parseInt(p[0],10), m=parseInt(p[1],10);
    if(isNaN(y)||isNaN(m)) return null;
    return y*12 + m;
  }
  function refreshCarTotal(){
    var el=$('carTotal'); if(!el) return;
    var total=0;
    career.forEach(function(c){
      var s=ymToMonths(c.startYm);
      var e=c.endYm ? ymToMonths(c.endYm) : null;
      if(e==null){ var d=new Date(); e=d.getFullYear()*12+(d.getMonth()+1); } // 재직중 = 현재까지
      if(s!=null && e!=null && e>s) total += (e-s);
    });
    if(total>0){ var yy=Math.floor(total/12), mm=total%12; el.textContent='(총 '+(yy>0?yy+'년 ':'')+mm+'개월)'; }
    else { el.textContent=''; }
  }

  // ---------- state ----------
  // 학력/경력은 서버(API)에서 로드. 각 항목은 EducationDto/CareerDto 필드 그대로.
  var education = [];
  var career = [];
  var empType = '';
  var prefs = [];
  // 같은 진행 세션의 입력(앞으로 갔다 돌아온 경우)이 있으면 그것을 우선 복원
  var hasSessionSel = false;
  (function(){ try{ var s=JSON.parse(sessionStorage.getItem('wb_currentSituation')); if(s){ if(s.empType){ empType=s.empType; hasSessionSel=true; } if(Array.isArray(s.prefs)){ prefs=s.prefs; hasSessionSel=true; } } }catch(e){} })();

  var HAKLYEOK = ['전문학사','학사','석사','박사','고등학교 졸업','기타(대학 재학 등)'];
  var GRAD_STATUS = ['졸업','졸업예정','재학중','중퇴','수료'];
  var LANGS = ['선택','영어','일어','중국어','독일어','프랑스어','러시아어','이탈리아어','아랍어','태국어','스페인어','포르투갈어','베트남어','네덜란드어','힌디어','인도네시아어','몽골어','그리스어','직접입력'];
  var SPEAK = ['선택','일상 회화 가능','비즈니스 회화 가능','원어민 수준'];

  // ---------- modal shell ----------
  var modalRoot = $('modalRoot'), confirmRoot = $('confirmRoot');
  function closeModal(){ modalRoot.innerHTML=''; if(!confirmRoot.innerHTML) document.body.style.overflow=''; }
  function closeConfirm(){ confirmRoot.innerHTML=''; if(!modalRoot.innerHTML) document.body.style.overflow=''; }
  function footSave(label){ return '<button class="btn btn-ghost btn-pill" data-x>취소</button><button class="btn btn-brand btn-pill" data-x>'+label+'</button>'; }
  function field(l,req,inner){ return '<div class="wb-mfield"><label>'+l+(req?'<span class="req">*</span>':'')+'</label>'+inner+'</div>'; }
  function selH(attr,opts,sel){ return '<select class="select" '+attr+'>'+opts.map(function(o){ return '<option'+(o===sel?' selected':'')+'>'+o+'</option>'; }).join('')+'</select>'; }
  function fv(b,n){ var e=b.querySelector('[data-f="'+n+'"]'); return e? e.value.trim():''; }
  function fclear(b,names){ names.forEach(function(n){ var e=b.querySelector('[data-f="'+n+'"]'); if(e){ if(e.tagName==='SELECT') e.selectedIndex=0; else e.value=''; } }); }

  function shell(o){
    modalRoot.innerHTML =
      '<div class="wb-modal-overlay" data-ov>'+
        '<div class="wb-modal" style="max-width:'+(o.width||720)+'px" role="dialog" aria-modal="true">'+
          '<button class="wb-modal-x" data-x aria-label="닫기">'+svg(P.x,20,'#6B7078')+'</button>'+
          '<div class="wb-modal-head"><h2>'+esc(o.title)+'</h2>'+(o.sub?'<p>'+o.sub+'</p>':'')+(o.headerRight||'')+'</div>'+
          '<div class="wb-modal-body">'+o.bodyHtml+'</div>'+
          (o.footHtml?'<div class="wb-modal-foot">'+o.footHtml+'</div>':'')+
        '</div></div>';
    document.body.style.overflow='hidden';
    var ov = modalRoot.querySelector('[data-ov]');
    ov.addEventListener('mousedown', function(e){ if(e.target===ov) closeModal(); });
    Array.prototype.forEach.call(modalRoot.querySelectorAll('[data-x]'), function(b){ b.addEventListener('click', closeModal); });
    return modalRoot.querySelector('.wb-modal-body');
  }
  function confirmPopup(msg, onOk){
    confirmRoot.innerHTML =
      '<div class="wb-modal-overlay" data-cov style="z-index:240; align-items:center;">'+
        '<div class="wb-modal wb-confirm" role="alertdialog" aria-modal="true">'+
          '<div class="wb-confirm-body"><p>'+esc(msg)+'</p></div>'+
          '<div class="wb-confirm-foot"><button class="btn btn-brand btn-pill" data-ok>확인</button><button class="btn btn-ghost btn-pill" data-cc>취소</button></div>'+
        '</div></div>';
    document.body.style.overflow='hidden';
    var cov = confirmRoot.querySelector('[data-cov]');
    cov.addEventListener('mousedown', function(e){ if(e.target===cov) closeConfirm(); });
    confirmRoot.querySelector('[data-cc]').addEventListener('click', closeConfirm);
    confirmRoot.querySelector('[data-ok]').addEventListener('click', function(){ closeConfirm(); onOk && onOk(); });
  }
  function wireCheckrows(){
    Array.prototype.forEach.call(modalRoot.querySelectorAll('[data-check]'), function(el){
      el.addEventListener('click', function(){
        var on = el.classList.toggle('on');
        el.querySelector('.wb-check').innerHTML = on ? svg(P.check,12,'#fff',2.4) : '';
      });
    });
  }

  // ---------- 학력/경력 모달 ----------
  function eduModal(mode, idx){
    var edit = mode==='edit';
    var rec = edit ? (education[idx]||{}) : {};
    var hr = edit ? '<button class="btn btn-danger btn-pill btn-sm wb-modal-danger" data-danger>삭제</button>' : '';
    var body =
      '<div style="display:flex; flex-direction:column; gap:22px;">'+
        field('학력 구분',true,'<div style="max-width:260px">'+selH('data-f="se"',['선택'].concat(HAKLYEOK), rec.seLabel||'선택')+'</div>')+
        '<span class="wb-checkrow'+(rec.isFinal?' on':'')+'" data-check><span class="wb-check">'+(rec.isFinal?svg(P.check,12,'#fff',2.4):'')+'</span>최종학력으로 선택 <span class="caption" style="margin-left:2px;">(최종학력은 한 건만 선택 가능합니다)</span></span>'+
        '<div class="wb-mgrid" style="grid-template-columns:repeat(4,1fr)">'+
          field('학교명',false,'<input class="input" data-f="school" value="'+esc(rec.schoolName||'')+'" placeholder="학교명을 입력해주세요">')+
          field('입학년월',false,'<input class="input" data-f="entrance" value="'+esc(rec.entranceYm||'')+'" placeholder="2010.02">')+
          field('졸업년월',false,'<input class="input" data-f="graduation" value="'+esc(rec.graduationYm||'')+'" placeholder="2011.02">')+
          field('졸업상태',false, selH('data-f="grad"',['선택'].concat(GRAD_STATUS), rec.gradStatusLabel||'선택'))+
        '</div>'+
        '<div class="wb-mgrid" style="grid-template-columns:2fr 1fr 1fr">'+
          field('전공명<span class="req">*</span> <span class="caption" data-note="majorHint" style="display:none; font-weight:400; margin-left:4px;">(인문계 / 자연계로 작성해주시면 됩니다)</span>',false,'<input class="input" data-f="major" value="'+esc(rec.majorName||'')+'" placeholder="전공명을 입력해주세요">')+
          field('학점',false,'<input class="input" data-f="gpa" value="'+esc(rec.gpa||'')+'" placeholder="3.8">')+
          field('총점',false,'<input class="input" data-f="total" value="'+esc(rec.totalGpa||'')+'" placeholder="4.5">')+
        '</div>'+
        field('다른 전공',false,'<input class="input" data-f="minor" value="'+esc(rec.minorMajor||'')+'" placeholder="복수전공·부전공이 있다면 입력해주세요">')+
        field('졸업논문/작품',false,'<textarea class="input" rows="4" data-f="thesis" placeholder="졸업논문/작품을 요약해서 적어주세요.">'+esc(rec.thesis||'')+'</textarea>')+
      '</div>';
    var bodyEl = shell({ width:720, title: edit?'학력/전공 수정':'학력/전공 입력', sub:'* 학력 선택 후 정보를 입력하고 전공명을 등록해주세요.', headerRight:hr, bodyHtml:body, footHtml:'<button class="btn btn-ghost btn-pill" data-x>취소</button><button class="btn btn-brand btn-pill" data-save>저장</button>' });
    wireCheckrows();
    // 학력구분이 '고등학교 졸업'일 때만 전공명 안내(인문계/자연계) 노출
    (function(){
      var seSel = bodyEl.querySelector('[data-f="se"]');
      var hint = bodyEl.querySelector('[data-note="majorHint"]');
      function syncMajorHint(){ if(hint){ hint.style.display = (seSel && seSel.value==='고등학교 졸업') ? 'inline' : 'none'; } }
      if(seSel){ seSel.addEventListener('change', syncMajorHint); }
      syncMajorHint();
    })();
    modalRoot.querySelector('[data-save]').addEventListener('click', function(){
      var dto = {
        acdmcrSn: (rec.acdmcrSn!=null?rec.acdmcrSn:null),
        seLabel: selVal(bodyEl,'se'), schoolName: fv(bodyEl,'school'),
        entranceYm: fv(bodyEl,'entrance'), graduationYm: fv(bodyEl,'graduation'),
        gradStatusLabel: selVal(bodyEl,'grad'), majorName: fv(bodyEl,'major'),
        gpa: fv(bodyEl,'gpa'), totalGpa: fv(bodyEl,'total'), minorMajor: fv(bodyEl,'minor'),
        thesis: fv(bodyEl,'thesis'), isFinal: bodyEl.querySelector('[data-check]').classList.contains('on')
      };
      if(!dto.majorName){ alert('전공명을 입력해주세요.'); return; }
      api('POST','/education',dto).then(reloadEdu).then(closeModal).catch(function(e){ alert('저장 실패: '+e.message); });
    });
    if(edit) modalRoot.querySelector('[data-danger]').addEventListener('click', function(){ confirmPopup('정말로 학력/전공 정보를 삭제하시겠습니까?', function(){ api('DELETE','/education/'+rec.acdmcrSn).then(reloadEdu).then(closeModal).catch(function(e){ alert('삭제 실패: '+e.message); }); }); });
  }

  function carModal(mode, idx){
    var edit = mode==='edit';
    var rec = edit ? (career[idx]||{}) : {};
    var hr = edit ? '<button class="btn btn-danger btn-pill btn-sm wb-modal-danger" data-danger>삭제</button>' : '';
    var body =
      '<div style="display:flex; flex-direction:column; gap:22px;">'+
        '<div class="wb-mgrid" style="grid-template-columns:repeat(4,1fr)">'+
          field('회사명',false,'<input class="input" data-f="company" value="'+esc(rec.companyName||'')+'" placeholder="소속 회사명 입력">')+
          field('부서명',false,'<input class="input" data-f="dept" value="'+esc(rec.deptName||'')+'" placeholder="부서명 입력">')+
          field('입사년월',false,'<input class="input" data-f="start" value="'+esc(rec.startYm||'')+'" placeholder="0000.00">')+
          field('퇴사년월',false,'<input class="input" data-f="end" value="'+esc(rec.endYm||'')+'" placeholder="0000.00">')+
        '</div>'+
        '<div class="wb-mgrid" style="grid-template-columns:2fr 1fr 1fr">'+
          field('직급/직책',false,'<input class="input" data-f="position" value="'+esc(rec.position||'')+'" placeholder="직급/직책 입력">')+
          field('직무',false,'<input class="input" data-f="jobField" value="'+esc(rec.jobField||'')+'" placeholder="직무 입력">')+
          field('연봉',false,'<input class="input" data-f="salary" value="'+esc(rec.salary||'')+'" placeholder="원단위 입력">')+
        '</div>'+
        field('담당업무 서술',false,'<textarea class="input" rows="5" data-f="desc" placeholder="담당한 업무에 대해 자세하게 서술해주세요">'+esc(rec.jobDescription||'')+'</textarea>')+
      '</div>';
    var bodyEl = shell({ width:720, title: edit?'경력사항 수정':'경력사항 입력', sub:'* 경력사항에 대한 정보를 입력하고 \''+(edit?'저장':'추가')+'\' 버튼을 눌러주세요', headerRight:hr, bodyHtml:body, footHtml:'<button class="btn btn-ghost btn-pill" data-x>취소</button><button class="btn btn-brand btn-pill" data-save>'+(edit?'저장':'추가')+'</button>' });
    modalRoot.querySelector('[data-save]').addEventListener('click', function(){
      var dto = {
        careerSn: (rec.careerSn!=null?rec.careerSn:null),
        companyName: fv(bodyEl,'company'), deptName: fv(bodyEl,'dept'),
        startYm: fv(bodyEl,'start'), endYm: fv(bodyEl,'end'),
        position: fv(bodyEl,'position'), jobField: fv(bodyEl,'jobField'),
        salary: fv(bodyEl,'salary'), jobDescription: fv(bodyEl,'desc')
      };
      if(!dto.companyName){ alert('회사명을 입력해주세요.'); return; }
      api('POST','/career',dto).then(reloadCar).then(closeModal).catch(function(e){ alert('저장 실패: '+e.message); });
    });
    if(edit) modalRoot.querySelector('[data-danger]').addEventListener('click', function(){ confirmPopup('정말로 경력사항 정보를 삭제하시겠습니까?', function(){ api('DELETE','/career/'+rec.careerSn).then(reloadCar).then(closeModal).catch(function(e){ alert('삭제 실패: '+e.message); }); }); });
  }

  // ---------- 리스트형 모달 공용 ----------
  function listModal(cfg){
    var list = [];
    var idKey = ID_KEYS[cfg.type];
    var body = shell({ width:cfg.width||700, title:cfg.title, sub:cfg.sub, bodyHtml: cfg.form + '<div data-list style="display:flex; flex-direction:column; gap:10px; margin-top:16px;"></div>', footHtml: '<button class="btn btn-brand btn-pill" data-x>완료</button>' });
    var listEl = body.querySelector('[data-list]');
    function render(){
      listEl.innerHTML = '';
      if(!list.length){ if(cfg.empty) listEl.innerHTML = '<div class="wb-modal-empty">'+cfg.empty+'</div>'; return; }
      list.forEach(function(r,i){
        var row = document.createElement('div'); row.className='wb-rec';
        row.innerHTML = '<span style="flex:1; font-size:13.5px; color:var(--ink-700); line-height:1.5;">'+cfg.text(r)+'</span><button class="wb-rec-x" aria-label="삭제">'+svg(P.x,16,'#9AA0A8')+'</button>';
        row.querySelector('.wb-rec-x').addEventListener('click', function(){ confirmPopup('선택한 정보를 삭제하시겠습니까?', function(){
          api('DELETE','/'+cfg.type+'/'+r[idKey]).then(function(){ list.splice(i,1); render(); setExtraBadge(cfg.type, list.length); }).catch(function(e){ alert('삭제 실패: '+e.message); });
        }); });
        listEl.appendChild(row);
      });
    }
    // 추가하기 = 건별 POST (그때그때 저장)
    body.querySelector('[data-add]').addEventListener('click', function(){
      var rec=cfg.collect(body); if(rec==null) return;
      api('POST','/'+cfg.type, rec).then(function(saved){ list.push(saved); cfg.clear && cfg.clear(body); render(); setExtraBadge(cfg.type, list.length); }).catch(function(e){ alert('추가 실패: '+e.message); });
    });
    cfg.init && cfg.init(body);
    api('GET','/'+cfg.type).then(function(rows){ list = rows||[]; render(); }).catch(function(){ render(); });
  }

  function paperModal(){
    listModal({ width:680, title:'논문·연구내역 입력/수정', type:'research',
      sub:"* 논문·연구내역 정보를 입력하고 '추가하기' 버튼을 누른 뒤 '저장' 버튼을 눌러주세요.",
      empty:'추가된 논문·연구내역이 없습니다.',
      form: field('논문/연구내역',false,'<div style="display:flex; gap:10px;"><input class="input" data-f="text" style="flex:1" placeholder="논문 제목과 내용을 입력해주세요."><button class="wb-addbar" data-add style="width:auto; padding:0 22px;">추가하기 '+svg(P.plus,15,'#fff')+'</button></div>'),
      collect:function(b){ var t=fv(b,'text'); return t? {content:t} : null; },
      clear:function(b){ fclear(b,['text']); },
      text:function(r){ return esc(r.content); }
    });
  }
  function internModal(){
    listModal({ width:700, title:'인턴·대외활동 입력/수정', type:'activity',
      sub:"* 인턴·대외활동 정보를 입력하고 '추가하기' 버튼을 누른 뒤 '저장' 버튼을 눌러주세요.",
      form:'<div style="display:flex; flex-direction:column; gap:16px;"><div class="wb-mgrid" style="grid-template-columns:repeat(4,1fr)">'+
        field('구분',false, selH('data-f="kind"',['선택','인턴','아르바이트','동아리','사회활동'],'선택'))+
        field('회사/기관/단체명',false,'<input class="input" data-f="org" placeholder="회사/기관/단체명 입력">')+
        field('시작년월',false,'<input class="input" data-f="start" placeholder="0000.00">')+
        field('종료년월',false,'<input class="input" data-f="end" placeholder="0000.00">')+
      '</div>'+ field('활동내용',false,'<textarea class="input" rows="4" data-f="desc" placeholder="다양한 경험을 서술해주세요"></textarea>')+
      '<button class="wb-addbar" data-add>추가하기 '+svg(P.plus,16,'#fff')+'</button></div>',
      collect:function(b){ var kind=b.querySelector('[data-f="kind"]').value; var org=fv(b,'org'); if(org&&kind!=='선택') return {kind:kind,org:org,start:fv(b,'start'),end:fv(b,'end'),desc:fv(b,'desc')}; return null; },
      clear:function(b){ fclear(b,['kind','org','start','end','desc']); },
      text:function(r){ return '<b>'+esc(r.kind)+'</b> · '+esc(r.org)+' <span class="t-ink500">'+(r.start?esc(r.start)+' ~ '+esc(r.end):'')+'</span>'; }
    });
  }
  function eduCourseModal(){
    listModal({ width:700, title:'교육이수 입력/수정', footLabel:'추가', type:'training',
      sub:"* 교육 이수 정보를 입력하고 '추가하기' 버튼을 누른 뒤 '추가' 버튼을 눌러주세요.",
      form:'<div style="display:flex; flex-direction:column; gap:16px;"><div class="wb-mgrid" style="grid-template-columns:repeat(4,1fr)">'+
        field('교육명',false,'<input class="input" data-f="name" placeholder="교육명 입력">')+
        field('교육기관',false,'<input class="input" data-f="org" placeholder="교육기관 입력">')+
        field('시작년월',false,'<input class="input" data-f="start" placeholder="0000.00">')+
        field('종료년월',false,'<input class="input" data-f="end" placeholder="0000.00">')+
      '</div>'+ field('교육내용',false,'<textarea class="input" rows="4" data-f="desc" placeholder="교육과정에 대해 적어주세요"></textarea>')+
      '<button class="wb-addbar" data-add>추가하기 '+svg(P.plus,16,'#fff')+'</button></div>',
      collect:function(b){ var n=fv(b,'name'); if(n) return {name:n,org:fv(b,'org'),start:fv(b,'start'),end:fv(b,'end'),desc:fv(b,'desc')}; return null; },
      clear:function(b){ fclear(b,['name','org','start','end','desc']); },
      text:function(r){ return '<b>'+esc(r.name)+'</b> · '+esc(r.org)+' <span class="t-ink500">'+(r.start?esc(r.start)+' ~ '+esc(r.end):'')+'</span>'; }
    });
  }
  function certModal(){
    listModal({ width:700, title:'자격증 입력/수정', footLabel:'추가', type:'certificate',
      sub:"* 자격증 정보를 입력하고 추가 버튼을 눌러 정보를 추가한 후 '추가' 버튼을 눌러주세요.",
      form:'<div style="display:flex; flex-direction:column; gap:16px;"><div class="wb-mgrid" style="grid-template-columns:repeat(4,1fr)">'+
        field('자격증명',false,'<input class="input" data-f="name" placeholder="자격증명을 입력">')+
        field('발행처',false,'<input class="input" data-f="issuer" placeholder="발행처를 입력">')+
        field('취득일',false,'<input class="input" data-f="got" placeholder="0000.00.00">')+
        field('만기일',false,'<input class="input" data-f="exp" placeholder="0000.00.00">')+
      '</div><button class="wb-addbar" data-add>추가하기 '+svg(P.plus,16,'#fff')+'</button></div>',
      collect:function(b){ var n=fv(b,'name'); if(n) return {name:n,issuer:fv(b,'issuer'),got:fv(b,'got'),exp:fv(b,'exp')}; return null; },
      clear:function(b){ fclear(b,['name','issuer','got','exp']); },
      text:function(r){ return '<b>'+esc(r.name)+'</b> · '+esc(r.issuer)+' <span class="t-ink500">'+(r.got?'취득 '+esc(r.got):'')+'</span>'; }
    });
  }
  function awardModal(){
    listModal({ width:700, title:'수상 입력/수정', footLabel:'추가', type:'award',
      sub:"* 수상 정보를 입력하고 추가 버튼을 눌러 정보를 추가한 후 '추가' 버튼을 눌러주세요.",
      form:'<div style="display:flex; flex-direction:column; gap:16px;"><div class="wb-mgrid" style="grid-template-columns:2fr 1fr 1fr">'+
        field('수상명',false,'<input class="input" data-f="name" placeholder="수상명을 입력">')+
        field('수여기관',false,'<input class="input" data-f="org" placeholder="수여기관을 입력">')+
        field('수상년도',false,'<input class="input" data-f="year" placeholder="0000">')+
      '</div>'+ field('수상내용 및 결과',false,'<textarea class="input" rows="4" data-f="desc" placeholder="수상 내용 및 결과를 입력해주세요"></textarea>')+
      '<button class="wb-addbar" data-add>추가하기 '+svg(P.plus,16,'#fff')+'</button></div>',
      collect:function(b){ var n=fv(b,'name'); if(n) return {name:n,org:fv(b,'org'),year:fv(b,'year'),desc:fv(b,'desc')}; return null; },
      clear:function(b){ fclear(b,['name','org','year','desc']); },
      text:function(r){ return '<b>'+esc(r.name)+'</b> · '+esc(r.org)+' <span class="t-ink500">'+esc(r.year)+'</span>'; }
    });
  }
  function overseasModal(){
    listModal({ width:700, title:'해외경험 입력/수정', footLabel:'추가', type:'overseas',
      sub:"* 해외경험 정보를 입력하고 추가 버튼을 눌러 정보를 추가한 후 '추가' 버튼을 눌러주세요.",
      form:'<div style="display:flex; flex-direction:column; gap:16px;"><div class="wb-mgrid" style="grid-template-columns:2fr 1fr 1fr">'+
        field('경험국가',false,'<input class="input" data-f="country" placeholder="국가명을 입력해주세요">')+
        field('시작년월',false,'<input class="input" data-f="start" placeholder="0000.00">')+
        field('종료년월',false,'<input class="input" data-f="end" placeholder="0000.00">')+
      '</div>'+ field('경험 내용',false,'<textarea class="input" rows="4" data-f="desc" placeholder="해외경험한 내용을 적어주세요(예: 어학연수, 교환학생, 워킹홀리데이, 해외근무)"></textarea>')+
      '<button class="wb-addbar" data-add>추가하기 '+svg(P.plus,16,'#fff')+'</button></div>',
      collect:function(b){ var c=fv(b,'country'); if(c) return {country:c,start:fv(b,'start'),end:fv(b,'end'),desc:fv(b,'desc')}; return null; },
      clear:function(b){ fclear(b,['country','start','end','desc']); },
      text:function(r){ return '<b>'+esc(r.country)+'</b> <span class="t-ink500">'+(r.start?esc(r.start)+' ~ '+esc(r.end):'')+'</span>'; }
    });
  }
  function langModal(){
    listModal({ width:720, title:'어학 입력/수정', footLabel:'추가', type:'language',
      sub:"* 어학 관련 정보를 입력하고 추가 버튼을 눌러 정보를 추가한 후 '추가' 버튼을 눌러주세요.",
      form:'<div style="display:flex; flex-direction:column; gap:16px;"><div class="wb-mgrid" style="grid-template-columns:repeat(3,1fr)">'+
        field('외국어명',false, selH('data-f="lang"',LANGS,'선택'))+
        field('직접 입력',false,'<input class="input" data-f="manual" placeholder="외국어명 입력" disabled style="background:var(--bg-soft)">')+
        field('회화능력',false, selH('data-f="speak"',SPEAK,'선택'))+
      '</div><div class="wb-mgrid" style="grid-template-columns:repeat(2,1fr)">'+
        field('공인시험명',false,'<input class="input" data-f="testName" placeholder="공인시험명 입력">')+
        field('공인시험점수',false,'<input class="input" data-f="testScore" placeholder="공인시험점수 입력">')+
      '</div><button class="wb-addbar" data-add>추가하기 '+svg(P.plus,16,'#fff')+'</button></div>',
      init:function(b){ var L=b.querySelector('[data-f="lang"]'), M=b.querySelector('[data-f="manual"]'); L.addEventListener('change', function(){ var on=L.value==='직접입력'; M.disabled=!on; M.style.background=on?'#fff':'var(--bg-soft)'; }); },
      collect:function(b){ var lang=b.querySelector('[data-f="lang"]').value; var tn=fv(b,'testName'); if(lang!=='선택'||tn) return {lang:lang,manual:fv(b,'manual'),speak:b.querySelector('[data-f="speak"]').value,testName:tn,testScore:fv(b,'testScore')}; return null; },
      clear:function(b){ fclear(b,['lang','manual','speak','testName','testScore']); var M=b.querySelector('[data-f="manual"]'); M.disabled=true; M.style.background='var(--bg-soft)'; },
      text:function(r){ return '<b>'+esc(r.lang==='직접입력'?r.manual:r.lang)+'</b> <span class="t-ink500">'+(r.speak!=='선택'?esc(r.speak):'')+(r.testName?' · '+esc(r.testName)+' '+esc(r.testScore):'')+'</span>'; }
    });
  }
  // 바이트 → 사람이 읽는 용량 표기
  function humanSize(bytes){
    if(bytes==null || isNaN(bytes)) return '';
    if(bytes < 1024) return bytes+'B';
    if(bytes < 1048576) return Math.round(bytes/1024)+'KB';
    return (bytes/1048576).toFixed(1)+'MB';
  }
  // URL + 파일 첨부 모달 (포트폴리오: 배치 저장).
  //   원래 UI 그대로: 좌측 'URL 추가하기'(입력칸 행 추가) / 우측 '파일 추가하기'.
  //   변경은 로컬에 모았다가 '변경사항 저장' 클릭 시 한 번에 순차 커밋:
  //     URL = 전체 교체(기존 전부 DELETE → 현재 목록 POST) / 파일 = 신규 업로드 + 삭제분 DELETE → 재조회.
  //   '취소'/닫기는 미저장 변경 폐기. (apiBase=null=자기소개서는 클라 보관만)
  function urlFileModal(title, apiBase){
    var urls=[];        // { url }  (편집 가능)
    var files=[];       // { fileSn?, n, s, file? }  (fileSn 없으면 신규 업로드 대기)
    var origUrlSns=[];  // 로드 시 기존 URL sn (저장 때 전체 삭제 후 재등록)
    var delFileSns=[];  // 삭제 예약된 기존 파일 fileSn
    var saving=false;
    var foot = apiBase
      ? '<button class="btn btn-ghost btn-pill" data-x>취소</button><button class="btn btn-brand btn-pill" data-save>변경사항 저장</button>'
      : footSave('닫기');
    var body = shell({ width:720, title:title,
      sub: apiBase ? "* URL/파일을 추가·삭제한 뒤 '변경사항 저장'을 눌러야 반영됩니다." : "* URL 또는 파일을 추가해주세요. (※ 저장 기능 준비 중)",
      bodyHtml:'<div style="display:grid; grid-template-columns:1fr 1fr; gap:20px;"><div data-urls style="display:flex; flex-direction:column; gap:12px;"></div><div data-files style="display:flex; flex-direction:column; gap:12px;"></div></div>',
      footHtml: foot });
    var ue=body.querySelector('[data-urls]'), fe=body.querySelector('[data-files]');
    var picker=document.createElement('input'); picker.type='file'; picker.multiple=true; picker.style.display='none';
    body.appendChild(picker);
    // 파일 선택 = 업로드 대기열에 적재(저장 시 업로드)
    picker.addEventListener('change', function(){
      Array.prototype.forEach.call(picker.files, function(f){ files.push({ n:f.name, s:humanSize(f.size), file:f }); });
      picker.value=''; rf();
    });
    function ru(){
      ue.innerHTML='<button class="wb-addslot" data-addurl>URL 추가하기 '+svg(P.plus,15,'#6A4C9C')+'</button>';
      urls.forEach(function(u,i){
        var d=document.createElement('div'); d.style.cssText='display:flex; align-items:center; gap:8px;';
        d.innerHTML='<input class="input" value="'+esc(u.url)+'" placeholder="https://"><button class="wb-rec-x" aria-label="삭제">'+svg(P.x,16,'#9AA0A8')+'</button>';
        d.querySelector('input').addEventListener('input', function(e){ urls[i].url=e.target.value; });
        d.querySelector('.wb-rec-x').addEventListener('click', function(){ urls.splice(i,1); ru(); });
        ue.appendChild(d);
      });
      ue.querySelector('[data-addurl]').addEventListener('click', function(){ urls.push({url:''}); ru(); });
    }
    function rf(){
      fe.innerHTML='<button class="wb-addslot" data-addfile>파일 추가하기 '+svg(P.plus,15,'#6A4C9C')+' <span class="caption" style="color:var(--ink-400); font-weight:400;">(최대 20MB)</span></button>';
      if(!files.length){ var em=document.createElement('div'); em.className='caption'; em.style.cssText='color:var(--ink-400); padding:6px 4px;'; em.textContent='첨부된 파일이 없습니다.'; fe.appendChild(em); }
      files.forEach(function(f,i){
        var d=document.createElement('div'); d.style.cssText='display:flex; align-items:center; gap:8px; padding:10px 4px;';
        var sizeHtml = f.s ? ' <span class="caption" style="font-weight:400;">('+esc(f.s)+')</span>' : '';
        var nameHtml = (apiBase && f.fileSn!=null)
          ? '<a href="'+ctx+'/api/current-situation'+apiBase+'/file/'+f.fileSn+'" style="flex:1; font-size:13.5px; color:var(--brand-deep); font-weight:600;">'+esc(f.n)+sizeHtml+'</a>'
          : '<span style="flex:1; font-size:13.5px; color:var(--brand-deep); font-weight:600;">'+esc(f.n)+sizeHtml+'</span>';
        d.innerHTML=svg(P.file,16,'#6A4C9C')+nameHtml+'<button class="wb-rec-x" aria-label="삭제">'+svg(P.x,16,'#9AA0A8')+'</button>';
        d.querySelector('.wb-rec-x').addEventListener('click', function(){ var ff=files[i]; if(ff.fileSn!=null) delFileSns.push(ff.fileSn); files.splice(i,1); rf(); });
        fe.appendChild(d);
      });
      fe.querySelector('[data-addfile]').addEventListener('click', function(){ picker.click(); });
    }
    // 순차 실행(채번 MAX+1 충돌 방지)
    function runSeq(tasks){ return tasks.reduce(function(p,t){ return p.then(t); }, Promise.resolve()); }
    function commit(){
      if(saving) return; saving=true;
      var tasks=[];
      origUrlSns.forEach(function(id){ tasks.push(function(){ return api('DELETE', apiBase+'/url/'+id); }); }); // URL 전체 교체
      urls.forEach(function(u){ var v=(u.url||'').trim(); if(v) tasks.push(function(){ return api('POST', apiBase+'/url', {url:v}); }); });
      delFileSns.forEach(function(id){ tasks.push(function(){ return api('DELETE', apiBase+'/file/'+id); }); });
      var newFiles=files.filter(function(f){ return f.file; });
      if(newFiles.length){ tasks.push(function(){ var fd=new FormData(); newFiles.forEach(function(f){ fd.append('files', f.file); }); return fetch(ctx+'/api/current-situation'+apiBase+'/files', { method:'POST', body:fd }).then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); }); }); }
      runSeq(tasks).then(function(){
        return api('GET', apiBase).then(function(d){ badgeByKey('portfolio', (((d&&d.urls)||[]).length)+(((d&&d.files)||[]).length)); });
      }).then(function(){ saving=false; closeModal(); })
        .catch(function(e){ saving=false; alert('저장 실패: '+e.message); });
    }
    if(apiBase){ var sv=modalRoot.querySelector('[data-save]'); if(sv) sv.addEventListener('click', commit); }
    // 초기 로드
    if(apiBase){
      api('GET', apiBase).then(function(d){
        var us=((d&&d.urls)||[]);
        urls=us.map(function(x){ return {url:x.url}; });
        origUrlSns=us.map(function(x){ return x.sn; });
        files=((d&&d.files)||[]).map(function(x){ return {fileSn:x.fileSn, n:x.name, s:humanSize(x.size)}; });
        ru(); rf();
      }).catch(function(){ ru(); rf(); });
    } else { ru(); rf(); }
  }

  // 자기소개서 입력/수정 (SCR-03-M): 제목 + 내용(textarea) + 파일 첨부. 배치 저장.
  //   저장 시: 제목+내용 upsert(TN_RESUME_SELF_INTRCN) + 신규 파일 업로드 + 삭제분 제거(TN_ATCH_FILE 'cover').
  function coverModal(){
    var files=[];        // { fileSn?, n, s, file? }
    var delFileSns=[];   // 삭제 예약된 기존 파일 fileSn
    var saving=false;
    var body = shell({ width:720, title:'자기소개서 입력/수정',
      sub:"* 자기소개서를 직접 입력하거나 파일을 추가한 뒤 '저장'을 눌러주세요.",
      bodyHtml:'<div style="display:flex; flex-direction:column; gap:14px;">'+
        '<input class="input" data-f="title" placeholder="자기소개서 제목을 입력해주세요">'+
        '<textarea class="input" data-f="body" rows="9" placeholder="자기소개서 내용을 입력해주세요" style="resize:vertical;"></textarea>'+
        '<button class="wb-addslot" data-addfile style="align-self:flex-start; min-width:220px;">파일 추가하기 '+svg(P.plus,15,'#6A4C9C')+'</button>'+
        '<div data-files style="display:flex; flex-direction:column; gap:4px;"></div>'+
      '</div>',
      footHtml: '<button class="btn btn-ghost btn-pill" data-x>취소</button><button class="btn btn-brand btn-pill" data-save>저장</button>' });
    var fe=body.querySelector('[data-files]');
    var titleEl=body.querySelector('[data-f="title"]'), bodyEl=body.querySelector('[data-f="body"]');
    var picker=document.createElement('input'); picker.type='file'; picker.multiple=true; picker.style.display='none';
    body.appendChild(picker);
    picker.addEventListener('change', function(){
      Array.prototype.forEach.call(picker.files, function(f){ files.push({ n:f.name, s:humanSize(f.size), file:f }); });
      picker.value=''; rf();
    });
    function rf(){
      fe.innerHTML='';
      files.forEach(function(f,i){
        var d=document.createElement('div'); d.style.cssText='display:flex; align-items:center; gap:8px; padding:8px 4px;';
        var sz = f.s ? ' <span class="caption" style="font-weight:400;">('+esc(f.s)+')</span>' : '';
        var nameHtml = (f.fileSn!=null)
          ? '<a href="'+ctx+'/api/current-situation/cover/file/'+f.fileSn+'" style="flex:1; font-size:13.5px; color:var(--brand-deep); font-weight:600;">'+esc(f.n)+sz+'</a>'
          : '<span style="flex:1; font-size:13.5px; color:var(--brand-deep); font-weight:600;">'+esc(f.n)+sz+'</span>';
        d.innerHTML=svg(P.file,16,'#6A4C9C')+nameHtml+'<button class="wb-rec-x" aria-label="삭제">'+svg(P.x,16,'#9AA0A8')+'</button>';
        d.querySelector('.wb-rec-x').addEventListener('click', function(){ var ff=files[i]; if(ff.fileSn!=null) delFileSns.push(ff.fileSn); files.splice(i,1); rf(); });
        fe.appendChild(d);
      });
    }
    function runSeq(tasks){ return tasks.reduce(function(p,t){ return p.then(t); }, Promise.resolve()); }
    function commit(){
      if(saving) return; saving=true;
      var tasks=[];
      tasks.push(function(){ return api('POST','/cover/text', { title:(titleEl.value||''), content:(bodyEl.value||'') }); });
      delFileSns.forEach(function(id){ tasks.push(function(){ return api('DELETE','/cover/file/'+id); }); });
      var nf=files.filter(function(f){ return f.file; });
      if(nf.length){ tasks.push(function(){ var fd=new FormData(); nf.forEach(function(f){ fd.append('files', f.file); }); return fetch(ctx+'/api/current-situation/cover/files', { method:'POST', body:fd }).then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.json(); }); }); }
      runSeq(tasks).then(function(){
        return api('GET','/cover').then(function(d){ var n=((d&&(d.title||d.content))?1:0)+(((d&&d.files)||[]).length); badgeByKey('cover', n); });
      }).then(function(){ saving=false; closeModal(); })
        .catch(function(e){ saving=false; alert('저장 실패: '+e.message); });
    }
    body.querySelector('[data-addfile]').addEventListener('click', function(){ picker.click(); });
    var sv=modalRoot.querySelector('[data-save]'); if(sv) sv.addEventListener('click', commit);
    // 초기 로드
    api('GET','/cover').then(function(d){
      if(d){ titleEl.value=d.title||''; bodyEl.value=d.content||''; files=((d.files)||[]).map(function(x){ return {fileSn:x.fileSn, n:x.name, s:humanSize(x.size)}; }); }
      rf();
    }).catch(function(){ rf(); });
  }

  var EXTRA_FN = { paper:paperModal, intern:internModal, edu2:eduCourseModal, cert:certModal, award:awardModal, overseas:overseasModal, lang:langModal,
    portfolio:function(){ urlFileModal('포트폴리오 입력/수정', '/portfolio'); }, cover:coverModal };

  // ---------- body renderers ----------
  function renderEdu(){
    var el=$('eduList'); el.innerHTML='';
    education.forEach(function(ed,i){
      var period = (ed.entranceYm||'') + (ed.graduationYm ? ' ~ '+ed.graduationYm : '');
      var row=document.createElement('div'); row.className='row items-center gap-12';
      row.style.cssText='padding:14px 16px; border:1px solid var(--line); border-radius:10px;';
      row.innerHTML=
        '<span class="caption fw-700 mono" style="min-width:100px; color:var(--ink-700);">'+esc(period)+'</span>'+
        '<span class="body" style="flex:1; font-size:13px;"><b>'+esc(ed.schoolName||'')+'</b><span class="t-ink500"> · '+esc(ed.majorName||'')+'</span></span>'+
        (ed.gradStatusLabel?'<span class="badge badge-blue">'+esc(ed.gradStatusLabel)+'</span>':'')+
        '<span data-edit style="cursor:pointer; display:inline-flex;">'+svg(P.search,15,'#9AA0A8')+'</span>'+
        '<span data-del style="cursor:pointer; display:inline-flex;">'+svg(P.x,15,'#9AA0A8')+'</span>';
      row.querySelector('[data-edit]').addEventListener('click', function(){ eduModal('edit',i); });
      row.querySelector('[data-del]').addEventListener('click', function(){ confirmPopup('정말로 학력/전공 정보를 삭제하시겠습니까?', function(){ api('DELETE','/education/'+ed.acdmcrSn).then(reloadEdu).catch(function(e){ alert('삭제 실패: '+e.message); }); }); });
      el.appendChild(row);
    });
  }
  function renderCar(){
    var el=$('carList'); el.innerHTML='';
    career.forEach(function(c,i){
      var period = (c.startYm||'') + (c.endYm ? ' ~ '+c.endYm : '');
      var row=document.createElement('div'); row.className='row items-center gap-12';
      row.style.cssText='padding:14px 16px; border:1px solid var(--line); border-radius:10px;';
      row.innerHTML=
        '<span class="caption fw-700 mono" style="min-width:124px; color:var(--ink-700);">'+esc(period)+'</span>'+
        '<span class="body" style="flex:1; font-size:13px;"><b>'+esc(c.companyName||'')+'</b><span class="t-ink500"> · '+esc(c.deptName||'')+' · '+esc(c.position||'')+'</span></span>'+
        (c.jobField?'<span class="badge badge-brand">'+esc(c.jobField)+'</span>':'')+
        '<span data-edit style="cursor:pointer; display:inline-flex;">'+svg(P.search,15,'#9AA0A8')+'</span>'+
        '<span data-del style="cursor:pointer; display:inline-flex;">'+svg(P.x,15,'#9AA0A8')+'</span>';
      row.querySelector('[data-edit]').addEventListener('click', function(){ carModal('edit',i); });
      row.querySelector('[data-del]').addEventListener('click', function(){ confirmPopup('정말로 경력사항 정보를 삭제하시겠습니까?', function(){ api('DELETE','/career/'+c.careerSn).then(reloadCar).catch(function(e){ alert('삭제 실패: '+e.message); }); }); });
      el.appendChild(row);
    });
    refreshCarTotal();
  }
  function renderEmp(){
    var el=$('empSeg'); el.innerHTML=''; el.style.display='flex';
    ['신입','경력'].forEach(function(t){
      var b=document.createElement('button'); b.type='button'; b.textContent=t; b.style.flex='1';
      if(empType===t) b.className='on';
      b.addEventListener('click', function(){ empType=t; renderEmp(); });
      el.appendChild(b);
    });
  }
  function renderPref(){
    var el=$('prefRow'); el.innerHTML='';
    ['보훈대상','장애','병역'].forEach(function(p){
      var on=prefs.indexOf(p)>=0;
      var b=document.createElement('button'); b.type='button'; b.textContent=p;
      b.style.cssText='flex:1; padding:10px 0; border-radius:8px; font-size:13px; cursor:pointer; background:'+(on?'var(--brand-50)':'#fff')+'; color:'+(on?'var(--brand)':'var(--ink-700)')+'; border:1.5px solid '+(on?'var(--brand)':'var(--line)')+'; font-weight:'+(on?'700':'500')+';';
      b.addEventListener('click', function(){ var k=prefs.indexOf(p); if(k>=0) prefs.splice(k,1); else prefs.push(p); renderPref(); });
      el.appendChild(b);
    });
  }

  // ---------- wiring ----------
  $('eduAdd').addEventListener('click', function(){ eduModal('add'); });
  $('carAdd').addEventListener('click', function(){ carModal('add'); });
  Array.prototype.forEach.call(document.querySelectorAll('[data-modal]'), function(b){
    b.addEventListener('click', function(){ var fn=EXTRA_FN[b.getAttribute('data-modal')]; if(fn) fn(); });
  });
  function qp(n){ var m=new RegExp('[?&]'+n+'=([^&]*)').exec(location.search); return m?decodeURIComponent(m[1]):''; }
  var personaSuf = qp('persona') ? ('?persona='+encodeURIComponent(qp('persona'))) : '';
  $('prevBtn').addEventListener('click', function(){ location.href = ctx + '/persona-select'; });
  $('nextBtn').addEventListener('click', function(){
    // 팝업분(학력/경력/추가정보)은 이미 DB 저장됨. 최종제출분만 로컬 보관 → 분석 시작서 일괄 저장
    sessionStorage.setItem('wb_currentSituation', JSON.stringify({ empType: empType, prefs: prefs }));
    location.href = ctx + '/career-goal' + personaSuf;
  });
  window.addEventListener('keydown', function(e){ if(e.key==='Escape'){ if(confirmRoot.innerHTML) closeConfirm(); else if(modalRoot.innerHTML) closeModal(); } });

  // ---------- init ----------
  renderEmp(); renderPref();
  // 진행 세션 입력이 없으면, 서버(최종제출 때 저장된 값)에서 복원. 없으면 미선택 유지.
  if(!hasSessionSel){
    api('GET','/profile-selections').then(function(d){
      if(!d) return;
      if(d.empType){ empType = d.empType; renderEmp(); }
      if(Array.isArray(d.prefs) && d.prefs.length){ prefs = d.prefs.slice(); renderPref(); }
    }).catch(function(){ /* 미로그인/신규 사용자 등 — 미선택 유지 */ });
  }
  reloadEdu().catch(function(e){ console.error('학력 로드 실패', e); });
  reloadCar().catch(function(e){ console.error('경력 로드 실패', e); });
  reloadCnsl().catch(function(e){ console.error('컨설팅 로드 실패', e); });
  refreshExtraBadges();
})();
</script>
</body>
</html>

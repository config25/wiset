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
  <title>AI 리포트 · 액션 플랜 · W브릿지</title>
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
      <span class="sep">›</span><span class="current">나의 AI 리포트</span>
    </div>
  </div>

  <%-- Report header + tabs --%>
  <div style="max-width:1100px; margin:0 auto; padding:32px 40px 0;">
    <div class="row items-center justify-between mb-16">
      <div>
        <span class="badge badge-brand mb-8">AI REPORT · 2026.04.29</span>
        <%-- TODO(통합): 사용자 이름 하드코딩(더미). W브릿지 인증 통합 시 실명 연동. 자세한 내용은 common/header.jspf 참고. --%>
        <h1 class="h2 mt-8" style="margin-bottom:3px;">김지수 님의 AI 커리어 리포트</h1>
        <div class="caption" id="reportCaption">분석 준비 중…</div>
      </div>
      <div class="row gap-8">
        <button type="button" class="btn btn-ghost btn-sm"><wb:icon-ds name="download" size="14" color="#3D4048" /> PDF 저장</button>
      </div>
    </div>
    <div class="tabs">
      <div class="tab" data-go="/ai-coaching">AI 코칭</div>
      <div class="tab" data-go="/activity-analysis">활동 분석</div>
      <div class="tab active">액션 플랜</div>
    </div>
  </div>

  <%-- Content --%>
  <div style="max-width:1100px; margin:0 auto; padding:24px 40px 60px;" id="content"></div>

  <%@ include file="common/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  // 리포트 헤더 캡션 — 신입/경력 + 희망 업종·직무 + 스크랩 수 (DB 동적). 이름은 별도.
  fetch(ctx + '/api/report/profile-summary').then(function(r){ return r.ok ? r.json() : null; }).then(function(s){
    if(s && s.caption){ var el=document.getElementById('reportCaption'); if(el) el.textContent = s.caption; }
  }).catch(function(){});
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function qp(n){ var m=new RegExp('[?&]'+n+'=([^&]*)').exec(location.search); return m?decodeURIComponent(m[1]):''; }
  var ICONS = {
    plus:'<path d="M12 5v14M5 12h14"/>', x:'<path d="M6 6l12 12M18 6L6 18"/>', check:'<path d="M4.5 12.5l4.5 4.5L19.5 6.5"/>',
    zap:'<path d="M13 3L5 13h6l-1 8 8-10h-6l1-8z"/>', book:'<path d="M4 5.5A2.5 2.5 0 016.5 3H20v15H6.5A2.5 2.5 0 004 20.5z"/><path d="M4 5.5v15"/>',
    user:'<circle cx="12" cy="8" r="4"/><path d="M4.5 20a7.5 7.5 0 0115 0"/>', file:'<path d="M14 3H7a2 2 0 00-2 2v14a2 2 0 002 2h10a2 2 0 002-2V8z"/><path d="M14 3v5h5"/>',
    chat:'<path d="M20.5 12a7.5 7.5 0 01-10.8 6.7L4 20.5l1.8-5.7A7.5 7.5 0 1120.5 12z"/>', arrow:'<path d="M4 12h15M13 5l7 7-7 7"/>'
  };
  function icon(name,size,color){ return '<svg width="'+size+'" height="'+size+'" viewBox="0 0 24 24" fill="none" stroke="'+color+'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">'+(ICONS[name]||'')+'</svg>'; }
  var TONES = { blue:['var(--blue-50)','var(--blue)'], pink:['var(--pink-50)','var(--pink)'], brand:['var(--brand-50)','var(--brand)'], green:['var(--green-50)','var(--green-deep)'], amber:['var(--amber-50)','var(--amber)'] };
  function chip(name,tone,size,ic,radius){ var t=TONES[tone]||TONES.brand; return '<span style="width:'+size+'px;height:'+size+'px;border-radius:'+radius+'px;flex-shrink:0;display:inline-flex;align-items:center;justify-content:center;background:'+t[0]+';">'+icon(name,ic,t[1])+'</span>'; }
  function toneVarOf(tone){ return tone==='green'?'var(--green-deep)':tone==='pink'?'var(--pink)':tone==='amber'?'var(--amber)':'var(--brand)'; }
  function tone50Of(tone){ return tone==='green'?'var(--green-50)':tone==='pink'?'var(--pink-50)':tone==='amber'?'var(--amber-50)':'var(--brand-50)'; }

  // ---------- 추천 활동 데이터 ----------
  var cats = [
    { key:'job', label:'채용', count:12, tone:'brand', desc:'내 역량 매칭 점수와 JD 적합률 기반의 추천 공고',
      items:[
        { src:'W브릿지', hot:true, type:'정규직', tags:['경력','석사우대'], t:'예시바이오 — R&D 연구원 (항체 정제)', region:'경기 판교', job:'바이오·제약 연구개발직', head:'2명', pay:'연봉 4,500~5,500만원', career:'경력 3년 이상', edu:'석사 이상', cta:'상세보기' },
        { src:'외부연계', type:'정규직', tags:['경력무관','학사'], t:'셀라이프사이언스 — 바이오 공정 개발 연구원', region:'인천 송도', job:'생명·자연과학 관련직', head:'1명', pay:'회사 내규에 따름', career:'경력무관', edu:'학사 이상', cta:'상세보기' },
        { src:'W브릿지', type:'정규직', tags:['경력','석사'], t:'제이앤바이오 — 분자생물학 시니어 연구원', region:'서울 강서', job:'바이오·제약 연구개발직', head:'1명', pay:'연봉 5,000~6,200만원', career:'경력 5년 이상', edu:'석사 이상', cta:'상세보기' },
        { src:'외부연계', type:'정규직', tags:['신입','대학졸'], t:'생명과학 과학기기 및 키트 교육/개발/연구 사원 채용', region:'서울 강서구', job:'생명 및 자연과학 관련직', head:'1명', pay:'연봉 3,000~4,000만원', career:'신입', edu:'대졸 이상', cta:'상세보기' } ] },
    { key:'support', label:'지원사업', count:7, tone:'brand', desc:'경력단절 예방·재취업·연구역량 강화를 위한 정부·공공 지원사업',
      items:[
        { src:'W브릿지', status:'접수중', hot:true, t:'여성과학기술인 R&D 경력복귀 지원사업', apply:'2026.04.01 ~ 05.31', period:'2026.07 ~ 2027.06 (12개월)', sub:'W브릿지 직접 운영 · 월 200만원', cta:'상세보기' },
        { src:'외부연계', status:'접수중', t:'한국연구재단 신진연구자 지원 (생애 첫 연구)', apply:'2026.05.15 ~ 06.15', period:'2026.09 ~ 2029.08 (3년)', sub:'연 5천만원 지원', cta:'상세보기' },
        { src:'W브릿지', status:'접수예정', t:'일경험·인턴 연계 사업', apply:'2026.07.01 ~ 07.20 (예정)', period:'2026.08 ~ 2026.11 (4개월)', sub:'모집 시작 시 알림 발송', cta:'상세보기' },
        { src:'외부연계', status:'마감', t:'중기부 여성기업 R&D 인력 지원', apply:'2026.02.01 ~ 03.31', period:'2026.04 ~ 2026.09 (6개월)', sub:'월 150만원 지원', cta:'상세보기' } ] },
    { key:'cohort', label:'코호트 추천', count:11, tone:'brand', desc:'비슷한 배경(석사·30대·바이오 R&D)의 사용자들이 자주 참고한 자료',
      items:[
        { src:'인기', hot:true, t:'면접 후기 · 바이오 R&D 직군 (12건)', d:'유사 배경 사용자가 자주 열람한 면접 후기 모음', cta:'상세보기' },
        { src:'추천', t:'학술 → 산업체 이력서 변환 워크북', d:'유사 배경 사용자 다수가 활용 · 무료 다운로드', cta:'상세보기' },
        { src:'추천', t:'바이오 R&D 연봉 협상 사례집 (2025)', d:'실제 협상 대화 16건 수록', cta:'상세보기' } ] }
  ];
  var gapRecs = [
    { gap:'GMP 규제 이해', score:-20, priority:'최우선', tone:'brand', keywords:['GMP 기초','SOP 작성','QC 실무','품질 시스템','GMP 자격증'] },
    { gap:'Python·R 자동화', score:-25, priority:'높음', tone:'brand', keywords:['Python 기초','pandas','Bioconductor','Jupyter','데이터 시각화'] },
    { gap:'협업·커뮤니케이션', score:-18, priority:'중간', tone:'brand', keywords:['STAR 면접 화법','비전공자 설명','협업 사례 정리','학회 발표'] }
  ];
  var planner = [
    { p:'단기', period:'1~2주', c:'var(--pink)', items:[{t:'NCS GMP 기초 교육 신청',src:'W브릿지 추천'},{t:'이력서 GMP 키워드 보강',src:'직접 입력'}] },
    { p:'중기', period:'1~2개월', c:'var(--brand)', items:[{t:'Python 데이터 분석 강좌 결제',src:'외부 추천'}] },
    { p:'장기', period:'3~6개월', c:'var(--green-deep)', items:[] }
  ];
  var survey = [4,4,5,0]; // [전체, 정확성, 도움정도, 적합성]
  var thumb = null;       // 추천 의향: 'up' | 'down' | null
  // 담은 항목은 planner[*].items 에 직접 보관(미저장은 .pending 부착, 저장됨은 .plannerId 보유)
  // 제출 저장 모델: 담기/삭제 모두 '플래너 저장' 시점에 일괄 커밋. 삭제 예정 plannerId 는 여기에 모음.
  var pendingDeletes = [];
  // 리포트 재조회 모드: ?diagnosisId 있으면 저장된 스냅샷을 읽기전용으로 렌더(라이브 편집 비활성)
  var reportMode = !!qp('diagnosisId');
  var readOnly = reportMode;
  var TERM_BY_LABEL = { '단기':{idx:0,code:'SHORT'}, '중기':{idx:1,code:'MID'}, '장기':{idx:2,code:'LONG'} };

  // ---------- 정적 섹션 ----------
  function plannerHTML(){
    var cols = planner.map(function(b, bi){
      var inner = b.items.length===0
        ? '<div class="caption text-center" style="padding:24px 0;color:var(--ink-400);">아래에서 활동을 끌어와 담아보세요</div>'
        : b.items.map(function(it, ii){ return '<div class="card" style="padding:10px;"><div class="row items-center justify-between"><span class="caption fw-700 t-ink500">'+esc(it.src)+'</span>'+(readOnly?'':'<span data-remove="'+bi+':'+ii+'" title="플래너에서 제거" style="cursor:pointer;display:inline-flex;padding:2px;margin:-2px;">'+icon('x',12,'#9AA0A8')+'</span>')+'</div><div class="fw-600 mt-4" style="font-size:13px;">'+esc(it.t)+'</div></div>'; }).join('');
      return '<div class="flex-1" style="border:1.5px dashed var(--line);border-radius:12px;padding:16px;background:#fff;min-height:180px;">'+
        '<div class="row items-center gap-8 mb-12"><span style="width:8px;height:8px;border-radius:9px;background:'+b.c+';"></span>'+
        '<span class="fw-700" style="font-size:14px;">'+esc(b.p)+'</span><span class="caption t-ink500">· '+esc(b.period)+'</span><span class="caption" style="margin-left:auto;">'+b.items.length+'건</span></div>'+
        '<div class="col gap-8">'+inner+'</div></div>';
    }).join('');
    return '<div class="card" id="plannerWrap" style="background:linear-gradient(180deg,#FAF8FD 0%,#fff 100%);">'+
      '<div class="row items-center justify-between mb-16"><div><span class="badge badge-brand mb-8">My Planner</span><div class="h2 mt-8" style="margin-bottom:4px;">나만의 액션 플래너</div><div class="caption">직접 입력하거나 아래 추천 활동에서 골라 담아보세요. 마이페이지에서 이어서 관리할 수 있습니다.</div></div>'+
      '<div class="row gap-8"><span class="badge badge-brand">담은 활동 <b>'+planner.reduce(function(s,b){return s+b.items.length;},0)+'</b></span>'+(readOnly?'':'<button type="button" class="btn btn-ghost btn-sm">초기화</button>')+'</div></div>'+
      (readOnly?'':'<div class="row gap-12 mb-16"><div class="input flex-1 row items-center gap-8">'+icon('plus',14,'#6A4C9C')+'<input id="manualTitle" style="border:none;outline:none;flex:1;font-size:14px;background:transparent;font-family:inherit;" placeholder="예: GMP 모의시험 1회 풀이 / 박사후연구원 면접 준비 등 자유롭게 입력"></div>'+
      '<select id="manualTerm" class="input" style="width:150px;font-size:14px;font-family:inherit;cursor:pointer;"><option value="SHORT">단기 (1~2주)</option><option value="MID" selected>중기 (1~2개월)</option><option value="LONG">장기 (3~6개월)</option></select>'+
      '<button type="button" id="manualAdd" class="btn btn-brand">담기</button></div>')+
      '<div class="row gap-12">'+cols+'</div>'+
      (readOnly?'':'<div class="row justify-end mt-16"><button type="button" id="plannerSave" class="btn btn-brand btn-pill">플래너 저장 '+icon('check',14,'#fff')+'</button></div>')+'</div>';
  }
  function eduHTML(){
    var cards = gapRecs.map(function(g){
      var tv = toneVarOf(g.tone), t50 = tone50Of(g.tone);
      var kw = g.keywords.map(function(k){ return '<span class="row items-center gap-6" style="padding:11px 18px;border-radius:999px;background:'+tv+';color:#fff;font-weight:700;font-size:15px;box-shadow:0 4px 12px -4px '+tv+';line-height:1;"><span style="opacity:0.7;font-weight:800;">#</span>'+esc(k)+'</span>'; }).join('');
      return '<div style="border-radius:14px;overflow:hidden;border:1px solid var(--line);display:flex;">'+
        '<div style="width:6px;background:'+tv+';flex-shrink:0;"></div>'+
        '<div style="flex:1;padding:20px 22px;">'+
          '<div class="row items-center gap-10 mb-16"><span class="badge" style="background:'+t50+';color:'+tv+';">'+esc(g.priority)+'</span><span class="fw-700" style="font-size:16px;">'+esc(g.gap)+'</span><span class="badge badge-pink">'+g.score+'</span></div>'+
          '<div class="row items-center gap-8 mb-12"><span style="font-size:11px;font-weight:800;letter-spacing:0.08em;color:'+tv+';text-transform:uppercase;">추천 키워드</span><span style="flex:1;height:1px;background:var(--line);"></span></div>'+
          '<div class="row gap-10 flex-wrap">'+kw+'</div>'+
        '</div></div>';
    }).join('');
    return '<div class="card mt-32" id="eduWrap"><div class="row items-center gap-10 mb-4">'+chip('book','brand',30,16,8)+'<div class="h2" style="margin-bottom:0;">교육 프로그램</div><span class="badge badge-brand" style="margin-left:6px;">부족 역량 기반 추천</span></div>'+
      '<div class="caption mb-16">활동 분석 3가지 부족 역량을 채울 수 있는 키워드와 활동을 모았어요</div><div class="col gap-16">'+cards+'</div></div>';
  }
  function ctaHTML(){
    return '<div class="card mt-32" style="background:var(--brand-grad);border:none;color:#fff;overflow:hidden;position:relative;">'+
      '<div style="position:absolute;right:-40px;top:-40px;width:220px;height:220px;border-radius:50%;background:rgba(255,255,255,0.08);"></div>'+
      '<div class="row items-center gap-24" style="position:relative;">'+
        '<div style="width:72px;height:72px;border-radius:18px;background:rgba(255,255,255,0.15);display:flex;align-items:center;justify-content:center;flex-shrink:0;border:1px solid rgba(255,255,255,0.25);">'+icon('chat',32,'#fff')+'</div>'+
        '<div style="flex:1;"><span class="badge mb-8" style="background:rgba(255,255,255,0.2);color:#fff;">NEXT STEP · 전문 컨설턴트와 함께</span>'+
        '<div class="h2 mb-8" style="color:#fff;margin-top:8px;">AI 추천만으로 부족하다면, 1:1 전문 컨설팅으로 이어가세요</div>'+
        /* TODO(통합): '김지수' 사용자 이름 하드코딩(더미). W브릿지 인증 통합 시 실명 연동. header.jspf 참고. */
        '<p class="body" style="color:rgba(255,255,255,0.9);font-size:14px;line-height:1.7;margin-bottom:0;">AI의 코칭 리포트를 바탕으로 전문 컨설턴트가 김지수 님의 고민을 함께 점검합니다.</p></div>'+
        '<div class="col gap-8" style="flex-shrink:0;align-items:flex-end;"><button type="button" class="btn btn-pill btn-lg" style="background:#fff;color:var(--brand);">1:1 컨설팅 신청 '+icon('arrow',15,'#6A4C9C')+'</button></div>'+
      '</div></div>';
  }
  function stars(rowIdx, val, sz){ var s=''; for(var n=1;n<=5;n++){ s+='<span data-star="'+rowIdx+':'+n+'" style="font-size:'+sz+'px;color:'+(val>=n?'var(--brand)':'var(--ink-300)')+';cursor:pointer;">★</span>'; } return s; }
  function thumbSvg(down){ return '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"'+(down?' style="transform:scaleY(-1);"':'')+'><path d="M7 10v11"/><path d="M7 10l4-7a2.2 2.2 0 0 1 3 2l-1 5h5a2 2 0 0 1 2 2.3l-1.3 6A2 2 0 0 1 17.7 21H7"/></svg>'; }
  function thumbBtn(k,label,onColor){ var on=thumb===k; return '<button type="button" data-thumb="'+k+'" class="row items-center gap-8" style="padding:11px 22px;border-radius:999px;cursor:pointer;font-size:14px;font-weight:700;background:'+(on?onColor:'#fff')+';color:'+(on?'#fff':'var(--ink-500)')+';border:1.5px solid '+(on?onColor:'var(--line)')+';">'+thumbSvg(k==='down')+label+'</button>'; }
  function thumbHTML(){
    return '<div class="row items-center justify-between mb-20" id="thumbRow" style="padding:20px 22px;border-radius:12px;background:var(--brand-50);border:1px solid var(--brand-50);">'+
      '<div><div class="fw-700 mb-4" style="font-size:15px;">이 리포트를 다른 분께 추천하시겠어요?</div><div class="caption">한 번의 클릭으로 간단히 평가해 주세요</div></div>'+
      '<div class="row gap-10">'+thumbBtn('up','좋아요','var(--brand)')+thumbBtn('down','싫어요','var(--pink)')+'</div></div>';
  }
  function surveyHTML(){
    var rows = [{q:'2. 활동 분석의 정확성',i:1},{q:'3. AI 코칭 의견의 도움 정도',i:2},{q:'4. 추천 활동의 적합성',i:3}].map(function(r){
      var v=survey[r.i];
      return '<div class="row items-center justify-between" style="padding:14px 18px;border:1px solid var(--line);border-radius:10px;background:'+(v===0?'#FFF8F2':'#fff')+';" data-srow="'+r.i+'">'+
        '<div class="row items-center gap-12"><span class="fw-600" style="font-size:14px;">'+esc(r.q)+'</span>'+(v===0?'<span class="badge badge-pink">응답 필요</span>':'')+'</div>'+
        '<div class="row gap-6" data-stars="'+r.i+'">'+stars(r.i,v,22)+'</div></div>';
    }).join('');
    return '<div class="card mt-32"><div class="row items-center justify-between mb-20"><div><span class="badge badge-brand mb-8">SURVEY</span><div class="h2 mt-8" style="margin-bottom:4px;">이번 AI 리포트, 어떠셨나요?</div><div class="caption">평가는 AI 추천 알고리즘 보정 + 다음 리포트 개선에 활용됩니다 · 약 1분 소요</div></div><span class="caption" id="surveyCount"></span></div>'+
      thumbHTML()+
      '<div style="padding:20px;background:var(--bg-soft);border-radius:12px;margin-bottom:16px;"><div class="row items-center justify-between"><div><div class="fw-700 mb-4" style="font-size:14px;">1. 전체적인 리포트의 유용함</div><div class="caption">진단 결과·컨설팅·추천 활동을 종합한 만족도</div></div><div class="row gap-6" data-stars="0">'+stars(0,survey[0],26)+'</div></div></div>'+
      '<div class="col gap-12 mb-20" id="surveyRows">'+rows+'</div>'+
      '<div class="mb-20"><div class="fw-700 mb-4" style="font-size:14px;">5. 자유 의견 <span class="caption fw-500">(선택)</span></div>'+
      '<div class="caption mb-10">리포트에서 좋았던 점이나 아쉬웠던 점, 개선 아이디어를 자유롭게 남겨 주세요.</div>'+
      '<textarea id="surveyOpinion" rows="4" class="input" style="width:100%;resize:vertical;font-family:inherit;font-size:14px;line-height:1.6;" placeholder="예) 활동 분석은 정확했지만, 추천 채용공고가 제 경력과 조금 달랐어요. 지역 조건을 더 반영해 주면 좋겠습니다."></textarea></div>'+
      '<div class="row items-center justify-between" style="padding-top:16px;border-top:1px solid var(--line);"><div class="caption row items-center gap-4">'+icon('check',12,'#6A4C9C')+' 응답은 익명 처리되며, 개인 식별 정보와 분리되어 저장됩니다.</div>'+
      '<div class="row gap-8"><button type="button" class="btn btn-ghost btn-sm">나중에</button><button type="button" id="surveySubmit" class="btn btn-brand btn-pill">평가 제출 '+icon('check',14,'#fff')+'</button></div></div></div>';
  }

  // ---------- 추천 활동 (3개 카테고리 스택) ----------
  function planBtn(pk, tv){
    if(readOnly) return ''; // 읽기전용(리포트 스냅샷)에선 담기 버튼 숨김
    var menu = [['단기','1~2주','var(--pink)'],['중기','1~2개월','var(--brand)'],['장기','3~6개월','var(--green-deep)']].map(function(o){
      return '<button type="button" class="row items-center gap-10" data-planadd="'+pk+'::'+o[0]+'" style="width:100%;padding:11px 14px;background:transparent;border:none;border-top:1px solid var(--line);cursor:pointer;font-family:inherit;text-align:left;"><span style="width:8px;height:8px;border-radius:9px;background:'+o[2]+';flex-shrink:0;"></span><span class="fw-700" style="font-size:13px;">'+o[0]+'</span><span class="caption" style="margin-left:auto;">'+o[1]+'</span></button>';
    }).join('');
    return '<div style="position:relative;" data-planwrap="'+pk+'">'+
      '<button type="button" class="btn btn-ghost btn-sm" data-planbtn="'+pk+'" data-tv="'+tv+'">+ 플래너 <span style="font-size:10px;margin-left:2px;">▾</span></button>'+
      '<div data-planmenu="'+pk+'" style="display:none;position:absolute;top:calc(100% + 6px);right:0;z-index:20;width:188px;background:#fff;border:1px solid var(--line);border-radius:10px;box-shadow:0 12px 28px -8px rgba(30,20,50,0.25);overflow:hidden;"><div class="caption fw-700 t-ink500" style="padding:10px 14px 6px;">어느 기간에 담을까요?</div>'+menu+'</div></div>';
  }
  function recsHTML(){
    var blocks = cats.map(function(c){
      var tv = toneVarOf(c.tone), tint = tone50Of(c.tone), inner;
      if(c.key==='job'){
        inner = '<div style="display:grid;grid-template-columns:repeat(2,1fr);gap:14px;padding:0 22px 20px;">'+ c.items.map(function(it,i){
          var pk=c.key+'-'+i;
          var tags = (it.tags||[]).map(function(g){ return '<span class="badge" style="background:#fff;color:'+tv+';border:1px solid '+tv+';">'+esc(g)+'</span>'; }).join('');
          var fields = [['근무지역',it.region],['직종',it.job],['모집인원',it.head],['급여',it.pay]].filter(function(f){ return f[1]; }).map(function(f){ return '<div class="row items-baseline gap-12" style="font-size:13px;"><span class="caption" style="width:56px;flex-shrink:0;color:var(--ink-500);">'+f[0]+'</span><span class="t-ink700 fw-600">'+esc(f[1])+'</span></div>'; }).join('');
          return '<div style="border:1px solid var(--line);border-radius:12px;background:#fff;display:flex;flex-direction:column;">'+
            '<div style="padding:16px 18px;flex:1;"><div class="row items-center gap-8 mb-14" style="flex-wrap:wrap;"><span class="fw-700" style="font-size:13px;color:'+tv+';">'+esc(it.type)+'</span>'+tags+(it.hot?icon('zap',14,tv):'')+(it.src?'<span class="badge badge-outline" style="margin-left:auto;">'+esc(it.src)+'</span>':'')+'</div>'+
              '<div class="fw-700 mb-16" style="font-size:18px;line-height:1.4;">'+esc(it.t)+'</div><div class="col" style="gap:9px;">'+fields+'</div></div>'+
            '<div class="row items-center gap-10" style="padding:12px 18px;border-top:1px solid var(--line);background:rgba(255,255,255,0.5);">'+
              '<button type="button" data-scrap="'+pk+'" data-tv="'+tv+'" data-tint="'+tint+'" title="스크랩" style="width:36px;height:36px;border-radius:9px;border:1px solid var(--line);background:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;flex-shrink:0;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--ink-400)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.1 8.6 22 9.3 17 14.1 18.2 21 12 17.6 5.8 21 7 14.1 2 9.3 8.9 8.6 12 2"/></svg></button>'+
              '<div style="margin-left:auto;"></div>'+planBtn(pk,tv)+'<button type="button" class="btn btn-sm" style="background:'+tv+';color:#fff;">'+esc(it.cta)+'</button></div></div>';
        }).join('')+'</div>';
      } else if(c.key==='support'){
        inner = '<div style="padding:0 22px 20px;display:flex;flex-direction:column;gap:12px;">'+ c.items.map(function(it,i){
          var pk=c.key+'-'+i;
          var st = it.status==='접수중'?{c:'var(--brand)',bg:'var(--brand-50)',bd:'var(--brand)'}:it.status==='접수예정'?{c:'var(--amber)',bg:'var(--amber-50)',bd:'var(--amber)'}:{c:'var(--ink-400)',bg:'var(--bg-soft)',bd:'var(--line)'};
          var closed = it.status==='마감';
          return '<div class="row items-center gap-20" style="border:1px solid var(--line);border-radius:10px;background:#fff;padding:16px 20px;opacity:'+(closed?'0.66':'1')+';">'+
            '<div style="flex:1.6;min-width:0;"><div class="row items-center gap-6 mb-4"><span style="font-size:12.5px;font-weight:700;color:'+tv+';">'+esc(it.src)+'</span>'+(it.hot?icon('zap',12,tv):'')+'</div><div class="fw-700" style="font-size:15.5px;line-height:1.4;">'+esc(it.t)+'</div></div>'+
            '<div class="col gap-6" style="flex:1.2;flex-shrink:0;"><div style="font-size:13px;"><span class="caption" style="color:var(--ink-500);">신청기간 : </span><span class="t-ink700 fw-600">'+esc(it.apply)+'</span></div><div style="font-size:13px;"><span class="caption" style="color:var(--ink-500);">프로그램기간 : </span><span class="t-ink700 fw-600">'+esc(it.period)+'</span></div></div>'+
            '<div class="row items-center gap-10" style="flex-shrink:0;"><span class="badge" style="background:'+st.bg+';color:'+st.c+';border:1px solid '+st.bd+';font-weight:700;padding:8px 16px;font-size:13px;">'+esc(it.status)+'</span>'+(closed?'':planBtn(pk,tv))+'</div></div>';
        }).join('')+'</div>';
      } else {
        inner = '<div style="padding:0 22px 20px;display:flex;flex-direction:column;gap:12px;">'+ c.items.map(function(it,i){
          var pk=c.key+'-'+i;
          return '<div class="row items-center gap-14" style="padding:14px 16px;border:1px solid var(--line);border-radius:10px;background:#fff;">'+
            (it.src?'<span class="badge badge-outline" style="flex-shrink:0;margin-right:6px;">'+esc(it.src)+'</span>':'')+
            '<div style="flex:1;"><div class="row items-center gap-6"><span class="fw-700" style="font-size:14px;">'+esc(it.t)+'</span>'+(it.hot?icon('zap',13,tv):'')+'</div><div class="caption mt-4">'+esc(it.d)+'</div></div>'+
            '<button type="button" class="btn btn-sm" style="background:'+tv+';color:#fff;flex-shrink:0;">'+esc(it.cta)+'</button><span style="width:6px;flex-shrink:0;"></span>'+planBtn(pk,tv)+'</div>';
        }).join('')+'</div>';
      }
      return '<div class="card" style="padding:0;overflow:visible;"><div class="row items-center gap-10" style="padding:18px 22px 14px;"><span class="fw-700" style="font-size:16px;color:'+tv+';">'+esc(c.label)+'</span><span class="caption" style="margin-left:auto;">'+esc(c.desc)+'</span></div>'+inner+'</div>';
    }).join('');
    return '<div class="mt-32" id="recsWrap"><h2 class="h2" style="margin-bottom:4px;">추천 활동</h2><div class="caption mb-16">경력 개발 목표를 달성하기 위해 추천하는 콘텐츠입니다.</div><div class="col gap-20">'+blocks+'</div></div>';
  }

  // ---------- 조립 ----------
  var html = '';
  html += '<div class="tab-intro" style="margin-bottom:20px;"><h2 class="h2" style="margin:0 0 6px;">액션 플랜</h2><p class="body" style="margin-bottom:0;">우선순위 기반 추천 활동 + 나만의 액션 플래너</p></div>';
  html += plannerHTML();
  html += recsHTML();
  html += eduHTML();
  html += ctaHTML();
  html += surveyHTML();
  document.getElementById('content').innerHTML = html;

  // 액션 플래너 + 추천 활동: 기존 테이블(sys_action_planner / sys_resource) 선연결.
  //   데이터 있으면 목업을 덮어쓰고 해당 영역만 재렌더(이벤트는 #content 위임이라 유지),
  //   비어 있으면(=AI 출력 전) 목업 유지. 리치 필드(직종·모집인원·신청기간 등)는 AI가 채우면 끼워짐.
  function loadActionPlanData(){
    fetch(ctx + '/api/action-plan/data').then(function(r){ return r.ok ? r.json() : null; }).then(function(d){
      if(!d) return;
      // 플래너 — 기간(SHORT/MID/LONG) → 단기/중기/장기. plannerId 는 닫기(삭제)용.
      var P = d.planner || {};
      if((P.SHORT||[]).length + (P.MID||[]).length + (P.LONG||[]).length > 0){
        ['SHORT','MID','LONG'].forEach(function(k, idx){
          planner[idx].items = (P[k]||[]).map(function(x){ return { t:x.title, src:x.source, plannerId:x.plannerId }; });
        });
        var pw=document.getElementById('plannerWrap'); if(pw) pw.outerHTML = plannerHTML();
      }
      // 추천 활동 — 카테고리별. DB 행 있는 카테고리만 교체(없으면 목업 유지)
      var R = d.recommendations || {};
      function payOf(x){ return (x.salaryMin && x.salaryMax)
        ? ('연봉 ' + x.salaryMin.toLocaleString() + '~' + x.salaryMax.toLocaleString() + '만원')
        : '회사 내규에 따름'; }
      var mapped = {
        job: (R.job||[]).map(function(x){ return { rid:x.resourceId, srcCode:x.sourceCode, type:'정규직', src:x.source, t:(x.org? x.org+' — ':'')+x.title, region:x.location, pay:payOf(x), cta:'상세보기' }; }),
        support: (R.support||[]).map(function(x){ return { rid:x.resourceId, srcCode:x.sourceCode, src:x.source, status:'접수중', t:x.title, apply:'상시 모집', period:x.content, cta:'상세보기' }; }),
        cohort: (R.cohort||[]).map(function(x){ return { rid:x.resourceId, srcCode:x.sourceCode, src:x.source, t:x.title, d:x.content, cta:'상세보기' }; })
      };
      var changed=false;
      cats.forEach(function(c){ if(mapped[c.key] && mapped[c.key].length){ c.items=mapped[c.key]; c.count=mapped[c.key].length; changed=true; } });
      if(changed){ var rw=document.getElementById('recsWrap'); if(rw) rw.outerHTML = recsHTML(); }
    }).catch(function(e){ console.error('action-plan 데이터 로드 실패', e); });
  }

  // 리포트 재조회 스냅샷(읽기전용) — 생성 시점의 planner+recommendations+gapRecs 를 그대로 렌더
  function loadReportSnapshot(){
    var did = qp('diagnosisId');
    fetch(ctx + '/api/action-plan/report?diagnosisId=' + encodeURIComponent(did)).then(function(r){ return r.ok ? r.json() : null; }).then(function(rep){
      var c = rep && rep.content; if(!c) return; // 스냅샷 없으면 목업 유지
      if(c.planner){
        ['SHORT','MID','LONG'].forEach(function(k, idx){ planner[idx].items = c.planner[k] || []; });
        var pw=document.getElementById('plannerWrap'); if(pw) pw.outerHTML = plannerHTML();
      }
      if(c.recommendations){
        var changed=false;
        cats.forEach(function(cat){ var arr=c.recommendations[cat.key]; if(arr){ cat.items=arr; cat.count=arr.length; changed=true; } });
        if(changed){ var rw=document.getElementById('recsWrap'); if(rw) rw.outerHTML = recsHTML(); }
      }
      if(c.gapRecs){ gapRecs=c.gapRecs; var ew=document.getElementById('eduWrap'); if(ew) ew.outerHTML = eduHTML(); }
    }).catch(function(e){ console.error('action-plan 리포트 로드 실패', e); });
  }

  if(reportMode) loadReportSnapshot(); else loadActionPlanData();

  // 추천 활동: 플래너 드롭다운 + 스크랩 토글
  function closeAllPlanMenus(){ Array.prototype.forEach.call(document.querySelectorAll('[data-planmenu]'), function(m){ m.style.display='none'; }); }
  document.getElementById('content').addEventListener('click', function(e){
    var t = e.target;
    // 직접입력 담기 — 입력값+기간을 미저장(pending)으로 추가. '플래너 저장'에서 일괄 커밋(source=MANUAL).
    var ma = t.closest && t.closest('#manualAdd');
    if(ma){
      var ti = document.getElementById('manualTitle');
      var title = ti ? ti.value.trim() : '';
      if(!title){ alert('활동 내용을 입력해주세요.'); if(ti) ti.focus(); return; }
      var sel = document.getElementById('manualTerm');
      var code = sel ? sel.value : 'MID';
      var idx = {SHORT:0,MID:1,LONG:2}[code]; if(idx==null) idx=1;
      planner[idx].items.push({ t:title, src:'직접 입력',
        pending:{ resourceId:null, customTitle:title, term:code, source:'MANUAL' } });
      var pw=document.getElementById('plannerWrap'); if(pw) pw.outerHTML = plannerHTML(); // 입력칸도 새로 그려져 비워짐
      return;
    }
    // 플래너 저장(제출/일괄) — 담기(pending)+삭제(pendingDeletes)를 한 번에 커밋. 위임이라 재렌더에도 유지.
    var ps = t.closest && t.closest('#plannerSave');
    if(ps){
      var reqs=[]; planner.forEach(function(b){ b.items.forEach(function(i){ if(i.pending) reqs.push(i.pending); }); });
      var dels = pendingDeletes.slice();
      if(!reqs.length && !dels.length){ alert('변경사항이 없습니다.'); return; }
      ps.disabled=true;
      var calls=[];
      if(reqs.length){ calls.push(fetch(ctx + '/api/action-planner/items/batch', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(reqs) })); }
      dels.forEach(function(id){ calls.push(fetch(ctx + '/api/action-planner/items/' + id, { method:'DELETE' })); });
      Promise.all(calls)
        .then(function(rs){ rs.forEach(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); }); pendingDeletes=[]; alert('저장되었습니다. (추가 '+reqs.length+'건 · 삭제 '+dels.length+'건)'); loadActionPlanData(); })
        .catch(function(err){ alert('저장 실패: '+err.message); })
        .then(function(){ ps.disabled=false; });
      return;
    }
    // 플래너 항목 닫기(X): 화면에서 제거. 저장됐던 항목이면 '삭제 예정'으로 모아 '플래너 저장' 때 함께 커밋.
    var rm = t.closest && t.closest('[data-remove]');
    if(rm){
      var rp=rm.getAttribute('data-remove').split(':'), bi=+rp[0], ii=+rp[1];
      var bucket=planner[bi]; var it=bucket && bucket.items[ii]; if(!it){ return; }
      if(it.plannerId){ pendingDeletes.push(it.plannerId); } // 저장된 항목은 저장 시 DELETE
      bucket.items.splice(ii,1);                              // 미저장 항목은 담기 취소(로컬 제거만)
      var pw=document.getElementById('plannerWrap'); if(pw) pw.outerHTML=plannerHTML();
      return;
    }
    var pb = t.closest && t.closest('[data-planbtn]');
    if(pb){ var pk=pb.getAttribute('data-planbtn'); var menu=document.querySelector('[data-planmenu="'+pk+'"]'); var openNow=(menu.style.display==='none'); closeAllPlanMenus(); if(openNow) menu.style.display='block'; e.stopPropagation(); return; }
    var pa = t.closest && t.closest('[data-planadd]');
    if(pa){
      var spec=pa.getAttribute('data-planadd').split('::');
      // pk = '<catKey>-<index>' → 추천 항목 역참조
      var dash=spec[0].lastIndexOf('-'), key=spec[0].slice(0,dash), idx=+spec[0].slice(dash+1);
      var cat=null; for(var ci=0;ci<cats.length;ci++){ if(cats[ci].key===key){ cat=cats[ci]; break; } }
      var item = cat ? cat.items[idx] : null;
      var term = TERM_BY_LABEL[spec[1]];
      if(item && term){
        // 제출 저장: 담는 순간엔 로컬에만(항목에 pending 정보 부착), '플래너 저장'에서 일괄 persist
        planner[term.idx].items.push({ t:item.t, src:item.src||'추천',
          pending:{ resourceId:item.rid||null, customTitle:item.rid?null:item.t, term:term.code, source:item.srcCode||null } });
        var pw=document.getElementById('plannerWrap'); if(pw) pw.outerHTML = plannerHTML();
      }
      // 버튼 피드백
      var wrap=document.querySelector('[data-planwrap="'+spec[0]+'"]'); var btn=wrap?wrap.querySelector('[data-planbtn]'):null;
      if(btn){ var tv=btn.getAttribute('data-tv'); btn.innerHTML='✓ '+spec[1]+' 담음 <span style="font-size:10px;margin-left:2px;">▾</span>'; btn.style.color=tv; btn.style.borderColor=tv; btn.style.fontWeight='700'; }
      closeAllPlanMenus(); e.stopPropagation(); return;
    }
    var sc = t.closest && t.closest('[data-scrap]');
    if(sc){ var poly=sc.querySelector('polygon'); var on=(sc.getAttribute('data-on')==='1'); var tv2=sc.getAttribute('data-tv'), tint=sc.getAttribute('data-tint');
      if(on){ sc.setAttribute('data-on','0'); sc.style.borderColor='var(--line)'; sc.style.background='#fff'; poly.setAttribute('fill','none'); poly.setAttribute('stroke','var(--ink-400)'); }
      else { sc.setAttribute('data-on','1'); sc.style.borderColor=tv2; sc.style.background=tint; poly.setAttribute('fill',tv2); poly.setAttribute('stroke',tv2); }
      return; }
    closeAllPlanMenus();
  });

  // 설문 별점 인터랙션
  function refreshSurveyCount(){ var done=survey.filter(function(v){return v>0;}).length; document.getElementById('surveyCount').textContent = done+' / 4 문항 응답'; }
  function rerenderStars(){
    document.querySelector('[data-stars="0"]').innerHTML = stars(0,survey[0],26);
    var rowsEl = document.getElementById('surveyRows');
    [{q:'2. 활동 분석의 정확성',i:1},{q:'3. AI 코칭 의견의 도움 정도',i:2},{q:'4. 추천 활동의 적합성',i:3}].forEach(function(r){
      var row = rowsEl.querySelector('[data-srow="'+r.i+'"]');
      var v = survey[r.i];
      row.style.background = v===0 ? '#FFF8F2' : '#fff';
      row.querySelector('.row.items-center.gap-12').innerHTML = '<span class="fw-600" style="font-size:14px;">'+esc(r.q)+'</span>'+(v===0?'<span class="badge badge-pink">응답 필요</span>':'');
      row.querySelector('[data-stars="'+r.i+'"]').innerHTML = stars(r.i,v,22);
    });
    refreshSurveyCount();
  }
  document.getElementById('content').addEventListener('click', function(e){
    var star = e.target.closest ? e.target.closest('[data-star]') : null;
    if(star){ var parts=star.getAttribute('data-star').split(':'); survey[+parts[0]] = +parts[1]; rerenderStars(); return; }
    var tb = e.target.closest ? e.target.closest('[data-thumb]') : null;
    if(tb){ var k=tb.getAttribute('data-thumb'); thumb = (thumb===k ? null : k); var row=document.getElementById('thumbRow'); if(row){ row.querySelector('.row.gap-10').innerHTML = thumbBtn('up','좋아요','var(--brand)')+thumbBtn('down','싫어요','var(--pink)'); } }
  });
  refreshSurveyCount();

  // 만족도 제출 → 별점·자유의견은 sys_ai_report_survey, 추천 의향은 sys_user_activity_log(thumbs).
  // report_id 는 AI 리포트 전이라 NULL.
  var __sb = document.getElementById('surveySubmit');
  if(__sb) __sb.addEventListener('click', function(){
    var ratings = [];
    survey.forEach(function(v,i){ if(v>0) ratings.push({ questionNo:i+1, rating:v }); });
    var opEl = document.getElementById('surveyOpinion');
    var opinion = opEl ? opEl.value.trim() : '';
    if(!ratings.length && !thumb && !opinion){ alert('별점·추천·의견 중 하나 이상 응답해주세요.'); return; }
    var payload = { recommend: thumb, ratings: ratings, opinion: opinion };
    fetch(ctx + '/api/action-plan/survey', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) })
      .then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); alert('평가가 제출되었습니다. 감사합니다!'); })
      .catch(function(e){ alert('제출 실패: '+e.message); });
  });

  // 리포트 탭 이동 (persona + diagnosisId 유지 — 특정 진단 리포트 조회 모드 보존)
  var sp=[]; if(qp('persona')) sp.push('persona='+encodeURIComponent(qp('persona'))); if(qp('diagnosisId')) sp.push('diagnosisId='+encodeURIComponent(qp('diagnosisId')));
  var suf = sp.length ? ('?'+sp.join('&')) : '';
  Array.prototype.forEach.call(document.querySelectorAll('.tab[data-go]'), function(t){
    t.addEventListener('click', function(){ location.href = ctx + t.getAttribute('data-go') + suf; });
  });
})();
</script>
</body>
</html>

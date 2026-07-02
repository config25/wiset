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
  <title>AI 리포트 · 활동 분석 · W브릿지</title>
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
      <span class="sep">›</span><span class="current">나의 AI 리포트</span>
    </div>
  </div>

  <%-- Report header + tabs --%>
  <div style="max-width:1100px; margin:0 auto; padding:32px 40px 0;">
    <div class="row items-center justify-between mb-16">
      <div>
        <span class="badge badge-brand mb-8">AI REPORT · 2026.04.29</span>
        <%-- TODO(통합): 이름("김지수")만 하드코딩 유지(인증 통합 시 연동). 아래 캡션은 DB에서 동적 로드. --%>
        <h1 class="h2 mt-8" style="margin-bottom:3px;">김지수 님의 AI 커리어 리포트</h1>
        <div class="caption" id="reportCaption">분석 준비 중…</div>
      </div>
      <div class="row gap-8">
        <button type="button" class="btn btn-ghost btn-sm"><wb:icon-ds name="download" size="14" color="#3D4048" /> PDF 저장</button>
      </div>
    </div>
    <div class="tabs">
      <div class="tab" data-go="/ai-coaching">AI 코칭</div>
      <div class="tab active">활동 분석</div>
      <div class="tab" data-go="/action-plan">액션 플랜</div>
    </div>
  </div>

  <%-- Content --%>
  <div style="max-width:1100px; margin:0 auto; padding:24px 40px 60px;" id="content"></div>

  <%@ include file="../common-w/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function qp(n){ var m=new RegExp('[?&]'+n+'=([^&]*)').exec(location.search); return m?decodeURIComponent(m[1]):''; }
  var ICONS = {
    flask:'<path d="M9 3h6M10 3v6L5 18a2 2 0 002 3h10a2 2 0 002-3l-5-9V3"/><path d="M8 14h8"/>',
    chart:'<path d="M4 20h16"/><rect x="6" y="11" width="3.2" height="6" rx="1"/><rect x="11.4" y="6" width="3.2" height="11" rx="1"/><rect x="16.8" y="13" width="3.2" height="4" rx="1"/>',
    lightbulb:'<path d="M9 18h6M10 21h4"/><path d="M12 3a6 6 0 00-3.6 10.8c.6.5 1 1.2 1.1 2H14.5c.1-.8.5-1.5 1.1-2A6 6 0 0012 3z"/>',
    code:'<path d="M8.5 8L4.5 12l4 4M15.5 8l4 4-4 4M13.5 5l-3 14"/>',
    shield:'<path d="M12 3l7 3v5c0 4.5-3 8.2-7 10-4-1.8-7-5.5-7-10V6l7-3z"/><path d="M9 12l2 2 4-4"/>',
    users:'<circle cx="9" cy="8" r="3.4"/><path d="M3.5 19a5.5 5.5 0 0111 0"/><path d="M16 5.2a3.4 3.4 0 010 6.4M17.5 13.4A5.5 5.5 0 0121 18.5"/>',
    sparkle:'<path d="M12 3l1.9 4.8L18.6 9l-4.7 1.9L12 15.6 10.1 10.9 5.4 9l4.7-1.2L12 3z"/><path d="M19 14l.7 1.8L21.5 16.5l-1.8.7L19 19l-.7-1.8L16.5 16.5l1.8-.7L19 14z"/>'
  };
  function icon(name,size,color){ return '<svg width="'+size+'" height="'+size+'" viewBox="0 0 24 24" fill="none" stroke="'+color+'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">'+(ICONS[name]||'')+'</svg>'; }
  var TONES = { blue:['var(--blue-50)','var(--blue)'], pink:['var(--pink-50)','var(--pink)'], brand:['var(--brand-50)','var(--brand)'], green:['var(--green-50)','var(--green-deep)'], amber:['var(--amber-50)','var(--amber)'] };
  function chip(name,tone,size,ic,radius){ var t=TONES[tone]||TONES.brand; return '<span style="width:'+size+'px;height:'+size+'px;border-radius:'+radius+'px;flex-shrink:0;display:inline-flex;align-items:center;justify-content:center;background:'+t[0]+';">'+icon(name,ic,t[1])+'</span>'; }
  var GRADS = { brand:'var(--brand-grad)', blue:'var(--blue-grad)', green:'var(--green-grad)', pink:'var(--pink-grad)' };
  function logoChip(initial,tone,size,radius){ return '<span style="width:'+size+'px;height:'+size+'px;border-radius:'+radius+'px;background:'+(GRADS[tone]||GRADS.brand)+';color:#fff;display:inline-flex;align-items:center;justify-content:center;font-weight:800;font-size:'+(size*0.42)+'px;flex-shrink:0;box-shadow:0 4px 12px rgba(0,0,0,0.12);">'+esc(initial)+'</span>'; }

  function ring(value,size,stroke,label,delta,unit){
    unit = unit || '%';
    var r=(size-stroke)/2, c=2*Math.PI*r, off=c*(1-value/100);
    return '<div style="position:relative;width:'+size+'px;height:'+size+'px;">'+
      '<svg width="'+size+'" height="'+size+'" style="transform:rotate(-90deg);">'+
        '<circle cx="'+(size/2)+'" cy="'+(size/2)+'" r="'+r+'" fill="none" stroke="#EAE3F3" stroke-width="'+stroke+'"/>'+
        '<circle cx="'+(size/2)+'" cy="'+(size/2)+'" r="'+r+'" fill="none" stroke="var(--brand)" stroke-width="'+stroke+'" stroke-dasharray="'+c.toFixed(1)+'" stroke-dashoffset="'+off.toFixed(1)+'" stroke-linecap="round"/>'+
      '</svg>'+
      '<div style="position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;">'+
        (label?'<div class="caption">'+esc(label)+'</div>':'')+
        '<div style="font-size:'+(size*0.24)+'px;font-weight:800;color:var(--brand);line-height:1;">'+value+'<span style="font-size:'+(size*0.12)+'px;">'+unit+'</span></div>'+
        (delta?'<div class="caption" style="color:var(--blue);font-weight:700;">'+esc(delta)+'</div>':'')+
      '</div></div>';
  }
  function radar(values,compare,labels,size){
    var cx=size/2, cy=size/2, r=size*0.36, n=values.length;
    function pts(vals){ return vals.map(function(v,i){ var a=-Math.PI/2 + i*2*Math.PI/vals.length; var rr=(v/100)*r; return [cx+rr*Math.cos(a), cy+rr*Math.sin(a)]; }); }
    function poly(vs){ return pts(vs).map(function(p){ return p[0].toFixed(1)+','+p[1].toFixed(1); }).join(' '); }
    var s='<svg width="'+size+'" height="'+size+'" viewBox="0 0 '+size+' '+size+'">';
    [0.25,0.5,0.75,1].forEach(function(sc){ s+='<polygon points="'+poly(values.map(function(){return 100*sc;}))+'" fill="none" stroke="#E6E7EB" stroke-width="1"/>'; });
    values.forEach(function(_,i){ var a=-Math.PI/2 + i*2*Math.PI/n; s+='<line x1="'+cx+'" y1="'+cy+'" x2="'+(cx+r*Math.cos(a)).toFixed(1)+'" y2="'+(cy+r*Math.sin(a)).toFixed(1)+'" stroke="#E6E7EB"/>'; });
    if(compare) s+='<polygon points="'+poly(compare)+'" fill="rgba(58,91,165,0.16)" stroke="var(--blue)" stroke-width="1.5" stroke-dasharray="4 3"/>';
    s+='<polygon points="'+poly(values)+'" fill="rgba(106,76,156,0.20)" stroke="var(--brand)" stroke-width="2.2"/>';
    pts(values).forEach(function(p){ s+='<circle cx="'+p[0].toFixed(1)+'" cy="'+p[1].toFixed(1)+'" r="4" fill="var(--brand)"/>'; });
    labels.forEach(function(l,i){ var a=-Math.PI/2 + i*2*Math.PI/n; var lx=cx+(r+22)*Math.cos(a), ly=cy+(r+22)*Math.sin(a); s+='<text x="'+lx.toFixed(1)+'" y="'+ly.toFixed(1)+'" text-anchor="middle" dy="4" font-size="11.5" font-weight="700" fill="#3D4048">'+esc(l)+'</text>'; });
    return s+'</svg>';
  }

  // ---------- 데이터 (12 AI 리포트 · 활동 분석) ----------
  var strengthsTop = [ {ic:'flask',n:'분자생물학 실험 설계',v:88}, {ic:'chart',n:'학술 데이터 분석 (R)',v:84}, {ic:'lightbulb',n:'문제 해결력',v:78} ];
  var gapsTop = [ {ic:'code',n:'Python·R 자동화',v:60,gap:'-25'}, {ic:'shield',n:'GMP 규제 이해',v:55,gap:'-20'}, {ic:'users',n:'협업·커뮤니케이션',v:62,gap:'-18'} ];
  var rows = [
    {l:'화학·바이오 산업 이해',g:'공통',v:82,avg:70,comment:'석사 연구 경험과 산업 키워드 매칭에서 화학·바이오 도메인 이해도가 높게 확인됩니다. 집단 평균(70점)을 상회하는 강점 영역입니다.',sources:[{t:'이력서',d:'산업 키워드 9회 매칭'},{t:'NCS 기준',d:'공통역량 충족'}]},
    {l:'문서 이해·작성',g:'공통',v:78,avg:72,comment:'연구 보고서·논문 작성 경험으로 문서 역량은 양호합니다. 산업 문서 양식 경험을 보강하면 더 높일 수 있습니다.',sources:[{t:'이력서',d:'보고서 산출물 다수'},{t:'WISET 역량모델',d:'공통역량 평균 이상'}]},
    {l:'정보 탐색',g:'공통',v:85,avg:74,comment:'문헌·데이터 탐색 능력이 우수합니다. 연구 과정에서 다양한 정보원을 활용한 이력이 확인됩니다.',sources:[{t:'이력서',d:'문헌 활용 다수'},{t:'진단 결과',d:'정보활용 85점'}]},
    {l:'기술·문헌자료 조사',g:'직무',v:88,avg:73,comment:'기술 문헌 조사·분석 역량이 핵심 강점입니다. 직무 수행에 즉시 활용 가능한 수준입니다.',sources:[{t:'이력서',d:'문헌조사 12회 매칭'},{t:'NCS 기준',d:'직무역량 상위'}]},
    {l:'연구·시험 데이터 정리',g:'직무',v:84,avg:71,comment:'실험·시험 데이터 정리 및 관리 경험이 풍부합니다. 데이터 기반 직무에 강점으로 작용합니다.',sources:[{t:'이력서',d:'데이터 관리 경험'},{t:'논문',d:'데이터 분석 포함'}]},
    {l:'과제·일정 지원',g:'직무',v:66,avg:68,comment:'연구 과제 수행 경험은 있으나 일정·자원 관리 측면의 주도 경험이 제한적입니다. 집단 평균(68점)에 근접하나 보완이 필요합니다.',sources:[{t:'이력서',d:'과제 참여 이력'},{t:'WISET 역량모델',d:'관리역량 보완 권고'}]},
    {l:'연구자 커뮤니케이션',g:'리더십',v:62,avg:70,comment:'개인 연구 중심 경력으로 협업·커뮤니케이션 경험이 상대적으로 적습니다. 집단 평균(70점)에 미치지 못합니다.',sources:[{t:'이력서',d:'협업 키워드 2회'},{t:'진단 결과',d:'커뮤니케이션 62점'}]},
    {l:'지원업무 개선',g:'리더십',v:58,avg:65,comment:'업무 프로세스 개선·제안 경험이 식별되지 않습니다. 리더십 영역에서 집중 보완이 필요합니다.',sources:[{t:'이력서',d:'개선 활동 0회'},{t:'WISET 역량모델',d:'리더십 보완 우선'}]}
  ];
  var lvlReq = {'기초':60,'실무':75,'심화':85};
  var ksa = [
    {area:'Knowledge',sub:'지식 요건',l:'AI·정보보안 기초 이해 역량',lvl:'기초',v:64,comment:'채용 공고에서 요구하는 AI·정보보안 기초 이해는 시장 요구(60점)를 충족하나 절대 수준은 보완 여지가 있습니다.',sources:[{t:'채용공고',d:'기초 요구 다수'},{t:'시장 동향',d:'AI 리터러시 +28%'}]},
    {area:'Knowledge',sub:'지식 요건',l:'정보보안·데이터 처리 구조 이해 역량',lvl:'기초',v:70,comment:'데이터 처리 구조에 대한 이해가 양호하며 시장 요구(60점)를 충족합니다.',sources:[{t:'채용공고',d:'데이터 처리 요구'},{t:'이력서',d:'데이터 경험 확인'}]},
    {area:'Skill',sub:'기술 요건',l:'AI 모델 개발 및 활용 역량',lvl:'심화',v:52,comment:'AI 모델 개발·활용 경험이 부족해 심화 요구(85점) 대비 격차가 큽니다. 시장 수요가 빠르게 증가하는 영역입니다.',sources:[{t:'채용공고',d:'AI 역량 심화 요구'},{t:'시장 동향',d:'AI 직무 +51%'}]},
    {area:'Skill',sub:'기술 요건',l:'Python 기반 분석·자동화 수행 역량',lvl:'실무',v:60,comment:'R 활용 경험은 있으나 Python 기반 자동화 경험이 부족해 실무 요구(75점)에 미흡합니다.',sources:[{t:'이력서',d:'Python 0회 매칭'},{t:'시장 동향',d:'Python 요구 +43%'}]},
    {area:'Skill',sub:'기술 요건',l:'데이터 파이프라인 구축 및 운영 역량',lvl:'실무',v:58,comment:'데이터 파이프라인 구축·운영 경험이 식별되지 않아 실무 요구(75점) 대비 집중 보완이 필요합니다.',sources:[{t:'채용공고',d:'파이프라인 요구'},{t:'시장 동향',d:'데이터 엔지니어링 수요↑'}]},
    {area:'Skill',sub:'기술 요건',l:'로그 데이터 분석 및 문제해결 역량',lvl:'실무',v:68,comment:'데이터 분석 기반은 갖추었으나 로그·운영 데이터 분석 경험은 부분적입니다. 실무 요구(75점)에 다소 미흡합니다.',sources:[{t:'이력서',d:'분석 경험 일부'},{t:'채용공고',d:'로그 분석 요구'}]},
    {area:'Attitude',sub:'태도 요건',l:'협업 및 커뮤니케이션 기반 업무 수행 태도',lvl:'실무',v:72,comment:'협업 태도는 양호하며 실무 요구(75점)에 근접합니다. 다부서 협업 경험을 더하면 충족 가능합니다.',sources:[{t:'진단 결과',d:'태도 72점'},{t:'채용공고',d:'협업 태도 중시'}]},
    {area:'Attitude',sub:'태도 요건',l:'지속학습 및 자기개발 태도',lvl:'기초',v:82,comment:'지속적 학습·자기개발 태도가 우수해 기초 요구(60점)를 크게 상회합니다. 면접에서 어필 가능한 강점입니다.',sources:[{t:'이력서',d:'교육 이수 다수'},{t:'진단 결과',d:'자기개발 82점'}]},
    {area:'Attitude',sub:'태도 요건',l:'주도적 문제해결 및 실행 역량',lvl:'심화',v:76,comment:'주도적 문제해결 역량이 양호하며 심화 요구(85점)에는 다소 미치지 못하나 잠재력이 확인됩니다.',sources:[{t:'진단 결과',d:'문제해결 76점'},{t:'RAG 사례',d:'유사 합격자 평균 수준'}]}
  ];
  var jds = [
    {co:'예시바이오',role:'R&D 연구원 (항체 정제)',meta:'판교 · 4,500~5,500',fit:72,match:'8 / 12',gap:['GMP 실무','Python 자동화'],rec:'추천',tone:'brand',met:['항체 정제·단백질 분석 실무 경험','석사 연구 도메인 적합도 우수','실험 설계·데이터 해석 역량'],advice:['GMP 규제 실무 교육(2주) 이수 권장','Python 기반 분석 자동화 포트폴리오 보강']},
    {co:'셀라이프사이언스',role:'바이오 공정 개발 연구원',meta:'인천 송도 · 협의',fit:65,match:'7 / 12',gap:['공정 스케일업','품질 시스템','영문 보고서'],rec:'도전',tone:'pink',met:['바이오 공정 기초 지식 보유','실험 설계·검증 역량','협업 기반 연구 수행 경험'],advice:['파일럿 규모 공정 스케일업 경험 확보','품질 시스템(QMS)·영문 보고서 작성 역량 강화']}
  ];
  // 저장 JSON 으로 덮어쓰기 가능한 분석 본문 텍스트(요약/해설). 강조(<b>)는 그대로 렌더.
  var cfiScore=72, cfiDelta='↑ 평균 +8';
  var cfiTitle='기술 전문성은 우수, 산업 응용 경험 보강이 필요합니다';
  var cfiSummary='12개 핵심 역량 중 <b>8개를 충족</b>하며, 학술 연구 역량은 집단 평균을 상회하는 상위권입니다. 다만 GMP 환경 경험과 협업 도구 숙련도에서 격차가 두드러집니다.';
  var cfiBadges=[{tone:'blue',t:'강점 · 분자생물학 실험 설계'},{tone:'blue',t:'강점 · 학술 데이터 분석'},{tone:'pink',t:'보완 · GMP 규제 이해'},{tone:'pink',t:'보완 · Python·R 자동화'}];
  var criteriaSummary='공통·직무 역량 전반이 집단 평균을 크게 상회하며, 특히 <b>문헌조사(88)·정보탐색(85)·산업이해(82)</b>에서 상위권 강점이 확인됩니다. 다만 <b>커뮤니케이션(62)·업무개선(58)</b> 등 리더십 영역은 집단 평균 수준에 머물러 보강이 필요합니다.';
  var marketSummary='태도 요건인 <b>지속학습(82)·주도성(76)·협업태도(72)</b>는 시장 요구를 충족·상회합니다. 반면 기술 요건의 <b>AI 모델링(52)·파이프라인(58)·Python 분석(60)</b>이 큰 격차를 보여 핵심 보완 과제입니다.';

  function bandFor(s){ return s>=90?{tag:'매우 우수',color:'var(--blue)',bg:'var(--blue-50)'}:s>=80?{tag:'우수',color:'var(--green-deep)',bg:'var(--green-50)'}:s>=70?{tag:'양호',color:'var(--brand)',bg:'var(--brand-50)'}:s>=60?{tag:'보완 필요',color:'var(--amber)',bg:'var(--amber-50)'}:{tag:'집중 보완 필요',color:'var(--pink)',bg:'var(--pink-50)'}; }
  function fitGroups(groups, items, markFn, markLabel){
    return groups.map(function(grp){
      var label = grp.a ? (esc(grp.a)+' <span class="t-ink500" style="font-weight:500;">· '+esc(grp.s)+'</span>') : esc(grp);
      var gi = items.filter(function(r){ return grp.a ? r.area===grp.a : r.g===grp; });
      var bars = gi.map(function(r){ var bd=bandFor(r.v), mk=markFn(r); var hasMk=(mk!=null && !isNaN(mk));
        return '<div><div class="row justify-between caption mb-4"><span class="row items-center gap-8"><span class="fw-600" style="color:var(--ink);">'+esc(r.l)+'</span><span class="badge" style="background:'+bd.bg+';color:'+bd.color+';font-size:11px;">'+bd.tag+'</span></span><span><b style="color:'+bd.color+';">'+r.v+'</b><span class="t-ink500"> / 100'+(hasMk?(' · '+markLabel+' '+mk):'')+'</span></span></div><div class="score-track"><div class="score-fill" style="width:'+r.v+'%;background:'+bd.color+';"></div>'+(hasMk?('<div class="score-mark" style="left:'+mk+'%;"></div>'):'')+'</div></div>';
      }).join('');
      return '<div><div class="row items-center gap-10 mb-10"><span class="badge badge-gray" style="font-size:11px;">'+label+'</span><span style="flex:1;height:1px;background:var(--line);"></span></div><div class="col" style="gap:16px;">'+bars+'</div></div>';
    }).join('');
  }
  // AI 역량평가(type1)는 점수만 주고 역량별 해설·근거는 미제공 → 점수 밴드로 해설을 파생해 폴백 렌더.
  function autoComment(c){
    var s=c.v, l=c.l||'해당';
    if(s>=80) return l+' 역량이 우수합니다(획득 '+s+'점). 집단 평균을 상회하는 상위권 강점으로, 직무 수행에 바로 활용 가능한 수준입니다.';
    if(s>=70) return l+' 역량은 양호합니다(획득 '+s+'점). 관련 경험을 조금 더 보강하면 확실한 강점으로 굳힐 수 있습니다.';
    if(s>=60) return l+' 역량은 보완이 필요합니다(획득 '+s+'점). 관련 학습·경험을 쌓으면 평균 이상으로 끌어올릴 여지가 있습니다.';
    return l+' 역량은 집중 보완이 필요합니다(획득 '+s+'점). 우선순위 높은 개발 과제로, 단기 학습 목표로 설정할 것을 권장합니다.';
  }
  function explainSection(sec){
    var items = sec.items.map(function(c){ var bd=bandFor(c.v);
      var cmt=(c.comment && String(c.comment).trim()!=='')?String(c.comment):autoComment(c);
      var srcs=(c.sources && c.sources.length)?c.sources:[{t:'AI 역량진단',d:'점수 산출 결과'},{t:'입력 데이터',d:'이력서·진단 기반'}];
      return '<div class="row items-stretch" style="border:1px solid var(--line);border-radius:12px;overflow:hidden;background:#fff;">'+
        '<div class="col" style="flex:0 0 200px;padding:16px;background:'+sec.tint+';border-right:1px solid '+sec.line+';justify-content:center;">'+
          '<span class="badge" style="background:'+bd.bg+';color:'+bd.color+';font-size:11px;align-self:flex-start;margin-bottom:8px;">'+bd.tag+'</span>'+
          '<span class="fw-700" style="font-size:14px;line-height:1.35;margin-bottom:8px;">'+esc(c.l)+'</span>'+
          '<span class="caption">획득 <b style="color:'+bd.color+';font-size:14px;">'+c.v+'</b> / 100</span></div>'+
        '<div style="flex:1;padding:16px 18px;">'+
              '<div style="font-size:13px;line-height:1.7;color:var(--ink-700);margin-bottom:14px;">'+esc(cmt)+'</div>'+
              '<div class="caption fw-700 mb-8 t-ink700">📎 근거 소스</div><div class="row gap-8 flex-wrap">'+
              srcs.map(function(s){ return '<span class="row items-center gap-6" style="padding:7px 12px;border:1px solid var(--line);border-radius:8px;background:#fff;font-size:12px;"><b style="color:'+sec.c+';">'+esc(s.t)+'</b><span class="t-ink500">·</span><span class="t-ink700">'+esc(s.d)+'</span></span>'; }).join('')+
              '</div>'+
          '</div></div>';
    }).join('');
    return '<div style="border:1.5px solid '+sec.line+';border-left:5px solid '+sec.c+';border-radius:14px;overflow:hidden;">'+
      '<div class="row items-center gap-12" style="padding:14px 18px;background:'+sec.tint+';border-bottom:1px solid '+sec.line+';">'+
        '<div style="width:30px;height:30px;border-radius:9px;background:'+sec.grad+';display:flex;align-items:center;justify-content:center;flex-shrink:0;">'+icon('shield',16,'#fff')+'</div>'+
        '<div style="flex:1;"><div style="font-size:15px;font-weight:800;color:'+sec.deep+';">'+esc(sec.title)+'</div><div class="caption" style="color:'+sec.c+';opacity:0.85;">'+esc(sec.sub)+'</div></div>'+
        '<span class="caption" style="color:'+sec.c+';flex-shrink:0;">역량 <b style="font-size:14px;">'+sec.items.length+'</b>개</span></div>'+
      '<div class="col gap-12" style="padding:18px;">'+items+'</div></div>';
  }

  // ---------- 렌더 ----------
  function renderReport(){
  var html = '';
  html += '<div class="tab-intro" style="margin-bottom:20px;"><h2 class="h2" style="margin:0 0 6px;">활동 분석</h2><p class="body" style="margin-bottom:0;">NCS 산업별 역량체계·WISET 역량모델과 채용 시장 정보를 기반으로 12개 핵심 역량의 현재 수준을 수치화했습니다.</p></div>';

  // SUMMARY (CFI)
  html += '<div class="hero-banner hb-violet" style="padding:28px;"><div class="hb-pattern"></div>'+
    '<div style="flex-shrink:0;position:relative;z-index:2;display:flex;flex-direction:column;align-items:center;gap:12px;">'+
      '<div class="fw-800" style="font-size:21px;color:var(--brand);letter-spacing:-0.01em;line-height:1.1;text-align:center;">경력활동지수<div style="font-size:13px;font-weight:700;color:var(--ink-500);letter-spacing:0.04em;margin-top:2px;">Career Fit Index (CFI)</div></div>'+
      ring(cfiScore,176,20,null,cfiDelta,'점')+
    '</div>'+
    '<div style="flex:1;position:relative;z-index:2;">'+
      '<div class="eyebrow mb-12">Summary</div>'+
      '<h2 class="h2 mb-12">'+esc(cfiTitle)+'</h2>'+
      '<p class="body mb-16" style="font-size:14px;">'+cfiSummary+'</p>'+
      '<div class="row gap-8 flex-wrap">'+cfiBadges.map(function(bd){ return '<span class="badge badge-'+esc(bd.tone)+'">'+esc(bd.t)+'</span>'; }).join('')+'</div>'+
    '</div></div>';

  // CFI 설명
  html += '<div class="card mt-16" style="background:var(--bg-soft);border-left:4px solid var(--brand);">'+
    '<div class="row items-center gap-8 mb-8"><div style="width:26px;height:26px;border-radius:50%;background:var(--brand-grad);display:flex;align-items:center;justify-content:center;flex-shrink:0;">'+icon('sparkle',13,'#fff')+'</div><div class="h3" style="margin-bottom:0;">CFI(Career Fit Index)란?</div></div>'+
    '<p class="body" style="font-size:13.5px;line-height:1.85;color:var(--ink-700);">경력활동지수(CFI)는 NCS 산업별 역량체계와 WISET 역량모델을 기반으로 측정한 <b class="t-brand">기준 정합도</b>와, 채용 시장 정보를 바탕으로 측정한 <b class="t-brand">시장 정합도</b>를 종합해 산출한 지표입니다. 현재 경력 활동이 얼마나 안정적으로 형성되어 있는지를 100점 만점으로 나타냅니다.</p></div>';

  // 강점 / 보완 TOP3
  var top3 = [ {title:'잘하고 있어요',tag:'강점 TOP3',items:strengthsTop,tone:'blue',barCls:'s'}, {title:'보완이 필요해요',tag:'성장포인트 TOP3',items:gapsTop,tone:'pink',barCls:'g'} ];
  html += '<div class="row gap-20 mt-24">';
  top3.forEach(function(p){
    var head = p.tone==='blue' ? 'var(--blue-50)' : 'var(--pink-50)';
    var col = p.tone==='blue' ? 'var(--blue)' : 'var(--pink)';
    html += '<div class="card flex-1" style="padding:0;overflow:hidden;"><div class="row items-center justify-between" style="padding:16px 22px;background:'+head+';"><span class="h3" style="color:'+col+';">'+esc(p.title)+'</span><span class="badge" style="background:#fff;color:'+col+';">'+esc(p.tag)+'</span></div><div class="col gap-12" style="padding:22px;">';
    p.items.forEach(function(it,i){ var vcol = p.tone==='blue' ? 'var(--blue)' : 'var(--amber)';
      html += '<div class="row items-center gap-14"><span class="mono fw-700" style="font-size:12px;color:var(--ink-400);width:18px;">'+(i+1)+'</span>'+'<div style="flex:1;"><div class="row items-center justify-between mb-6"><span class="fw-700" style="font-size:14px;">'+esc(it.n)+'</span><span class="fw-800" style="font-size:15px;color:'+vcol+';">'+it.v+(it.gap?'<span class="caption" style="color:var(--pink);margin-left:4px;">'+esc(it.gap)+'</span>':'')+'</span></div><div class="score-track"><div class="score-fill '+p.barCls+'" style="width:'+it.v+'%;"></div></div></div></div>';
    });
    html += '</div></div>';
  });
  html += '</div>';

  // 기준 정합도 분석
  html += '<div class="card mt-24"><div class="h3 mb-4">기준 정합도 분석</div>'+
    '<div class="row items-center gap-12 mb-16"><span class="caption">NCS·WISET 역량모델 활동요소 기준 · 100점 만점 획득 점수</span><span class="caption row items-center gap-5"><span style="display:inline-block;width:2px;height:13px;background:var(--ink-400);"></span>집단 평균</span></div>'+
    '<div class="row gap-32 items-center"><div class="flex-1"><div class="col" style="gap:20px;">'+
      fitGroups(['공통','직무','리더십'], rows, function(r){return r.avg;}, '집단 평균')+
    '</div></div>'+
    (rows.length>=3 ? '<div style="flex:0 0 360px;"><div class="row justify-center gap-12 caption mb-8"><span><span style="display:inline-block;width:10px;height:10px;background:var(--brand);border-radius:2px;margin-right:5px;"></span>획득 점수</span><span><span style="display:inline-block;width:10px;height:10px;background:var(--blue);border-radius:2px;margin-right:5px;"></span>집단 평균</span></div>'+
      '<div class="row justify-center">'+radar(rows.map(function(r){return r.v;}),rows.map(function(r){return r.avg;}),['산업이해','문서작성','정보탐색','문헌조사','데이터정리','과제지원','커뮤니케이션','업무개선'].slice(0,rows.length),270)+'</div></div>' : '')+
    '</div>'+
    '<div class="mt-20" style="display:flex;gap:12px;padding:16px 18px;border-radius:12px;background:var(--brand-50);border:1px solid var(--brand-100);"><div style="width:28px;height:28px;border-radius:50%;background:var(--brand-grad);display:flex;align-items:center;justify-content:center;flex-shrink:0;">'+icon('sparkle',14,'#fff')+'</div><div><div class="fw-700 mb-4" style="font-size:13.5px;color:var(--brand-deep);">종합 해설</div><p style="font-size:13px;line-height:1.75;color:var(--ink-700);margin:0;">'+criteriaSummary+'</p></div></div></div>';

  // 시장 정합도 분석 (KSA)
  html += '<div class="card mt-24"><div class="h3 mb-4">시장 정합도 분석</div>'+
    '<div class="row items-center gap-12 mb-16"><span class="caption">채용 정보 기반 KSA 요구역량 충족도 · 100점 만점 획득 점수</span><span class="caption row items-center gap-5"><span style="display:inline-block;width:2px;height:13px;background:var(--ink-400);"></span>시장 요구 수준</span></div>'+
    '<div class="row gap-32 items-center"><div class="flex-1"><div class="col" style="gap:20px;">'+
      fitGroups([{a:'Knowledge',s:'지식 요건'},{a:'Skill',s:'기술 요건'},{a:'Attitude',s:'태도 요건'}], ksa, function(r){return lvlReq[r.lvl];}, '시장 요구')+
    '</div></div>'+
    (ksa.length>=3 ? '<div style="flex:0 0 360px;"><div class="row justify-center gap-12 caption mb-8"><span><span style="display:inline-block;width:10px;height:10px;background:var(--brand);border-radius:2px;margin-right:5px;"></span>획득 점수</span><span><span style="display:inline-block;width:10px;height:10px;background:var(--blue);border-radius:2px;margin-right:5px;"></span>시장 요구</span></div>'+
      '<div class="row justify-center">'+radar(ksa.map(function(k){return k.v;}),ksa.map(function(k){return lvlReq[k.lvl];}),['AI보안이해','데이터구조','AI모델','Python분석','파이프라인','로그분석','협업태도','지속학습','주도성'].slice(0,ksa.length),270)+'</div></div>' : '')+
    '</div>'+
    '<div class="mt-20" style="display:flex;gap:12px;padding:16px 18px;border-radius:12px;background:var(--blue-50);border:1px solid var(--blue-100);"><div style="width:28px;height:28px;border-radius:50%;background:var(--blue-grad);display:flex;align-items:center;justify-content:center;flex-shrink:0;">'+icon('sparkle',14,'#fff')+'</div><div><div class="fw-700 mb-4" style="font-size:13.5px;color:var(--blue-deep);">종합 해설</div><p style="font-size:13px;line-height:1.75;color:var(--ink-700);margin:0;">'+marketSummary+'</p></div></div></div>';

  // 역량별 해설 & 근거 소스
  html += '<div class="card mt-24"><div class="row items-center gap-10 mb-4"><div style="width:28px;height:28px;border-radius:50%;background:var(--brand-grad);display:flex;align-items:center;justify-content:center;">'+icon('sparkle',14,'#fff')+'</div><div class="h2" style="margin-bottom:0;">역량별 해설 &amp; 근거 소스</div></div><div class="caption mb-16">각 역량의 점수 산출 근거와 RAG 학습 기반 컨설팅 평어</div>';
  html += explainSection({title:'기준 정합도 역량',sub:'NCS·WISET 역량모델 기준',items:rows,c:'var(--brand)',deep:'var(--brand-deep)',tint:'var(--brand-50)',line:'var(--brand-100)',grad:'var(--brand-grad)'});
  html += '<div class="mt-20">'+explainSection({title:'시장 정합도 역량',sub:'채용 정보 기반 KSA 요구역량',items:ksa,c:'var(--blue)',deep:'var(--blue-deep)',tint:'var(--blue-50)',line:'var(--blue-100)',grad:'var(--blue-grad)'})+'</div>';
  html += '</div>';

  // JD 비교
  html += '<div class="card mt-24"><div class="h2 mb-16" style="margin-bottom:16px;">스크랩한 채용공고와 내 역량 비교</div><div class="col gap-12">';
  jds.forEach(function(j,i){
    var fitcol = j.fit>=70 ? 'var(--brand)' : 'var(--pink)';
    html += '<div style="border:1px solid var(--line);border-radius:12px;background:'+(i===0?'var(--brand-50)':'#fff')+';overflow:hidden;">'+
      '<div class="row items-center gap-20" style="padding:18px;">'+logoChip(j.co.charAt(0),j.tone,48,11)+
        '<div style="flex:1.4;"><div class="row items-center gap-8 mb-4"><span class="fw-700" style="font-size:15px;">'+esc(j.role)+'</span><span class="badge '+(j.rec==='추천'?'badge-brand':'badge-pink')+'">'+esc(j.rec)+'</span></div><div class="caption">'+esc(j.co)+' · '+esc(j.meta)+'</div></div>'+
        '<div style="width:130px;text-align:center;flex-shrink:0;"><div class="caption mb-4">JD 적합률</div><div class="row items-end justify-center gap-2 mb-4"><span style="font-size:28px;font-weight:800;color:'+fitcol+';line-height:1;">'+j.fit+'</span><span class="caption" style="margin-bottom:2px;">%</span></div><div class="score-track"><div class="score-fill" style="width:'+j.fit+'%;background:'+fitcol+';"></div></div><div class="caption mt-4">충족 '+esc(j.match)+'</div></div>'+
        '<div style="flex:1.1;flex-shrink:0;"><div class="caption mb-4">부족 역량</div><div class="row gap-4 flex-wrap">'+j.gap.map(function(g){return '<span class="badge badge-pink">'+esc(g)+'</span>';}).join('')+'</div></div></div>'+
      '<div class="row gap-24 items-start" style="padding:16px 18px;border-top:1px solid var(--line);background:rgba(255,255,255,0.55);">'+
        '<div style="flex:1;"><div class="caption fw-700 t-ink700 mb-8 row items-center gap-6">'+icon('shield',13,'var(--brand)')+' 충족 강점</div><div class="col gap-6">'+
          j.met.map(function(m){return '<div class="row items-start gap-8" style="font-size:12.5px;line-height:1.5;color:var(--ink-700);"><span style="width:5px;height:5px;border-radius:9px;background:var(--brand);margin-top:6px;flex-shrink:0;"></span>'+esc(m)+'</div>';}).join('')+'</div></div>'+
        '<div style="width:1px;align-self:stretch;background:var(--line);"></div>'+
        '<div style="flex:1;"><div class="caption fw-700 t-ink700 mb-8 row items-center gap-6">'+icon('code',13,'var(--pink)')+' 보완 제안</div><div class="col gap-6">'+
          j.advice.map(function(a){return '<div class="row items-start gap-8" style="font-size:12.5px;line-height:1.5;color:var(--ink-700);"><span style="width:5px;height:5px;border-radius:9px;background:var(--pink);margin-top:6px;flex-shrink:0;"></span>'+esc(a)+'</div>';}).join('')+'</div></div></div></div>';
  });
  html += '</div></div>';

  document.getElementById('content').innerHTML = html;
  }

  // 리포트 헤더 캡션 — 신입/경력 + 희망 업종·직무 + 스크랩 수 (DB 동적). 이름은 별도.
  fetch(ctx + '/api/report/profile-summary').then(function(r){ return r.ok ? r.json() : null; }).then(function(s){
    if(s && s.caption){ var el=document.getElementById('reportCaption'); if(el) el.textContent = s.caption; }
  }).catch(function(){});

  // 저장된 분석 리포트(JSON)가 있으면 데이터·요약을 덮어쓰고 렌더(차트/색은 프론트 계산). 없으면 목업 폴백.
  var did = qp('diagnosisId');
  fetch(ctx + '/api/activity-analysis/report' + (did?('?diagnosisId='+encodeURIComponent(did)):'')).then(function(r){ return r.ok ? r.json() : null; }).then(function(rep){
    var c = rep && rep.content;
    if(c){
      if(c.cfi){ if(c.cfi.score!=null) cfiScore=c.cfi.score; if(c.cfi.delta) cfiDelta=c.cfi.delta; if(c.cfi.title) cfiTitle=c.cfi.title; if(c.cfi.summary) cfiSummary=c.cfi.summary; if(c.cfi.badges) cfiBadges=c.cfi.badges; }
      if(c.strengthsTop) strengthsTop=c.strengthsTop;
      if(c.gapsTop) gapsTop=c.gapsTop;
      if(c.rows) rows=c.rows;
      if(c.ksa) ksa=c.ksa;
      if(c.criteriaSummary) criteriaSummary=c.criteriaSummary;
      if(c.marketSummary) marketSummary=c.marketSummary;
      if(c.jds) jds=c.jds;
    }
    // 점수/근거/CFI/요약/JD 는 관계형 테이블에서 온 값을 우선 적용. 비면 위 c
    //
    // ontent/목업 유지.
    if(rep){
      if(rep.rows && rep.rows.length) rows = rep.rows;
      if(rep.ksa && rep.ksa.length) ksa = rep.ksa;
      if(rep.strengthsTop && rep.strengthsTop.length) strengthsTop = rep.strengthsTop;
      if(rep.gapsTop && rep.gapsTop.length) gapsTop = rep.gapsTop;
      if(rep.cfi){ var k=rep.cfi; if(k.score!=null) cfiScore=k.score; if(k.delta) cfiDelta=k.delta; if(k.title) cfiTitle=k.title; if(k.summary) cfiSummary=k.summary; if(k.badges && k.badges.length) cfiBadges=k.badges; }
      if(rep.criteriaSummary) criteriaSummary=rep.criteriaSummary;
      if(rep.marketSummary) marketSummary=rep.marketSummary;
      if(rep.jds && rep.jds.length) jds=rep.jds;
    }
    renderReport();
  }).catch(function(){ renderReport(); });

  // 탭 이동 (persona + diagnosisId 유지 — 특정 진단 리포트 조회 모드 보존)
  var sp=[]; if(qp('persona')) sp.push('persona='+encodeURIComponent(qp('persona'))); if(did) sp.push('diagnosisId='+encodeURIComponent(did));
  var suf = sp.length ? ('?'+sp.join('&')) : '';
  Array.prototype.forEach.call(document.querySelectorAll('.tab[data-go]'), function(t){
    t.addEventListener('click', function(){ location.href = ctx + t.getAttribute('data-go') + suf; });
  });
})();
</script>
</body>
</html>

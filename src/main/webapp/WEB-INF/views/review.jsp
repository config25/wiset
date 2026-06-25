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
  <title>06 입력 데이터 확인 · W브릿지 AI 커리어 코칭</title>
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
      <span class="sep">›</span><span class="current">AI 경력개발 진단</span>
    </div>
  </div>

  <div class="section" style="padding:20px 40px 56px;">

    <%-- Stepper (STEP 5 / 5) --%>
    <div class="row justify-center">
      <div class="stepper" style="padding:22px 0;">
        <div class="step done"><div class="step-num"><wb:icon-ds name="check" size="14" color="#fff" /></div><span>페르소나 선택</span></div>
        <div class="step-line active"></div>
        <div class="step done"><div class="step-num"><wb:icon-ds name="check" size="14" color="#fff" /></div><span>현 상황 입력</span></div>
        <div class="step-line active"></div>
        <div class="step done"><div class="step-num"><wb:icon-ds name="check" size="14" color="#fff" /></div><span>경력개발 목표</span></div>
        <div class="step-line active"></div>
        <div class="step done"><div class="step-num"><wb:icon-ds name="check" size="14" color="#fff" /></div><span>세부 고민</span></div>
        <div class="step-line active"></div>
        <div class="step active"><div class="step-num">5</div><span>입력 데이터 확인</span></div>
      </div>
    </div>

    <div class="text-center mt-24">
      <span class="badge badge-brand mb-12" style="letter-spacing:0.1em;">STEP 5 / 5 · 마지막 단계</span>
      <h1 class="display mt-12 mb-8">입력하신 내용을 확인해주세요</h1>
      <p class="body-lg">분석 시작 전 데이터를 검토하세요. 각 항목 우측 「수정」 버튼으로 해당 단계로 돌아갈 수 있습니다.</p>
    </div>

    <%-- AI readiness banner (입력 완성도 진행바) --%>
    <div class="card mt-24" style="border:none; background:linear-gradient(110deg,#F2EDFA 0%,#EFEAF7 60%,#F4EEF6 100%); max-width:800px; margin:24px auto 0;">
      <div class="row items-start gap-20">
        <div style="width:64px; height:64px; border-radius:50%; background:var(--brand-grad); display:flex; align-items:center; justify-content:center; flex-shrink:0;"><wb:icon-ds name="sparkle" size="28" color="#fff" /></div>
        <div style="flex:1;">
          <span class="badge badge-brand-solid mb-8">AI 분석 준비 완료</span>
          <div class="h2 mt-8" style="margin-bottom:14px;">입력 완성도 <span class="t-brand" id="rvPct">0%</span> · 분석 정확도 <span id="rvAccuracy">—</span></div>
          <div style="position:relative; height:12px; border-radius:999px; background:rgba(106,76,156,0.12); overflow:hidden;">
            <div id="rvBar" style="position:absolute; top:0; bottom:0; left:0; width:0%; background:var(--brand-grad); border-radius:999px; transition:width .4s ease;"></div>
            <div style="position:absolute; top:-1px; bottom:-1px; left:80%; width:2px; background:#fff; box-shadow:0 0 0 1px rgba(106,76,156,0.25);"></div>
          </div>
          <div class="row justify-between" style="margin-top:7px;">
            <span class="caption" id="rvReqStatus" style="color:var(--ink-500); font-weight:700;">필수 항목 80% 입력 중</span>
            <span class="caption" style="color:var(--ink-500);">선택 항목 입력 시 +20%</span>
          </div>
          <p class="caption" style="margin-top:10px; color:var(--ink-600);">풍부한 입력 데이터일수록 AI가 더 정확한 분석 보고서를 만들어 드립니다. 선택 항목도 입력해 보세요.</p>
        </div>
      </div>
    </div>

    <div class="mt-24" style="max-width:800px; margin:24px auto 0;">

      <%-- 01~04 섹션: JS가 sessionStorage + DB 로 렌더 --%>
      <div id="reviewSections"></div>

      <%-- Privacy consent --%>
      <div class="card" style="padding:18px; background:var(--bg-soft);">
        <div class="row items-start gap-12">
          <div id="consentBox" style="width:18px; height:18px; border-radius:4px; background:var(--brand); display:flex; align-items:center; justify-content:center; flex-shrink:0; margin-top:2px; cursor:pointer;"><wb:icon-ds name="check" size="11" color="#fff" sw="2.4" /></div>
          <div style="flex:1;">
            <div class="fw-700 mb-4" style="font-size:13px;">개인정보 비식별 처리 및 AI 분석 활용에 동의합니다 <span class="t-pink">(필수)</span></div>
            <div class="caption">입력하신 데이터는 비식별화 후 AI 분석에만 활용되며, 외부 전송되지 않습니다. 학습 데이터로 사용되지 않습니다.<span style="color:var(--brand); text-decoration:underline; margin-left:6px; cursor:pointer;">전체 약관 보기</span></div>
          </div>
        </div>
      </div>

      <%-- AI 면책 고지 --%>
      <p class="caption text-center" style="margin-top:14px; color:var(--ink-400);">AI의 답변은 정답이 아닙니다. AI는 실수를 할 수 있습니다.</p>

    </div>

    <div class="row justify-between" style="max-width:800px; margin:32px auto 0;">
      <button type="button" class="btn btn-ghost btn-pill" id="prevBtn">이전 단계</button>
      <button type="button" class="btn btn-pill btn-lg" id="startBtn" style="background:var(--pink-grad); color:#fff; border:none;"><wb:icon-ds name="sparkle" size="16" color="#fff" /> AI 분석 시작하기</button>
    </div>

  </div>

  <%@ include file="common/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  function qp(n){ var m=new RegExp('[?&]'+n+'=([^&]*)').exec(location.search); return m?decodeURIComponent(m[1]):''; }
  var suf = qp('persona') ? ('?persona='+encodeURIComponent(qp('persona'))) : '';

  // 개인정보 동의 토글 (기본 동의)
  var consented = true;
  var box = document.getElementById('consentBox');
  box.addEventListener('click', function(){
    consented = !consented;
    box.style.background = consented ? 'var(--brand)' : '#fff';
    box.style.border = consented ? 'none' : '1.5px solid var(--ink-300)';
    box.innerHTML = consented ? '<svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M4.5 12.5l4.5 4.5L19.5 6.5"/></svg>' : '';
  });

  document.getElementById('prevBtn').addEventListener('click', function(){ location.href = ctx + '/concern' + suf; });
  document.getElementById('startBtn').addEventListener('click', function(){
    if(!consented){ alert('필수 동의 항목에 동의해주세요.'); return; }
    var btn = this; btn.disabled = true;
    // 로컬(sessionStorage) 선택값을 DB에 일괄 저장 → 분석 화면으로 (AI 전송은 추후)
    var payload = {
      persona: sessionStorage.getItem('wb_persona') || qp('persona') || '',
      currentSituation: ssObj('wb_currentSituation'),
      careerGoal: ssObj('wb_careerGoal'),
      careerGrowth: ssObj('wb_careerGrowth'),
      concern: sessionStorage.getItem('wb_concern') || ''
    };
    fetch(ctx + '/api/analysis/save', { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) })
      .then(function(r){ if(!r.ok) return r.json().then(function(e){ throw new Error(e.message||('HTTP '+r.status)); }); return r.json().catch(function(){ return {}; }); })
      .then(function(){ location.href = ctx + '/analyzing' + suf; })
      .catch(function(e){ btn.disabled = false; alert('저장 실패: ' + e.message); });
  });

  // ===== 입력 데이터: sessionStorage(로컬) + DB(팝업 저장분) → 섹션 구성 후 렌더 =====
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function ssObj(k){ try{ return JSON.parse(sessionStorage.getItem(k))||{}; }catch(e){ return {}; } }
  function apiCS(p){ return fetch(ctx+'/api/current-situation'+p).then(function(r){ return r.ok?r.json():[]; }).catch(function(){ return []; }); }
  function ymDiff(s,e){ if(!s) return 0; var a=String(s).split('.'),b=String(e||'').split('.'); var sy=+a[0],sm=+(a[1]||1); var d=new Date(); var ey=b[0]?+b[0]:d.getFullYear(), em=b[1]?+b[1]:(d.getMonth()+1); var n=(ey-sy)*12+(em-sm); return n>0?n:0; }
  function row(k, v, opt){ opt=opt||{}; return { k:k, v:v, req:!!opt.req, empty:(opt.empty!=null?opt.empty:(v==null||v==='')), tags:opt.tags, list:opt.list }; }
  // 이름 목록 → "앞 2개 · 로 연결 [등 N건]" 요약. 없으면 null(미입력).
  function summ(arr){ arr=(arr||[]).filter(Boolean); if(!arr.length) return null; var shown=arr.slice(0,2).join(' · '); return arr.length>2 ? (shown+' 등 '+arr.length+'건') : shown; }
  function scraps(){ return fetch(ctx+'/api/career-goal/scraps').then(function(r){return r.ok?r.json():[];}).then(function(sc){ var by={}; sc.forEach(function(s){by[s.id]=s.title;}); return by; }).catch(function(){return {};}); }
  var PERSONA = { '1':'신규 취업','2':'이직 준비','3':'재취업','4':'승진 / 보직 희망' };
  var persona = sessionStorage.getItem('wb_persona') || qp('persona');

  Promise.all([
    apiCS('/education'), apiCS('/career'), apiCS('/research'), apiCS('/activity'),
    apiCS('/training'), apiCS('/certificate'), apiCS('/award'), apiCS('/overseas'),
    apiCS('/language'), scraps(), apiCS('/portfolio'), apiCS('/cover')
  ]).then(function(R){
    var edu=R[0], car=R[1], res=R[2], act=R[3], tr=R[4], cert=R[5], awd=R[6], ov=R[7], lang=R[8], scrapMap=R[9];
    var pf=R[10]||{}, cv=R[11]||{};
    var pfUrls=(pf.urls)||[], pfFiles=(pf.files)||[];
    var coverList=[];
    if(cv.title) coverList.push('제목: '+cv.title);
    else if(cv.content) coverList.push('내용 작성됨');
    ((cv.files)||[]).forEach(function(f){ coverList.push('파일: '+f.name); });

    var sec1 = { n:'01', t:'페르소나', step:1, edit:'/persona-select', rows:[ row('선택', PERSONA[persona], {req:true}) ] };

    var finEdu = edu.filter(function(e){return e.isFinal;})[0] || edu[edu.length-1];
    var months=0; car.forEach(function(c){ months += ymDiff(c.startYm, c.endYm); });
    var sec2 = { n:'02', t:'현 상황', step:2, edit:'/current-situation', rows:[
      row('학력 / 전공', finEdu? [finEdu.seLabel, finEdu.majorName].filter(Boolean).join(' · ') : null, {req:true}),
      row('졸업 연도', finEdu && finEdu.graduationYm ? String(finEdu.graduationYm).split('.')[0] : null),
      row('총 경력', months>0 ? (Math.floor(months/12)+'년 '+(months%12)+'개월') : null),
      row('경력 사항', null, { empty: car.length===0, list: car.map(function(c){ return [c.companyName, c.deptName, c.position].filter(Boolean).join(' · ') + (c.startYm? ' ('+c.startYm+' ~ '+(c.endYm||'')+')':''); }) }),
      // TODO: 컨설팅 결과 — 추후 TEXT 형태로 연동 예정 (현재는 UI 플레이스홀더)
      row('컨설팅 결과', '1:1 커리어컨설팅 데이터 3건 연동'),
      row('논문 / 연구내역', res.length? (res.length+'건') : null),
      row('인턴 · 대외활동', act.length? (act.length+'건') : null),
      row('교육이수', summ(tr.map(function(t){ return t.name; }))),
      row('자격증', cert.length? cert.map(function(c){return c.name;}).filter(Boolean).join(', ') : null),
      row('수상', awd.length? awd.map(function(a){return a.name;}).filter(Boolean).join(', ') : null),
      row('해외경험', summ(ov.map(function(o){ return o.country; }))),
      row('어학', lang.length? lang.map(function(l){return (l.lang||'')+(l.testName?' '+l.testName:'');}).filter(Boolean).join(', ') : null),
      row('포트폴리오', null, { empty:(pfUrls.length+pfFiles.length)===0,
          list: pfFiles.map(function(f){return '파일: '+f.name;}).concat(pfUrls.map(function(u){return 'URL: '+u.url;})) }),
      row('자기소개서', null, { empty: coverList.length===0, list: coverList })
    ] };

    var rows3;
    if(persona==='4'){
      var g=ssObj('wb_careerGrowth');
      rows3=[ row('목표 보직', g.targetRole, {req:true}), row('강화 역량', (g.skills||[]).join(', ')), row('현재 담당업무', g.duties), row('목표 처우', g.targetPay), row('평가 요소', g.evalFactor) ];
    } else {
      var cg=ssObj('wb_careerGoal');
      var tnames=(cg.targets||[]).map(function(id){ return scrapMap[id]||('#'+id); });
      rows3=[
        row('희망 업종', cg.industry, {req:true}),
        row('희망 직무', cg.job, {req:true}),
        row('희망 근무지', null, { req:true, empty:!(cg.regions&&cg.regions.length), tags:(cg.regions||[]) }),
        row('희망 고용 형태', (cg.employment||[]).join(', ')),
        row('타겟 공고', tnames.length? (tnames.join(' / ')+' · 총 '+tnames.length+'건') : null)
      ];
    }
    var sec3 = { n:'03', t:'경력개발 목표', step:3, edit:'/career-goal', rows:rows3 };

    var sec4 = { n:'04', t:'세부 고민', step:4, edit:'/concern', rows:[ row('자유 서술', sessionStorage.getItem('wb_concern')) ] };

    render([sec1, sec2, sec3, sec4]);
  });

  function render(sections){
    var html = sections.map(function(s){
      var rows = s.rows.map(function(r, j){
        var border = j < s.rows.length-1 ? 'border-bottom:1px dashed var(--line);' : '';
        var label = esc(r.k) + (r.req? '<span style="color:#D92D20; margin-left:2px;">*</span>':'');
        var val;
        if(r.tags){ val = r.tags.length? '<div class="row gap-8" style="flex-wrap:wrap;">'+r.tags.map(function(t){return '<span class="badge" style="background:var(--brand-50); color:var(--brand);">'+esc(t)+'</span>';}).join('')+'</div>' : '미입력'; }
        else if(r.list){ val = (r.list.length)? '<div class="col gap-6">'+r.list.map(function(t){return '<div class="row items-center gap-8"><span style="width:4px;height:4px;border-radius:50%;background:var(--ink-400);flex-shrink:0;"></span><span>'+esc(t)+'</span></div>';}).join('')+'</div>' : '미입력'; }
        else { val = esc(r.empty? '미입력' : r.v); }
        var vstyle = 'flex:1; font-size:13px; color:'+(r.empty?'var(--ink-400)':'var(--ink)')+';'+(r.empty?' font-style:italic;':'');
        return '<div class="row items-start gap-16" style="padding:10px 0; '+border+'"><div class="caption fw-700" style="width:140px; color:var(--ink-500); flex-shrink:0;">'+label+'</div><div class="body" style="'+vstyle+'">'+val+'</div></div>';
      }).join('');
      return '<div class="card mb-16"><div class="row items-center justify-between mb-16"><div class="row items-center gap-12"><div class="mono" style="width:36px;height:36px;border-radius:8px;background:var(--brand-50);color:var(--brand);display:flex;align-items:center;justify-content:center;font-weight:700;font-size:13px;">'+s.n+'</div><div><div class="h3" style="margin-bottom:0;">'+esc(s.t)+'</div><div class="caption mt-4">STEP '+s.step+'에서 입력</div></div></div><button type="button" class="btn btn-ghost btn-sm" data-edit="'+s.edit+'">수정 ✏️</button></div><div class="col gap-0">'+rows+'</div></div>';
    }).join('');
    document.getElementById('reviewSections').innerHTML = html;

    var all=[]; sections.forEach(function(s){ s.rows.forEach(function(r){ all.push(r); }); });
    var reqRows=all.filter(function(r){return r.req;}), optRows=all.filter(function(r){return !r.req;});
    var reqFilled=reqRows.filter(function(r){return !r.empty;}).length, optFilled=optRows.filter(function(r){return !r.empty;}).length;
    var reqPct=reqRows.length? reqFilled/reqRows.length*80 : 80;
    var optPct=optRows.length? optFilled/optRows.length*20 : 0;
    var pct=Math.round(reqPct+optPct), reqDone=reqFilled===reqRows.length;
    document.getElementById('rvPct').textContent = pct+'%';
    document.getElementById('rvBar').style.width = pct+'%';
    document.getElementById('rvAccuracy').textContent = pct>=80? '매우 높음' : (pct>=50? '양호':'보통');
    var rs=document.getElementById('rvReqStatus'); rs.textContent='필수 항목 80% '+(reqDone?'완료':'입력 중'); rs.style.color = reqDone?'var(--brand)':'var(--ink-500)';

    Array.prototype.forEach.call(document.getElementById('reviewSections').querySelectorAll('[data-edit]'), function(b){ b.addEventListener('click', function(){ location.href = ctx + b.getAttribute('data-edit') + suf; }); });
  }
})();
</script>
</body>
</html>

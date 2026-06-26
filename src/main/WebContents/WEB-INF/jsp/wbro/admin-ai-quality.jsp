<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="wb" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>관리자 · AI 품질 관리 · W브릿지</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">

<wb:admin active="ai" title="AI 품질 관리" sub="답변 품질 지표 · 알고리즘 가중치 · 프롬프트 관리">
  <div id="content"><div class="caption" style="padding:40px 0; color:var(--ink-400);">불러오는 중…</div></div>
</wb:admin>

<script>
(function () {
  var ctx = '${ctx}';
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  function nf(n){ return (n==null?0:n).toLocaleString('ko-KR'); }
  var DATA = null, curJob = null, curPrompt = 0;

  // ---- SECTION 1: 품질 지표 + 낮은 만족도 + 요인 ----
  function section1(d){
    var metrics = d.metrics||[];
    var s = '<div class="row items-center gap-8 mb-12"><span class="badge badge-ai">SECTION 1</span><h2 style="font-size:16px; font-weight:700; margin:0;">AI 답변 품질 상세 지표</h2></div>';
    s += '<div class="row gap-16 mb-16">'+metrics.map(function(m){
      var good = (m.delta==null || m.delta>=0), col = good?'#10B981':'#FB923C';
      var dtxt = (m.delta==null)?'—':(m.delta>0?'↑ +'+m.delta+'%':(m.delta<0?'↓ '+m.delta+'%':'± 0%'));
      return '<div class="card flex-1" style="padding:18px;"><div class="caption mb-4">'+esc(m.label)+'</div>'+
        '<div class="row items-baseline gap-4 mb-8"><span style="font-size:28px; font-weight:800; color:'+col+';">'+m.value+'</span><span class="caption">%</span><span class="caption" style="margin-left:auto; color:'+col+'; font-weight:700;">'+dtxt+'</span></div>'+
        '<div style="height:4px; background:#F0F0F2; border-radius:2px;"><div style="width:'+m.value+'%; height:100%; background:'+col+'; border-radius:2px;"></div></div>'+
        '<div class="caption mt-4" style="color:var(--ink-500);">'+esc(m.desc)+'</div></div>';
    }).join('')+'</div>';

    var low = d.lowReports||[], factors = d.factors||[];
    s += '<div class="row gap-16 mb-16">'+
      '<div class="card" style="flex:2;"><div class="row justify-between items-center mb-16"><div class="h3">낮은 만족도 리포트 목록</div><div class="row gap-8"><span class="badge" style="background:#FEE2E2; color:#B91C1C;">★ 3.0 이하 '+nf(d.lowReportCount)+'건</span><button type="button" class="btn btn-ghost btn-sm">전체 보기 →</button></div></div>'+
        '<table style="width:100%; border-collapse:collapse; font-size:12px;"><thead><tr style="text-align:left; color:var(--ink-500); border-bottom:1px solid var(--line);"><th style="padding:8px 6px; font-weight:600;">리포트 ID</th><th style="padding:8px 6px; font-weight:600;">페르소나</th><th style="padding:8px 6px; font-weight:600;">★</th><th style="padding:8px 6px; font-weight:600;">속도</th><th style="padding:8px 6px; font-weight:600;">품질 저하 사유</th><th style="padding:8px 6px; font-weight:600;"></th></tr></thead><tbody>'+
        (low.length? low.map(function(r){ return '<tr style="border-bottom:1px solid var(--line);"><td style="padding:10px 6px; font-family:\'JetBrains Mono\',monospace; color:var(--primary); font-size:11px;">'+esc(r.reportId)+'</td><td style="padding:10px 6px;">'+esc(r.persona)+'</td><td style="padding:10px 6px;"><span class="badge" style="background:#FEE2E2; color:#B91C1C; font-size:10px;">★ '+(r.star!=null?r.star:'-')+'</span></td><td style="padding:10px 6px; color:var(--ink-500);">'+esc(r.speed)+'</td><td style="padding:10px 6px; font-size:11px;">'+esc(r.issue)+'</td><td style="padding:10px 6px; text-align:right;"><button type="button" class="btn btn-ghost btn-sm" style="font-size:11px; padding:4px 8px;">분석</button></td></tr>'; }).join('')
          : '<tr><td colspan="6" style="padding:16px 6px; color:var(--ink-400);">낮은 만족도 리포트가 없습니다.</td></tr>')+
        '</tbody></table></div>'+
      '<div class="card flex-1"><div class="h3 mb-16">품질 저하 요인 분포</div><div class="col gap-12">'+
        (factors.length? factors.map(function(f){ return '<div><div class="row justify-between mb-4"><span class="caption fw-700">'+esc(f.label)+'</span><span class="caption">'+nf(f.count)+'건 ('+f.percent+'%)</span></div><div style="height:8px; background:#F0F0F2; border-radius:4px;"><div style="width:'+f.percent+'%; height:100%; background:var(--accent); border-radius:4px;"></div></div></div>'; }).join('')
          : '<div class="caption" style="color:var(--ink-400);">품질 저하 요인이 없습니다.</div>')+
        '</div>'+
        (factors.length? '<div class="caption mt-16" style="padding:10px; background:var(--bg-soft); border-radius:6px; color:var(--ink-500);">💡 \''+esc(factors[0].label)+'\'이(가) 가장 큰 품질 저하 요인입니다 ('+factors[0].percent+'%).</div>':'')+
      '</div></div>';
    return s;
  }

  // ---- SECTION 2: 가중치 ----
  function weightRows(job){
    var rows = (DATA.weights.byJob||{})[job] || [];
    return rows.map(function(s){ var diff=s.weight!==s.defaultWeight, bc=diff?'var(--accent)':'var(--primary)';
      return '<div class="row items-center gap-12"><div class="caption fw-700" style="width:140px;">'+esc(s.competency)+'</div>'+
        '<div style="flex:1; position:relative;"><div style="height:6px; background:#F0F0F2; border-radius:3px;"><div style="width:'+s.weight+'%; height:100%; background:'+bc+'; border-radius:3px;"></div></div><div style="position:absolute; left:'+s.defaultWeight+'%; top:-3px; width:1px; height:12px; background:var(--ink-500);"></div></div>'+
        '<div class="row items-center gap-4" style="width:100px;"><input type="text" inputmode="numeric" data-comp="'+esc(s.competency)+'" value="'+s.weight+'" style="width:50px; padding:4px 6px; border:1px solid var(--line); border-radius:4px; font-size:13px; text-align:center; font-weight:700; color:'+bc+';"><span class="caption">%</span></div>'+
        '<div class="caption" style="width:50px; color:var(--ink-500); font-size:11px;">기본 '+s.defaultWeight+'</div></div>';
    }).join('') || '<div class="caption" style="color:var(--ink-400);">가중치 데이터가 없습니다.</div>';
  }
  function weightSum(job){
    var rows = (DATA.weights.byJob||{})[job] || [], t=0; rows.forEach(function(s){ t+=s.weight; });
    return t;
  }
  function renderWeights(){
    var sum = weightSum(curJob);
    document.getElementById('weightBody').innerHTML = weightRows(curJob);
    document.getElementById('weightSum').innerHTML = '합계 '+sum+'% / 100% '+(sum===100?'✓':'⚠');
    document.querySelectorAll('#weightBody input[data-comp]').forEach(function(inp){ inp.addEventListener('input', liveSum); });
    var tabs = document.querySelectorAll('#jobTabs .job-tab');
    tabs.forEach(function(t){ var on=t.getAttribute('data-job')===curJob;
      t.style.background=on?'var(--primary)':'#fff'; t.style.color=on?'#fff':'var(--ink-700)'; t.style.borderColor=on?'var(--primary)':'var(--line)'; });
  }
  function section2(d){
    var jobs = (d.weights.jobs||[]); curJob = curJob || jobs[0];
    var hist = d.weightsHistory||[];
    var s = '<div class="row items-center gap-8 mb-12"><span class="badge badge-blue">SECTION 2</span><h2 style="font-size:16px; font-weight:700; margin:0;">알고리즘 가중치 관리</h2></div>';
    s += '<div class="row gap-16 mb-24">'+
      '<div class="card" style="flex:2;"><div class="row justify-between items-center mb-16"><div class="h3">직무별 · 역량별 가중치 조정</div><div class="row gap-8"><button type="button" id="wReset" class="btn btn-ghost btn-sm">기본값 복원</button><button type="button" id="wSave" class="btn btn-brand btn-sm">변경사항 저장</button></div></div>'+
        '<div class="caption fw-700 mb-8">대상 직무</div><div class="row gap-8 mb-16 flex-wrap" id="jobTabs">'+
        jobs.map(function(t){ return '<span class="job-tab badge" data-job="'+esc(t)+'" style="background:#fff; color:var(--ink-700); border:1px solid var(--line); padding:6px 12px; cursor:pointer;">'+esc(t)+'</span>'; }).join('')+'</div>'+
        '<div class="col gap-12" id="weightBody"></div>'+
        '<div class="caption mt-8" id="weightSum" style="color:var(--ink-500); text-align:right;"></div></div>'+
      '<div class="card flex-1"><div class="row justify-between items-center mb-16"><div class="h3">변경 이력</div><button type="button" class="btn btn-ghost btn-sm" style="font-size:11px;">↺ 회귀</button></div><div class="col gap-0">'+
        (hist.length? hist.map(function(h,i){ return '<div class="row gap-8" style="padding:12px 8px; border-bottom:'+(i<hist.length-1?'1px solid var(--line)':'none')+'; background:'+(h.current?'var(--primary-50)':'transparent')+'; border-radius:4px;">'+
          '<div style="width:8px; height:8px; border-radius:50%; background:'+(h.current?'var(--primary)':'var(--ink-500)')+'; margin-top:4px;"></div>'+
          '<div style="flex:1;"><div class="row items-center gap-8"><span class="fw-700" style="font-size:12px; color:var(--primary);">'+esc(h.version)+'</span>'+(h.current?'<span class="badge badge-blue" style="font-size:9px; padding:1px 6px;">현재</span>':'')+'<span class="caption" style="margin-left:auto; font-size:10px;">'+esc(h.date)+'</span></div>'+
          '<div class="caption mt-4" style="font-size:11px;">'+esc(h.reason)+'</div><div class="caption" style="font-size:10px; color:var(--ink-500);">'+esc(h.modifier)+(h.jobName?' · '+esc(h.jobName):'')+'</div></div>'+
          (h.current?'':'<button type="button" style="background:none; border:none; cursor:pointer; color:var(--primary); font-size:11px;">↺</button>')+'</div>'; }).join('')
          : '<div class="caption" style="color:var(--ink-400); padding:8px;">변경 이력이 없습니다.</div>')+
        '</div></div></div>';
    return s;
  }

  // ---- SECTION 3: 프롬프트 ----
  function renderPromptDetail(){
    var p = (DATA.prompts||[])[curPrompt]; if(!p){ document.getElementById('promptDetail').innerHTML=''; return; }
    var contentHtml = esc(p.content||'').replace(/\n/g,'<br>')
      .replace(/(\{\{[a-z_]+\}\})/g,'<span style="color:#FBBF24;">$1</span>')
      .replace(/(#\s?[A-Z]+)/g,'<span style="color:#9AA0AA;">$1</span>');
    document.getElementById('promptDetail').innerHTML =
      '<div class="row justify-between items-center mb-12"><div><div class="row items-center gap-8"><span class="caption" style="font-family:\'JetBrains Mono\',monospace; color:var(--primary); font-size:12px;">'+esc(p.code)+'</span><span class="badge badge-blue" style="font-size:10px;">'+esc(p.version)+' · 현재</span></div><div class="h3 mt-4" style="margin-bottom:0;">'+esc(p.title)+'</div></div><div class="row gap-8"><button type="button" class="btn btn-ghost btn-sm">버전 이력</button><button type="button" class="btn btn-brand btn-sm">시뮬레이션</button></div></div>'+
      '<div class="caption fw-700 mt-12 mb-8">변수 (Variables)</div><div class="row gap-8 mb-16 flex-wrap">'+
      ((p.variables||[]).map(function(v){ return '<span class="badge" style="font-family:\'JetBrains Mono\',monospace; font-size:11px; background:var(--brand-50); color:var(--primary);">'+esc(v)+'</span>'; }).join('') || '<span class="caption" style="color:var(--ink-400);">변수 없음</span>')+'</div>'+
      '<div class="caption fw-700 mb-8">프롬프트 본문</div>'+
      '<div style="background:#1B1B1F; color:#E0E0E5; padding:14px; border-radius:6px; font-family:\'JetBrains Mono\',monospace; font-size:11px; line-height:1.6;">'+contentHtml+'</div>';
    var items = document.querySelectorAll('#promptList .prompt-item');
    items.forEach(function(el,i){ var on=i===curPrompt; el.style.background=on?'var(--primary-50)':'transparent'; el.style.border='1px solid '+(on?'var(--primary)':'transparent'); });
  }
  function section3(d){
    var prompts = d.prompts||[];
    var s = '<div class="row items-center gap-8 mb-12"><span class="badge" style="background:var(--blue-50); color:var(--blue);">SECTION 3</span><h2 style="font-size:16px; font-weight:700; margin:0;">프롬프트 관리</h2></div>';
    s += '<div class="row gap-16">'+
      '<div class="card" style="flex:1;"><div class="h3 mb-12">프롬프트 목록</div><input class="input" placeholder="🔍 검색" style="width:100%; padding:8px 12px; margin-bottom:12px;"><div class="col gap-2" id="promptList">'+
      (prompts.length? prompts.map(function(p,i){ return '<div class="prompt-item row items-center gap-8" data-idx="'+i+'" style="padding:10px 12px; border-radius:6px; cursor:pointer; border:1px solid transparent;"><div style="flex:1;"><div class="row items-center gap-4"><span class="caption" style="font-family:\'JetBrains Mono\',monospace; font-size:10px; color:var(--ink-500);">'+esc(p.code)+'</span><span class="badge badge-gray" style="font-size:9px; padding:1px 6px;">'+esc(p.version)+'</span></div><div class="fw-700 mt-2" style="font-size:13px;">'+esc(p.title)+'</div></div></div>'; }).join('')
        : '<div class="caption" style="color:var(--ink-400);">프롬프트가 없습니다.</div>')+
      '</div></div>'+
      '<div class="card" style="flex:2;" id="promptDetail"></div></div>';
    return s;
  }

  // 현재 직무 입력칸 → [{competency, weight}]
  function collectWeights(){
    var arr=[];
    document.querySelectorAll('#weightBody input[data-comp]').forEach(function(inp){
      arr.push({ competency: inp.getAttribute('data-comp'), weight: parseInt(inp.value,10)||0 });
    });
    return arr;
  }
  function liveSum(){
    var t=0; collectWeights().forEach(function(w){ t+=w.weight; });
    var el=document.getElementById('weightSum'); if(el) el.innerHTML='합계 '+t+'% / 100% '+(t===100?'✓':'⚠');
    return t;
  }
  // 변경 사유 자동 생성(원본 대비 diff)
  function changeReason(){
    var rows=(DATA.weights.byJob||{})[curJob]||[], cur=collectWeights(), ch=[];
    cur.forEach(function(w){ var o=rows.filter(function(r){return r.competency===w.competency;})[0];
      if(o && o.weight!==w.weight) ch.push(w.competency+' '+o.weight+'→'+w.weight+'%'); });
    if(!ch.length) return curJob+' 가중치 저장';
    return ch[0]+(ch.length>1?(' 외 '+(ch.length-1)+'건'):'');
  }
  function postWeights(weights, reason){
    var sum=0; weights.forEach(function(w){ sum+=w.weight; });
    if(sum!==100){ alert('가중치 합계가 100%가 되어야 합니다. (현재 '+sum+'%)'); return; }
    fetch(ctx+'/api/admin/ai-quality/weights',{ method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ jobName:curJob, weights:weights, reason:reason }) })
      .then(function(r){ if(!r.ok) return r.json().then(function(e){ throw new Error(e.message||('HTTP '+r.status)); }); return r.json(); })
      .then(function(d){ render(d); alert('저장되었습니다.'); })
      .catch(function(e){ alert('저장 실패: '+e.message); });
  }

  function render(d){
    DATA = d;
    document.getElementById('content').innerHTML = section1(d) + section2(d) + section3(d);
    renderWeights();
    renderPromptDetail();
    // 직무 탭 이벤트
    document.querySelectorAll('#jobTabs .job-tab').forEach(function(t){
      t.addEventListener('click', function(){ curJob = t.getAttribute('data-job'); renderWeights(); });
    });
    // 프롬프트 선택 이벤트
    document.querySelectorAll('#promptList .prompt-item').forEach(function(el){
      el.addEventListener('click', function(){ curPrompt = parseInt(el.getAttribute('data-idx'),10)||0; renderPromptDetail(); });
    });
    // (입력 시 합계 실시간 표시는 renderWeights 에서 부착)
    // 변경사항 저장 / 기본값 복원
    var save=document.getElementById('wSave'); if(save) save.addEventListener('click', function(){ postWeights(collectWeights(), changeReason()); });
    var reset=document.getElementById('wReset'); if(reset) reset.addEventListener('click', function(){
      var rows=(DATA.weights.byJob||{})[curJob]||[];
      var defs=rows.map(function(r){ return { competency:r.competency, weight:r.defaultWeight }; });
      postWeights(defs, curJob + ' 기본값 복원');
    });
  }

  fetch(ctx + '/api/admin/ai-quality').then(function(r){ return r.ok ? r.json() : null; }).then(function(d){
    if(!d){ document.getElementById('content').innerHTML = '<div class="caption" style="padding:40px 0; color:var(--accent);">데이터를 불러오지 못했습니다.</div>'; return; }
    render(d);
  }).catch(function(e){ console.error('AI 품질 로드 실패', e); });
})();
</script>
</body>
</html>

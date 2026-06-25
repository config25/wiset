<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="wb" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="activeNav" value="" scope="request" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>마이페이지 · 액션 플래너 · W브릿지</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">
<div class="wb wb-frame" style="background:#fff;">

  <%@ include file="common/header-ds.jspf" %>

  <wb:mypage active="planner">

    <%-- 액션 플래너 --%>
    <div class="card mb-24" style="background:linear-gradient(180deg, #FAF7FC 0%, #fff 100%);">
      <div class="row items-center justify-between mb-16">
        <div>
          <span class="badge badge-ai mb-8">My Planner</span>
          <div class="h2 mt-8" style="margin-bottom:4px;">나만의 액션 플래너</div>
          <div class="caption">직접 입력하거나 아래 추천 활동에서 골라 담아보세요. 진행 상태도 여기서 관리됩니다.</div>
        </div>
        <div class="row gap-8"><span class="badge badge-blue">담은 활동 <span class="fw-700" id="planCount">0</span></span></div>
      </div>
      <div class="row gap-12 mb-16">
        <div class="input flex-1 row items-center gap-8"><wb:icon-ds name="plus" size="14" color="#6A4C9C" /><input id="planInput" style="border:none; outline:none; flex:1; font-size:14px; background:transparent; font-family:inherit;" placeholder="예: GMP 모의시험 1회 풀이 / 박사후연구원 면접 준비 등 자유롭게 입력"></div>
        <select class="select" id="planTerm" style="width:170px;"><option value="SHORT">단기 (1~2주)</option><option value="MID" selected>중기 (1~2개월)</option><option value="LONG">장기 (3~6개월)</option></select>
        <button type="button" id="planAdd" class="btn btn-brand">담기</button>
      </div>
      <div class="row gap-12" id="planCols"></div>
      <div class="row justify-end mt-16"><button type="button" id="planSave" class="btn btn-brand btn-pill">플래너 저장 <wb:icon-ds name="check" size="14" color="#fff" /></button></div>
    </div>

    <%-- 추천 활동 --%>
    <div class="mt-32">
      <div class="row items-center justify-between mb-16">
        <div><h2 class="h2" style="margin-bottom:4px;">추천 활동</h2><div class="caption">위 액션 플래너에 담아 사용할 수 있어요</div></div>
      </div>
      <div class="row gap-2 mb-20" id="recTabs" style="border-bottom:1px solid var(--line);"></div>
      <div class="row gap-12 flex-wrap" id="recGrid"></div>
    </div>

  </wb:mypage>

  <%@ include file="common/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function api(method, path, body){ return fetch(ctx+'/api/action-planner'+path, {method:method, headers:{'Content-Type':'application/json'}, body: body!=null?JSON.stringify(body):undefined}).then(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); return r.text(); }).then(function(t){ return t?JSON.parse(t):null; }); }

  var TERM = {SHORT:'단기', MID:'중기', LONG:'장기'};
  var STATUS = {TODO:'대기', IN_PROGRESS:'진행중', DONE:'완료'};
  var STATUS_CYCLE = {TODO:'IN_PROGRESS', IN_PROGRESS:'DONE', DONE:'TODO'};
  var SOURCE = {WBRIDGE:'WISET 추천', EXTERNAL_LINK:'외부 연계', EXTERNAL_REC:'외부 추천', MANUAL:'직접 입력', COHORT:'코호트 추천', AI:'AI 추천'};

  // ---------- 액션 플래너 (담기/삭제는 로컬에 모아 '플래너 저장'에서 일괄 커밋) ----------
  var planner = [];          // {plannerId?, title, source, term, status, pending?}
  var pendingDeletes = [];   // 저장됐던 항목 삭제 예정 plannerId
  function renderPlanner(){
    var el=document.getElementById('planCols');
    var terms=[{k:'SHORT',sub:'1~2주',dot:'var(--accent)'},{k:'MID',sub:'1~2개월',dot:'var(--primary)'},{k:'LONG',sub:'3~6개월',dot:'var(--blue)'}];
    el.innerHTML = terms.map(function(tm){
      var its=planner.filter(function(p){ return p.term===tm.k; });
      var cards = its.map(function(p){
        var i = planner.indexOf(p);
        var unsaved = !p.plannerId;
        var done=p.status==='DONE';
        var bs = done?'background:var(--brand-50); color:var(--primary);':'background:var(--pink-50); color:var(--accent);';
        // 상태 뱃지: 저장된 항목만 클릭(진행도) 가능. 미저장 항목은 표시만.
        var statusBadge = unsaved
          ? '<span class="badge" style="'+bs+' font-size:10px; opacity:.55;">'+esc(STATUS[p.status]||p.status)+'</span>'
          : '<span class="badge" data-status="'+p.plannerId+'" style="'+bs+' font-size:10px; cursor:pointer;" title="클릭하여 상태 변경">'+esc(STATUS[p.status]||p.status)+'</span>';
        var mark = unsaved ? '<span class="badge" style="background:var(--pink-50); color:var(--accent); font-size:9px;">미저장</span> ' : '';
        return '<div class="card" style="padding:10px;'+(unsaved?' border:1px dashed var(--accent);':'')+'"><div class="row items-center justify-between mb-4"><span class="caption fw-700" style="color:var(--ink-500);">'+mark+esc(SOURCE[p.source]||p.source||'')+'</span>'+
          '<span class="row items-center gap-6">'+statusBadge+
          '<span data-rm="'+i+'" style="cursor:pointer; color:var(--ink-400); font-size:14px;" title="삭제">&times;</span></span></div>'+
          '<div class="fw-600" style="font-size:13px;">'+esc(p.title||'')+'</div></div>';
      }).join('') || '<div class="caption" style="color:var(--ink-400);">없음</div>';
      return '<div class="flex-1" style="border:1.5px dashed var(--line); border-radius:12px; padding:16px; background:#fff; min-height:200px;">'+
        '<div class="row items-center gap-8 mb-12"><span style="width:8px;height:8px;border-radius:50%;background:'+tm.dot+';"></span><span class="fw-700" style="font-size:14px;">'+TERM[tm.k]+'</span><span class="caption" style="color:var(--ink-500);">· '+tm.sub+'</span><span class="caption" style="margin-left:auto;">'+its.length+'건</span></div>'+
        '<div class="col gap-8">'+cards+'</div></div>';
    }).join('');
    var pc=document.getElementById('planCount'); if(pc) pc.textContent=planner.length;
  }
  function loadPlanner(){ return api('GET','/items').then(function(items){
    planner = (items||[]).map(function(p){ return { plannerId:p.plannerId, title:p.title, source:p.source, term:p.term, status:p.status }; });
    pendingDeletes = [];
    renderPlanner();
  }); }

  document.getElementById('planCols').addEventListener('click', function(e){
    var sid=e.target.getAttribute('data-status'), rm=e.target.getAttribute('data-rm');
    if(sid){ // 상태(진행도) 변경 — 저장된 항목만 즉시 반영. 미저장 담기 항목 보존 위해 loadPlanner 대신 로컬 갱신.
      var cur=e.target.textContent.trim(); var code='TODO'; for(var k in STATUS){ if(STATUS[k]===cur) code=k; }
      var next=STATUS_CYCLE[code];
      api('PUT','/items/'+sid,{status:next}).then(function(){
        var it=planner.filter(function(p){ return String(p.plannerId)===sid; })[0]; if(it) it.status=next;
        renderPlanner();
      }).catch(function(err){alert('변경 실패: '+err.message);});
    } else if(rm!=null && rm!==''){ // 닫기(X): 저장됐던 항목은 삭제 예정으로, 미저장 항목은 담기 취소(로컬 제거)
      var i=+rm; var it=planner[i]; if(!it) return;
      if(it.plannerId) pendingDeletes.push(it.plannerId);
      planner.splice(i,1);
      renderPlanner();
    }
  });
  document.getElementById('planAdd').addEventListener('click', function(){
    var inp=document.getElementById('planInput'); var title=inp.value.trim();
    if(!title){ alert('내용을 입력해주세요.'); return; }
    var term=document.getElementById('planTerm').value;
    planner.push({ title:title, source:'MANUAL', term:term, status:'TODO',
      pending:{ customTitle:title, term:term, source:'MANUAL' } }); // 미저장 — '플래너 저장'에서 커밋
    inp.value='';
    renderPlanner();
  });

  // ---------- 추천 활동 ----------
  var GROUPS=[{key:'job',label:'채용',tone:'primary',types:['JOB']},{key:'edu',label:'교육 및 멘토링',tone:'sub',types:['EDUCATION']},{key:'support',label:'지원사업',tone:'accent',types:['SUPPORT']}];
  var cats=[], tab='job';
  function toneColor(t){ return t==='accent'?'var(--accent)':t==='sub'?'var(--blue)':'var(--primary)'; }
  function recMeta(it){ var p=[]; if(it.location) p.push(it.location); if(it.salaryMin) p.push(it.salaryMin+'~'+(it.salaryMax||'')+'만원'); if(it.content) p.push(it.content); return p.join(' · '); }
  function buildCats(recs){
    cats = GROUPS.map(function(g){ return { key:g.key, label:g.label, tone:g.tone, items:(recs||[]).filter(function(r){ return g.types.indexOf(r.type)>=0; }).map(function(r){ return { t:(r.org?r.org+' — ':'')+r.title, d:recMeta(r), src:(r.sourceType==='WBRIDGE'?'W브릿지':'외부연계'), srcCode:r.sourceType, id:r.resourceId }; }) }; });
  }
  function renderTabs(){
    var el=document.getElementById('recTabs'); el.innerHTML='';
    cats.forEach(function(c){ var on=c.key===tab; var tc=toneColor(c.tone); var d=document.createElement('div'); d.style.cssText='padding:12px 20px;font-size:14px;margin-bottom:-1px;cursor:pointer;font-weight:'+(on?'700':'500')+';color:'+(on?tc:'var(--ink-700)')+';border-bottom:2px solid '+(on?tc:'transparent')+';'; d.innerHTML=esc(c.label)+' <span class="caption" style="margin-left:4px;color:var(--ink-500);">'+c.items.length+'</span>'; d.addEventListener('click',function(){ tab=c.key; renderTabs(); renderGrid(); }); el.appendChild(d); });
  }
  // '+ 플래너' 기간 선택 드롭다운 (담는 순간엔 미저장 pending, '플래너 저장'에서 커밋)
  function recPlanBtn(id){
    var menu=[['단기','1~2주','SHORT','var(--accent)'],['중기','1~2개월','MID','var(--primary)'],['장기','3~6개월','LONG','var(--blue)']].map(function(o){
      return '<button type="button" class="row items-center gap-10" data-recadd="'+id+'::'+o[2]+'" style="width:100%;padding:11px 14px;background:transparent;border:none;border-top:1px solid var(--line);cursor:pointer;font-family:inherit;text-align:left;"><span style="width:8px;height:8px;border-radius:9px;background:'+o[3]+';flex-shrink:0;"></span><span class="fw-700" style="font-size:13px;">'+o[0]+'</span><span class="caption" style="margin-left:auto;">'+o[1]+'</span></button>';
    }).join('');
    return '<div style="position:relative;">'+
      '<button type="button" class="btn btn-ghost btn-sm" data-recbtn="'+id+'">+ 플래너 <span style="font-size:10px;margin-left:2px;">▾</span></button>'+
      '<div data-recmenu="'+id+'" style="display:none;position:absolute;top:calc(100% + 6px);right:0;z-index:20;width:188px;background:#fff;border:1px solid var(--line);border-radius:10px;box-shadow:0 12px 28px -8px rgba(30,20,50,0.25);overflow:hidden;"><div class="caption fw-700" style="padding:10px 14px 6px;color:var(--ink-500);">어느 기간에 담을까요?</div>'+menu+'</div></div>';
  }
  function closeAllRecMenus(){ Array.prototype.forEach.call(document.querySelectorAll('[data-recmenu]'), function(m){ m.style.display='none'; }); }
  function renderGrid(){
    var cat=cats.filter(function(c){return c.key===tab;})[0]; if(!cat){ document.getElementById('recGrid').innerHTML=''; return; }
    var cta=tab==='job'?'지원하기':'신청하기';
    document.getElementById('recGrid').innerHTML = cat.items.map(function(it){
      var srcBadge = it.src==='W브릿지' ? '<span class="badge" style="background:var(--brand-50);color:var(--primary);">'+esc(it.src)+'</span>' : '<span class="badge" style="background:var(--bg-soft);color:var(--ink-700);border:1px solid var(--line);">'+esc(it.src)+'</span>';
      return '<div class="card" style="flex:1 1 calc(50% - 8px);min-width:300px;overflow:visible;">'+
        '<div class="row items-center justify-between mb-8"><div class="row items-center gap-4">'+srcBadge+'</div></div>'+
        '<div class="fw-700 mb-8" style="font-size:15px;line-height:1.4;">'+esc(it.t)+'</div>'+
        '<div class="caption mb-16">'+esc(it.d)+'</div>'+
        '<div class="row gap-8"><button type="button" class="btn btn-brand btn-sm" style="flex:1;justify-content:center;">'+cta+'</button>'+recPlanBtn(it.id)+'</div></div>';
    }).join('') || '<div class="caption" style="color:var(--ink-400);">추천 항목이 없습니다.</div>';
  }
  document.getElementById('recGrid').addEventListener('click', function(e){
    var btn=e.target.closest && e.target.closest('[data-recbtn]');
    if(btn){ var id=btn.getAttribute('data-recbtn'); var menu=document.querySelector('[data-recmenu="'+id+'"]'); var openNow=(menu.style.display==='none'); closeAllRecMenus(); if(openNow) menu.style.display='block'; e.stopPropagation(); return; }
    var add=e.target.closest && e.target.closest('[data-recadd]');
    if(add){
      var spec=add.getAttribute('data-recadd').split('::'); var rid=spec[0], term=spec[1];
      var found=null; cats.forEach(function(c){ c.items.forEach(function(it){ if(String(it.id)===rid) found=it; }); });
      planner.push({ title: found?found.t:'', source:(found&&found.srcCode)||'WBRIDGE', term:term, status:'TODO',
        pending:{ resourceId:+rid, term:term, source:(found&&found.srcCode)||null } }); // 미저장 — '플래너 저장'에서 커밋
      renderPlanner();
      closeAllRecMenus(); e.stopPropagation();
    }
  });
  document.addEventListener('click', function(){ closeAllRecMenus(); }); // 바깥 클릭 시 메뉴 닫기

  // ---------- 일괄 저장 (담기 추가분 + 삭제 예정분을 한 번에 커밋) ----------
  document.getElementById('planSave').addEventListener('click', function(){
    var reqs=planner.filter(function(p){ return p.pending; }).map(function(p){ return p.pending; });
    var dels=pendingDeletes.slice();
    if(!reqs.length && !dels.length){ alert('변경사항이 없습니다.'); return; }
    var btn=this; btn.disabled=true;
    var calls=[];
    if(reqs.length){ calls.push(fetch(ctx+'/api/action-planner/items/batch',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(reqs)})); }
    dels.forEach(function(id){ calls.push(fetch(ctx+'/api/action-planner/items/'+id,{method:'DELETE'})); });
    Promise.all(calls)
      .then(function(rs){ rs.forEach(function(r){ if(!r.ok) throw new Error('HTTP '+r.status); }); alert('저장되었습니다. (추가 '+reqs.length+'건 · 삭제 '+dels.length+'건)'); return loadPlanner(); })
      .catch(function(err){ alert('저장 실패: '+err.message); })
      .then(function(){ btn.disabled=false; });
  });

  // ---------- init ----------
  loadPlanner();
  api('GET','/recommendations').then(function(recs){ buildCats(recs); renderTabs(); renderGrid(); }).catch(function(e){ console.error('추천 로드 실패', e); });
})();
</script>
</body>
</html>

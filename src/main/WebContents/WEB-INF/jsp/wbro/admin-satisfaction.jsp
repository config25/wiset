<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="wb" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>관리자 · 만족도 관리 · W브릿지</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">

<wb:admin active="sat" title="만족도 관리" sub="사용자 만족도 지표 및 피드백 상세로그">
  <div id="content"><div class="caption" style="padding:40px 0; color:var(--ink-400);">불러오는 중…</div></div>
</wb:admin>

<script>
(function () {
  var ctx = '${ctx}';
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  function nf(n){ return (n==null?0:n).toLocaleString('ko-KR'); }
  function stars(n,size){ var s=''; for(var i=1;i<=5;i++){ s+='<span style="color:'+(i<=n?'#FBBF24':'#E5E7EB')+'; font-size:'+size+'px;">★</span>'; } return s; }
  function avgStars(avg,size){ var s=''; for(var i=1;i<=5;i++){ var op=(i<=Math.round(avg))?1:0.3; s+='<span style="color:#FBBF24; opacity:'+op+'; font-size:'+size+'px;">★</span>'; } return s; }
  function sentTag(t){ return t==='긍정'?['#D1FAE5','#065F46']:t==='부정'?['#FEE2E2','#B91C1C']:['#F3F4F6','#374151']; }

  function render(d){
    var sm = d.summary||{}, sent = d.sentiment||[], trend = d.trend||{}, comp = d.complaints||[];
    var html = '';

    // SECTION 1
    html += '<div class="row items-center gap-8 mb-12"><span class="badge badge-blue">SECTION 1</span><h2 style="font-size:16px; font-weight:700; margin:0;">만족도 지표</h2></div>';

    var sentColor = {'긍정':'#10B981','중립':'#9CA3AF','부정':'#EF4444'};
    var deltaHtml = (sm.delta==null) ? '<span style="color:var(--ink-400);">전월 데이터 없음</span>'
        : (sm.delta>0 ? '<span style="color:#10B981;">↑ +'+sm.delta+' (전월 대비)</span>'
        : (sm.delta<0 ? '<span style="color:#EF4444;">↓ '+sm.delta+' (전월 대비)</span>'
        : '<span style="color:var(--ink-500);">± 0.00 (전월 대비)</span>'));

    html += '<div class="row gap-16 mb-16">'+
      '<div class="card" style="flex:1; padding:20px;"><div class="caption mb-8">사용자 만족도 평균</div>'+
        '<div class="row items-baseline gap-4 mb-12"><span style="font-size:32px; font-weight:800; color:var(--primary);">'+(sm.avg!=null?sm.avg:'-')+'</span><span class="caption">/ 5.0</span></div>'+
        '<div class="row gap-2 mb-8">'+avgStars(sm.avg||0,18)+'</div>'+
        '<div class="caption">'+deltaHtml+'</div>'+
        '<div class="caption mt-8" style="color:var(--ink-500);">평가 '+nf(sm.totalRatings)+'건 · 의견 '+nf(sm.totalFeedback)+'건</div></div>'+
      '<div class="card" style="flex:2; padding:20px;"><div class="h3 mb-12">유의 평가 결과 (텍스트 분석)</div><div class="row gap-12">'+
        sent.map(function(s){ var c=sentColor[s.label]||'#9CA3AF';
          return '<div class="card flex-1" style="text-align:center; padding:14px;"><div style="font-size:22px; font-weight:800; color:'+c+';">'+s.percent+'%</div><div class="caption fw-700">'+esc(s.label)+'</div><div class="caption" style="color:var(--ink-500);">'+nf(s.count)+'건</div></div>';
        }).join('')+
        '</div><div class="caption mt-12" style="color:var(--ink-500);">피드백 텍스트 NLP 분석 · 감성 분류 및 토픽 클러스터링</div></div></div>';

    // 행동 연계 추이 (라인 차트) + 불만 요소
    var pts = trend.points||[];
    var xs = pts.map(function(_,i){ return 60 + i*(320/Math.max(1,pts.length-1)); });
    function liney(v){ return (148-(v/100)*128).toFixed(1); }
    var chart = '<svg width="100%" height="180" viewBox="0 0 400 180">';
    for(var i=0;i<5;i++){ chart += '<line x1="40" y1="'+(20+i*32)+'" x2="380" y2="'+(20+i*32)+'" stroke="#E8EAEE"/>'; }
    chart += '<text x="20" y="24" font-size="10" fill="#6B7280" text-anchor="end">100%</text><text x="20" y="148" font-size="10" fill="#6B7280" text-anchor="end">0%</text>';
    [['satisfaction','#8B57AC'],['actionRate','#C8336B']].forEach(function(sk){
      var key=sk[0], col=sk[1];
      var poly = pts.map(function(p,i){ return xs[i].toFixed(1)+','+liney(p[key]); }).join(' ');
      chart += '<polyline points="'+poly+'" fill="none" stroke="'+col+'" stroke-width="2.5"/>';
      pts.forEach(function(p,i){ chart += '<circle cx="'+xs[i].toFixed(1)+'" cy="'+liney(p[key])+'" r="3.5" fill="'+col+'"/>'; });
    });
    pts.forEach(function(p,i){ chart += '<text x="'+xs[i].toFixed(1)+'" y="170" font-size="10" fill="#6B7280" text-anchor="middle">'+esc(p.label)+'</text>'; });
    chart += '</svg>';
    var corr = trend.correlation;
    var corrColor = (corr!=null && corr>=0)?'#10B981':'#EF4444';

    html += '<div class="row gap-16 mb-16">'+
      '<div class="card flex-1"><div class="h3 mb-16">행동 연계 추이</div><div class="caption mb-12" style="color:var(--ink-500);">리포트 만족도와 액션 실행률 상관 (최근 7주)</div>'+chart+
        '<div class="row gap-16 caption mt-8"><span><span style="display:inline-block; width:12px; height:2px; background:#8B57AC; vertical-align:middle; margin-right:6px;"></span>만족도</span><span><span style="display:inline-block; width:12px; height:2px; background:#C8336B; vertical-align:middle; margin-right:6px;"></span>액션 실행률</span><span style="margin-left:auto; color:'+corrColor+';">상관계수 '+(corr==null?'-':(corr>=0?'+':'')+corr)+'</span></div></div>'+
      '<div class="card flex-1"><div class="h3 mb-16">불만 요소 분석 (TOP 5)</div><div class="col gap-12">'+
        (comp.length? comp.map(function(s){ return '<div><div class="row justify-between mb-4"><span class="caption fw-700">'+esc(s.category)+'</span><span class="caption">'+nf(s.count)+'건 ('+s.percent+'%)</span></div><div style="height:10px; background:#FEE2E2; border-radius:5px;"><div style="width:'+s.percent+'%; height:100%; background:var(--accent); border-radius:5px;"></div></div></div>'; }).join('')
          : '<div class="caption" style="color:var(--ink-400);">부정 피드백이 없습니다.</div>')+
        '</div></div></div>';

    // 최근 피드백 목록
    var fb = d.recentFeedback||[];
    html += '<div class="card mb-24"><div class="row justify-between items-center mb-16"><div class="h3">최근 피드백 수집 목록</div><div class="row gap-8"><span class="badge badge-gray">의견 '+nf(sm.totalFeedback)+'</span><button type="button" class="btn btn-ghost btn-sm">전체 보기 →</button></div></div><div class="col gap-2">'+
      (fb.length? fb.map(function(f,i){ var tg=sentTag(f.sentiment); return '<div class="row gap-12" style="padding:12px 8px; border-bottom:'+(i<fb.length-1?'1px solid var(--line)':'none')+';">'+
        '<div class="caption" style="width:90px; color:var(--ink-500);">'+esc(f.time)+'</div><div class="caption" style="width:70px;">'+esc(f.persona)+'</div>'+
        '<div style="width:80px;">'+stars(f.rating,13)+'</div><div style="flex:1; font-size:13px; color:var(--ink-700);">'+esc(f.opinion)+'</div>'+
        '<span class="badge" style="background:'+tg[0]+'; color:'+tg[1]+';">'+esc(f.sentiment)+'</span></div>'; }).join('')
        : '<div class="caption" style="padding:16px 8px; color:var(--ink-400);">수집된 피드백이 없습니다.</div>')+
      '</div></div>';

    // SECTION 2
    html += '<div class="row items-center gap-8 mb-12"><span class="badge badge-ai">SECTION 2</span><h2 style="font-size:16px; font-weight:700; margin:0;">피드백 상세로그</h2></div>';
    var evals = d.evalHistory||[], logs = d.activityLog||[];
    html += '<div class="row gap-16">'+
      '<div class="card flex-1"><div class="row justify-between items-center mb-12"><div class="h3">만족도 평가 내역</div><input class="input" placeholder="🔍 사용자 ID, 리포트 ID 검색" style="font-size:12px; padding:6px 12px; width:180px;"></div>'+
        '<table style="width:100%; border-collapse:collapse; font-size:12px;"><thead><tr style="text-align:left; color:var(--ink-500); border-bottom:1px solid var(--line);"><th style="padding:8px 6px; font-weight:600;">일시</th><th style="padding:8px 6px; font-weight:600;">리포트</th><th style="padding:8px 6px; font-weight:600;">★</th><th style="padding:8px 6px; font-weight:600;">4문항 평균</th><th style="padding:8px 6px; font-weight:600;">의견</th></tr></thead><tbody>'+
        (evals.length? evals.map(function(r){ return '<tr style="border-bottom:1px solid var(--line);"><td style="padding:10px 6px; color:var(--ink-500);">'+esc(r.time)+'</td><td style="padding:10px 6px; font-family:\'JetBrains Mono\',monospace; color:var(--primary); font-size:11px;">'+esc(r.reportId)+'</td><td style="padding:10px 6px;"><span style="color:#FBBF24;">★</span> '+(r.star!=null?r.star:'-')+'</td><td style="padding:10px 6px;">'+(r.avg4!=null?r.avg4:'-')+'</td><td style="padding:10px 6px; color:var(--ink-500);">'+(r.hasOpinion?'있음':'없음')+'</td></tr>'; }).join('')
          : '<tr><td colspan="5" style="padding:16px 6px; color:var(--ink-400);">평가 내역이 없습니다.</td></tr>')+
        '</tbody></table></div>'+
      '<div class="card flex-1"><div class="row justify-between items-center mb-12"><div class="h3">행동 로그 상세</div><span class="caption" style="color:#10B981;">● LIVE</span></div>'+
        '<div class="col gap-0" style="font-size:12px; font-family:\'JetBrains Mono\',monospace;">'+
        (logs.length? logs.map(function(r){ return '<div class="row gap-8" style="padding:6px 4px; border-bottom:1px solid #F0F0F2;"><span style="color:#9AA0AA;">'+esc(r.time)+'</span><span style="color:var(--primary);">'+esc(r.user)+'</span><span class="badge" style="background:#F0F0F2; font-size:10px; padding:1px 6px;">'+esc(r.action)+'</span><span style="color:var(--ink-700); flex:1; font-size:11px;">'+esc(r.detail)+'</span></div>'; }).join('')
          : '<div class="caption" style="color:var(--ink-400); padding:8px 4px;">로그가 없습니다.</div>')+
        '</div></div></div>';

    document.getElementById('content').innerHTML = html;
  }

  function load(){
    fetch(ctx + '/api/admin/satisfaction').then(function(r){ return r.ok ? r.json() : null; }).then(function(d){
      if(!d){ document.getElementById('content').innerHTML = '<div class="caption" style="padding:40px 0; color:var(--accent);">데이터를 불러오지 못했습니다.</div>'; return; }
      render(d);
    }).catch(function(e){ console.error('만족도 로드 실패', e); });
  }

  load();
  setInterval(load, 5 * 60 * 1000);
})();
</script>
</body>
</html>

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
  <title>AI 코칭 리포트 · W브릿지 AI 커리어 코칭</title>
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

  <%-- Title + tabs --%>
  <div style="max-width:1100px; margin:0 auto; padding:32px 40px 0;">
    <div class="row items-center justify-between mb-16">
      <div>
        <span class="badge badge-ai" style="margin-bottom:8px;">AI 코칭 리포트</span>
        <h1 class="h1" style="margin:8px 0 4px;">AI 코칭</h1>
        <div class="caption" id="subtitle"></div>
      </div>
      <div class="row gap-8">
        <button type="button" class="btn btn-ghost btn-sm"><wb:icon-ds name="download" size="14" color="#3D4048" /> PDF 저장</button>
      </div>
    </div>
    <div class="tabs">
      <div class="tab active">AI 코칭</div>
      <div class="tab" data-go="/activity-analysis">활동 분석</div>
      <div class="tab" data-go="/action-plan">액션 플랜</div>
    </div>
  </div>

  <%-- Banner --%>
  <div style="max-width:1100px; margin:0 auto; padding:28px 40px 0;"><div id="banner"></div></div>

  <%-- Content --%>
  <div style="max-width:1100px; margin:0 auto; padding:24px 40px 60px;"><div class="card" style="padding:44px 48px;" id="content"></div></div>

  <%@ include file="common/footer-ds.jspf" %>

</div>

<script>
(function () {
  var ctx = '${ctx}';
  function esc(s){ return String(s==null?'':s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
  function qp(n){ var m=new RegExp('[?&]'+n+'=([^&]*)').exec(location.search); return m?decodeURIComponent(m[1]):''; }
  var ICONS = {
    flask:'<path d="M9 3h6M10 3v6L5 18a2 2 0 002 3h10a2 2 0 002-3l-5-9V3"/><path d="M8 14h8"/>',
    layers:'<path d="M12 3l9 5-9 5-9-5 9-5z"/><path d="M3 13l9 5 9-5M3 17l9 5 9-5"/>',
    refresh:'<path d="M4 11a8 8 0 0114-5l2 2M20 13a8 8 0 01-14 5l-2-2"/><path d="M20 4v5h-5M4 20v-5h5"/>',
    shield:'<path d="M12 3l7 3v5c0 4.5-3 8.2-7 10-4-1.8-7-5.5-7-10V6l7-3z"/><path d="M9 12l2 2 4-4"/>',
    sparkle:'<path d="M12 3l1.9 4.8L18.6 9l-4.7 1.9L12 15.6 10.1 10.9 5.4 9l4.7-1.2L12 3z"/><path d="M19 14l.7 1.8L21.5 16.5l-1.8.7L19 19l-.7-1.8L16.5 16.5l1.8-.7L19 14z"/>',
    graduation:'<path d="M3 9l9-4 9 4-9 4-9-4z"/><path d="M7 11v4.5c0 1.1 2.2 2 5 2s5-.9 5-2V11"/><path d="M21 9v5"/>',
    users:'<circle cx="9" cy="8" r="3.4"/><path d="M3.5 19a5.5 5.5 0 0111 0"/><path d="M16 5.2a3.4 3.4 0 010 6.4M17.5 13.4A5.5 5.5 0 0121 18.5"/>',
    trending:'<path d="M3 17l6-6 4 4 8-8"/><path d="M16 7h5v5"/>',
    trophy:'<path d="M7 4h10v4a5 5 0 01-10 0V4z"/><path d="M7 6H4.5a2.5 2.5 0 002.5 2.5M17 6h2.5A2.5 2.5 0 0117 8.5"/><path d="M10 13.5V17M14 13.5V17M8.5 21h7M9.5 21v-1.5a2.5 2.5 0 015 0V21"/>'
  };
  function icon(name,size,color){ return '<svg width="'+size+'" height="'+size+'" viewBox="0 0 24 24" fill="none" stroke="'+color+'" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0">'+(ICONS[name]||'')+'</svg>'; }

  var DATA = {
    '2': {
      subtitle: '화학·바이오 기술직 직무 전환 전략',
      banner: { grad:'linear-gradient(118deg, #0F5A4C 0%, #16887A 46%, #157C97 100%)', shadow:'0 20px 44px -22px rgba(12,70,62,0.6)', glow:'rgba(38,198,218,0.24)', icon:'flask',
        title:'화학·바이오 기술직에서 새로운 직무로의 전환을 준비하시는 회원님, 환영합니다.',
        chips:[{ic:'flask',t:'화학·바이오 산업'},{ic:'layers',t:'기술직 (R&D·QC·공정)'},{ic:'refresh',t:'직무 전환·이직 준비'}] },
      accent: '#0F7C8C',
      intro: [`화학 및 바이오 산업에서 기술직(연구개발, QC, 공정 등)으로 재직하다가 다른 직무로의 전환(이직 및 전직)을 희망하시는 경우, 기존에 쌓은 기술적 전문성을 완전히 버리는 것이 아니라 새로운 직무에서 어떻게 시너지를 낼 수 있을지 ‘전용성 기술(Transferable Skills)’을 파악하고 어필하는 것이 가장 중요합니다. 제공된 컨설팅 사례들을 바탕으로, 성공적인 직무 전환을 위한 맞춤형 경력개발 조언을 다음과 같이 제안해 드립니다.`],
      sections: [
        { no:'1', title:'기술적 백그라운드를 무기로 삼을 수 있는 타겟 직무 설정',
          lead:`화학/바이오 기술직의 경험은 비기술 직무에서 오히려 대체 불가능한 강력한 무기가 될 수 있습니다. 본인의 성향에 맞춰 다음의 직무들을 고려해 볼 수 있습니다.`,
          points:[
            {label:'사업개발(BD) 및 연구기획', text:`신약 파이프라인이나 새로운 기술의 가치를 1차적으로 평가하고 도입/수출을 논의하는 데 있어 연구 경험은 필수적인 자산입니다. 외부 기술을 검토하거나 유관부서와 소통할 때, 기초 생물학/화학에 대한 이해도와 실제 실험 경험을 갖춘 인재는 매우 유리합니다. 단, 글로벌 파트너링이 많으므로 비즈니스 영어 소통 능력을 반드시 갖추어야 합니다.`},
            {label:'인허가(RA) 및 품질보증(QA)', text:`실험실에서 원리를 이해하며 얻은 지식은 규제 기관의 가이드라인에 맞춰 문서를 작성하고 데이터를 검증하는 데 큰 도움이 됩니다. 화학/바이오 전공 지식을 살리되, 한국식약처(MFDS), FDA, EMA 등의 규정이나 GMP 가이드라인에 대한 추가적인 학습을 병행해야 합니다.`},
            {label:'기술영업 및 학술 마케팅', text:`사람들과 소통하고 설득하는 데 흥미가 있다면, 전문 지식을 바탕으로 고객에게 제품/솔루션을 설명하는 직무도 훌륭한 선택지입니다.`} ] },
        { no:'2', title:'사내 직무 이동(Job Rotation) 선행 검토',
          paras:[
            `다른 직무로 완전히 회사를 옮기는 것은 ‘이직’이 아닌 ‘전직’에 가깝기 때문에, 동일 직무 경력자들과 경쟁할 때 신입으로 평가받거나 연봉/처우 면에서 손해를 볼 수 있습니다.`,
            `따라서 가장 성공 확률이 높은 방법은 현재 재직 중인 회사 내부에서 먼저 원하는 부서(기획, 사업개발, RA 등)로 이동하여 1~2년 정도 실무 경력을 쌓은 뒤, 그 경력을 바탕으로 타 회사로 이직하는 것입니다.`] },
        { no:'3', title:'경력기술서의 전면적인 재구성 (Did List에서 성과 중심으로)',
          paras:[
            `새로운 직무로 지원할 때, 기존 이력서에 “어떤 장비를 써봤고, 어떤 실험을 했다”는 식의 단순 나열(Did List)을 작성하는 것은 피해야 합니다. 타겟으로 하는 새로운 직무의 요구 역량에 맞춰 본인의 경험을 번역해야 합니다.`,
            `예를 들어, “A실험 수행”이 아니라 “문제 발생 시 데이터를 기반으로 원인을 분석하고, 조건 최적화를 통해 수율을 00% 향상시켰으며, 이 과정에서 유관 부서와의 소통을 주도함”과 같이, 문제해결력, 데이터 분석력, 기획력, 소통 능력이 돋보이도록 STAR 기법(상황-과제-행동-결과)으로 성과를 수치화하여 포장해야 합니다.`] },
        { no:'4', title:'‘준비된 솔직함’으로 직무 전환 사유 포장',
          paras:[
            `면접 시 직무를 왜 바꾸려는지에 대한 질문은 반드시 나옵니다. 이때 “실험이 체력적으로 힘들어서”, “현재 직장 상사와의 불화 때문에”와 같은 부정적인 이유는 감점 요소가 됩니다.`,
            `대신, “기술적 실무를 수행하다 보니 개발된 기술이 시장에 어떻게 적용되고 사업화되는지에 더 큰 흥미를 느꼈다”거나 “연구 결과를 활용해 상용화와 전체 프로세스를 기획하는 일에 나의 강점이 있음을 깨달았다”는 등, 더 큰 시야로 성장하기 위한 능동적인 선택이었음을 어필해야 합니다.`] },
        { no:'5', title:'업계 트렌드 파악 및 추가 역량 개발',
          paras:[
            `직무 전환을 결심했다면, 한국바이오협회, 안전성평가연구소 등에서 주관하는 RA, 임상, GMP 관련 직무 교육을 수강하여 직무에 대한 관심도와 기본 지식을 객관적으로 증명하는 것이 좋습니다. 또한, ‘바이오스펙테이터’ 등 전문 언론을 통해 해당 산업계의 최신 파이프라인 동향과 트렌드를 꾸준히 학습하여, 면접 시 산업에 대한 깊은 이해도를 보여주어야 합니다.`] }
      ]
    },
    '1': {
      subtitle: 'AI × 정보보안 융합 취업 전략',
      banner: { grad:'linear-gradient(118deg, #45205F 0%, #6A2D91 44%, #0F7C8C 100%)', shadow:'0 20px 44px -22px rgba(50,20,80,0.65)', glow:'rgba(38,198,218,0.22)', icon:'shield',
        title:'AI 정보보안 연구지원직 신규 취업을 준비하시는 회원님, 환영합니다.',
        chips:[{ic:'sparkle',t:'AI 정보보안'},{ic:'flask',t:'연구지원직'},{ic:'graduation',t:'신규취업 희망자'}] },
      accent: 'var(--brand)',
      intro: [`AI 정보보안 업계로 취업을 희망하는 졸업예정자를 위한 맞춤형 경력개발 및 취업 전략을 제안해 드립니다. 신입 지원자로서 AI 기술 트렌드와 정보보안의 융합을 어떻게 강점으로 어필할 수 있을지에 대한 구체적인 방법론입니다.`],
      sections: [
        { no:'1', title:'AI 프로젝트 경험과 보안 직무의 전략적 연결',
          lead:`학부 시절 캡스톤 디자인 등에서 진행한 AI 관련 프로젝트(예: 챗봇, 이미지 인식 등)가 보안과 직접적인 연관이 없다고 느껴질 수 있으나, 이를 보안 컨설팅 및 운영과 연결 짓는 스토리텔링이 중요합니다.`,
          points:[
            {label:'보안 자동화 도구로의 어필', text:`단순히 AI 모델을 써봤다에 그치지 않고, RAG(검색 증강 생성)나 sLLM(소형 언어 모델) 기반의 자동화 툴을 설계하여 수작업 중심의 보안 정책 적용 한계를 극복한 사례로 발전시킬 수 있습니다. 이때 AI의 판단 결과에 대한 ‘책임 추적성(Human-in-the-loop)’을 확보했다는 논리를 더하면, 기술을 위한 기술이 아닌 실제 보안 운영 현장의 병목을 해결하는 역량으로 평가받을 수 있습니다.`},
            {label:'최신 보안 위협 대응 논리', text:`생성형 AI를 이용한 딥페이크나 AI 사칭 공격 등 새로운 위협에 대응하기 위해, 거래 맥락을 실시간으로 분석하는 ‘적응형 인증’ 체계를 도입해야 한다는 식의 트렌디한 접근을 자소서나 면접에 녹여내는 것이 좋습니다. 보안성은 극대화하되 고객의 체감 속도는 저해하지 않는 ‘빠르고 안전한’ 환경 구축을 강조하십시오.`} ] },
        { no:'2', title:'명확한 타겟 직무 설정',
          paras:[
            `정보보안 분야는 크게 ISMS/ISO27001 인증, 개인정보 컴플라이언스를 다루는 관리/컨설팅 직무와 모의해킹, 취약점 진단을 수행하는 기술 직무, 그리고 사내 보안을 담당하는 보안 운영 담당자로 나뉩니다.`,
            `만약 해킹 기술이나 소스코드 분석에 스트레스를 받는다면, 고객사의 보안 수준을 진단하고 정책을 수립하는 보안 컨설팅이나 관리 직무로 방향을 잡는 것이 유리합니다.`,
            `신입의 경우 영업적인 스킬보다는 고객사와의 원활한 커뮤니케이션 능력이 훨씬 중요하게 요구되므로, 내향적인 성격이더라도 논리적 소통 능력을 기르는 데 집중하면 충분히 훌륭한 컨설턴트가 될 수 있습니다.`] },
        { no:'3', title:'필수 자격증 및 클라우드 보안 역량 강화',
          lead:`정보보안 전문가로 성장하기 위해 졸업 전후로 취득 및 보완해야 할 스펙은 다음과 같습니다.`,
          points:[
            {label:'보안 관련 자격증', text:`정보보안기사 취득이 어렵다면, 실무에서 널리 인정받는 CPPG(개인정보관리사)나 PIA(개인정보 영향평가 전문인력) 자격증 취득을 적극적으로 고려하시기 바랍니다.`},
            {label:'클라우드 보안 역량', text:`최근 대다수의 기업이 클라우드 환경으로 인프라를 이전함에 따라 클라우드 보안 지식은 필수가 되었습니다. AWS, GCP, MS Azure 등의 클라우드 환경에 대한 이해도를 높이고, 관련된 기본 자격증(예: AWS Certified Security 등)을 취득하면 취업 시장에서 매우 강력한 차별화 포인트가 됩니다.`} ] },
        { no:'4', title:'자기소개서 및 포트폴리오 작성 전략',
          points:[
            {label:'‘바르게’와 ‘빠르게’의 가치 어필', text:`단순 문서 작업이 아니라 실제 보안 취약점을 메우는 ‘실천적 보안’을 수행하겠다는 점을 강조하십시오. ACL 목록과 실제 권한 체계 사이의 사각지대를 조사해 비인가 접근을 원천 차단한다는 식의 구체적인 개선 방향을 제시하는 것이 좋습니다.`},
            {label:'포트폴리오의 구체화', text:`포트폴리오를 작성할 때는 단순히 프로젝트명이나 툴을 나열하는 것을 넘어, “어떤 문제를 발견했고, 왜 AI/보안 기술을 적용했으며, 결과적으로 어떤 개선(예: 응답 정확도 60%에서 85%로 향상)을 이루었는지”를 명확하게 수치화하여 담아야 합니다.`} ] },
        { no:'5', title:'기술 면접 대비 및 보안 트렌드 학습',
          lead:`신입 보안 직무 면접에서는 기본적인 전공 지식과 최신 보안 동향에 대한 질문이 반드시 출제됩니다.`,
          points:[
            {label:'기술 지식', text:`SSL/TLS 등 암호화 프로토콜, RSA(공개키 암호화), 양방향/단방향 암호화, OSI 7계층 및 TCP 3-way handshake 등 CS 기본 지식을 탄탄히 준비해야 합니다.`},
            {label:'보안 취약점 이해', text:`OWASP Top 10을 비롯해 XSS, SQL 인젝션, 버퍼 오버플로우 등 주요 공격 기법과 방어 대책을 숙지하십시오.`},
            {label:'최신 동향 파악', text:`랜섬웨어, 제로데이 공격, 블록체인 등 최신 IT 이슈와 개인정보보호법, 정보통신망법 등 관련 법률 트렌드를 주기적으로 학습하여 면접 시 본인의 통찰력을 어필하는 것이 좋습니다.`} ] }
      ],
      closing: `AI와 정보보안 모두 변화가 매우 빠른 분야이므로, 가장 중요한 것은 끊임없이 새로운 기술과 법률 동향을 학습하려는 성장 의지와 주도성을 보여주는 것입니다. 완벽한 기술력을 포장하기보다는, 현재 가진 AI 프로젝트 경험을 보안의 관점에서 재해석하여 지원하신다면 좋은 결과를 얻을 수 있을 것입니다.`
    },
    '3': {
      subtitle: '반도체 연구개발직 경력복귀 전략',
      banner: { grad:'linear-gradient(118deg, #5C1E48 0%, #B5266E 48%, #E0497F 100%)', shadow:'0 20px 44px -22px rgba(80,18,55,0.6)', glow:'rgba(255,210,225,0.22)', icon:'refresh',
        title:'반도체 연구개발직으로의 경력복귀를 준비하시는 회원님, 응원합니다.',
        chips:[{ic:'layers',t:'반도체·디스플레이 산업'},{ic:'flask',t:'연구개발(R&D) 직무'},{ic:'refresh',t:'경력단절 후 재취업'}] },
      accent: '#C9295F',
      intro: [`반도체 연구개발직 재취업을 준비하시면서 긴 공백기로 인해 막막함과 두려움이 크실 것으로 생각됩니다. 제공된 컨설팅 사례 중에는 삼성전자 반도체 개발 엔지니어로 7년 이상 근무하다가 건강 및 육아 등의 이유로 6년 이상의 경력단절을 겪은 후, 40대 후반의 나이에 다시 반도체 업계로 복귀를 희망한 매우 유사한 사례가 존재합니다. 이 사례에서 여러 이공계 전문 컨설턴트들이 제시한 조언을 바탕으로, 성공적인 재취업을 위한 5가지 핵심 경력개발 전략을 1000자 이상으로 상세히 제안해 드립니다.`],
      sections: [
        { no:'1', title:'지원 산업 및 직무의 유연한 확장',
          paras:[
            `경력단절 후 재진입 시, 과거에 근무했던 종합 반도체 제조사(칩메이커)나 특정 R&D 직무만을 고집하기보다는 시야를 넓히는 것이 매우 중요합니다. 반도체 산업뿐만 아니라 기술적 유사성이 높은 디스플레이 산업까지 지원 범위를 넓히는 것을 권장합니다.`,
            `또한, 직무에 있어서도 순수 연구개발에만 국한하지 말고, 과거의 공정 지식과 분석 경험을 활용할 수 있는 장비 업체나 재료 업체로 지원하거나, 더 나아가 기술 마케팅, 공정 기술, 재료 물성 분석 등 본인의 역량으로 커버할 수 있는 다양한 직무로 가능성을 열어두어야 합니다.`] },
        { no:'2', title:'타겟 직무별 맞춤형 이력서 준비 및 역량 어필',
          paras:[
            `경력직 재취업의 핵심은 지원자가 가진 과거의 역량이 현재 지원하는 직무에서 ‘어떤 강점이 될 것인지’를 명확히 보여주는 것입니다. 이를 위해 원본 이력서를 하나 만들어 둔 후, 본인의 경험, 지식, 기술을 세부적으로 분류하여 표 형태로 정리해 두는 작업이 필요합니다.`,
            `이를 바탕으로 공정, 마케팅, 디스플레이 등 지원하려는 직무 유형에 최적화된 2~3가지 버전의 이력서와 자기소개서를 미리 준비해 두면, 적합한 채용 공고가 떴을 때 즉각적이고 효과적으로 대응할 수 있습니다.`] },
        { no:'3', title:'공백기에 대한 긍정적인 스토리텔링 구축',
          paras:[
            `면접 시 긴 공백기에 대한 질문은 반드시 나옵니다. 이때 공백기를 단순히 육아, 건강 악화 등의 개인적인 약점으로만 설명하기보다는, 삶의 방향을 제고해 보고 자신의 직업적 가치관과 방향을 더욱 확고히 다지는 시간으로 긍정적으로 재해석하여 풀어내는 것이 현명합니다.`,
            `더불어, 긴 공백을 깨고 “왜 다시 다른 곳도 아닌 반도체 업계로 돌아오고자 하는지”에 대한 명확하고 설득력 있는 답변을 미리 준비하여, 지원자의 확고한 복귀 의지와 열정을 면접관에게 각인시켜야 합니다.`] },
        { no:'4', title:'헤드헌터 및 비즈니스 네트워킹의 적극적 활용',
          paras:[
            `공개된 채용 공고에만 의존하기보다는 헤드헌터의 제안을 적극적으로 활용하는 것이 경력직 취업에 훨씬 수월할 수 있습니다. 사람인, 잡코리아는 물론, 최근 경력직 이직이 활발한 리멤버 커리어(어플) 같은 플랫폼에 이력서를 오픈해 두시길 권합니다.`,
            `또한, 링크드인(LinkedIn)에 영문 이력서를 업데이트하여 동종 업계 실무자 및 헤드헌터들과 네트워크를 구축하고, 이를 기반으로 추천 입사 기회를 마련하는 것도 매우 훌륭한 전략입니다.`,
            `나아가 외국계 장비사 등을 목표로 한다면 피플앤잡 같은 외국계 전문 사이트를 주시하며 영문 커버레터와 레쥬메를 함께 준비해 두는 것이 좋습니다.`] },
        { no:'5', title:'정부 지원 사업(WISET 경력복귀 지원사업) 적극 활용',
          paras:[
            `한국여성과학기술인육성재단(WISET) 등에서 운영하는 ‘여성과학기술인 R&D 경력복귀 지원사업’을 적극적으로 활용해 보시기 바랍니다.`,
            `이 사업은 임신, 출산, 육아 등으로 경력이 단절된 이공계 여성 인력이 연구 현장으로 복귀할 수 있도록 채용 기업에 인건비를 지원해 주는 프로그램입니다. 입사 지원 시 본인이 이러한 인건비 지원 사업의 대상자임을 기업에 적극적으로 피력한다면, 채용 기업 입장에서도 인건비 부담을 줄일 수 있어 채용의 문턱이 훨씬 낮아지는 긍정적인 혜택을 볼 수 있습니다.`] }
      ],
      closing: { title:'마무리 조언', paras:[
        `반도체 산업은 기술 변화가 매우 빨라 공백기에 대한 두려움이 클 수 있습니다. 하지만 과거에 쌓은 탄탄한 R&D 실무 경력은 결코 사라지지 않습니다. 공백기에 대한 걱정보다는 본인의 과거 업무 역량과 전문성에 확신을 가지고 당당하게 어필하며 적극적으로 여러 곳에 지원하는 것이 재취업 성공의 가장 빠른 지름길입니다. 스스로의 역량을 믿고 씩씩하게 도전하시기를 응원합니다.`] }
    },
    '4': {
      subtitle: '연구지원 실무자 → 팀장(관리자) 성장 전략',
      banner: { grad:'linear-gradient(118deg, #1B2F5E 0%, #294C92 48%, #3A6FC0 100%)', shadow:'0 20px 44px -22px rgba(20,40,90,0.62)', glow:'rgba(120,170,255,0.24)', icon:'trophy',
        title:'화학·바이오 연구지원직에서 팀장(관리자)으로의 성장을 준비하시는 회원님, 응원합니다.',
        chips:[{ic:'flask',t:'화학·바이오 연구지원'},{ic:'users',t:'팀장·중간관리자 목표'},{ic:'trending',t:'승진·리더십 성장'}] },
      accent: '#2D5BA8',
      intro: [
        `화학·바이오 분야에서 연구지원 업무를 수행하며 팀장(관리자)으로의 승진과 성장을 꿈꾸시는 상황이군요. 제공된 여러 컨설팅 사례 중, 실무자에서 중간 관리자나 매니지먼트 역할로 도약하고자 하는 내담자들을 위한 조언을 바탕으로 맞춤형 경력개발 가이드를 제안해 드립니다.`,
        `팀장으로 성장하기 위해서는 단순히 주어진 실무를 꼼꼼히 해내는 '실무자(Doer)'의 마인드에서 벗어나, 조직 전체의 성과를 관리하고 비전을 제시하는 '관리자(Manager/Planner)'의 시각을 갖추는 것이 핵심입니다. 성공적인 승진과 리더십 구축을 위해 다음의 4가지 전략을 실천해 보시기를 권해드립니다.`],
      sections: [
        { no:'1', title:`'데이터 전달자'에서 '의사결정 설계자(Decision Architect)'로의 진화`,
          paras:[
            `연구지원 직무는 연구가 원활히 진행되도록 돕는 것이 기본이지만, 팀장급으로 성장하려면 수집된 현장의 데이터를 바탕으로 '큰 그림'을 그릴 줄 알아야 합니다. 현장의 데이터나 보고서를 단순히 취합하여 전달하는 것에 그치지 말고, 경영진의 판단과 의사결정에 필요한 인사이트로 번역하여 제시하는 '의사결정 구조 설계자'로서의 역량을 키워야 합니다.`,
            `또한, 현재 회사가 진행 중인 화학·바이오 파이프라인이나 연구가 시장 트렌드와 어떻게 맞닿아 있는지 분석하고, 새로운 시스템이나 업무 효율화 방안을 선제적으로 제안할 수 있어야 합니다.`] },
        { no:'2', title:`상하급자를 연결하는 '소통과 조율의 리더십' 함양`,
          paras:[
            `팀장은 상급자(임원진)의 요구사항과 하급자(팀원)의 의견을 절충하고 조율하는 핵심적인 위치입니다. 중간관리자로서 상급자의 지시를 단순히 전달하는 역할에 머무르면 안 됩니다. 지시사항의 명확한 목적을 먼저 이해한 후, 이를 본인만의 언어로 팀원들에게 전달하고 설득하는 리더십이 필요합니다.`,
            `동시에 팀원들이 업무에서 기대하는 바나 개인적 역량을 1:1 면담 등을 통해 파악하고, 이를 반영해 업무를 분배하고 이끌어가는 현명한 관리가 필수적입니다.`] },
        { no:'3', title:`연구지원을 넘어 '조직 전체 성과 창출'로 업무 시야 확장`,
          paras:[
            `매니지먼트(팀장)로서의 커리어를 목표로 한다면, 자신의 고유 업무를 완벽히 수행하는 것을 넘어 다른 팀과의 협업 능력을 적극적으로 증명해야 합니다. ① 본인 업무의 철저한 완성을 기본으로 하되, ② 연관 부서의 업무에 대한 이해도를 높이고, ③ 공통 업무에 적극적으로 관심을 가지십시오.`,
            `연구지원 업무는 결국 연구자의 진행을 관리할 뿐만 아니라 타 부서와의 협업을 원활하게 만들어 '소속 조직 전체의 성과 증대'에 기여하는 자리입니다. 타 부서(기획, 개발, 영업 등)와 협업할 기회가 있다면 자진해서 참여하고 우호적인 네트워크를 쌓아둔다면, 조직 내에서 없어서는 안 될 핵심 인재로 평가받을 수 있습니다.`] },
        { no:'4', title:'체계적인 성과 기록과 전략적인 자기 PR',
          paras:[
            `임원진이나 인사권자에게 리더로서의 자질을 인정받으려면 '자기 PR'도 무척 중요합니다. 묵묵히 일만 한다고 해서 조직이 나의 모든 헌신을 알아주지는 않습니다. 본인이 지원한 연구 프로젝트가 구체적으로 어떤 성과를 냈는지, 부서 간 협력을 통해 얼마나 일정을 단축하고 비용을 절감했는지 등을 정량적인 수치와 함께 기록해 두십시오.`,
            `그리고 업무 중간보고나 결과보고, 메신저 보고 등 다양한 기회를 수시로 활용하여 본인이 조직 내에서 어떤 기여를 하고 있는지 상급자에게 자연스러우면서도 명확하게 어필하는 습관을 들이셔야 합니다.`] }
      ],
      closing: `팀장이라는 자리는 단순히 실무를 오래 했다고 주어지는 것이 아니라, 조직의 비전을 이해하고 구성원의 시너지를 이끌어낼 수 있음을 증명할 때 쟁취할 수 있습니다. 현재의 연구지원 실무 감각을 잃지 않으면서도 타 부서와의 소통을 이끌고 적극적으로 성과를 어필해 나가신다면, 머지않아 훌륭한 관리자로 발돋움하실 수 있을 것입니다.`
    }
  };

  var persona = qp('persona');
  var d = DATA[persona] || DATA['2'];

  // 배너(페르소나 테마 컬러 카드) — 구조화/TEXT 모드 공용.
  function renderBanner(d){
  var b = d.banner;
  document.getElementById('banner').innerHTML =
    '<div style="border-radius:18px; padding:26px 30px; position:relative; overflow:hidden; background:'+b.grad+'; box-shadow:'+b.shadow+';">'+
      '<div style="position:absolute; right:-46px; top:-54px; width:210px; height:210px; border-radius:50%; background:radial-gradient(circle, rgba(255,255,255,0.13), transparent 70%);"></div>'+
      '<div style="position:absolute; left:38%; bottom:-90px; width:200px; height:200px; border-radius:50%; background:radial-gradient(circle, '+b.glow+', transparent 70%);"></div>'+
      '<div class="row items-center gap-20" style="position:relative;">'+
        '<div style="width:66px; height:66px; border-radius:18px; flex-shrink:0; background:rgba(255,255,255,0.13); border:1px solid rgba(255,255,255,0.28); display:flex; align-items:center; justify-content:center;">'+icon(b.icon,30,'#fff')+'</div>'+
        '<div style="flex:1;">'+
          '<div style="font-size:12px; font-weight:800; letter-spacing:0.13em; color:rgba(255,255,255,0.82); text-transform:uppercase; margin-bottom:7px;">맞춤형 AI 커리어 코칭</div>'+
          '<div style="font-size:20px; font-weight:700; color:#fff; line-height:1.45; margin-bottom:12px;">'+esc(b.title)+'</div>'+
          '<div class="row gap-8 flex-wrap">'+ b.chips.map(function(c){ return '<span style="display:inline-flex; align-items:center; gap:6px; padding:7px 14px; border-radius:999px; font-size:12.5px; font-weight:700; background:rgba(255,255,255,0.15); color:#fff; border:1px solid rgba(255,255,255,0.3);">'+icon(c.ic,13,'#fff')+' '+esc(c.t)+'</span>'; }).join('')+'</div>'+
        '</div>'+
      '</div>'+
    '</div>';
  }

  // 통짜 TEXT 본문 → 간단 서식 규칙으로 구조 복원(원래 섹션 디자인 재현).
  //   "숫자." 단독 줄 = 섹션 번호(다음 줄이 제목) / "숫자. 제목" 인라인 허용,
  //   종결(마침표·다/요 등)로 끝나는 줄 = 문단, 그 외 짧은 줄 = 소제목, 빈 줄 = 블록 구분.
  //   배너/부제목은 페르소나 테마 유지.
  function renderText(d, text){
    document.getElementById('subtitle').textContent = d.subtitle;
    renderBanner(d);
    var lines = String(text==null?'':text).split(/\r?\n/);
    var pBody  = 'font-size:15px; line-height:1.9; color:var(--ink-700);';
    var pIntro = 'font-size:16px; line-height:1.9; color:var(--ink);';
    function endsSentence(s){ return /[.!?…]$/.test(s) || /[다요죠함음됨임니다]$/.test(s); }
    var html = '', open = false, seen = false;
    function close(){ if(open){ html += '</div>'; open = false; } }
    function head(no, title){
      close();
      html += '<div style="margin-top:40px; padding-top:32px; border-top:1px solid var(--line);">'+
        '<h2 style="font-size:21px; font-weight:700; color:var(--ink); letter-spacing:-0.02em; line-height:1.4; margin:0 0 16px; display:flex; align-items:baseline; gap:10px;">'+
        (no!=null ? '<span style="color:'+d.accent+'; font-family:\'JetBrains Mono\',monospace; font-weight:700; font-size:18px;">'+esc(no)+'.</span>' : '')+
        esc(title)+'</h2>';
      open = true; seen = true;
    }
    for(var i=0; i<lines.length; i++){
      var line = lines[i].trim();
      if(line === '') continue;
      var mAlone = /^(\d+)\.$/.exec(line);          // "1." 단독 줄 → 다음 비빈 줄이 제목
      if(mAlone){
        var j=i+1; while(j<lines.length && lines[j].trim()==='') j++;
        head(mAlone[1], j<lines.length ? lines[j].trim() : '');
        i = j; continue;
      }
      var mInline = /^(\d+)\.\s+(.+)$/.exec(line);   // "1. 제목" 인라인
      if(mInline){ head(mInline[1], mInline[2]); continue; }
      if(!endsSentence(line) && line.length <= 40){  // 소제목(종결 안 됨 + 짧음) — accent 색 굵게
        html += '<div style="font-size:15px; font-weight:700; color:'+d.accent+'; margin:20px 0 7px;">'+esc(line)+'</div>';
        continue;
      }
      html += '<p style="'+(seen?pBody:pIntro)+' margin:0 0 14px;">'+esc(line)+'</p>'; // 문단
    }
    close();
    document.getElementById('content').innerHTML = html;
  }

  function renderReport(d){
  document.getElementById('subtitle').textContent = d.subtitle;
  renderBanner(d);

  // 본문
  var pStyle = 'font-size:15px; line-height:1.9; color:var(--ink-700);';
  var html = '';
  d.intro.forEach(function(p,i){ html += '<p style="font-size:16px; line-height:1.9; color:var(--ink); margin:'+(i===d.intro.length-1?'0':'0 0 12px')+';">'+esc(p)+'</p>'; });
  d.sections.forEach(function(s){
    html += '<div style="margin-top:40px; padding-top:32px; border-top:1px solid var(--line);">';
    html += '<h2 style="font-size:21px; font-weight:700; color:var(--ink); letter-spacing:-0.02em; line-height:1.4; margin:0 0 16px; display:flex; align-items:baseline; gap:10px;"><span style="color:'+d.accent+'; font-family:\'JetBrains Mono\',monospace; font-weight:700; font-size:18px;">'+s.no+'.</span>'+esc(s.title)+'</h2>';
    if(s.lead) html += '<p style="'+pStyle+' margin:0 0 18px;">'+esc(s.lead)+'</p>';
    if(s.paras) s.paras.forEach(function(p,j){ html += '<p style="'+pStyle+' margin:'+(j===s.paras.length-1?'0':'0 0 14px')+';">'+esc(p)+'</p>'; });
    if(s.points){ html += '<div style="display:flex; flex-direction:column; gap:18px;">'; s.points.forEach(function(pt){ html += '<div><div style="font-size:15px; font-weight:700; color:var(--ink); margin-bottom:6px;">'+esc(pt.label)+'</div><p style="'+pStyle+' margin:0;">'+esc(pt.text)+'</p></div>'; }); html += '</div>'; }
    html += '</div>';
  });
  if(d.closing){
    html += '<div style="margin-top:40px; padding-top:32px; border-top:1px solid var(--line);">';
    if(typeof d.closing === 'object'){
      if(d.closing.title) html += '<h2 style="font-size:21px; font-weight:700; color:var(--ink); letter-spacing:-0.02em; line-height:1.4; margin:0 0 16px; display:flex; align-items:center; gap:10px;">'+icon('sparkle',20,d.accent)+esc(d.closing.title)+'</h2>';
      d.closing.paras.forEach(function(p){ html += '<p style="'+pStyle+' margin:0;">'+esc(p)+'</p>'; });
    } else {
      html += '<p style="'+pStyle+' margin:0;">'+esc(d.closing)+'</p>';
    }
    html += '</div>';
  }
  document.getElementById('content').innerHTML = html;
  }

  // 저장된 리포트(JSON)가 있으면 '내용'만 덮어쓰고 렌더 — 테마(색/그라데이션)는 페르소나 디자인 유지.
  // 리포트 재조회(리포트 보기) 시 동일 디자인 그대로 재현. 저장된 게 없으면 목업(DATA) 폴백.
  var did = qp('diagnosisId');
  fetch(ctx + '/api/ai-coaching/report' + (did?('?diagnosisId='+encodeURIComponent(did)):'')).then(function(r){ return r.ok ? r.json() : null; }).then(function(rep){
    var c = rep && rep.content;
    // 컬럼형 메타(AI 생성 제목/부제목/키워드 칩) — 텍스트/구조 모드 무관하게 배너에 반영.
    // chips 는 서버에서 [{ic,t}] 로 파싱돼 오므로 아이콘이 보존된다.
    if(rep){
      if(rep.bannerTitle) d.banner.title = rep.bannerTitle;
      if(rep.subtitle)    d.subtitle     = rep.subtitle;
      if(rep.chips && rep.chips.length) d.banner.chips = rep.chips;
    }
    // 자동 감지: content 가 통짜 문자열이거나 {text:"..."} 형태면 TEXT 모드,
    //            sections 등을 가진 객체면 기존 구조화 렌더. (둘 다 호환)
    var bodyText = null;
    if(typeof c === 'string')                bodyText = c;
    else if(c && typeof c.text === 'string') bodyText = c.text;
    if(bodyText != null){
      // 레거시: 메타가 content(JSON) 안에 들어온 경우도 반영
      if(c && typeof c === 'object'){
        if(c.subtitle) d.subtitle = c.subtitle;
        if(c.title)    d.banner.title = c.title;
        if(c.chips)    d.banner.chips = c.chips;
      }
      renderText(d, bodyText);
      return;
    }
    if(c){
      if(c.subtitle) d.subtitle = c.subtitle;
      if(c.title)    d.banner.title = c.title;
      if(c.chips)    d.banner.chips = c.chips;
      if(c.intro)    d.intro = c.intro;
      if(c.sections) d.sections = c.sections;
      if('closing' in c) d.closing = c.closing;
    }
    renderReport(d);
  }).catch(function(){ renderReport(d); });

  // 탭 이동 (persona + diagnosisId 유지 — 특정 진단 리포트 조회 모드 보존)
  var sp=[]; if(persona) sp.push('persona='+encodeURIComponent(persona)); if(did) sp.push('diagnosisId='+encodeURIComponent(did));
  var suf = sp.length ? ('?'+sp.join('&')) : '';
  Array.prototype.forEach.call(document.querySelectorAll('.tab[data-go]'), function(t){
    t.style.cursor = 'pointer';
    t.addEventListener('click', function(){ location.href = ctx + t.getAttribute('data-go') + suf; });
  });
})();
</script>
</body>
</html>

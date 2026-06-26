<%@ tag pageEncoding="UTF-8" body-content="scriptless" %>
<%-- 마이페이지 공용 크롬 (GNB는 페이지가 include, 푸터도 페이지가 include). active: dash | planner | history --%>
<%@ attribute name="active" required="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="wb" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- Breadcrumb --%>
<div style="max-width:1100px; margin:0 auto; padding:14px 40px 0;">
  <div class="caption" style="color:var(--ink-500);">🏠 Home › MyPage › 나의커리어지원 › <span class="fw-700" style="color:var(--ink);">AI 커리어 코칭</span></div>
</div>
<div style="max-width:1100px; margin:0 auto; padding:24px 40px 8px; text-align:center;">
  <h1 style="font-size:26px; font-weight:800; margin:0;">MyPage</h1>
</div>

<%-- Top tabs --%>
<div style="max-width:1100px; margin:0 auto; padding:20px 40px 0; border-bottom:1px solid var(--line);">
  <div class="row justify-center" style="gap:0;">
    <div style="padding:14px 22px; font-size:14px; font-weight:500; color:var(--ink-700); border-bottom:3px solid transparent; cursor:pointer;">기본정보</div>
    <div style="padding:14px 22px; font-size:14px; font-weight:500; color:var(--ink-700); border-bottom:3px solid transparent; cursor:pointer;">경력정보관리</div>
    <div style="padding:14px 22px; font-size:14px; font-weight:500; color:var(--ink-700); border-bottom:3px solid transparent; cursor:pointer;">나의교육</div>
    <div style="padding:14px 22px; font-size:14px; font-weight:500; color:var(--ink-700); border-bottom:3px solid transparent; cursor:pointer;">나의멘토링</div>
    <div style="padding:14px 22px; font-size:14px; font-weight:500; color:var(--ink-700); border-bottom:3px solid transparent; cursor:pointer;">나의일자리</div>
    <div style="padding:14px 22px; font-size:14px; font-weight:700; color:var(--primary); border-bottom:3px solid var(--primary); cursor:pointer;">나의커리어지원</div>
    <div style="padding:14px 22px; font-size:14px; font-weight:500; color:var(--ink-700); border-bottom:3px solid transparent; cursor:pointer;">나의전문가활동</div>
  </div>
</div>

<%-- Sub tabs --%>
<div style="background:var(--bg-soft); border-bottom:1px solid var(--line);">
  <div style="max-width:1100px; margin:0 auto; padding:0 40px;">
    <div class="row" style="gap:0;">
      <div style="padding:12px 18px; font-size:13px; font-weight:500; color:var(--ink-700); border-top:2px solid transparent; cursor:pointer;">진단 이력</div>
      <div style="padding:12px 18px; font-size:13px; font-weight:700; color:var(--primary); background:#fff; border-top:2px solid var(--primary); cursor:pointer;">AI 커리어 코칭</div>
      <div style="padding:12px 18px; font-size:13px; font-weight:500; color:var(--ink-700); border-top:2px solid transparent; cursor:pointer;">관심 채용공고</div>
      <div style="padding:12px 18px; font-size:13px; font-weight:500; color:var(--ink-700); border-top:2px solid transparent; cursor:pointer;">컨설팅 신청</div>
    </div>
  </div>
</div>

<%-- Content area --%>
<div style="max-width:1100px; margin:0 auto; padding:32px 40px 60px;">
  <div class="row items-center gap-8 mb-24">
    <wb:icon-ds name="sparkle" size="20" color="#6A4C9C" />
    <h2 style="font-size:20px; font-weight:800; margin:0; color:var(--primary);">AI 커리어 코칭</h2>
  </div>
  <div class="row gap-2 mb-24" style="border-bottom:1px solid var(--line);">
    <a href="${ctx}/mypage-dashboard" style="padding:10px 18px; font-size:13px; margin-bottom:-1px; cursor:pointer; text-decoration:none; font-weight:${active eq 'dash' ? 700 : 500}; color:${active eq 'dash' ? 'var(--accent)' : 'var(--ink-700)'}; border-bottom:2px solid ${active eq 'dash' ? 'var(--accent)' : 'transparent'};">대시보드</a>
    <a href="${ctx}/mypage-action-planner" style="padding:10px 18px; font-size:13px; margin-bottom:-1px; cursor:pointer; text-decoration:none; font-weight:${active eq 'planner' ? 700 : 500}; color:${active eq 'planner' ? 'var(--accent)' : 'var(--ink-700)'}; border-bottom:2px solid ${active eq 'planner' ? 'var(--accent)' : 'transparent'};">액션 플래너</a>
    <a href="${ctx}/mypage-history" style="padding:10px 18px; font-size:13px; margin-bottom:-1px; cursor:pointer; text-decoration:none; font-weight:${active eq 'history' ? 700 : 500}; color:${active eq 'history' ? 'var(--accent)' : 'var(--ink-700)'}; border-bottom:2px solid ${active eq 'history' ? 'var(--accent)' : 'transparent'};">코칭 이력</a>
  </div>
  <jsp:doBody/>
</div>

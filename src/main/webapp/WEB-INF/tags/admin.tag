<%@ tag pageEncoding="UTF-8" body-content="scriptless" %>
<%-- 관리자 공용 셸 (다크 헤더 + 좌측 사이드바 + 메인). active: dash|sat|ai|rep --%>
<%@ attribute name="active" required="true" %>
<%@ attribute name="title" required="true" %>
<%@ attribute name="sub" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="wb" tagdir="/WEB-INF/tags" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<div class="wb wb-frame" style="background:#F4F6F8;">
  <header style="background:#1B1B1F; height:60px; display:flex; align-items:center; padding:0 24px; color:#fff;">
    <div style="font-weight:800; font-size:16px; color:#fff;"><span style="color:var(--accent);">●</span> W브릿지 ADMIN</div>
    <div style="margin-left:24px; font-size:12px; color:#9AA0AA;">AI 솔루션 모니터링</div>
    <div style="margin-left:auto; font-size:12px; color:#C9CDD4;">WISET 운영자 · 박관리</div>
  </header>

  <div class="row" style="min-height:700px;">
    <aside style="width:220px; background:#fff; border-right:1px solid var(--line); padding:20px 12px;">
      <div class="caption fw-700" style="padding:8px 12px; color:var(--ink-500); letter-spacing:0.05em;">AI 솔루션</div>
      <div class="col gap-2 mt-8">
        <a href="${ctx}/admin-dashboard" class="row items-center gap-8" style="padding:10px 12px; border-radius:6px; text-decoration:none; font-size:13px; cursor:pointer; background:${active eq 'dash' ? 'var(--primary-50)' : 'transparent'}; color:${active eq 'dash' ? 'var(--primary)' : 'var(--ink-700)'}; font-weight:${active eq 'dash' ? 700 : 500};"><wb:icon-ds name="chart" size="16" color="${active eq 'dash' ? '#6A4C9C' : '#6B7280'}" /> 대시보드</a>
        <a href="${ctx}/admin-satisfaction" class="row items-center gap-8" style="padding:10px 12px; border-radius:6px; text-decoration:none; font-size:13px; cursor:pointer; background:${active eq 'sat' ? 'var(--primary-50)' : 'transparent'}; color:${active eq 'sat' ? 'var(--primary)' : 'var(--ink-700)'}; font-weight:${active eq 'sat' ? 700 : 500};"><wb:icon-ds name="spark" size="16" color="${active eq 'sat' ? '#6A4C9C' : '#6B7280'}" /> 만족도 관리</a>
        <a href="${ctx}/admin-ai-quality" class="row items-center gap-8" style="padding:10px 12px; border-radius:6px; text-decoration:none; font-size:13px; cursor:pointer; background:${active eq 'ai' ? 'var(--primary-50)' : 'transparent'}; color:${active eq 'ai' ? 'var(--primary)' : 'var(--ink-700)'}; font-weight:${active eq 'ai' ? 700 : 500};"><wb:icon-ds name="target" size="16" color="${active eq 'ai' ? '#6A4C9C' : '#6B7280'}" /> AI 품질 관리</a>
        <a href="${ctx}/admin-reports" class="row items-center gap-8" style="padding:10px 12px; border-radius:6px; text-decoration:none; font-size:13px; cursor:pointer; background:${active eq 'rep' ? 'var(--primary-50)' : 'transparent'}; color:${active eq 'rep' ? 'var(--primary)' : 'var(--ink-700)'}; font-weight:${active eq 'rep' ? 700 : 500};"><wb:icon-ds name="file" size="16" color="${active eq 'rep' ? '#6A4C9C' : '#6B7280'}" /> 리포트 관리</a>
      </div>
      <div class="divider mt-16 mb-16"></div>
      <div class="caption fw-700" style="padding:8px 12px; color:var(--ink-500); letter-spacing:0.05em;">시스템</div>
      <div class="col gap-2 mt-8">
        <div style="padding:10px 12px; font-size:13px; color:var(--ink-700); cursor:pointer;">사용자 관리</div>
        <div style="padding:10px 12px; font-size:13px; color:var(--ink-700); cursor:pointer;">권한 설정</div>
        <div style="padding:10px 12px; font-size:13px; color:var(--ink-700); cursor:pointer;">운영 로그</div>
      </div>
    </aside>

    <main style="flex:1; padding:24px;">
      <div class="row justify-between items-center mb-24">
        <div>
          <h1 style="font-size:22px; font-weight:700; margin:0;">${title}</h1>
          <c:if test="${not empty sub}"><div class="caption mt-4">${sub}</div></c:if>
        </div>
        <div class="row gap-8">
          <div class="row items-center gap-4 caption">
            <span class="badge badge-gray">최근 7일</span>
            <span class="badge badge-gray">최근 30일</span>
            <span class="badge badge-blue">전체 기간</span>
          </div>
          <button type="button" class="btn btn-ghost btn-sm"><wb:icon-ds name="download" size="14" color="#3D4048" /> CSV 내보내기</button>
        </div>
      </div>
      <jsp:doBody/>
    </main>
  </div>
</div>

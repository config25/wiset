<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>오류 · W브릿지</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.min.css">
  <link rel="stylesheet" href="${ctx}/css/wb-ds.css">
</head>
<body class="wb-canvas">
  <div class="wb wb-frame" style="min-height:100vh; display:flex; align-items:center; justify-content:center; background:#F4F6F8;">
    <div class="card" style="max-width:440px; width:90%; text-align:center; padding:40px 32px;">
      <div style="font-size:48px; font-weight:800; color:var(--primary); line-height:1;">
        <c:out value="${status}" default="오류" />
      </div>
      <div class="h3 mt-16" style="margin-bottom:8px;">
        <c:choose>
          <c:when test="${status == 404}">페이지를 찾을 수 없습니다</c:when>
          <c:when test="${status == 403}">접근 권한이 없습니다</c:when>
          <c:when test="${status >= 500}">일시적인 오류가 발생했습니다</c:when>
          <c:otherwise>요청을 처리할 수 없습니다</c:otherwise>
        </c:choose>
      </div>
      <div class="caption" style="color:var(--ink-500);">
        <c:out value="${error}" default="잠시 후 다시 시도해 주세요." />
      </div>
      <c:if test="${not empty path}">
        <div class="caption mt-8" style="color:var(--ink-400); font-family:'JetBrains Mono',monospace; font-size:11px;">
          <c:out value="${path}" />
        </div>
      </c:if>
      <div class="row gap-8 justify-center mt-24">
        <a class="btn btn-ghost btn-sm" href="javascript:history.back()">이전으로</a>
        <a class="btn btn-brand btn-sm" href="${ctx}/">홈으로</a>
      </div>
    </div>
  </div>
</body>
</html>

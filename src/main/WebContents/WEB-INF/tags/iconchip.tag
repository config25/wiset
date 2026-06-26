<%@ tag pageEncoding="UTF-8" body-content="empty" %>
<%-- 신규 디자인 시스템 IconChip (ds.jsx 이식): 둥근 배경 위 아이콘 --%>
<%@ attribute name="name" required="true" %>
<%@ attribute name="tone" %>
<%@ attribute name="size" %>
<%@ attribute name="icon" %>
<%@ attribute name="radius" %>
<%@ attribute name="solid" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="wb" tagdir="/WEB-INF/tags" %>
<c:set var="t" value="${empty tone ? 'brand' : tone}" />
<c:set var="sz" value="${empty size ? 46 : size}" />
<c:set var="ic" value="${empty icon ? 23 : icon}" />
<c:set var="rad" value="${empty radius ? 12 : radius}" />
<c:choose>
  <c:when test="${t eq 'blue'}"><c:set var="bg" value="var(--blue-50)"/><c:set var="fg" value="var(--blue)"/></c:when>
  <c:when test="${t eq 'green'}"><c:set var="bg" value="var(--green-50)"/><c:set var="fg" value="var(--green-deep)"/></c:when>
  <c:when test="${t eq 'pink'}"><c:set var="bg" value="var(--pink-50)"/><c:set var="fg" value="var(--pink)"/></c:when>
  <c:when test="${t eq 'amber'}"><c:set var="bg" value="var(--amber-50)"/><c:set var="fg" value="var(--amber)"/></c:when>
  <c:when test="${t eq 'ink'}"><c:set var="bg" value="var(--bg-soft)"/><c:set var="fg" value="var(--ink-600)"/></c:when>
  <c:otherwise><c:set var="bg" value="var(--brand-50)"/><c:set var="fg" value="var(--brand)"/></c:otherwise>
</c:choose>
<span style="width:${sz}px;height:${sz}px;border-radius:${rad}px;flex-shrink:0;display:inline-flex;align-items:center;justify-content:center;background:${solid eq 'true' ? fg : bg}"><wb:icon-ds name="${name}" size="${ic}" color="${solid eq 'true' ? '#fff' : fg}" sw="1.8" /></span>

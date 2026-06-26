<%@ tag pageEncoding="UTF-8" body-content="empty" %>
<%@ attribute name="name" required="true" %>
<%@ attribute name="size" %>
<%@ attribute name="color" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="s" value="${empty size ? 18 : size}" />
<c:set var="col" value="${empty color ? 'currentColor' : color}" />
<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${col}" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><c:choose><c:when
  test="${name eq 'arrow'}"><path d="M5 12h14M13 5l7 7-7 7"/></c:when><c:when
  test="${name eq 'check'}"><path d="M5 12l5 5L20 7"/></c:when><c:when
  test="${name eq 'user'}"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0116 0"/></c:when><c:when
  test="${name eq 'target'}"><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1.5" fill="${col}"/></c:when><c:when
  test="${name eq 'chat'}"><path d="M21 12a8 8 0 01-11.5 7.2L4 21l1.8-4.8A8 8 0 1121 12z"/></c:when><c:when
  test="${name eq 'sparkle'}"><path d="M12 3v3M12 18v3M3 12h3M18 12h3"/><path d="M12 8l2 2-2 2-2-2 2-2z"/></c:when><c:when
  test="${name eq 'spark'}"><path d="M12 2v6M12 16v6M2 12h6M16 12h6M5 5l4 4M15 15l4 4M5 19l4-4M15 9l4-4"/></c:when><c:when
  test="${name eq 'chart'}"><path d="M4 20h16M7 16V10M12 16V6M17 16v-8"/></c:when><c:when
  test="${name eq 'download'}"><path d="M12 4v12"/><path d="M7 11l5 5 5-5"/><path d="M5 20h14"/></c:when><c:when
  test="${name eq 'plus'}"><path d="M12 5v14M5 12h14"/></c:when><c:when
  test="${name eq 'book'}"><path d="M4 4h7a4 4 0 014 4v12a3 3 0 00-3-3H4V4z"/><path d="M20 4h-7a4 4 0 00-4 4v12a3 3 0 013-3h8V4z"/></c:when><c:when
  test="${name eq 'bookmark'}"><path d="M6 3h12a1 1 0 011 1v17l-7-4-7 4V4a1 1 0 011-1z"/></c:when><c:otherwise><%-- file / doc fallback --%><path d="M14 3H6a2 2 0 00-2 2v14a2 2 0 002 2h12a2 2 0 002-2V9z"/><path d="M14 3v6h6"/></c:otherwise></c:choose></svg>

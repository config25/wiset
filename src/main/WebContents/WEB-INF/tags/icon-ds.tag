<%@ tag pageEncoding="UTF-8" body-content="empty" %>
<%-- 신규 디자인 시스템 아이콘 (ds.jsx ICON 라이브러리 이식). 구버전 icon.tag와 별개. --%>
<%@ attribute name="name" required="true" %>
<%@ attribute name="size" %>
<%@ attribute name="color" %>
<%@ attribute name="sw" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="s" value="${empty size ? 18 : size}" />
<c:set var="col" value="${empty color ? 'currentColor' : color}" />
<c:set var="w" value="${empty sw ? '1.7' : sw}" />
<svg width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="${col}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0"><c:choose><c:when
 test="${name eq 'spark'}"><path d="M12 3v6M12 15v6M3 12h6M15 12h6M5.6 5.6l4.2 4.2M14.2 14.2l4.2 4.2M5.6 18.4l4.2-4.2M14.2 9.8l4.2-4.2"/></c:when><c:when
 test="${name eq 'sparkle'}"><path d="M12 3l1.9 4.8L18.6 9l-4.7 1.9L12 15.6 10.1 10.9 5.4 9l4.7-1.2L12 3z"/><path d="M19 14l.7 1.8L21.5 16.5l-1.8.7L19 19l-.7-1.8L16.5 16.5l1.8-.7L19 14z"/></c:when><c:when
 test="${name eq 'target'}"><circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4.5"/><circle cx="12" cy="12" r="1" fill="${col}" stroke="none"/></c:when><c:when
 test="${name eq 'check'}"><path d="M4.5 12.5l4.5 4.5L19.5 6.5"/></c:when><c:when
 test="${name eq 'checkCircle'}"><circle cx="12" cy="12" r="9"/><path d="M8.5 12.5l2.5 2.5L16 9"/></c:when><c:when
 test="${name eq 'arrow'}"><path d="M4 12h15M13 5l7 7-7 7"/></c:when><c:when
 test="${name eq 'arrowR'}"><path d="M9 6l6 6-6 6"/></c:when><c:when
 test="${name eq 'arrowUp'}"><path d="M12 20V5M5 12l7-7 7 7"/></c:when><c:when
 test="${name eq 'download'}"><path d="M12 3v12M7.5 10.5L12 15l4.5-4.5"/><path d="M5 20h14"/></c:when><c:when
 test="${name eq 'plus'}"><path d="M12 5v14M5 12h14"/></c:when><c:when
 test="${name eq 'user'}"><circle cx="12" cy="8" r="4"/><path d="M4.5 20a7.5 7.5 0 0115 0"/></c:when><c:when
 test="${name eq 'users'}"><circle cx="9" cy="8" r="3.4"/><path d="M3.5 19a5.5 5.5 0 0111 0"/><path d="M16 5.2a3.4 3.4 0 010 6.4M17.5 13.4A5.5 5.5 0 0121 18.5"/></c:when><c:when
 test="${name eq 'chart'}"><path d="M4 20h16"/><rect x="6" y="11" width="3.2" height="6" rx="1"/><rect x="11.4" y="6" width="3.2" height="11" rx="1"/><rect x="16.8" y="13" width="3.2" height="4" rx="1"/></c:when><c:when
 test="${name eq 'trending'}"><path d="M3 17l6-6 4 4 8-8"/><path d="M16 7h5v5"/></c:when><c:when
 test="${name eq 'file'}"><path d="M14 3H7a2 2 0 00-2 2v14a2 2 0 002 2h10a2 2 0 002-2V8z"/><path d="M14 3v5h5"/></c:when><c:when
 test="${name eq 'doc'}"><path d="M14 3H7a2 2 0 00-2 2v14a2 2 0 002 2h10a2 2 0 002-2V8z"/><path d="M14 3v5h5"/><path d="M8.5 13h7M8.5 16.5h5"/></c:when><c:when
 test="${name eq 'graduation'}"><path d="M3 9l9-4 9 4-9 4-9-4z"/><path d="M7 11v4.5c0 1.1 2.2 2 5 2s5-.9 5-2V11"/><path d="M21 9v5"/></c:when><c:when
 test="${name eq 'award'}"><circle cx="12" cy="9" r="5.2"/><path d="M9 13.5L7.5 21l4.5-2.5L16.5 21 15 13.5"/></c:when><c:when
 test="${name eq 'trophy'}"><path d="M7 4h10v4a5 5 0 01-10 0V4z"/><path d="M7 6H4.5a2.5 2.5 0 002.5 2.5M17 6h2.5A2.5 2.5 0 0117 8.5"/><path d="M10 13.5V17M14 13.5V17M8.5 21h7M9.5 21v-1.5a2.5 2.5 0 015 0V21"/></c:when><c:when
 test="${name eq 'briefcase'}"><rect x="3" y="7.5" width="18" height="12" rx="2"/><path d="M8.5 7.5V6a2 2 0 012-2h3a2 2 0 012 2v1.5M3 13h18"/></c:when><c:when
 test="${name eq 'search'}"><circle cx="11" cy="11" r="6.5"/><path d="M20 20l-4-4"/></c:when><c:when
 test="${name eq 'chat'}"><path d="M20.5 12a7.5 7.5 0 01-10.8 6.7L4 20.5l1.8-5.7A7.5 7.5 0 1120.5 12z"/></c:when><c:when
 test="${name eq 'message'}"><path d="M4 5h16v11H8l-4 4V5z"/><path d="M8.5 10h7M8.5 13h4"/></c:when><c:when
 test="${name eq 'calendar'}"><rect x="4" y="5" width="16" height="16" rx="2"/><path d="M4 9h16M8 3v4M16 3v4"/></c:when><c:when
 test="${name eq 'clock'}"><circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/></c:when><c:when
 test="${name eq 'shield'}"><path d="M12 3l7 3v5c0 4.5-3 8.2-7 10-4-1.8-7-5.5-7-10V6l7-3z"/><path d="M9 12l2 2 4-4"/></c:when><c:when
 test="${name eq 'zap'}"><path d="M13 3L5 13h6l-1 8 8-10h-6l1-8z"/></c:when><c:when
 test="${name eq 'rocket'}"><path d="M5 15c-1.5 1.5-2 5-2 5s3.5-.5 5-2"/><path d="M9 12c.8 2 2 3.2 4 4l3.5-3.5C19 9 19.5 5 19.5 4.5 19 4.5 15 5 11.5 8.5L8 12z"/><circle cx="14.5" cy="9.5" r="1.4"/></c:when><c:when
 test="${name eq 'flag'}"><path d="M5 21V4M5 4h11l-2 4 2 4H5"/></c:when><c:when
 test="${name eq 'home'}"><path d="M4 11l8-7 8 7"/><path d="M6 9.5V20h12V9.5"/></c:when><c:when
 test="${name eq 'refresh'}"><path d="M4 11a8 8 0 0114-5l2 2M20 13a8 8 0 01-14 5l-2-2"/><path d="M20 4v5h-5M4 20v-5h5"/></c:when><c:when
 test="${name eq 'plane'}"><path d="M10.5 13.5L3 11l1-2 6.5 1L15 5.5a2 2 0 012.8 2.8L13 13l1 6.5-2 1-2.5-7z"/></c:when><c:when
 test="${name eq 'mic'}"><rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5.5 11.5a6.5 6.5 0 0013 0M12 18v3M9 21h6"/></c:when><c:when
 test="${name eq 'pen'}"><path d="M16.5 4.5l3 3L8 19l-4 1 1-4L16.5 4.5z"/></c:when><c:when
 test="${name eq 'x'}"><path d="M6 6l12 12M18 6L6 18"/></c:when><c:when
 test="${name eq 'cursor'}"><path d="M5 3l15 8-6 2-2 6-7-16z"/></c:when><c:otherwise><path d="M12 3v6M12 15v6M3 12h6M15 12h6M5.6 5.6l4.2 4.2M14.2 14.2l4.2 4.2M5.6 18.4l4.2-4.2M14.2 9.8l4.2-4.2"/></c:otherwise></c:choose></svg>

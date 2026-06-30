package com.example.wiset.report.service.impl;

import com.example.wiset.support.CommonDAO;
import com.example.wiset.support.CurrentUser;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 08 AI 코칭 리포트 (조회 전용).
 *   리포트는 sys_ai_report 의 컬럼들로 저장된다(모두 AI 생성):
 *     - banner_title : 환영 제목 문장        → 응답 bannerTitle
 *     - subtitle     : 부제목                → 응답 subtitle
 *     - keywords     : 키워드 칩(줄바꿈 구분, 줄 = "아이콘명|라벨") → 응답 chips[{ic,t}]
 *     - content      : 본문. 구조화 JSON 문서 또는 통짜 TEXT(공백·줄바꿈 그대로) → 응답 content
 *   본문은 형태를 자동 감지: JSON 이면 객체로, 아니면 원문 문자열(TEXT)로 내려준다.
 *   색/그라데이션 등 배너 테마는 프론트가 페르소나로 입힌다.
 *
 *   // [wbridge] @Mapper 제거 → CommonDAO(report.aiReport.*) 이식. DTO 유지.
 */
@Service
public class AiCoachingServiceImpl {

    private static final Logger log = LoggerFactory.getLogger(AiCoachingServiceImpl.class);

    /** keywords 줄에 "아이콘|라벨" 형식이 아닐 때 쓰는 기본 아이콘. */
    private static final String DEFAULT_CHIP_ICON = "sparkle";

    private final CommonDAO commonDAO;
    private final ObjectMapper om = new ObjectMapper();

    public AiCoachingServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    /**
     * {@code { content, bannerTitle, subtitle, chips }} — diagnosisId 지정 시 그 진단 리포트, null 이면 최신.
     * 행이 없으면 content=null(프론트가 페르소나 목업으로 폴백).
     */
    public Map<String, Object> getCoachingReport(Long diagnosisId) throws Exception {
        long u = CurrentUser.userSn();
        log.info("[코칭조회] ===== ① 화면 렌더용 DB 읽기 시작 — user={}, reportType=COACHING, diagnosisId={} =====",
                u, diagnosisId);
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", u);
        p.put("reportType", "COACHING");
        p.put("diagnosisId", diagnosisId);
        Map<String, Object> row = commonDAO.selectOne("report.aiReport.findReport", p);
        Map<String, Object> out = new LinkedHashMap<>();
        if (row == null) {
            log.warn("[코칭조회] ② sys_ai_report 에 COACHING 행 없음 → content=null (프론트가 페르소나 목업으로 폴백)");
            out.put("content", null);
            return out;
        }

        // 본문 — JSON 이면 객체로, 아니면 통짜 TEXT 원문으로 (자동 감지)
        Object content = null;
        String raw = str(row.get("content"));
        log.info("[코칭조회] ② DB 행 발견 — content {}자, bannerTitle='{}' (※ 이 값이 그대로 화면에 렌더됨)",
                raw == null ? 0 : raw.length(), str(row.get("bannerTitle")));
        if (raw != null && !raw.trim().isEmpty()) {
            try {
                content = om.readValue(raw, Object.class);
            } catch (Exception e) {
                content = raw; // JSON 아님 → pre-wrap TEXT 모드
            }
        }
        out.put("content", content);
        out.put("bannerTitle", emptyToNull(str(row.get("bannerTitle"))));
        out.put("subtitle", emptyToNull(str(row.get("subtitle"))));
        out.put("chips", parseChips(str(row.get("keywords"))));
        log.info("[코칭조회] ===== ③ 읽기 완료 → 화면 반환 (content {}) =====",
                content == null ? "없음(null)" : "있음");
        return out;
    }

    /** keywords TEXT(줄바꿈 구분, 줄 = "아이콘명|라벨") → [{ic, t}] 칩 목록. 비면 빈 리스트. */
    private List<Map<String, String>> parseChips(String keywords) {
        List<Map<String, String>> chips = new ArrayList<>();
        if (keywords == null || keywords.trim().isEmpty()) return chips;
        for (String line : keywords.split("\\r?\\n")) {
            String s = line.trim();
            if (s.isEmpty()) continue;
            String ic = DEFAULT_CHIP_ICON;
            String t = s;
            int bar = s.indexOf('|');
            if (bar >= 0) {
                String left = s.substring(0, bar).trim();
                String right = s.substring(bar + 1).trim();
                if (!left.isEmpty()) ic = left;
                t = right;
            }
            if (t.isEmpty()) continue;
            Map<String, String> chip = new LinkedHashMap<>();
            chip.put("ic", ic);
            chip.put("t", t);
            chips.add(chip);
        }
        return chips;
    }

    private static String emptyToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s;
    }

    private static String str(Object o) { return o == null ? null : o.toString(); }
}

package com.example.wiset.controller.admin;

import com.example.wiset.service.AdminDashboardService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/** 17_관리자 통합 대시보드 - 조회/내보내기 API */
@Slf4j
@RestController
@RequestMapping("/api/admin/dashboard")
public class AdminDashboardApiController {

    private final AdminDashboardService service;

    public AdminDashboardApiController(AdminDashboardService service) {
        this.service = service;
    }

    /** 대시보드 전체 지표 (JSON) */
    @GetMapping
    public ResponseEntity<?> dashboard() {
        try {
            return ResponseEntity.ok(service.getDashboard());
        } catch (Exception e) {
            log.error("관리자 대시보드 조회 실패", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Collections.singletonMap("message", "대시보드 데이터를 불러오지 못했습니다."));
        }
    }

    /**
     * 전체 서비스 현황 CSV 내보내기.
     * @param scope all|realtime|answer|system (기본 all)
     */
    @GetMapping("/export")
    public ResponseEntity<?> export(@RequestParam(defaultValue = "all") String scope) {
        try {
            Map<String, Object> d = service.getDashboard();
            StringBuilder sb = new StringBuilder();
            sb.append('﻿'); // UTF-8 BOM (엑셀 한글)

            if ("all".equals(scope) || "realtime".equals(scope)) appendRealtime(sb, d);
            if ("all".equals(scope) || "answer".equals(scope))   appendAnswer(sb, d);
            if ("all".equals(scope) || "system".equals(scope))   appendSystem(sb, d);

            byte[] body = sb.toString().getBytes(StandardCharsets.UTF_8);
            String filename = "wbridge-dashboard-" + scope + "-" + LocalDate.now() + ".csv";
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.parseMediaType("text/csv; charset=UTF-8"));
            headers.set(HttpHeaders.CONTENT_DISPOSITION,
                    ContentDisposition.attachment().filename(filename, StandardCharsets.UTF_8).build().toString());
            return new ResponseEntity<>(body, headers, HttpStatus.OK);
        } catch (Exception e) {
            log.error("대시보드 CSV 내보내기 실패 (scope={})", scope, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("CSV 내보내기에 실패했습니다.".getBytes(StandardCharsets.UTF_8));
        }
    }

    @SuppressWarnings("unchecked")
    private void appendRealtime(StringBuilder sb, Map<String, Object> d) {
        Map<String, Object> r = (Map<String, Object>) d.get("realtime");
        Map<String, Object> funnel = (Map<String, Object>) d.get("funnel");
        sb.append("[실시간 지표]\n");
        sb.append("지표,값\n");
        line(sb, "누적 진단 건수", r.get("cumulative"));
        line(sb, "MAU", r.get("mau"));
        line(sb, "실시간 동시접속(진행중 세션)", r.get("live"));
        line(sb, "오늘 진단 시작", r.get("todayStarted"));
        sb.append("\n[페르소나별 유입]\n페르소나,인원,비율(%)\n");
        for (Map<String, Object> p : (List<Map<String, Object>>) d.get("persona")) {
            row(sb, p.get("label"), p.get("count"), p.get("percent"));
        }
        sb.append("\n[진단 플로우 단계별 이탈률]\n단계,도달 인원,도달률(%),이탈률(%)\n");
        for (Map<String, Object> s : (List<Map<String, Object>>) funnel.get("steps")) {
            row(sb, s.get("step"), s.get("count"), s.get("pct"), s.get("drop"));
        }
        sb.append('\n');
    }

    @SuppressWarnings("unchecked")
    private void appendAnswer(StringBuilder sb, Map<String, Object> d) {
        Map<String, Object> a = (Map<String, Object>) d.get("answer");
        Map<String, Object> sat = (Map<String, Object>) a.get("satisfaction");
        Map<String, Object> sp = (Map<String, Object>) a.get("speed");
        Map<String, Object> rt = (Map<String, Object>) a.get("rating");
        sb.append("[답변 통계]\n지표,값\n");
        line(sb, "좋아요", sat.get("up"));
        line(sb, "싫어요", sat.get("down"));
        line(sb, "좋아요 비율(%)", sat.get("upPercent"));
        line(sb, "평균 응답속도(초)", sp.get("avgSec"));
        line(sb, "P95 응답속도(초)", sp.get("p95Sec"));
        line(sb, "P99 응답속도(초)", sp.get("p99Sec"));
        line(sb, "최대 응답속도(초)", sp.get("maxSec"));
        line(sb, "평균 만족도(5점)", rt.get("avg"));
        sb.append("\n[답변 품질 지표]\n항목,점수\n");
        for (Map<String, Object> q : (List<Map<String, Object>>) d.get("quality")) {
            row(sb, q.get("label"), q.get("value"));
        }
        sb.append('\n');
    }

    @SuppressWarnings("unchecked")
    private void appendSystem(StringBuilder sb, Map<String, Object> d) {
        Map<String, Object> sys = (Map<String, Object>) d.get("system");
        Map<String, Object> usage = (Map<String, Object>) sys.get("usage");
        Map<String, Object> perf = (Map<String, Object>) sys.get("performance");
        sb.append("[시스템 활용량(일별)]\n요일,처리 건수\n");
        for (Map<String, Object> day : (List<Map<String, Object>>) usage.get("days")) {
            row(sb, day.get("day"), day.get("value"));
        }
        sb.append("\n[성능 지표]\n지표,값\n");
        line(sb, "API 가용성(%)", perf.get("apiAvailability"));
        line(sb, "GPU 사용률(%)", perf.get("gpuUsage"));
        line(sb, "DB 응답시간(ms)", perf.get("dbResponseMs"));
        line(sb, "에러율 5xx(%)", perf.get("errorRate"));
        line(sb, "큐 대기(건)", perf.get("queueWaiting"));
        sb.append("\n[최근 데이터 배치]\n배치 ID,유형,실행 시각,처리 건수,소요 시간,상태\n");
        for (Map<String, Object> b : (List<Map<String, Object>>) sys.get("batches")) {
            row(sb, b.get("id"), b.get("type"), b.get("ts"), b.get("count"), b.get("duration"), b.get("status"));
        }
        sb.append('\n');
    }

    private void line(StringBuilder sb, Object k, Object v) { row(sb, k, v); }

    private void row(StringBuilder sb, Object... cells) {
        for (int i = 0; i < cells.length; i++) {
            if (i > 0) sb.append(',');
            sb.append(csv(cells[i]));
        }
        sb.append('\n');
    }

    private String csv(Object o) {
        String s = o == null ? "" : o.toString();
        if (s.contains(",") || s.contains("\"") || s.contains("\n")) {
            return '"' + s.replace("\"", "\"\"") + '"';
        }
        return s;
    }
}

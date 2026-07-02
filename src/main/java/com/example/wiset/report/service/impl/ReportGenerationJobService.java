package com.example.wiset.report.service.impl;

import com.example.wiset.dto.ai.GenerationInputs;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * AI 리포트 생성을 백그라운드로 실행하는 잡 매니저(비동기).
 *   외부 AI 추론 서버(단일 GPU)가 느려 생성이 수 분 걸린다. 이를 HTTP 요청에서 동기로 기다리면
 *   요청이 수 분간 연결을 붙잡다 브라우저/프록시 타임아웃으로 끊긴다("터짐").
 *   → 요청은 잡만 띄우고 즉시 반환하고, 실제 생성은 전용 스레드에서 돌린다. 프론트는 상태를 폴링.
 *
 * ※ CurrentUser 가 세션 기반으로 바뀌면, 백그라운드 스레드엔 세션이 없으므로 userSn 을
 *   요청 스레드에서 캡처해 generate 로 전달하도록 바꿔야 한다(현재는 고정값이라 안전).
 */
@Service
public class ReportGenerationJobService {

    private static final Logger log = LoggerFactory.getLogger(ReportGenerationJobService.class);

    private final ReportGenerationServiceImpl generation;
    /** 리포트 생성 잡 전용 스레드(내부 AI 호출은 aiExecutor 를 별도로 씀). 한 번에 하나씩 처리(서버 보호). */
    private final ExecutorService jobExec = Executors.newSingleThreadExecutor(r -> {
        Thread t = new Thread(r, "report-gen-job");
        t.setDaemon(true);
        return t;
    });
    private final Map<Long, JobStatus> statusByUser = new ConcurrentHashMap<>();

    public ReportGenerationJobService(ReportGenerationServiceImpl generation) {
        this.generation = generation;
    }

    /** 잡 시작. 이미 진행 중이면 새로 띄우지 않고 진행 중 상태를 반환(중복 클릭 방지). */
    public synchronized Map<String, Object> start(long userSn, GenerationInputs in) {
        JobStatus cur = statusByUser.get(userSn);
        if (cur != null && cur.running) {
            log.info("[비동기생성] user={} 이미 진행 중 → 중복 시작 생략", userSn);
            return response("already_running", cur);
        }
        JobStatus js = new JobStatus();
        js.running = true;
        js.startedAt = System.currentTimeMillis();
        statusByUser.put(userSn, js);
        log.info("[비동기생성] user={} 백그라운드 잡 시작", userSn);
        jobExec.submit(() -> {
            try {
                Map<String, Object> result = generation.generate(in);
                js.result = result;
                js.done = true;
                log.info("[비동기생성] user={} 완료 → {}", userSn, result);
            } catch (Exception e) {
                js.failed = true;
                js.error = e.getMessage();
                log.error("[비동기생성] user={} 실패", userSn, e);
            } finally {
                js.running = false;
                js.finishedAt = System.currentTimeMillis();
            }
        });
        return response("started", js);
    }

    /** 현재 상태 조회(프론트 폴링용). idle=한 번도 안 돌림, running/done/failed. */
    public Map<String, Object> status(long userSn) {
        JobStatus js = statusByUser.get(userSn);
        if (js == null) return response("idle", null);
        return response(js.running ? "running" : (js.failed ? "failed" : "done"), js);
    }

    private Map<String, Object> response(String status, JobStatus js) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("status", status);
        if (js != null) {
            m.put("running", js.running);
            m.put("done", js.done);
            m.put("failed", js.failed);
            if (js.error != null) m.put("error", js.error);
            if (js.done && js.result != null) m.put("result", js.result);
            if (js.startedAt > 0 && js.finishedAt > 0) m.put("elapsedMs", js.finishedAt - js.startedAt);
        }
        return m;
    }

    /** 잡 진행 상태(단일 사용자 기준). 필드는 잡 스레드가 쓰고 요청 스레드가 읽으므로 volatile. */
    private static final class JobStatus {
        volatile boolean running;
        volatile boolean done;
        volatile boolean failed;
        volatile String error;
        volatile Map<String, Object> result;
        volatile long startedAt;
        volatile long finishedAt;
    }
}

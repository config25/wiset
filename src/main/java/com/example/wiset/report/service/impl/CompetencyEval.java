package com.example.wiset.report.service.impl;

import java.util.Collections;
import java.util.List;

/**
 * type1(역량평가) 파싱 결과 1건 — 점수 + AI 근거(reason) + 근거 출처(sources).
 *   AI 응답이 점수만 오던 시절엔 Double 하나로 충분했으나, 3겹 객체({score,reason,sources})로 진화하며
 *   근거·출처를 보존하기 위해 홀더로 승격(ISSUE-1 잔여분).
 *     - score   : 0~3 원점수 (적재 시 ×100/3)
 *     - reason  → sys_report_competency.comment (역량별 해설)
 *     - sources → sys_report_competency_source (각 [sourceType, detail])
 */
public class CompetencyEval {

    private final double score;
    private final String reason;                 // nullable
    private final List<String[]> sources;        // 각 원소 = [sourceType(nullable), detail]

    public CompetencyEval(double score, String reason, List<String[]> sources) {
        this.score = score;
        this.reason = reason;
        this.sources = sources == null ? Collections.emptyList() : sources;
    }

    public double getScore() { return score; }

    public String getReason() { return reason; }

    /** 각 원소 [sourceType(nullable), detail]. 없으면 빈 리스트. */
    public List<String[]> getSources() { return sources; }

    @Override
    public String toString() {   // 파싱 로그 가독성용 (근거 유무/출처 건수만)
        return score + (reason != null ? "+reason" : "") + "+src" + sources.size();
    }
}

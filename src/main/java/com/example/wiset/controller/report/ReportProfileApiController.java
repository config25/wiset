package com.example.wiset.controller.report;

import com.example.wiset.mapper.ResumeMapper;
import com.example.wiset.mapper.ScrapMapper;
import com.example.wiset.support.CurrentUser;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 리포트 헤더 캡션 — "신규 취업 준비 · IT·SW 공정개발 · 스크랩 JD 3건" 처럼
 * 신입/경력 + 희망 업종·직무 + 스크랩 수를 저장값에서 동적으로 조립.
 * (사용자 이름은 별도 — 인증 통합 시 연동 예정)
 */
@RestController
@RequestMapping("/api/report")
public class ReportProfileApiController {

    private final ScrapMapper scrapMapper;
    private final ResumeMapper resumeMapper;

    public ReportProfileApiController(ScrapMapper scrapMapper, ResumeMapper resumeMapper) {
        this.scrapMapper = scrapMapper;
        this.resumeMapper = resumeMapper;
    }

    @GetMapping("/profile-summary")
    public Map<String, Object> summary() {
        long u = CurrentUser.userSn();

        Integer sel = resumeMapper.findCareerLevelSel(u);
        String intent = sel == null ? "취업 준비" : (sel == 1 ? "신규 취업 준비" : "이직 준비");

        String industry = blankToNull(scrapMapper.findDesiredIndustry(u));
        String job = blankToNull(scrapMapper.findDesiredJob(u));
        String role = join(industry, job);
        if (role.isEmpty()) role = "희망 직무 미정";

        int scraps = scrapMapper.countScraps(u);

        Map<String, Object> m = new LinkedHashMap<>();
        m.put("intent", intent);
        m.put("role", role);
        m.put("scrapCount", scraps);
        m.put("caption", intent + " · " + role + " · 스크랩 JD " + scraps + "건");
        return m;
    }

    private static String join(String a, String b) {
        StringBuilder sb = new StringBuilder();
        if (a != null) sb.append(a);
        if (b != null) sb.append(sb.length() > 0 ? " " : "").append(b);
        return sb.toString();
    }

    private static String blankToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }
}

package com.example.wiset.stage.service.impl;

import com.example.wiset.support.CommonDAO;
import com.example.wiset.support.CurrentUser;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 분석 시작 시 sessionStorage 선택값 일괄 저장 (AI 전송 제외, 저장만).
 *   페르소나/신입·경력/희망업종·직무 → sys_user_profile (upsert)
 *   희망 근무지 → sys_user_desired_region (replace) · 고용형태+취업우대 → sys_user_type (replace)
 *   세부 고민 → sys_user_concern (insert) · 타깃 공고 → sys_user_job_scrap.is_target
 *   경력성장 목표(페르소나4) → sys_career_growth_goal + skill (replace)
 *   ※ 학력/경력/추가정보·포트폴리오·자소서는 각 화면 팝업에서 이미 저장됨(여기서 안 다룸).
 *
 * // [wbridge] @Mapper 제거 → CommonDAO(stage.analysis.*) 이식. DTO 유지.
 */
@Service
public class AnalysisServiceImpl {

    private final CommonDAO commonDAO;

    public AnalysisServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    @Transactional
    public void saveInput(Map<String, Object> p) throws Exception {
        long userSn = CurrentUser.userSn();

        Integer persona = toInt(p.get("persona"));
        Map<String, Object> cs = asMap(p.get("currentSituation"));
        Map<String, Object> cg = asMap(p.get("careerGoal"));
        Map<String, Object> gw = asMap(p.get("careerGrowth"));
        String concern = str(p.get("concern"));

        // 신입/경력 → career_level_code
        Integer careerLevel = null;
        String empType = str(cs.get("empType"));
        if ("신입".equals(empType)) careerLevel = 1;
        else if ("경력".equals(empType)) careerLevel = 2;
        // 사용자의 실제 선택값(미선택이면 null) — 재진입 시 '미선택' 복원용 보조 컬럼
        Integer careerLevelSel = careerLevel;

        // NOT NULL 컬럼 보호 (값 없으면 기본값)
        if (persona == null) persona = 1;
        if (careerLevel == null) careerLevel = 2;

        String industryCode = codeOrNull("INDUSTRY", str(cg.get("industry")));
        String jobCode = codeOrNull("JOB", str(cg.get("job")));
        {
            Map<String, Object> up = new HashMap<>();
            up.put("userSn", userSn);
            up.put("personaCode", persona);
            up.put("careerLevelCode", careerLevel);
            up.put("careerLevelSel", careerLevelSel);
            up.put("industryCode", industryCode);
            up.put("jobCode", jobCode);
            commonDAO.update("stage.analysis.upsertUserProfile", up);
        }

        // 희망 근무지 (replace-all)
        {
            Map<String, Object> dp = new HashMap<>();
            dp.put("userSn", userSn);
            commonDAO.delete("stage.analysis.deleteDesiredRegions", dp);
        }
        for (Object o : asList(cg.get("regions"))) {
            String label = str(o);
            if (label.isEmpty()) continue;
            int sp = label.indexOf(' ');
            String sido, sigungu;
            if (sp < 0) { sido = label; sigungu = label; }        // 전국 / 해외
            else { sido = label.substring(0, sp); sigungu = label.substring(sp + 1).trim(); }
            Map<String, Object> rp = new HashMap<>();
            rp.put("userSn", userSn);
            rp.put("sido", sido);
            rp.put("sigungu", sigungu);
            commonDAO.insert("stage.analysis.insertDesiredRegion", rp);
        }

        // 다중선택(고용형태 + 취업우대) (replace-all)
        {
            Map<String, Object> dp = new HashMap<>();
            dp.put("userSn", userSn);
            commonDAO.delete("stage.analysis.deleteUserTypes", dp);
        }
        for (Object o : asList(cg.get("employment"))) {
            Map<String, Object> cp = new HashMap<>();
            cp.put("group", "EMPLOYMENT_TYPE");
            cp.put("name", str(o));
            Long id = commonDAO.selectOne("stage.analysis.commonIdByName", cp);
            if (id != null) {
                Map<String, Object> tp = new HashMap<>();
                tp.put("userSn", userSn);
                tp.put("typeId", id);
                commonDAO.insert("stage.analysis.insertUserType", tp);
            }
        }
        for (Object o : asList(cs.get("prefs"))) {
            Map<String, Object> cp = new HashMap<>();
            cp.put("group", "JOB_PREFERENCE");
            cp.put("name", str(o));
            Long id = commonDAO.selectOne("stage.analysis.commonIdByName", cp);
            if (id != null) {
                Map<String, Object> tp = new HashMap<>();
                tp.put("userSn", userSn);
                tp.put("typeId", id);
                commonDAO.insert("stage.analysis.insertUserType", tp);
            }
        }

        // 세부 고민 (insert)
        if (concern != null && !concern.trim().isEmpty()) {
            Map<String, Object> ic = new HashMap<>();
            ic.put("userSn", userSn);
            ic.put("personaCode", persona);
            ic.put("category", null);
            ic.put("content", concern.trim());
            commonDAO.insert("stage.analysis.insertConcern", ic);
        }

        // 타깃 공고 (is_target)
        {
            Map<String, Object> tp = new HashMap<>();
            tp.put("userSn", userSn);
            commonDAO.update("stage.analysis.clearTargets", tp);
        }
        for (Object o : asList(cg.get("targets"))) {
            Long pb = toLong(o);
            if (pb != null) {
                Map<String, Object> mt = new HashMap<>();
                mt.put("userSn", userSn);
                mt.put("pblancSn", pb);
                commonDAO.update("stage.analysis.markTarget", mt);
            }
        }

        // 경력성장 목표 (페르소나 4)
        if (persona == 4 && !gw.isEmpty()) {
            {
                Map<String, Object> dp = new HashMap<>();
                dp.put("userSn", userSn);
                commonDAO.delete("stage.analysis.deleteGrowthSkillsByUser", dp);
            }
            {
                Map<String, Object> dp = new HashMap<>();
                dp.put("userSn", userSn);
                commonDAO.delete("stage.analysis.deleteGrowthGoal", dp);
            }
            String rankCode = codeOrNull("RANK", str(gw.get("rank")));
            Integer years = parseYears(str(gw.get("years")));
            String evalCode = codeOrNull("EVAL_FACTOR", str(gw.get("evalFactor")));
            Map<String, Object> gg = new HashMap<>();
            gg.put("userSn", userSn);
            gg.put("rankCode", rankCode);
            gg.put("years", years);
            gg.put("duties", blankToNull(str(gw.get("duties"))));
            gg.put("targetRole", blankToNull(str(gw.get("targetRole"))));
            gg.put("targetPay", blankToNull(str(gw.get("targetPay"))));
            gg.put("evalCode", evalCode);
            commonDAO.insert("stage.analysis.insertGrowthGoal", gg);
            Map<String, Object> lg = new HashMap<>();
            lg.put("userSn", userSn);
            Long goalId = commonDAO.selectOne("stage.analysis.latestGrowthGoalId", lg);
            if (goalId != null) {
                for (Object o : asList(gw.get("skills"))) {
                    String sc = codeOrNull("LEADERSHIP_SKILL", str(o));
                    if (sc != null) {
                        Map<String, Object> gs = new HashMap<>();
                        gs.put("goalId", goalId);
                        gs.put("skillCode", sc);
                        commonDAO.insert("stage.analysis.insertGrowthSkill", gs);
                    }
                }
            }
        }
    }

    // ---------------- helpers ----------------
    private String codeOrNull(String group, String name) throws Exception {
        String n = blankToNull(name);
        if (n == null) return null;
        Map<String, Object> cp = new HashMap<>();
        cp.put("group", group);
        cp.put("name", n);
        return commonDAO.selectOne("stage.analysis.codeByName", cp);
    }

    /** "5년" -> 5, "1년 미만" -> 0, 숫자 없으면 null */
    private static Integer parseYears(String s) {
        if (s == null) return null;
        if (s.contains("미만")) return 0;
        String d = s.replaceAll("[^0-9]", "");
        return d.isEmpty() ? null : Integer.valueOf(d);
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Object> asMap(Object o) {
        return (o instanceof Map) ? (Map<String, Object>) o : Collections.<String, Object>emptyMap();
    }
    @SuppressWarnings("unchecked")
    private static List<Object> asList(Object o) {
        return (o instanceof List) ? (List<Object>) o : Collections.emptyList();
    }
    private static String str(Object o) { return o == null ? "" : o.toString(); }
    private static String blankToNull(String s) { return (s == null || s.trim().isEmpty()) ? null : s.trim(); }
    private static Integer toInt(Object o) {
        if (o == null) return null;
        try { return Integer.valueOf(o.toString().trim()); } catch (Exception e) { return null; }
    }
    private static Long toLong(Object o) {
        if (o == null) return null;
        try { return Long.valueOf(o.toString().trim()); } catch (Exception e) { return null; }
    }
}

package com.example.wiset.mypage.service.impl;

import com.example.wiset.dto.PlannerAddReq;
import com.example.wiset.support.CommonDAO;
import com.example.wiset.support.CurrentUser;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** 마이페이지 액션 플래너: 조회 / 담기 / 상태변경 / 삭제 + 추천 활동 조회 */
// [wbridge] @Mapper 제거 → CommonDAO(mypage.actionPlanner.*, mypage.resume.*) 이식. DTO 유지.
@Service
public class ActionPlannerServiceImpl {

    private final CommonDAO commonDAO;

    public ActionPlannerServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    private void ensureProfile() throws Exception {
        long u = CurrentUser.userSn();
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", u);
        if (commonDAO.selectOne("mypage.resume.findUserProfile", p) == null) {
            commonDAO.insert("mypage.resume.insertUserProfilePlaceholder", p);
        }
    }

    public List<Map<String, Object>> listItems() throws Exception {
        ensureProfile();
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", CurrentUser.userSn());
        return commonDAO.selectList("mypage.actionPlanner.listItems", p);
    }

    @Transactional
    public void addItem(PlannerAddReq req) throws Exception {
        ensureProfile();
        long u = CurrentUser.userSn();
        if (req.getSource() == null) {
            req.setSource(req.getResourceId() != null ? "WBRIDGE" : "MANUAL");
        }
        // 담는 항목은 사용자의 최신 진단에 귀속(이력 화면의 진단별 실천 개수 집계용). 진단 없으면 null.
        Map<String, Object> dp = new HashMap<>();
        dp.put("userSn", u);
        Long diagnosisId = commonDAO.selectOne("mypage.actionPlanner.findLatestDiagnosisId", dp);
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", u);
        p.put("req", req);
        p.put("diagnosisId", diagnosisId);
        commonDAO.insert("mypage.actionPlanner.insertItem", p);
    }

    /** 제출(일괄) 저장 — action-plan 화면에서 담아둔 항목들을 한 번에 persist. */
    @Transactional
    public void addItems(List<PlannerAddReq> reqs) throws Exception {
        if (reqs == null || reqs.isEmpty()) return;
        ensureProfile();
        long u = CurrentUser.userSn();
        Map<String, Object> dp = new HashMap<>();
        dp.put("userSn", u);
        Long diagnosisId = commonDAO.selectOne("mypage.actionPlanner.findLatestDiagnosisId", dp); // 일괄 저장분 전부 최신 진단에 귀속
        for (PlannerAddReq req : reqs) {
            if (req == null) continue;
            // 직접입력도 추천담기도 아니면(둘 다 비면) 건너뜀
            if (req.getResourceId() == null
                    && (req.getCustomTitle() == null || req.getCustomTitle().trim().isEmpty())) continue;
            if (req.getSource() == null) {
                req.setSource(req.getResourceId() != null ? "WBRIDGE" : "MANUAL");
            }
            Map<String, Object> p = new HashMap<>();
            p.put("userSn", u);
            p.put("req", req);
            p.put("diagnosisId", diagnosisId);
            commonDAO.insert("mypage.actionPlanner.insertItem", p);
        }
    }

    @Transactional
    public void updateStatus(long plannerId, String status) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("plannerId", plannerId);
        p.put("status", status);
        commonDAO.update("mypage.actionPlanner.updateStatus", p);
    }

    @Transactional
    public void deleteItem(long plannerId) throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("plannerId", plannerId);
        commonDAO.delete("mypage.actionPlanner.deleteItem", p);
    }

    public List<Map<String, Object>> listRecommendations() throws Exception {
        return commonDAO.selectList("mypage.actionPlanner.listRecommendations");
    }
}

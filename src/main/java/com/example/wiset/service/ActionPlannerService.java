package com.example.wiset.service;

import com.example.wiset.dto.ActionPlannerItemDto;
import com.example.wiset.dto.PlannerAddReq;
import com.example.wiset.dto.RecommendationDto;
import com.example.wiset.mapper.ActionPlannerMapper;
import com.example.wiset.mapper.ResumeMapper;
import com.example.wiset.support.CurrentUser;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/** 마이페이지 액션 플래너: 조회 / 담기 / 상태변경 / 삭제 + 추천 활동 조회 */
@Service
public class ActionPlannerService {

    private final ActionPlannerMapper mapper;
    private final ResumeMapper resumeMapper; // sys_user_profile 보장(FK)

    public ActionPlannerService(ActionPlannerMapper mapper, ResumeMapper resumeMapper) {
        this.mapper = mapper;
        this.resumeMapper = resumeMapper;
    }

    private void ensureProfile() {
        long u = CurrentUser.userSn();
        if (resumeMapper.findUserProfile(u) == null) {
            resumeMapper.insertUserProfilePlaceholder(u);
        }
    }

    public List<ActionPlannerItemDto> listItems() {
        ensureProfile();
        return mapper.listItems(CurrentUser.userSn());
    }

    @Transactional
    public void addItem(PlannerAddReq req) {
        ensureProfile();
        long u = CurrentUser.userSn();
        if (req.getSource() == null) {
            req.setSource(req.getResourceId() != null ? "WBRIDGE" : "MANUAL");
        }
        // 담는 항목은 사용자의 최신 진단에 귀속(이력 화면의 진단별 실천 개수 집계용). 진단 없으면 null.
        mapper.insertItem(u, req, mapper.findLatestDiagnosisId(u));
    }

    /** 제출(일괄) 저장 — action-plan 화면에서 담아둔 항목들을 한 번에 persist. */
    @Transactional
    public void addItems(List<PlannerAddReq> reqs) {
        if (reqs == null || reqs.isEmpty()) return;
        ensureProfile();
        long u = CurrentUser.userSn();
        Long diagnosisId = mapper.findLatestDiagnosisId(u); // 일괄 저장분 전부 최신 진단에 귀속
        for (PlannerAddReq req : reqs) {
            if (req == null) continue;
            // 직접입력도 추천담기도 아니면(둘 다 비면) 건너뜀
            if (req.getResourceId() == null
                    && (req.getCustomTitle() == null || req.getCustomTitle().trim().isEmpty())) continue;
            if (req.getSource() == null) {
                req.setSource(req.getResourceId() != null ? "WBRIDGE" : "MANUAL");
            }
            mapper.insertItem(u, req, diagnosisId);
        }
    }

    @Transactional
    public void updateStatus(long plannerId, String status) {
        mapper.updateStatus(plannerId, status);
    }

    @Transactional
    public void deleteItem(long plannerId) {
        mapper.deleteItem(plannerId);
    }

    public List<RecommendationDto> listRecommendations() {
        return mapper.listRecommendations();
    }
}

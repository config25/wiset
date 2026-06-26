package com.example.wiset.stage.controller;

import com.example.wiset.support.CommonDAO;
import com.example.wiset.support.CurrentUser;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 04 경력개발 목표 - 조회 전용 API.
 *   선택값(희망업종/직무/근무지/고용형태/타겟공고)은 클라이언트 보관 후 최종 단계서 저장.
 *   여기선 타겟공고 선택용 "스크랩한 채용공고 목록" 조회만 제공.
 *   // [wbridge] @Mapper 제거 → CommonDAO(mypage.scrap.*) 이식. 컨트롤러는 Boot 유지.
 */
@RestController
@RequestMapping("/api/career-goal")
public class CareerGoalApiController {

    private final CommonDAO commonDAO;

    public CareerGoalApiController(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    @GetMapping("/scraps")
    public List<Map<String, Object>> listScraps() throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", CurrentUser.userSn());
        return commonDAO.<Map<String, Object>>selectList("mypage.scrap.listScraps", p);
    }

    /** 저장된 선택값(있으면) 일괄 조회: 희망 업종/직무/근무지/고용형태 */
    @GetMapping("/saved")
    public Map<String, Object> savedSelections() throws Exception {
        Map<String, Object> p = new HashMap<>();
        p.put("userSn", CurrentUser.userSn());
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("industry", commonDAO.selectOne("mypage.scrap.findDesiredIndustry", p));      // 미저장 시 null
        m.put("job", commonDAO.selectOne("mypage.scrap.findDesiredJob", p));                // 미저장 시 null
        m.put("regions", commonDAO.<String>selectList("mypage.scrap.listDesiredRegions", p));       // 미저장 시 []
        m.put("employment", commonDAO.<String>selectList("mypage.scrap.listDesiredEmployment", p)); // 미저장 시 []
        return m;
    }
}

package com.example.wiset.controller.stage;

import com.example.wiset.dto.ScrapDto;
import com.example.wiset.mapper.ScrapMapper;
import com.example.wiset.support.CurrentUser;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * 04 경력개발 목표 - 조회 전용 API.
 *   선택값(희망업종/직무/근무지/고용형태/타겟공고)은 클라이언트 보관 후 최종 단계서 저장.
 *   여기선 타겟공고 선택용 "스크랩한 채용공고 목록" 조회만 제공.
 */
@RestController
@RequestMapping("/api/career-goal")
public class CareerGoalApiController {

    private final ScrapMapper scrapMapper;

    public CareerGoalApiController(ScrapMapper scrapMapper) {
        this.scrapMapper = scrapMapper;
    }

    @GetMapping("/scraps")
    public List<ScrapDto> listScraps() {
        return scrapMapper.listScraps(CurrentUser.userSn());
    }

    /** 저장된 선택값(있으면) 일괄 조회: 희망 업종/직무/근무지/고용형태 */
    @GetMapping("/saved")
    public Map<String, Object> savedSelections() {
        long u = CurrentUser.userSn();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("industry", scrapMapper.findDesiredIndustry(u));     // 미저장 시 null
        m.put("job", scrapMapper.findDesiredJob(u));               // 미저장 시 null
        m.put("regions", scrapMapper.listDesiredRegions(u));       // 미저장 시 []
        m.put("employment", scrapMapper.listDesiredEmployment(u)); // 미저장 시 []
        return m;
    }
}

package com.example.wiset.mypage.controller;

import com.example.wiset.dto.PlannerAddReq;
import com.example.wiset.mypage.service.impl.ActionPlannerServiceImpl;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 마이페이지 액션 플래너 API (조회/담기/상태변경/삭제 + 추천 활동 조회)
 *
 * [wbridge 포팅 델타]
 *   - @Controller extends DefaultController, @Resource(name="actionPlannerService") ActionPlannerServiceImpl
 *   - @RequestMapping("/mypage/actionPlanner/*.do|.json"), @RequestParam Map param + ModelMap → return "jsonView"
 *   - @RequestBody → @RequestParam Map (요청바디 DTO PlannerAddReq 도 Map 으로). 조회 결과는 이미 Map.
 */
@RestController
@RequestMapping("/api/action-planner")
public class ActionPlannerApiController {

    private final ActionPlannerServiceImpl service;

    public ActionPlannerApiController(ActionPlannerServiceImpl service) {
        this.service = service;
    }

    @GetMapping("/items")
    public List<Map<String, Object>> listItems() throws Exception {
        return service.listItems();
    }

    @PostMapping("/items")
    public void addItem(@RequestBody PlannerAddReq req) throws Exception {
        service.addItem(req);
    }

    /** 제출(일괄) 저장 — action-plan 화면의 '플래너 저장' 버튼용 */
    @PostMapping("/items/batch")
    public void addItems(@RequestBody List<PlannerAddReq> reqs) throws Exception {
        service.addItems(reqs);
    }

    @PutMapping("/items/{plannerId}")
    public void updateStatus(@PathVariable long plannerId, @RequestBody Map<String, Object> body) throws Exception {
        service.updateStatus(plannerId, body.get("status") == null ? null : body.get("status").toString());
    }

    @DeleteMapping("/items/{plannerId}")
    public void deleteItem(@PathVariable long plannerId) throws Exception {
        service.deleteItem(plannerId);
    }

    @GetMapping("/recommendations")
    public List<Map<String, Object>> listRecommendations() throws Exception {
        return service.listRecommendations();
    }
}

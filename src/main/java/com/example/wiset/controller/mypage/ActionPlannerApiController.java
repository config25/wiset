package com.example.wiset.controller.mypage;

import com.example.wiset.dto.ActionPlannerItemDto;
import com.example.wiset.dto.PlannerAddReq;
import com.example.wiset.dto.RecommendationDto;
import com.example.wiset.service.ActionPlannerService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** 마이페이지 액션 플래너 API (조회/담기/상태변경/삭제 + 추천 활동 조회) */
@RestController
@RequestMapping("/api/action-planner")
public class ActionPlannerApiController {

    private final ActionPlannerService service;

    public ActionPlannerApiController(ActionPlannerService service) {
        this.service = service;
    }

    @GetMapping("/items")
    public List<ActionPlannerItemDto> listItems() {
        return service.listItems();
    }

    @PostMapping("/items")
    public void addItem(@RequestBody PlannerAddReq req) {
        service.addItem(req);
    }

    /** 제출(일괄) 저장 — action-plan 화면의 '플래너 저장' 버튼용 */
    @PostMapping("/items/batch")
    public void addItems(@RequestBody List<PlannerAddReq> reqs) {
        service.addItems(reqs);
    }

    @PutMapping("/items/{plannerId}")
    public void updateStatus(@PathVariable long plannerId, @RequestBody ActionPlannerItemDto body) {
        service.updateStatus(plannerId, body.getStatus());
    }

    @DeleteMapping("/items/{plannerId}")
    public void deleteItem(@PathVariable long plannerId) {
        service.deleteItem(plannerId);
    }

    @GetMapping("/recommendations")
    public List<RecommendationDto> listRecommendations() {
        return service.listRecommendations();
    }
}

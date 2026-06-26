package com.example.wiset.cnsl.controller;

import java.util.List;
import java.util.Map;

import com.example.wiset.cnsl.service.impl.CnslServiceImpl;
import com.example.wiset.support.CurrentUser;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * 1:1 커리어컨설팅 Q&A (AI 입력용) — 레거시 idiom 이식판(로컬 실행).
 *   @Controller + @ResponseBody + .do URL + @RequestParam Map = 레거시와 동일 스타일이며 Boot 에서도 동작.
 *   wbridge 포팅 시: `extends DefaultController` 추가, 서비스 주입을 @Resource(name="cnslService") 로.
 */
@Controller
public class CnslController {

    private final CnslServiceImpl cnslService;

    public CnslController(CnslServiceImpl cnslService) {
        this.cnslService = cnslService;
    }

    /**
     * 현재 로그인 사용자의 컨설팅 Q&A 목록 (완료+답변 있는 것).
     *   userSn 은 클라이언트 값이 아니라 세션 사용자(CurrentUser)로 강제 — 타인 데이터 조회 방지.
     *   wbridge 포팅 시: CurrentUser.userSn() → DefaultController.getUserSn().
     * 예: GET /indvdl/cnsl/selectCnslQnaList.do
     */
    @ResponseBody
    @RequestMapping("/indvdl/cnsl/selectCnslQnaList.do")
    public List<Map<String, Object>> selectCnslQnaList(@RequestParam Map<String, Object> param) throws Exception {
        param.put("userSn", CurrentUser.userSn());
        return cnslService.selectCnslQnaListByUser(param);
    }
}

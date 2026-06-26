package com.example.wiset.cnsl.service.impl;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.example.wiset.support.CommonDAO;

/**
 * 1:1 커리어컨설팅 Q&A 서비스 (AI 입력용) — 레거시 commonDAO idiom(로컬 실행판).
 *   SQL 은 sqlmap/indvdl_cnsl_SQL.xml (namespace indvdl.cnsl) 참조.
 *   wbridge 포팅 시: `extends DefaultServiceImpl` 로 바꾸고 CommonDAO 주입 제거(상속 commonDAO 사용).
 */
@Service("cnslService")
public class CnslServiceImpl {

    private final CommonDAO commonDAO;

    public CnslServiceImpl(CommonDAO commonDAO) {
        this.commonDAO = commonDAO;
    }

    /**
     * 사용자별 컨설팅 Q&A 조회 (완료 + 답변있음만).
     * @param param userSn
     * @return Q&A Map 리스트 (키: QUESTION/ANSWER/CNSL_* 대문자) → AI 입력 컨텍스트로 사용
     */
    public List<Map<String, Object>> selectCnslQnaListByUser(Map<String, Object> param) throws Exception {
        return commonDAO.selectList("indvdl.cnsl.selectCnslQnaListByUser", param);
    }
}

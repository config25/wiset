package com.example.wiset.support;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

/**
 * 레거시 wbridge commonDAO 패턴의 Boot 호환 이식판.
 *   - 문자열 쿼리ID("namespace.queryId") + Map 기반.
 *   - mybatis-spring-boot-starter 의 SqlSession 빈으로 동작(MariaDB).
 *   - insert/update 시 감사컬럼(register/updusr) 자동 주입 — 레거시와 동일.
 *   wbridge 포팅 시: 패키지명만 wbridge.* 로, stampAudit 는 SessionUtil 연동으로 교체.
 */
@Repository("commonDAO")
public class CommonDAO {

    @Autowired
    private SqlSession sqlSession;

    protected final Logger log = LoggerFactory.getLogger(getClass());

    // ---------- insert ----------
    // [wbridge 정합] 전 메서드 throws Exception (wbridge CommonDAO 시그니처와 일치 → 서비스 코드 수정 없이 이식).
    //   ※ 반환 제네릭(<T>/<E>)은 wiset 유지. wbridge 는 Object/List<?> 라 통합 시 wbridge CommonDAO 를 제네릭화(하위호환)하여 맞춘다.
    public Object insert(String queryId) throws Exception {
        log.debug(queryId);
        return sqlSession.insert(queryId);
    }

    public Object insert(String queryId, Map<String, Object> param) throws Exception {
        log.debug(queryId);
        stampAudit(param);
        return sqlSession.insert(queryId, param);
    }

    // ---------- update ----------
    public int update(String queryId) throws Exception {
        log.debug(queryId);
        return sqlSession.update(queryId);
    }

    public int update(String queryId, Map<String, Object> param) throws Exception {
        log.debug(queryId);
        stampAudit(param);
        return sqlSession.update(queryId, param);
    }

    // ---------- delete ----------
    public int delete(String queryId) throws Exception {
        log.debug(queryId);
        return sqlSession.delete(queryId);
    }

    public int delete(String queryId, Map<String, Object> param) throws Exception {
        log.debug(queryId);
        return sqlSession.delete(queryId, param);
    }

    // ---------- select ----------
    public <T> T selectOne(String queryId) throws Exception {
        log.debug(queryId);
        return sqlSession.selectOne(queryId);
    }

    public <T> T selectOne(String queryId, Object param) throws Exception {
        log.debug(queryId);
        return sqlSession.selectOne(queryId, param);
    }

    public <E> List<E> selectList(String queryId) throws Exception {
        log.debug(queryId);
        return sqlSession.selectList(queryId);
    }

    public <E> List<E> selectList(String queryId, Object param) throws Exception {
        log.debug(queryId);
        return sqlSession.selectList(queryId, param);
    }

    /**
     * 감사컬럼 자동 주입(register/updusr). 이미 값이 있으면 보존.
     * TODO: 로그인 사용자 연동(CurrentUser/세션) 시 "SYSTEM" 대체.
     */
    private void stampAudit(Map<String, Object> param) {
        if (param == null) return;
        String userId = "SYSTEM";
        param.putIfAbsent("register", userId);
        param.putIfAbsent("updusr", userId);
    }
}

package com.jeonbuk.report.infrastructure.websocket;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;

/**
 * WebSocket 세션 관리자
 * 사용자와 WebSocket 세션 간의 매핑을 관리합니다.
 */
@Slf4j
@Component
public class WebSocketSessionManager {
    
    // 사용자 ID -> 세션 ID들의 매핑 (한 사용자가 여러 세션을 가질 수 있음)
    private final Map<String, Set<String>> userSessions = new ConcurrentHashMap<>();
    
    // 세션 ID -> 사용자 ID 매핑
    private final Map<String, String> sessionUsers = new ConcurrentHashMap<>();
    
    /**
     * 사용자 세션 추가
     */
    public void addSession(String userId, String sessionId) {
        log.debug("Adding WebSocket session for user {} with session {}", userId, sessionId);
        
        userSessions.computeIfAbsent(userId, k -> new CopyOnWriteArraySet<>()).add(sessionId);
        sessionUsers.put(sessionId, userId);
        
        log.info("User {} connected via WebSocket. Total sessions: {}", 
                userId, userSessions.get(userId).size());
    }
    
    /**
     * 사용자 세션 제거
     */
    public void removeSession(String sessionId) {
        String userId = sessionUsers.remove(sessionId);
        if (userId != null) {
            Set<String> sessions = userSessions.get(userId);
            if (sessions != null) {
                sessions.remove(sessionId);
                if (sessions.isEmpty()) {
                    userSessions.remove(userId);
                    log.info("User {} disconnected from WebSocket. No active sessions.", userId);
                } else {
                    log.info("User {} session removed. Remaining sessions: {}", userId, sessions.size());
                }
            }
        }
        log.debug("Removed WebSocket session {}", sessionId);
    }
    
    /**
     * 사용자의 모든 세션 ID 조회
     */
    public Set<String> getUserSessions(String userId) {
        return userSessions.getOrDefault(userId, Set.of());
    }
    
    /**
     * 세션에 해당하는 사용자 ID 조회
     */
    public String getSessionUser(String sessionId) {
        return sessionUsers.get(sessionId);
    }
    
    /**
     * 사용자가 온라인인지 확인
     */
    public boolean isUserOnline(String userId) {
        Set<String> sessions = userSessions.get(userId);
        return sessions != null && !sessions.isEmpty();
    }
    
    /**
     * 현재 연결된 사용자 수
     */
    public int getConnectedUserCount() {
        return userSessions.size();
    }
    
    /**
     * 전체 세션 수
     */
    public int getTotalSessionCount() {
        return sessionUsers.size();
    }
    
    /**
     * 모든 온라인 사용자 ID 조회
     */
    public Set<String> getOnlineUsers() {
        return userSessions.keySet();
    }
}
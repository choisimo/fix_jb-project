package com.jeonbuk.report.infrastructure.websocket;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import java.security.Principal;

/**
 * WebSocket 이벤트 리스너
 * 연결/해제 이벤트를 처리하여 사용자 세션을 관리합니다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class WebSocketEventListener {
    
    private final WebSocketSessionManager sessionManager;
    
    /**
     * WebSocket 연결 이벤트 처리
     */
    @EventListener
    public void handleWebSocketConnectListener(SessionConnectEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        
        // 인증된 사용자 정보 가져오기
        Principal principal = headerAccessor.getUser();
        if (principal != null) {
            String userId = principal.getName();
            sessionManager.addSession(userId, sessionId);
            
            log.info("WebSocket connection established for user: {} with session: {}", 
                    userId, sessionId);
        } else {
            log.warn("WebSocket connection without authenticated user. Session: {}", sessionId);
        }
    }
    
    /**
     * WebSocket 연결 해제 이벤트 처리
     */
    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        
        String userId = sessionManager.getSessionUser(sessionId);
        if (userId != null) {
            log.info("WebSocket connection closed for user: {} with session: {}", 
                    userId, sessionId);
        } else {
            log.info("WebSocket connection closed for session: {}", sessionId);
        }
        
        sessionManager.removeSession(sessionId);
    }
}
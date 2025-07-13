package com.jeonbuk.report.infrastructure.websocket;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;
import java.time.LocalDateTime;
import java.util.Map;

/**
 * 알림 WebSocket 컨트롤러
 * 실시간 알림 메시지 처리를 담당합니다.
 */
@Slf4j
@Controller
@RequiredArgsConstructor
public class AlertWebSocketController {
    
    private final SimpMessagingTemplate messagingTemplate;
    private final WebSocketSessionManager sessionManager;
    
    /**
     * 클라이언트로부터 알림 구독 요청 처리
     */
    @MessageMapping("/alerts/subscribe")
    public void subscribeToAlerts(
            @Payload Map<String, Object> message,
            SimpMessageHeaderAccessor headerAccessor,
            Principal principal) {
        
        if (principal != null) {
            String userId = principal.getName();
            String sessionId = headerAccessor.getSessionId();
            
            log.info("User {} subscribed to alerts via session {}", userId, sessionId);
            
            // 구독 확인 메시지 전송
            messagingTemplate.convertAndSendToUser(
                userId, 
                "/queue/alerts", 
                Map.of(
                    "type", "SUBSCRIPTION_CONFIRMED",
                    "message", "Successfully subscribed to alerts",
                    "timestamp", LocalDateTime.now().toString()
                )
            );
        }
    }
    
    /**
     * 특정 사용자에게 알림 전송
     */
    public void sendAlertToUser(String userId, Object alertData) {
        if (sessionManager.isUserOnline(userId)) {
            messagingTemplate.convertAndSendToUser(
                userId, 
                "/queue/alerts", 
                alertData
            );
            log.debug("Alert sent to user: {}", userId);
        } else {
            log.debug("User {} is not online, alert not sent via WebSocket", userId);
        }
    }
    
    /**
     * 모든 연결된 사용자에게 시스템 알림 전송
     */
    public void sendSystemAlert(Object alertData) {
        messagingTemplate.convertAndSend("/topic/system-alerts", alertData);
        log.info("System alert broadcasted to all connected users");
    }
    
    /**
     * 관리자에게만 알림 전송
     */
    public void sendAdminAlert(Object alertData) {
        // TODO: 관리자 역할 사용자들에게만 전송하는 로직 구현
        messagingTemplate.convertAndSend("/topic/admin-alerts", alertData);
        log.info("Admin alert broadcasted");
    }
    
    /**
     * 클라이언트의 핑 요청 처리 (연결 상태 확인)
     */
    @MessageMapping("/alerts/ping")
    public void handlePing(Principal principal) {
        if (principal != null) {
            String userId = principal.getName();
            messagingTemplate.convertAndSendToUser(
                userId,
                "/queue/pong",
                Map.of(
                    "type", "PONG",
                    "timestamp", LocalDateTime.now().toString(),
                    "message", "Connection is alive"
                )
            );
        }
    }
}
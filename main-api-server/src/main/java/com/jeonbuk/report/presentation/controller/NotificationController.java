package com.jeonbuk.report.presentation.controller;

import com.jeonbuk.report.infrastructure.websocket.AlertWebSocketController;
import com.jeonbuk.report.infrastructure.websocket.WebSocketSessionManager;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {
    
    private final SimpMessagingTemplate messagingTemplate;
    private final AlertWebSocketController alertWebSocketController;
    private final WebSocketSessionManager sessionManager;

    /**
     * 기본 알림 브로드캐스트 (기존 호환성 유지)
     */
    @MessageMapping("/notify")
    @SendTo("/topic/notifications")
    public String sendNotification(String message) {
        log.info("Broadcasting notification: {}", message);
        return message;
    }

    /**
     * 특정 사용자에게 알림 전송 (기존 호환성 유지)
     */
    public void sendToUser(String userId, String message) {
        messagingTemplate.convertAndSendToUser(userId, "/topic/notifications", message);
        log.info("Sent notification to user {}: {}", userId, message);
    }
    
    /**
     * 향상된 사용자별 알림 전송
     */
    public void sendAlertToUser(String userId, Object alertData) {
        alertWebSocketController.sendAlertToUser(userId, alertData);
    }
    
    /**
     * 시스템 전체 알림 전송
     */
    public void sendSystemAlert(Object alertData) {
        alertWebSocketController.sendSystemAlert(alertData);
    }
    
    /**
     * WebSocket 연결 상태 정보 조회 (관리자용)
     */
    @GetMapping("/websocket/status")
    public Map<String, Object> getWebSocketStatus() {
        return Map.of(
            "connectedUsers", sessionManager.getConnectedUserCount(),
            "totalSessions", sessionManager.getTotalSessionCount(),
            "onlineUsers", sessionManager.getOnlineUsers(),
            "timestamp", LocalDateTime.now().toString()
        );
    }
}

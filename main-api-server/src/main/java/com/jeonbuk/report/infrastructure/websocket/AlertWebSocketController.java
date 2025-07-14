package com.jeonbuk.report.infrastructure.websocket;

import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.domain.repository.UserRepository;
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
import java.util.Optional;
import java.util.UUID;

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
    private final UserRepository userRepository;
    
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
        // 관리자 역할 사용자들에게만 전송하는 로직 구현
        java.util.List<User> adminUsers = userRepository.findByRoleAndIsActiveTrue(User.UserRole.ADMIN);
        java.util.List<User> managerUsers = userRepository.findByRoleAndIsActiveTrue(User.UserRole.MANAGER);
        
        int adminAlertsSent = 0;
        
        // 관리자들에게 직접 전송
        for (User admin : adminUsers) {
            if (sessionManager.isUserOnline(admin.getId().toString())) {
                messagingTemplate.convertAndSendToUser(
                    admin.getId().toString(),
                    "/queue/admin-alerts",
                    Map.of(
                        "type", "ADMIN_ALERT",
                        "data", alertData,
                        "timestamp", LocalDateTime.now().toString(),
                        "targetRole", "ADMIN"
                    )
                );
                adminAlertsSent++;
            }
        }
        
        // 매니저들에게도 전송 (관리 권한이 있으므로)
        for (User manager : managerUsers) {
            if (sessionManager.isUserOnline(manager.getId().toString())) {
                messagingTemplate.convertAndSendToUser(
                    manager.getId().toString(),
                    "/queue/admin-alerts",
                    Map.of(
                        "type", "ADMIN_ALERT",
                        "data", alertData,
                        "timestamp", LocalDateTime.now().toString(),
                        "targetRole", "MANAGER"
                    )
                );
                adminAlertsSent++;
            }
        }
        
        // 브로드캐스트도 함께 전송 (구독한 관리자들을 위해)
        messagingTemplate.convertAndSend("/topic/admin-alerts", Map.of(
            "type", "ADMIN_BROADCAST",
            "data", alertData,
            "timestamp", LocalDateTime.now().toString(),
            "totalAdminsSent", adminAlertsSent
        ));
        
        log.info("Admin alert sent to {} online administrators and managers", adminAlertsSent);
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
    
    /**
     * 특정 역할을 가진 사용자들에게 알림 전송
     */
    public void sendRoleBasedAlert(User.UserRole targetRole, Object alertData) {
        java.util.List<User> targetUsers = userRepository.findByRoleAndIsActiveTrue(targetRole);
        
        int alertsSent = 0;
        for (User user : targetUsers) {
            if (sessionManager.isUserOnline(user.getId().toString())) {
                messagingTemplate.convertAndSendToUser(
                    user.getId().toString(),
                    "/queue/role-alerts",
                    Map.of(
                        "type", "ROLE_BASED_ALERT",
                        "targetRole", targetRole.name(),
                        "data", alertData,
                        "timestamp", LocalDateTime.now().toString()
                    )
                );
                alertsSent++;
            }
        }
        
        log.info("Role-based alert sent to {} online {} users", alertsSent, targetRole.name());
    }
    
    /**
     * 사용자 그룹에게 알림 전송
     */
    public void sendGroupAlert(java.util.List<String> userIds, Object alertData) {
        int alertsSent = 0;
        
        for (String userId : userIds) {
            if (sessionManager.isUserOnline(userId)) {
                messagingTemplate.convertAndSendToUser(
                    userId,
                    "/queue/group-alerts",
                    Map.of(
                        "type", "GROUP_ALERT",
                        "data", alertData,
                        "timestamp", LocalDateTime.now().toString()
                    )
                );
                alertsSent++;
            }
        }
        
        log.info("Group alert sent to {} out of {} target users", alertsSent, userIds.size());
    }
    
    /**
     * 사용자별 알림 설정 변경 처리
     */
    @MessageMapping("/alerts/preferences")
    public void updateAlertPreferences(
            @Payload Map<String, Object> preferences,
            Principal principal) {
        
        if (principal != null) {
            String userId = principal.getName();
            
            // 알림 설정 업데이트 로직
            log.info("User {} updated alert preferences: {}", userId, preferences);
            
            // 설정 변경 확인 메시지 전송
            messagingTemplate.convertAndSendToUser(
                userId,
                "/queue/preferences",
                Map.of(
                    "type", "PREFERENCES_UPDATED",
                    "message", "Alert preferences updated successfully",
                    "preferences", preferences,
                    "timestamp", LocalDateTime.now().toString()
                )
            );
        }
    }
    
    /**
     * 연결 상태 확인 및 통계 제공
     */
    public Map<String, Object> getConnectionStats() {
        return Map.of(
            "totalConnectedUsers", sessionManager.getConnectedUserCount(),
            "totalSessions", sessionManager.getTotalSessionCount(),
            "onlineUsers", sessionManager.getOnlineUsers(),
            "timestamp", LocalDateTime.now().toString()
        );
    }
}
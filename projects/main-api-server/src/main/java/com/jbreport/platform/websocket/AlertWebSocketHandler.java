package com.jbreport.platform.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jbreport.platform.dto.AlertDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@RequiredArgsConstructor
@Slf4j
public class AlertWebSocketHandler extends TextWebSocketHandler {
    
    private final ObjectMapper objectMapper;
    private final Map<Long, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    private final Map<String, Long> sessionToUser = new ConcurrentHashMap<>();
    
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        log.info("WebSocket connection established: {}", session.getId());
        
        // Extract user ID from session attributes or query parameters
        Long userId = extractUserId(session);
        if (userId != null) {
            userSessions.put(userId, session);
            sessionToUser.put(session.getId(), userId);
            
            // Send connection success message
            sendMessage(session, Map.of(
                "type", "CONNECTION",
                "status", "CONNECTED",
                "message", "Alert WebSocket connection established"
            ));
        } else {
            log.warn("No user ID found for session {}", session.getId());
            session.close(CloseStatus.NOT_ACCEPTABLE);
        }
    }
    
    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        log.debug("Received message: {}", payload);
        
        try {
            Map<String, Object> data = objectMapper.readValue(payload, Map.class);
            String type = (String) data.get("type");
            
            switch (type) {
                case "PING":
                    sendMessage(session, Map.of("type", "PONG", "timestamp", System.currentTimeMillis()));
                    break;
                case "SUBSCRIBE":
                    // Handle subscription to specific alert types
                    handleSubscription(session, data);
                    break;
                default:
                    log.warn("Unknown message type: {}", type);
            }
        } catch (Exception e) {
            log.error("Error handling WebSocket message", e);
            sendError(session, "Invalid message format");
        }
    }
    
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        log.info("WebSocket connection closed: {} - {}", session.getId(), status);
        
        Long userId = sessionToUser.remove(session.getId());
        if (userId != null) {
            userSessions.remove(userId);
        }
    }
    
    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log.error("WebSocket transport error for session {}", session.getId(), exception);
        
        if (session.isOpen()) {
            sendError(session, "Connection error occurred");
            session.close(CloseStatus.SERVER_ERROR);
        }
    }
    
    public void sendAlertToUser(Long userId, AlertDTO alert) {
        WebSocketSession session = userSessions.get(userId);
        if (session != null && session.isOpen()) {
            try {
                Map<String, Object> message = Map.of(
                    "type", "ALERT",
                    "data", alert,
                    "timestamp", System.currentTimeMillis()
                );
                sendMessage(session, message);
                log.info("Alert sent to user {}: {}", userId, alert.getTitle());
            } catch (Exception e) {
                log.error("Failed to send alert to user {}", userId, e);
                handleSessionError(session);
            }
        } else {
            log.debug("No active session for user {}", userId);
        }
    }
    
    public void broadcastAlert(AlertDTO alert, String role) {
        userSessions.forEach((userId, session) -> {
            if (session.isOpen()) {
                try {
                    // Check if user has the required role (would need to implement role checking)
                    sendAlertToUser(userId, alert);
                } catch (Exception e) {
                    log.error("Failed to broadcast alert to user {}", userId, e);
                }
            }
        });
    }
    
    private Long extractUserId(WebSocketSession session) {
        // Extract from query parameters
        String query = session.getUri().getQuery();
        if (query != null && query.contains("userId=")) {
            String[] params = query.split("&");
            for (String param : params) {
                if (param.startsWith("userId=")) {
                    try {
                        return Long.parseLong(param.substring(7));
                    } catch (NumberFormatException e) {
                        log.error("Invalid user ID format", e);
                    }
                }
            }
        }
        
        // Try to extract from session attributes
        Object userIdAttr = session.getAttributes().get("userId");
        if (userIdAttr instanceof Long) {
            return (Long) userIdAttr;
        }
        
        return null;
    }
    
    private void sendMessage(WebSocketSession session, Map<String, Object> message) throws IOException {
        String json = objectMapper.writeValueAsString(message);
        session.sendMessage(new TextMessage(json));
    }
    
    private void sendError(WebSocketSession session, String error) {
        try {
            sendMessage(session, Map.of(
                "type", "ERROR",
                "error", error,
                "timestamp", System.currentTimeMillis()
            ));
        } catch (IOException e) {
            log.error("Failed to send error message", e);
        }
    }
    
    private void handleSubscription(WebSocketSession session, Map<String, Object> data) {
        // Handle subscription logic if needed
        log.info("Subscription request from session {}: {}", session.getId(), data);
    }
    
    private void handleSessionError(WebSocketSession session) {
        try {
            session.close(CloseStatus.SERVER_ERROR);
        } catch (IOException e) {
            log.error("Failed to close session", e);
        }
        
        Long userId = sessionToUser.remove(session.getId());
        if (userId != null) {
            userSessions.remove(userId);
        }
    }
    
    public int getActiveConnections() {
        return userSessions.size();
    }
    
    public boolean isUserConnected(Long userId) {
        WebSocketSession session = userSessions.get(userId);
        return session != null && session.isOpen();
    }
}

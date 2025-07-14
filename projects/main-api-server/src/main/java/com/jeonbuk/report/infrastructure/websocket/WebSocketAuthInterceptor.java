package com.jeonbuk.report.infrastructure.websocket;

import com.jeonbuk.report.infrastructure.security.jwt.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * WebSocket 인증 인터셉터
 * WebSocket 연결 시 JWT 토큰을 검증하여 사용자를 인증합니다.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class WebSocketAuthInterceptor implements ChannelInterceptor {
    
    private final JwtTokenProvider jwtTokenProvider;
    private final UserDetailsService userDetailsService;
    
    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        
        if (StompCommand.CONNECT.equals(accessor.getCommand())) {
            // CONNECT 명령 시 인증 처리
            String token = getJwtTokenFromHeaders(accessor);
            
            if (token != null && jwtTokenProvider.validateToken(token)) {
                try {
                    String username = jwtTokenProvider.getUsername(token);
                    UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                    
                    Authentication authentication = new UsernamePasswordAuthenticationToken(
                            userDetails, null, userDetails.getAuthorities());
                    
                    accessor.setUser(authentication);
                    log.debug("WebSocket authentication successful for user: {}", username);
                    
                } catch (Exception e) {
                    log.error("WebSocket authentication failed", e);
                    // 인증 실패 시 연결을 허용하지 않음
                    return null;
                }
            } else {
                log.warn("Invalid or missing JWT token in WebSocket connection");
                // 토큰이 없거나 유효하지 않은 경우 연결 거부
                return null;
            }
        }
        
        return message;
    }
    
    /**
     * WebSocket 헤더에서 JWT 토큰 추출
     */
    private String getJwtTokenFromHeaders(StompHeaderAccessor accessor) {
        // Authorization 헤더에서 토큰 추출
        List<String> authHeaders = accessor.getNativeHeader("Authorization");
        if (authHeaders != null && !authHeaders.isEmpty()) {
            String authHeader = authHeaders.get(0);
            if (authHeader.startsWith("Bearer ")) {
                return authHeader.substring(7);
            }
        }
        
        // 쿼리 파라미터에서 토큰 추출 (대안)
        List<String> tokenParams = accessor.getNativeHeader("token");
        if (tokenParams != null && !tokenParams.isEmpty()) {
            return tokenParams.get(0);
        }
        
        return null;
    }
}
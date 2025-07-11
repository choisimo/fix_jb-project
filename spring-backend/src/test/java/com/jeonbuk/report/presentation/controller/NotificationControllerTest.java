package com.jeonbuk.report.presentation.controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.messaging.converter.StringMessageConverter;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandlerAdapter;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.web.socket.WebSocketHttpHeaders;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;

import java.lang.reflect.Type;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.TimeUnit;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class NotificationControllerTest {
    @Autowired
    private org.springframework.boot.web.server.LocalServerPort int port;

    @Test
    void websocket_notification_broadcast() throws Exception {
        WebSocketStompClient stompClient = new WebSocketStompClient(new StandardWebSocketClient());
        stompClient.setMessageConverter(new StringMessageConverter());
        BlockingQueue<String> blockingQueue = new LinkedBlockingDeque<>();
        StompSession session = stompClient.connect(
                "ws://localhost:" + port + "/ws",
                new WebSocketHttpHeaders(),
                new StompSessionHandlerAdapter() {
                    @Override
                    public void afterConnected(StompSession session, StompSession.ConnectedHeaders connectedHeaders) {}
                }).get(1, TimeUnit.SECONDS);
        session.subscribe("/topic/notifications", new org.springframework.messaging.simp.stomp.StompFrameHandler() {
            @Override
            public Type getPayloadType(org.springframework.messaging.simp.stomp.StompHeaders headers) {
                return String.class;
            }
            @Override
            public void handleFrame(org.springframework.messaging.simp.stomp.StompHeaders headers, Object payload) {
                blockingQueue.offer((String) payload);
            }
        });
        session.send("/app/notify", "hello");
        String message = blockingQueue.poll(2, TimeUnit.SECONDS);
        assertThat(message).isEqualTo("hello");
    }
}

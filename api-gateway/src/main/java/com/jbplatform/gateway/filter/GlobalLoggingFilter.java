package com.jbplatform.gateway.filter;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Slf4j
@Component
public class GlobalLoggingFilter implements GlobalFilter, Ordered {

    private static final String REQUEST_ID_HEADER = "X-Request-ID";
    private static final String START_TIME = "startTime";

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String requestId = exchange.getRequest().getHeaders().getFirst(REQUEST_ID_HEADER);
        if (requestId == null) {
            requestId = UUID.randomUUID().toString();
        }
        
        exchange.getRequest().mutate()
            .header(REQUEST_ID_HEADER, requestId)
            .build();
        
        exchange.getAttributes().put(START_TIME, System.currentTimeMillis());
        exchange.getAttributes().put(REQUEST_ID_HEADER, requestId);
        
        log.info("Request: {} {} from {} with request-id: {}", 
            exchange.getRequest().getMethod(),
            exchange.getRequest().getPath(),
            exchange.getRequest().getRemoteAddress(),
            requestId);
        
        return chain.filter(exchange).then(Mono.fromRunnable(() -> {
            Long startTime = exchange.getAttribute(START_TIME);
            if (startTime != null) {
                long executionTime = System.currentTimeMillis() - startTime;
                
                exchange.getResponse().getHeaders().add(REQUEST_ID_HEADER, requestId);
                exchange.getResponse().getHeaders().add("X-Response-Time", executionTime + "ms");
                
                log.info("Response: {} {} {} {}ms request-id: {}", 
                    exchange.getRequest().getMethod(),
                    exchange.getRequest().getPath(),
                    exchange.getResponse().getStatusCode(),
                    executionTime,
                    requestId);
            }
        }));
    }

    @Override
    public int getOrder() {
        return -100;
    }
}

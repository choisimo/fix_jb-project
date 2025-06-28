package com.jeonbuk.report.domain.user;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * OAuth 정보 엔티티
 */
@Entity
@Table(name = "oauth_info")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class OAuthInfo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "oauth_id")
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
    
    @Column(name = "provider", nullable = false, length = 50)
    private String provider; // google, kakao, naver
    
    @Column(name = "provider_id", nullable = false, length = 255)
    private String providerId;
    
    @Builder
    public OAuthInfo(User user, String provider, String providerId) {
        this.user = user;
        this.provider = provider;
        this.providerId = providerId;
    }
    
    // 상수 정의
    public static final String GOOGLE = "google";
    public static final String KAKAO = "kakao";
    public static final String NAVER = "naver";
}

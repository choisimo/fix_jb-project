package com.jeonbuk.report.domain.user;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 역할 엔티티
 */
@Entity
@Table(name = "roles")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Role {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "role_id")
    private Long id;
    
    @Column(name = "role_name", unique = true, nullable = false, length = 50)
    private String roleName;
    
    @Builder
    public Role(String roleName) {
        this.roleName = roleName;
    }
    
    // 상수 정의
    public static final String USER = "ROLE_USER";
    public static final String TEAM_LEADER = "ROLE_TEAM_LEADER";
    public static final String ADMIN = "ROLE_ADMIN";
}

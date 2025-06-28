package com.jeonbuk.report.domain.user;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * 사용자-역할 매핑 엔티티
 */
@Entity
@Table(name = "user_roles")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class UserRole {
    
    @EmbeddedId
    private UserRoleId id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private User user;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("roleId")
    @JoinColumn(name = "role_id")
    private Role role;
    
    @Builder
    public UserRole(User user, Role role) {
        this.user = user;
        this.role = role;
        this.id = UserRoleId.builder()
                .userId(user.getId())
                .roleId(role.getId())
                .build();
    }
}

/**
 * 복합키 클래스
 */
@Embeddable
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@lombok.Builder
@lombok.AllArgsConstructor
@lombok.EqualsAndHashCode
public class UserRoleId implements java.io.Serializable {
    
    @Column(name = "user_id")
    private Long userId;
    
    @Column(name = "role_id")
    private Long roleId;
}

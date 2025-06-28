package com.jeonbuk.report.domain.user;

import com.jeonbuk.report.domain.common.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.HashSet;
import java.util.Set;

/**
 * 사용자 엔티티
 */
@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User extends BaseEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Long id;
    
    @Column(name = "name", nullable = false, length = 50)
    private String name;
    
    @Column(name = "email", unique = true, nullable = false, length = 100)
    private String email;
    
    @Column(name = "password", length = 255)
    private String password;
    
    @Column(name = "phone_number", length = 20)
    private String phoneNumber;
    
    @Column(name = "department", length = 100)
    private String department;
    
    @Column(name = "profile_image_url", length = 255)
    private String profileImageUrl;
    
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = false;
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private Set<UserRole> userRoles = new HashSet<>();
    
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private Set<OAuthInfo> oauthInfos = new HashSet<>();
    
    @Builder
    public User(String name, String email, String password, String phoneNumber, 
                String department, String profileImageUrl, Boolean isActive) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.phoneNumber = phoneNumber;
        this.department = department;
        this.profileImageUrl = profileImageUrl;
        this.isActive = isActive != null ? isActive : false;
    }
    
    // 비즈니스 메서드
    public void updateProfile(String name, String phoneNumber, String department) {
        this.name = name;
        this.phoneNumber = phoneNumber;
        this.department = department;
    }
    
    public void activate() {
        this.isActive = true;
    }
    
    public void deactivate() {
        this.isActive = false;
    }
    
    public void changePassword(String encodedPassword) {
        this.password = encodedPassword;
    }
    
    public void updateProfileImage(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }
}

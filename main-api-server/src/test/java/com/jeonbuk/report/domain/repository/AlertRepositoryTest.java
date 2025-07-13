package com.jeonbuk.report.domain.repository;

import com.jeonbuk.report.domain.entity.Alert;
import com.jeonbuk.report.domain.entity.Alert.AlertSeverity;
import com.jeonbuk.report.domain.entity.Alert.AlertType;
import com.jeonbuk.report.domain.entity.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * AlertRepository 단위 테스트
 */
@DataJpaTest
@ActiveProfiles("test")
class AlertRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private AlertRepository alertRepository;

    private User testUser;
    private Alert testAlert;

    @BeforeEach
    void setUp() {
        // 테스트용 사용자 생성
        testUser = User.builder()
                .email("test@example.com")
                .name("Test User")
                .build();
        entityManager.persistAndFlush(testUser);

        // 테스트용 알림 생성
        testAlert = Alert.builder()
                .user(testUser)
                .type(AlertType.SYSTEM_NOTIFICATION)
                .title("Test Alert")
                .content("This is a test alert")
                .severity(AlertSeverity.MEDIUM)
                .build();
    }

    @Test
    void save_ShouldPersistAlert() {
        // When
        Alert savedAlert = alertRepository.save(testAlert);

        // Then
        assertThat(savedAlert.getId()).isNotNull();
        assertThat(savedAlert.getUser()).isEqualTo(testUser);
        assertThat(savedAlert.getTitle()).isEqualTo("Test Alert");
        assertThat(savedAlert.getType()).isEqualTo(AlertType.SYSTEM_NOTIFICATION);
        assertThat(savedAlert.getSeverity()).isEqualTo(AlertSeverity.MEDIUM);
        assertThat(savedAlert.getIsRead()).isFalse();
        assertThat(savedAlert.getIsResolved()).isFalse();
        assertThat(savedAlert.getCreatedAt()).isNotNull();
    }

    @Test
    void findById_ShouldReturnAlert() {
        // Given
        Alert savedAlert = alertRepository.save(testAlert);

        // When
        Optional<Alert> foundAlert = alertRepository.findById(savedAlert.getId());

        // Then
        assertThat(foundAlert).isPresent();
        assertThat(foundAlert.get().getTitle()).isEqualTo("Test Alert");
    }

    @Test
    void findByUserIdOrderByCreatedAtDesc_ShouldReturnUserAlerts() {
        // Given
        Alert alert1 = Alert.builder()
                .user(testUser)
                .type(AlertType.HIGH_PRIORITY)
                .title("Alert 1")
                .content("First alert")
                .severity(AlertSeverity.HIGH)
                .build();
        
        Alert alert2 = Alert.builder()
                .user(testUser)
                .type(AlertType.CRITICAL)
                .title("Alert 2")
                .content("Second alert")
                .severity(AlertSeverity.CRITICAL)
                .build();

        Alert savedAlert1 = alertRepository.save(alert1);
        Alert savedAlert2 = alertRepository.save(alert2);
        
        // When
        List<Alert> alerts = alertRepository.findByUserIdOrderByCreatedAtDesc(testUser.getId());

        // Then
        assertThat(alerts).hasSize(2);
        assertThat(alerts.get(0).getTitle()).isEqualTo("Alert 2"); // 최신순
        assertThat(alerts.get(1).getTitle()).isEqualTo("Alert 1");
    }

    @Test
    void findByUserIdAndIsReadFalseOrderByCreatedAtDesc_ShouldReturnUnreadAlerts() {
        // Given
        Alert readAlert = Alert.builder()
                .user(testUser)
                .type(AlertType.SYSTEM_NOTIFICATION)
                .title("Read Alert")
                .content("This is read")
                .severity(AlertSeverity.LOW)
                .build();
        readAlert.markAsRead();
        
        Alert unreadAlert = Alert.builder()
                .user(testUser)
                .type(AlertType.HIGH_PRIORITY)
                .title("Unread Alert")
                .content("This is unread")
                .severity(AlertSeverity.HIGH)
                .build();

        alertRepository.save(readAlert);
        alertRepository.save(unreadAlert);

        // When
        List<Alert> unreadAlerts = alertRepository.findByUserIdAndIsReadFalseOrderByCreatedAtDesc(testUser.getId());

        // Then
        assertThat(unreadAlerts).hasSize(1);
        assertThat(unreadAlerts.get(0).getTitle()).isEqualTo("Unread Alert");
        assertThat(unreadAlerts.get(0).getIsRead()).isFalse();
    }

    @Test
    void countByUserIdAndIsReadFalse_ShouldReturnUnreadCount() {
        // Given
        Alert readAlert = Alert.builder()
                .user(testUser)
                .type(AlertType.SYSTEM_NOTIFICATION)
                .title("Read Alert")
                .content("This is read")
                .severity(AlertSeverity.LOW)
                .build();
        readAlert.markAsRead();

        Alert unreadAlert1 = Alert.builder()
                .user(testUser)
                .type(AlertType.HIGH_PRIORITY)
                .title("Unread Alert 1")
                .content("This is unread")
                .severity(AlertSeverity.HIGH)
                .build();

        Alert unreadAlert2 = Alert.builder()
                .user(testUser)
                .type(AlertType.CRITICAL)
                .title("Unread Alert 2")
                .content("This is also unread")
                .severity(AlertSeverity.CRITICAL)
                .build();

        alertRepository.save(readAlert);
        alertRepository.save(unreadAlert1);
        alertRepository.save(unreadAlert2);

        // When
        long unreadCount = alertRepository.countByUserIdAndIsReadFalse(testUser.getId());

        // Then
        assertThat(unreadCount).isEqualTo(2);
    }

    @Test
    void findActiveAlertsByUserId_ShouldReturnActiveAlerts() {
        // Given
        Alert readAlert = Alert.builder()
                .user(testUser)
                .type(AlertType.SYSTEM_NOTIFICATION)
                .title("Read Alert")
                .content("This is read")
                .severity(AlertSeverity.LOW)
                .build();
        readAlert.markAsRead();

        Alert resolvedAlert = Alert.builder()
                .user(testUser)
                .type(AlertType.HIGH_PRIORITY)
                .title("Resolved Alert")
                .content("This is resolved")
                .severity(AlertSeverity.HIGH)
                .build();
        resolvedAlert.markAsResolved(testUser);

        Alert expiredAlert = Alert.builder()
                .user(testUser)
                .type(AlertType.MAINTENANCE)
                .title("Expired Alert")
                .content("This is expired")
                .severity(AlertSeverity.MEDIUM)
                .expiresAt(LocalDateTime.now().minusHours(1)) // 1시간 전 만료
                .build();

        Alert activeAlert = Alert.builder()
                .user(testUser)
                .type(AlertType.CRITICAL)
                .title("Active Alert")
                .content("This is active")
                .severity(AlertSeverity.CRITICAL)
                .build();

        alertRepository.save(readAlert);
        alertRepository.save(resolvedAlert);
        alertRepository.save(expiredAlert);
        alertRepository.save(activeAlert);

        // When
        List<Alert> activeAlerts = alertRepository.findActiveAlertsByUserId(testUser.getId());

        // Then
        assertThat(activeAlerts).hasSize(1);
        assertThat(activeAlerts.get(0).getTitle()).isEqualTo("Active Alert");
        assertThat(activeAlerts.get(0).isActive()).isTrue();
    }

    @Test
    void findExpiredAlerts_ShouldReturnExpiredAlerts() {
        // Given
        Alert expiredAlert = Alert.builder()
                .user(testUser)
                .type(AlertType.MAINTENANCE)
                .title("Expired Alert")
                .content("This alert has expired")
                .severity(AlertSeverity.MEDIUM)
                .expiresAt(LocalDateTime.now().minusHours(1)) // 1시간 전 만료
                .build();

        Alert validAlert = Alert.builder()
                .user(testUser)
                .type(AlertType.SYSTEM_NOTIFICATION)
                .title("Valid Alert")
                .content("This alert is still valid")
                .severity(AlertSeverity.LOW)
                .expiresAt(LocalDateTime.now().plusHours(1)) // 1시간 후 만료
                .build();

        alertRepository.save(expiredAlert);
        alertRepository.save(validAlert);

        // When
        List<Alert> expiredAlerts = alertRepository.findExpiredAlerts();

        // Then
        assertThat(expiredAlerts).hasSize(1);
        assertThat(expiredAlerts.get(0).getTitle()).isEqualTo("Expired Alert");
        assertThat(expiredAlerts.get(0).isExpired()).isTrue();
    }
}
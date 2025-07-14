package com.jeonbuk.report.test.stability;

import com.jeonbuk.report.application.service.UserService;
import com.jeonbuk.report.domain.entity.User;
import com.jeonbuk.report.test.stability.StabilityTestFramework.TestReport;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import java.util.Optional;
import java.util.UUID;

/**
 * 사용자 회원가입/로그인 서비스 안정성 테스트
 */
@Slf4j
@SpringBootTest
@TestPropertySource(locations = "classpath:application-test.properties")
@RequiredArgsConstructor
public class UserServiceStabilityTest {

    private final UserService userService;
    private final StabilityTestFramework testFramework;

    @Test
    @DisplayName("사용자 회원가입 안정성 테스트 - 순차 5회")
    @Transactional
    public void testUserRegistrationStability() {
        TestReport report = testFramework.runRepeatedTest(
            "사용자 서비스",
            "사용자 회원가입",
            this::testUserRegistration,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 90% 성공률)
        assert report.getSuccessRate() >= 90.0 : 
            String.format("사용자 회원가입 성공률이 90%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("사용자 로그인 안정성 테스트 - 순차 6회")
    @Transactional
    public void testUserLoginStability() {
        TestReport report = testFramework.runRepeatedTest(
            "사용자 서비스",
            "사용자 로그인",
            this::testUserLogin,
            6
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 90% 성공률)
        assert report.getSuccessRate() >= 90.0 : 
            String.format("사용자 로그인 성공률이 90%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("사용자 조회 안정성 테스트 - 순차 7회")
    @Transactional
    public void testUserFindStability() {
        TestReport report = testFramework.runRepeatedTest(
            "사용자 서비스",
            "사용자 조회",
            this::testUserFind,
            7
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 95% 성공률)
        assert report.getSuccessRate() >= 95.0 : 
            String.format("사용자 조회 성공률이 95%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("사용자 정보 업데이트 안정성 테스트 - 순차 5회")
    @Transactional
    public void testUserUpdateStability() {
        TestReport report = testFramework.runRepeatedTest(
            "사용자 서비스",
            "사용자 정보 업데이트",
            this::testUserUpdate,
            5
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 90% 성공률)
        assert report.getSuccessRate() >= 90.0 : 
            String.format("사용자 정보 업데이트 성공률이 90%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("중복 체크 안정성 테스트 - 순차 8회")
    @Transactional
    public void testUserDuplicationCheckStability() {
        TestReport report = testFramework.runRepeatedTest(
            "사용자 서비스",
            "중복 체크",
            this::testUserDuplicationCheck,
            8
        );
        
        testFramework.printReport(report);
        
        // 안정성 검증 (최소 95% 성공률)
        assert report.getSuccessRate() >= 95.0 : 
            String.format("중복 체크 성공률이 95%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    @Test
    @DisplayName("사용자 서비스 부하 테스트 - 동시 8회")
    @Transactional
    public void testUserServiceLoadTest() {
        TestReport report = testFramework.runParallelTest(
            "사용자 서비스",
            "사용자 회원가입 (부하)",
            this::testUserRegistration,
            8
        );
        
        testFramework.printReport(report);
        
        // 부하 테스트 검증 (최소 80% 성공률, 평균 응답시간 2초 이하)
        assert report.getSuccessRate() >= 80.0 : 
            String.format("사용자 서비스 부하 테스트 성공률이 80%% 미만입니다: %.2f%%", report.getSuccessRate());
        assert report.getAverageExecutionTime() <= 2000 : 
            String.format("사용자 서비스 평균 응답시간이 2초를 초과했습니다: %dms", report.getAverageExecutionTime());
    }

    @Test
    @DisplayName("사용자 전체 플로우 안정성 테스트 - 순차 5회")
    @Transactional
    public void testUserFullFlowStability() {
        TestReport report = testFramework.runRepeatedTest(
            "사용자 서비스",
            "사용자 전체 플로우",
            this::testUserFullFlow,
            5
        );
        
        testFramework.printReport(report);
        
        // 전체 플로우 안정성 검증 (최소 85% 성공률)
        assert report.getSuccessRate() >= 85.0 : 
            String.format("사용자 전체 플로우 성공률이 85%% 미만입니다: %.2f%%", report.getSuccessRate());
    }

    /**
     * 사용자 회원가입 테스트
     */
    private User testUserRegistration() {
        try {
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String email = "test-" + uniqueId + "@test.com";
            String password = "password123!";
            String name = "테스트사용자" + uniqueId;
            String phone = "010-1234-" + String.format("%04d", (int)(Math.random() * 10000));
            String department = "테스트부서";

            User user = userService.registerUser(email, password, name, phone, department);
            
            if (user == null) {
                throw new RuntimeException("사용자 객체가 null입니다");
            }
            
            if (!email.equals(user.getEmail())) {
                throw new RuntimeException("이메일이 일치하지 않습니다");
            }
            
            if (!name.equals(user.getName())) {
                throw new RuntimeException("이름이 일치하지 않습니다");
            }
            
            log.info("사용자 회원가입 성공: {} ({})", user.getName(), user.getEmail());
            return user;
            
        } catch (Exception e) {
            throw new RuntimeException("사용자 회원가입 실패: " + e.getMessage());
        }
    }

    /**
     * 사용자 로그인 테스트
     */
    private User testUserLogin() {
        try {
            // 먼저 사용자 등록
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String email = "login-test-" + uniqueId + "@test.com";
            String password = "password123!";
            String name = "로그인테스트" + uniqueId;
            String phone = "010-5678-" + String.format("%04d", (int)(Math.random() * 10000));
            String department = "테스트부서";

            User registeredUser = userService.registerUser(email, password, name, phone, department);
            
            // 로그인 테스트
            Optional<User> loginResult = userService.authenticateUser(email, password);
            
            if (loginResult.isEmpty()) {
                throw new RuntimeException("로그인 실패: 사용자를 찾을 수 없음");
            }
            
            User loggedInUser = loginResult.get();
            
            if (!registeredUser.getId().equals(loggedInUser.getId())) {
                throw new RuntimeException("로그인된 사용자 ID가 일치하지 않습니다");
            }
            
            // 잘못된 비밀번호로 로그인 시도
            Optional<User> wrongPasswordResult = userService.authenticateUser(email, "wrongpassword");
            if (wrongPasswordResult.isPresent()) {
                throw new RuntimeException("잘못된 비밀번호로 로그인이 성공함");
            }
            
            log.info("사용자 로그인 성공: {} ({})", loggedInUser.getName(), loggedInUser.getEmail());
            return loggedInUser;
            
        } catch (Exception e) {
            throw new RuntimeException("사용자 로그인 실패: " + e.getMessage());
        }
    }

    /**
     * 사용자 조회 테스트
     */
    private User testUserFind() {
        try {
            // 먼저 사용자 등록
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String email = "find-test-" + uniqueId + "@test.com";
            String password = "password123!";
            String name = "조회테스트" + uniqueId;
            String phone = "010-9999-" + String.format("%04d", (int)(Math.random() * 10000));
            String department = "테스트부서";

            User registeredUser = userService.registerUser(email, password, name, phone, department);
            
            // 이메일로 조회
            Optional<User> foundByEmail = userService.findByEmail(email);
            if (foundByEmail.isEmpty()) {
                throw new RuntimeException("이메일로 사용자 조회 실패");
            }
            
            if (!registeredUser.getId().equals(foundByEmail.get().getId())) {
                throw new RuntimeException("조회된 사용자 ID가 일치하지 않습니다");
            }
            
            // 존재하지 않는 이메일로 조회
            Optional<User> notFound = userService.findByEmail("notexist@test.com");
            if (notFound.isPresent()) {
                throw new RuntimeException("존재하지 않는 이메일로 사용자가 조회됨");
            }
            
            log.info("사용자 조회 성공: {} ({})", foundByEmail.get().getName(), foundByEmail.get().getEmail());
            return foundByEmail.get();
            
        } catch (Exception e) {
            throw new RuntimeException("사용자 조회 실패: " + e.getMessage());
        }
    }

    /**
     * 사용자 정보 업데이트 테스트
     */
    private User testUserUpdate() {
        try {
            // 먼저 사용자 등록
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String email = "update-test-" + uniqueId + "@test.com";
            String password = "password123!";
            String name = "업데이트테스트" + uniqueId;
            String phone = "010-1111-" + String.format("%04d", (int)(Math.random() * 10000));
            String department = "테스트부서";

            User registeredUser = userService.registerUser(email, password, name, phone, department);
            
            // 정보 업데이트
            String newName = "수정된이름" + uniqueId;
            String newPhone = "010-2222-" + String.format("%04d", (int)(Math.random() * 10000));
            String newDepartment = "수정된부서";
            
            User updatedUser = userService.updateUser(registeredUser.getId(), newName, newPhone, newDepartment);
            
            if (!newName.equals(updatedUser.getName())) {
                throw new RuntimeException("이름이 업데이트되지 않았습니다");
            }
            
            if (!newPhone.equals(updatedUser.getPhone())) {
                throw new RuntimeException("전화번호가 업데이트되지 않았습니다");
            }
            
            if (!newDepartment.equals(updatedUser.getDepartment())) {
                throw new RuntimeException("부서가 업데이트되지 않았습니다");
            }
            
            // 이메일은 변경되지 않아야 함
            if (!email.equals(updatedUser.getEmail())) {
                throw new RuntimeException("이메일이 변경되었습니다");
            }
            
            log.info("사용자 정보 업데이트 성공: {} -> {}", name, newName);
            return updatedUser;
            
        } catch (Exception e) {
            throw new RuntimeException("사용자 정보 업데이트 실패: " + e.getMessage());
        }
    }

    /**
     * 중복 체크 테스트
     */
    private Boolean testUserDuplicationCheck() {
        try {
            // 먼저 사용자 등록
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String email = "dup-test-" + uniqueId + "@test.com";
            String password = "password123!";
            String name = "중복테스트" + uniqueId;
            String phone = "010-3333-" + String.format("%04d", (int)(Math.random() * 10000));
            String department = "테스트부서";

            User registeredUser = userService.registerUser(email, password, name, phone, department);
            
            // 이메일 중복 체크 (존재하는 이메일)
            Optional<User> existingEmail = userService.findByEmail(email);
            if (existingEmail.isEmpty()) {
                throw new RuntimeException("등록된 이메일이 조회되지 않음");
            }
            
            // 이메일 중복 체크 (존재하지 않는 이메일)
            String newEmail = "new-" + uniqueId + "@test.com";
            Optional<User> nonExistingEmail = userService.findByEmail(newEmail);
            if (nonExistingEmail.isPresent()) {
                throw new RuntimeException("존재하지 않는 이메일이 조회됨");
            }
            
            // 이름 사용 가능 여부 체크
            boolean isNameAvailable = userService.isNameAvailable("새로운이름" + uniqueId);
            if (!isNameAvailable) {
                throw new RuntimeException("새로운 이름이 사용 불가능하다고 판단됨");
            }
            
            // 전화번호 사용 가능 여부 체크
            boolean isPhoneAvailable = userService.isPhoneAvailable("010-4444-" + String.format("%04d", (int)(Math.random() * 10000)));
            if (!isPhoneAvailable) {
                throw new RuntimeException("새로운 전화번호가 사용 불가능하다고 판단됨");
            }
            
            // 등록된 전화번호 중복 체크
            boolean isExistingPhoneAvailable = userService.isPhoneAvailable(phone);
            if (isExistingPhoneAvailable) {
                throw new RuntimeException("등록된 전화번호가 사용 가능하다고 판단됨");
            }
            
            log.info("중복 체크 테스트 성공: {}", email);
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("중복 체크 실패: " + e.getMessage());
        }
    }

    /**
     * 사용자 전체 플로우 테스트
     */
    private Boolean testUserFullFlow() {
        try {
            String uniqueId = UUID.randomUUID().toString().substring(0, 8);
            String email = "flow-test-" + uniqueId + "@test.com";
            String password = "password123!";
            String name = "플로우테스트" + uniqueId;
            String phone = "010-5555-" + String.format("%04d", (int)(Math.random() * 10000));
            String department = "테스트부서";

            // 1. 중복 체크 (사용 가능해야 함)
            Optional<User> duplicateCheck = userService.findByEmail(email);
            if (duplicateCheck.isPresent()) {
                throw new RuntimeException("이미 존재하는 이메일입니다");
            }
            
            // 2. 회원가입
            User registeredUser = userService.registerUser(email, password, name, phone, department);
            
            // 3. 로그인
            Optional<User> loginResult = userService.authenticateUser(email, password);
            if (loginResult.isEmpty()) {
                throw new RuntimeException("회원가입 후 로그인 실패");
            }
            
            // 4. 사용자 정보 조회
            Optional<User> foundUser = userService.findByEmail(email);
            if (foundUser.isEmpty()) {
                throw new RuntimeException("등록된 사용자 조회 실패");
            }
            
            // 5. 정보 업데이트
            String newName = "업데이트된" + name;
            User updatedUser = userService.updateUser(registeredUser.getId(), newName, phone, department);
            
            // 6. 업데이트 결과 확인
            Optional<User> finalUser = userService.findByEmail(email);
            if (finalUser.isEmpty() || !newName.equals(finalUser.get().getName())) {
                throw new RuntimeException("업데이트 결과 확인 실패");
            }
            
            // 7. 중복 체크 (이제 사용 불가능해야 함)
            Optional<User> finalDuplicateCheck = userService.findByEmail(email);
            if (finalDuplicateCheck.isEmpty()) {
                throw new RuntimeException("등록된 이메일이 중복 체크에서 발견되지 않음");
            }
            
            log.info("사용자 전체 플로우 테스트 완료: {} -> {}", name, newName);
            return true;
            
        } catch (Exception e) {
            throw new RuntimeException("사용자 전체 플로우 실패: " + e.getMessage());
        }
    }
}
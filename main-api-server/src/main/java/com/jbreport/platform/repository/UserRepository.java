package com.jbreport.platform.repository;

import com.jbreport.platform.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByEmail(String email);
    
    boolean existsByEmail(String email);
    
    @Query("SELECT u FROM User u WHERE u.role = :role AND u.active = true")
    List<User> findByRole(@Param("role") String role);
    
    @Query("SELECT u FROM User u WHERE u.role IN :roles AND u.active = true")
    List<User> findByRoles(@Param("roles") List<String> roles);
    
    Optional<User> findByEmailAndActiveTrue(String email);
    
    @Query("SELECT COUNT(u) FROM User u WHERE u.role = :role AND u.active = true")
    Long countByRole(@Param("role") String role);
}

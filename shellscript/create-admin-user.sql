-- 새로운 관리자 계정 생성 스크립트
-- 비밀번호: admin123 (BCrypt 해시)

INSERT INTO users (
    id, 
    email, 
    password_hash, 
    name, 
    phone, 
    department,
    role, 
    is_active,
    email_verified, 
    created_at, 
    updated_at
) VALUES (
    uuid_generate_v4(),
    'admin@admin.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMye8IKDjT4v6RFJhGC5XXy5IxYHlE.E8m2',
    '관리자',
    '010-0000-0000',
    '시스템 관리부',
    'admin',
    true,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- 관리자 계정 확인
SELECT id, email, name, role, is_active, email_verified, created_at 
FROM users 
WHERE role = 'admin' 
ORDER BY created_at DESC;
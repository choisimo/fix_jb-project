-- 카테고리 초기 데이터
INSERT INTO categories (id, name, description, icon, color, parent_id, created_at, updated_at) VALUES
(1, '도로/교통', '도로 파손, 교통 관련 신고', 'road', '#FF5722', NULL, NOW(), NOW()),
(2, '환경/청소', '쓰레기, 환경 오염 관련 신고', 'environment', '#4CAF50', NULL, NOW(), NOW()),
(3, '시설물', '공공시설물 파손, 고장 관련 신고', 'facility', '#2196F3', NULL, NOW(), NOW()),
(4, '안전/보안', '안전사고, 보안 위험 관련 신고', 'security', '#F44336', NULL, NOW(), NOW()),
(5, '기타', '기타 신고사항', 'etc', '#9E9E9E', NULL, NOW(), NOW());

-- 하위 카테고리
INSERT INTO categories (id, name, description, icon, color, parent_id, created_at, updated_at) VALUES
(6, '도로 파손', '포트홀, 도로 균열 등', 'pothole', '#FF5722', 1, NOW(), NOW()),
(7, '불법주차', '불법 주차 신고', 'parking', '#FF9800', 1, NOW(), NOW()),
(8, '신호등 고장', '신호등 및 교통시설 고장', 'traffic_light', '#FFC107', 1, NOW(), NOW()),
(9, '무단투기', '쓰레기 무단투기', 'trash', '#4CAF50', 2, NOW(), NOW()),
(10, '대기오염', '매연, 악취 등', 'air_pollution', '#8BC34A', 2, NOW(), NOW()),
(11, '가로등', '가로등 고장', 'street_light', '#2196F3', 3, NOW(), NOW()),
(12, '공원시설', '공원 시설물 파손', 'park', '#03DAC6', 3, NOW(), NOW());

-- 상태 초기 데이터
INSERT INTO statuses (id, name, description, color, priority, created_at, updated_at) VALUES
(1, '접수', '신고가 접수된 상태', '#2196F3', 1, NOW(), NOW()),
(2, '검토중', '담당자가 검토 중인 상태', '#FF9800', 2, NOW(), NOW()),
(3, '처리중', '문제 해결을 위해 작업 중인 상태', '#FFC107', 3, NOW(), NOW()),
(4, '완료', '처리가 완료된 상태', '#4CAF50', 4, NOW(), NOW()),
(5, '반려', '신고가 반려된 상태', '#F44336', 5, NOW(), NOW()),
(6, '보류', '추가 검토가 필요한 상태', '#9E9E9E', 6, NOW(), NOW());

-- 관리자 사용자 생성
INSERT INTO users (id, email, password, name, phone, address, role, email_verified, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'admin@jeonbuk.go.kr', '$2a$10$N9qo8uLOickgx2ZMRZoMye8IKDjT4v6RFJhGC5XXy5IxYHlE.E8m2', '시스템 관리자', '010-1234-5678', '전북 전주시', 'ADMIN', true, NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440001', 'user@test.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye8IKDjT4v6RFJhGC5XXy5IxYHlE.E8m2', '테스트 사용자', '010-9876-5432', '전북 전주시', 'USER', true, NOW(), NOW());

-- 테스트 신고서 데이터
INSERT INTO reports (id, title, description, content, priority, user_id, category_id, status_id, latitude, longitude, address, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440100', '도로 파손 신고', '전주시 덕진구 도로에 큰 포트홀이 발생했습니다.', '차량 통행에 매우 위험한 상황입니다. 신속한 조치가 필요합니다.', 'HIGH', '550e8400-e29b-41d4-a716-446655440001', 6, 1, 35.8242238, 127.1479532, '전북 전주시 덕진구 덕진동1가', NOW(), NOW()),
('550e8400-e29b-41d4-a716-446655440101', '쓰레기 무단투기 신고', '아파트 단지 앞에 대형 쓰레기가 버려져 있습니다.', '며칠째 방치되어 있어 악취가 심합니다.', 'MEDIUM', '550e8400-e29b-41d4-a716-446655440001', 9, 1, 35.8150875, 127.1505672, '전북 전주시 완산구 서노송동', NOW(), NOW());
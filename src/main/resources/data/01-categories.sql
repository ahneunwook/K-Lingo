-- ===================================
-- 카테고리 초기 데이터 (핵심 15개)
-- ===================================

INSERT INTO word_categories (name_en, name_kr, icon, display_order, description, created_at, updated_at) VALUES
-- 기초 필수 (1-5)
('GREETINGS', '인사', '👋', 1, '인사말과 기본 예의', NOW(), NOW()),
('NUMBERS', '숫자', '🔢', 2, '숫자 세기', NOW(), NOW()),
('COLORS', '색깔', '🎨', 3, '색상', NOW(), NOW()),
('TIME', '시간', '⏰', 4, '시간과 날짜', NOW(), NOW()),
('LOCATIONS', '위치', '📍', 5, '위치와 방향', NOW(), NOW()),

-- 사람과 일상 (6-10)
('FAMILY', '가족', '👨‍👩‍👧‍👦', 6, '가족 관계', NOW(), NOW()),
('BODY', '신체', '🫱', 7, '신체 부위', NOW(), NOW()),
('EMOTIONS', '감정', '😊', 8, '감정 표현', NOW(), NOW()),
('FOOD', '음식', '🍽️', 9, '음식과 식사', NOW(), NOW()),
('HOME', '집', '🏠', 10, '집과 가구', NOW(), NOW()),

-- 활동과 사회 (11-15)
('DAILY_VERBS', '일상동사', '🏃', 11, '일상 행동', NOW(), NOW()),
('TRANSPORTATION', '교통', '🚗', 12, '교통수단', NOW(), NOW()),
('SHOPPING', '쇼핑', '🛍️', 13, '쇼핑과 구매', NOW(), NOW()),
('SCHOOL', '학교', '🏫', 14, '학교와 교육', NOW(), NOW()),
('WORK', '직장', '💼', 15, '회사와 업무', NOW(), NOW());


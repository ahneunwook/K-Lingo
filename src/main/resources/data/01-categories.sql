-- ===================================
-- 챕터 초기 데이터 (기존 카테고리 -> 챕터로 통합)
-- ===================================

INSERT INTO chapters (name_en, name_kr, icon, display_order, description, type, created_at, updated_at) VALUES
-- 1. 일단 생존하자 (TOPIC)
('GREETINGS', '왕기초 인사', '👋', 1, '안녕? 반가워! 필수 예절', 'TOPIC', NOW(), NOW()),
('NUMBERS', '숫자/계산', '🔢', 2, '하나 둘 셋, 가격 계산하기', 'TOPIC', NOW(), NOW()),
('SURVIVAL', '생존 회화', '🚨', 3, '도와주세요! 화장실 어디에요?', 'TOPIC', NOW(), NOW()),
('FOOD', '맛있는 음식', '🍗', 4, '김치, 치맥, 삼겹살 먹방', 'TOPIC', NOW(), NOW()),
('ORDERING', '주문하기', '☕', 5, '아이스 아메리카노 주세요', 'TOPIC', NOW(), NOW()),

-- 2. 한국 즐기기 (TOPIC)
('TRANSPORT', '교통/길찾기', '🚇', 6, '지옥철, 버스, 환승입니다', 'TOPIC', NOW(), NOW()),
('PLACES', '핫플레이스', '📍', 7, '한강, 편의점, 노래방, PC방', 'TOPIC', NOW(), NOW()),
('SHOPPING', '쇼핑하기', '🛍️', 8, '신상, 세일, 깎아주세요', 'TOPIC', NOW(), NOW()),
('TIME', '시간/약속', '⏰', 9, '주말 약속, 빨리빨리 문화', 'TOPIC', NOW(), NOW()),
('HEALTH', '병원/약국', '💊', 10, '아파요, 약 주세요, 밴드', 'TOPIC', NOW(), NOW()),

-- 3. 인싸 되기 (TOPIC)
('RELATIONSHIPS', '호칭/가족', '👨‍👩‍👧', 11, '오빠, 언니, 선배님, 꼰대(?)', 'TOPIC', NOW(), NOW()),
('EMOTIONS', '기분/감정', '🥰', 12, '행복해, 킹받네(?), 우울해', 'TOPIC', NOW(), NOW()),
('K_CULTURE', 'K-POP/드라마', '🎵', 13, '최애, 덕질, 정주행, 스포 금지', 'TOPIC', NOW(), NOW()),
('SLANG', '요즘 유행어', '😎', 14, '대박, 헐, 꿀잼, 인싸', 'TOPIC', NOW(), NOW()),
('LOVE', '연애/사랑', '💖', 15, '썸타다, 고백, 심쿵, 데이트', 'TOPIC', NOW(), NOW());


-- 기존 데이터가 있다면 순서가 꼬일 수 있으니 확인 필요 (보통 초기화 후 진행)
-- 1. Particle Master (조사)
INSERT INTO chapters (name_en, name_kr, type, display_order, description, icon, created_at, updated_at)
VALUES
    (
        'Particle Master',
        '조사(은/는/이/가) 지옥 훈련',
        'SENTENCE',
        1,
        '한국어의 가장 큰 벽! 은/는/이/가/을/를 헷갈리지 않고 완벽하게 마스터해보세요.',
        'https://your-s3-bucket.com/icons/particle_sword.png',
        NOW(),
        NOW()
    );

-- 2. Verb Ending (동사 변형)
INSERT INTO chapters (name_en, name_kr, type, display_order, description, icon, created_at, updated_at)
VALUES
    (
        'Verb Ending',
        '동사 변형(요/죠/습니다) 마스터',
        'SENTENCE',
        2,
        '가다 -> 가요, 갔어요, 갈 거예요... 상황에 맞게 동사를 자유자재로 바꿔보세요.',
        'https://your-s3-bucket.com/icons/verb_clock.png',
        NOW(),
        NOW()
    );

-- 3. Honorifics (존댓말)
INSERT INTO chapters (name_en, name_kr, type, display_order, description, icon, created_at, updated_at)
VALUES
    (
        'Honorifics',
        '한국 예절 배우기 (존댓말)',
        'SENTENCE',
        3,
        '반말(Casual)과 존댓말(Polite)의 차이! 드라마 주인공처럼 자연스럽게 예절을 지켜봐요.',
        'https://your-s3-bucket.com/icons/bow_manners.png',
        NOW(),
        NOW()
    );

-- 4. Word Puzzle (어순)
INSERT INTO chapters (name_en, name_kr, type, display_order, description, icon, created_at, updated_at)
VALUES
    (
        'Word Puzzle',
        '한국어 어순 감각 키우기',
        'SENTENCE',
        4,
        '영어와 정반대인 한국어 어순! 단어 퍼즐을 맞추며 한국어 뇌를 만들어보세요.',
        'https://your-s3-bucket.com/icons/puzzle_brain.png',
        NOW(),
        NOW()
    );
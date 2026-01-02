-- ===================================
-- K-Lingo 단어 데이터
-- 각 카테고리당 10-20개
-- base_difficulty: 1(쉬움) ~ 5(어려움)
-- ===================================

-- ============================================
-- 1. GREETINGS (인사) - 15개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('안녕', 'annyeong', 'Hi/Bye', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 1),
('네', 'ne', 'Yes', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 1),
('아니요', 'aniyo', 'No', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 1),
('안녕하세요', 'annyeonghaseyo', 'Hello', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 2),
('감사합니다', 'gamsahamnida', 'Thank you', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 2),
('미안해요', 'mianhaeyo', 'Sorry', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 2),
('괜찮아요', 'gwaenchanayo', 'It is okay', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 2),
('죄송합니다', 'joesonghamnida', 'I am sorry', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 3),
('반갑습니다', 'bangapseumnida', 'Nice to meet you', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 3),
('잘 지내요?', 'jal jinaeyo?', 'How are you?', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 3),
('수고하세요', 'sugohaseyo', 'Good job', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 3),
('안녕히 가세요', 'annyeonghi gaseyo', 'Goodbye (leaving)', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 4),
('안녕히 계세요', 'annyeonghi gyeseyo', 'Goodbye (staying)', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 4),
('오랜만이에요', 'oraenmanieyo', 'Long time no see', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 4),
('처음 뵙겠습니다', 'cheoeum boepgesseumnida', 'Nice to meet you (formal)', (SELECT id FROM word_categories WHERE name_en = 'GREETINGS'), 5);

-- ============================================
-- 2. NUMBERS (숫자) - 24개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
-- 고유어
('하나', 'hana', 'One', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
('둘', 'dul', 'Two', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
('셋', 'set', 'Three', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
('넷', 'net', 'Four', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
('다섯', 'daseot', 'Five', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
('여섯', 'yeoseot', 'Six', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 2),
('일곱', 'ilgop', 'Seven', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 2),
('여덟', 'yeodeol', 'Eight', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 2),
('아홉', 'ahop', 'Nine', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 2),
('열', 'yeol', 'Ten', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
-- 한자어
('일', 'il', 'One (Sino)', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
('이', 'i', 'Two (Sino)', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
('삼', 'sam', 'Three (Sino)', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
('사', 'sa', 'Four (Sino)', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
('오', 'o', 'Five (Sino)', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 1),
('십', 'sip', 'Ten', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 2),
('백', 'baek', 'Hundred', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 2),
('천', 'cheon', 'Thousand', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 2),
('만', 'man', 'Ten thousand', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 2),
('억', 'eok', 'Hundred million', (SELECT id FROM word_categories WHERE name_en = 'NUMBERS'), 3);

-- ============================================
-- 3. COLORS (색깔) - 12개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('빨강', 'ppalgang', 'Red', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 1),
('파랑', 'parang', 'Blue', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 1),
('노랑', 'norang', 'Yellow', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 1),
('하양', 'hayang', 'White', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 1),
('검정', 'geomjeong', 'Black', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 1),
('초록', 'chorok', 'Green', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 2),
('주황', 'juhwang', 'Orange', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 2),
('보라', 'bora', 'Purple', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 2),
('분홍', 'bunhong', 'Pink', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 2),
('회색', 'hoesaek', 'Gray', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 2),
('갈색', 'galsaek', 'Brown', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 2),
('금색', 'geumsaek', 'Gold', (SELECT id FROM word_categories WHERE name_en = 'COLORS'), 3);

-- ============================================
-- 4. TIME (시간) - 15개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('오늘', 'oneul', 'Today', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 1),
('어제', 'eoje', 'Yesterday', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 1),
('내일', 'naeil', 'Tomorrow', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 1),
('밤', 'bam', 'Night', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 1),
('아침', 'achim', 'Morning', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 2),
('점심', 'jeomsim', 'Lunch/Noon', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 2),
('저녁', 'jeonyeok', 'Evening/Dinner', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 2),
('시간', 'sigan', 'Time', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 2),
('주말', 'jumal', 'Weekend', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 3),
('평일', 'pyeongil', 'Weekday', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 3),
('월요일', 'woryoil', 'Monday', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 4),
('화요일', 'hwayoil', 'Tuesday', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 4),
('수요일', 'suyoil', 'Wednesday', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 4),
('금요일', 'geumyoil', 'Friday', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 4),
('토요일', 'toyoil', 'Saturday', (SELECT id FROM word_categories WHERE name_en = 'TIME'), 4);

-- ============================================
-- 5. LOCATIONS (위치) - 12개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('여기', 'yeogi', 'Here', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 1),
('위', 'wi', 'Above/Top', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 1),
('앞', 'ap', 'Front', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 1),
('뒤', 'dwi', 'Back/Behind', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 1),
('안', 'an', 'Inside', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 1),
('밖', 'bakk', 'Outside', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 1),
('저기', 'jeogi', 'There (far)', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 2),
('거기', 'geogi', 'There (middle)', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 2),
('아래', 'arae', 'Below/Bottom', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 2),
('옆', 'yeop', 'Side/Next to', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 2),
('왼쪽', 'oenjjok', 'Left', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 3),
('오른쪽', 'oreunjjok', 'Right', (SELECT id FROM word_categories WHERE name_en = 'LOCATIONS'), 3);

-- ============================================
-- 6. FAMILY (가족) - 15개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('엄마', 'eomma', 'Mom', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 1),
('아빠', 'appa', 'Dad', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 1),
('아들', 'adeul', 'Son', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 2),
('딸', 'ttal', 'Daughter', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 1),
('가족', 'gajok', 'Family', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 2),
('동생', 'dongsaeng', 'Younger sibling', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 2),
('할머니', 'halmeoni', 'Grandmother', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 2),
('할아버지', 'harabeoji', 'Grandfather', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 3),
('어머니', 'eomeoni', 'Mother (formal)', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 3),
('아버지', 'abeoji', 'Father (formal)', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 3),
('형', 'hyeong', 'Older brother (male)', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 2),
('오빠', 'oppa', 'Older brother (female)', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 2),
('언니', 'eonni', 'Older sister (female)', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 2),
('누나', 'nuna', 'Older sister (male)', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 2),
('부모님', 'bumonim', 'Parents', (SELECT id FROM word_categories WHERE name_en = 'FAMILY'), 3);

-- ============================================
-- 7. BODY (신체) - 12개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('머리', 'meori', 'Head/Hair', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1),
('눈', 'nun', 'Eye', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1),
('코', 'ko', 'Nose', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1),
('입', 'ip', 'Mouth', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1),
('귀', 'gwi', 'Ear', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1),
('손', 'son', 'Hand', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1),
('발', 'bal', 'Foot', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1),
('다리', 'dari', 'Leg', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1),
('팔', 'pal', 'Arm', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1),
('배', 'bae', 'Stomach', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1),
('얼굴', 'eolgul', 'Face', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 2),
('목', 'mok', 'Neck/Throat', (SELECT id FROM word_categories WHERE name_en = 'BODY'), 1);

-- ============================================
-- 8. EMOTIONS (감정) - 15개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('좋아요', 'joayo', 'I like it/Good', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 2),
('싫어요', 'sireoyo', 'I do not like it', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 2),
('행복해요', 'haengbokaeyo', 'I am happy', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 3),
('기뻐요', 'gippeoyo', 'I am joyful', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 3),
('슬퍼요', 'seulpeoyo', 'I am sad', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 3),
('화나요', 'hwanayo', 'I am angry', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 3),
('무서워요', 'musewoyo', 'I am scared', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 3),
('피곤해요', 'pigonhaeyo', 'I am tired', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 3),
('심심해요', 'simsimhaeyo', 'I am bored', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 3),
('외로워요', 'oerowoyo', 'I am lonely', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 4),
('부끄러워요', 'bukkeurewoyo', 'I am embarrassed', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 4),
('신나요', 'sinnayo', 'I am excited', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 3),
('걱정돼요', 'geokjeongdwaeyo', 'I am worried', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 4),
('놀라워요', 'nollawoyo', 'I am surprised', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 4),
('짜증나요', 'jjajeungnayo', 'I am annoyed', (SELECT id FROM word_categories WHERE name_en = 'EMOTIONS'), 4);

-- ============================================
-- 9. FOOD (음식) - 20개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('밥', 'bap', 'Rice/Meal', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 1),
('물', 'mul', 'Water', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 1),
('빵', 'ppang', 'Bread', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 1),
('고기', 'gogi', 'Meat', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 1),
('생선', 'saengseon', 'Fish', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 2),
('김치', 'gimchi', 'Kimchi', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 1),
('국', 'guk', 'Soup', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 1),
('우유', 'uyu', 'Milk', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 1),
('커피', 'keopi', 'Coffee', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 2),
('과일', 'gwail', 'Fruit', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 2),
('야채', 'yachae', 'Vegetable', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 2),
('계란', 'gyeran', 'Egg', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 2),
('라면', 'ramyeon', 'Ramen', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 2),
('불고기', 'bulgogi', 'Bulgogi', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 2),
('김밥', 'gimbap', 'Gimbap', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 2),
('비빔밥', 'bibimbap', 'Bibimbap', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 3),
('떡볶이', 'tteokbokki', 'Tteokbokki', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 3),
('삼겹살', 'samgyeopsal', 'Pork belly', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 3),
('된장찌개', 'doenjangjjigae', 'Soybean paste stew', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 4),
('김치찌개', 'gimchijjigae', 'Kimchi stew', (SELECT id FROM word_categories WHERE name_en = 'FOOD'), 4);

-- ============================================
-- 10. HOME (집) - 15개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('집', 'jip', 'House/Home', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 1),
('방', 'bang', 'Room', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 1),
('문', 'mun', 'Door', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 1),
('창문', 'changmun', 'Window', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 2),
('침대', 'chimdae', 'Bed', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 2),
('책상', 'chaeksang', 'Desk', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 2),
('의자', 'uija', 'Chair', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 2),
('소파', 'sopa', 'Sofa', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 2),
('부엌', 'bueok', 'Kitchen', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 2),
('화장실', 'hwajangsil', 'Bathroom/Toilet', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 3),
('냉장고', 'naengjanggo', 'Refrigerator', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 3),
('세탁기', 'setakgi', 'Washing machine', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 3),
('텔레비전', 'tellebijeon', 'Television', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 3),
('에어컨', 'eeokeun', 'Air conditioner', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 3),
('거실', 'geosil', 'Living room', (SELECT id FROM word_categories WHERE name_en = 'HOME'), 3);

-- ============================================
-- 11. CLOTHING (의류) - 12개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('옷', 'ot', 'Clothes', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 1),
('바지', 'baji', 'Pants', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 2),
('치마', 'chima', 'Skirt', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 2),
('신발', 'sinbal', 'Shoes', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 2),
('모자', 'moja', 'Hat/Cap', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 2),
('양말', 'yangmal', 'Socks', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 2),
('가방', 'gabang', 'Bag', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 2),
('안경', 'angyeong', 'Glasses', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 2),
('티셔츠', 'tisyeocheu', 'T-shirt', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 3),
('청바지', 'cheongbaji', 'Jeans', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 3),
('원피스', 'wonpiseu', 'Dress', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 3),
('코트', 'koteu', 'Coat', (SELECT id FROM word_categories WHERE name_en = 'CLOTHING'), 2);

-- ============================================
-- 12. SHOPPING (쇼핑) - 12개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('사다', 'sada', 'To buy', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 2),
('팔다', 'palda', 'To sell', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 2),
('돈', 'don', 'Money', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 1),
('가격', 'gagyeok', 'Price', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 3),
('비싸다', 'bissada', 'Expensive', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 3),
('싸다', 'ssada', 'Cheap', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 2),
('계산', 'gyesan', 'Payment/Calculation', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 3),
('카드', 'kadeu', 'Card', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 2),
('현금', 'hyeongeum', 'Cash', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 3),
('영수증', 'yeongsujeung', 'Receipt', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 4),
('할인', 'halin', 'Discount', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 3),
('마트', 'mateu', 'Mart/Supermarket', (SELECT id FROM word_categories WHERE name_en = 'SHOPPING'), 2);

-- ============================================
-- 13. DAILY_VERBS (일상동사) - 15개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('가다', 'gada', 'To go', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 1),
('오다', 'oda', 'To come', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 1),
('먹다', 'meokda', 'To eat', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 1),
('마시다', 'masida', 'To drink', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 2),
('자다', 'jada', 'To sleep', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 1),
('보다', 'boda', 'To see/watch', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 1),
('듣다', 'deutda', 'To hear/listen', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 2),
('말하다', 'malhada', 'To speak', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 2),
('읽다', 'ilkda', 'To read', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 2),
('쓰다', 'sseuda', 'To write', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 2),
('만들다', 'mandeulda', 'To make', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 3),
('씻다', 'ssitda', 'To wash', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 2),
('입다', 'ipda', 'To wear', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 2),
('걷다', 'geotda', 'To walk', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 2),
('달리다', 'dallida', 'To run', (SELECT id FROM word_categories WHERE name_en = 'DAILY_VERBS'), 3);

-- ============================================
-- 14. TRANSPORTATION (교통) - 12개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('버스', 'beoseu', 'Bus', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 1),
('택시', 'taeksi', 'Taxi', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 1),
('차', 'cha', 'Car', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 1),
('기차', 'gicha', 'Train', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 2),
('지하철', 'jihacheol', 'Subway', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 3),
('비행기', 'bihaenggi', 'Airplane', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 3),
('자전거', 'jajeongeo', 'Bicycle', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 3),
('배', 'bae', 'Ship/Boat', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 1),
('역', 'yeok', 'Station', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 2),
('정류장', 'jeongnyujang', 'Bus stop', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 4),
('공항', 'gonghang', 'Airport', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 3),
('항구', 'hangu', 'Port/Harbor', (SELECT id FROM word_categories WHERE name_en = 'TRANSPORTATION'), 3);

-- ============================================
-- 15. TRAVEL (여행) - 12개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('여행', 'yeohaeng', 'Travel/Trip', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 3),
('호텔', 'hotel', 'Hotel', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 3),
('공항', 'gonghang', 'Airport', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 3),
('여권', 'yeogwon', 'Passport', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 4),
('비자', 'bija', 'Visa', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 3),
('짐', 'jim', 'Luggage', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 2),
('관광', 'gwangwang', 'Tourism/Sightseeing', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 4),
('사진', 'sajin', 'Photo', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 3),
('지도', 'jido', 'Map', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 2),
('예약', 'yeyak', 'Reservation', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 3),
('가이드', 'gaideu', 'Guide', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 3),
('기념품', 'ginyeompum', 'Souvenir', (SELECT id FROM word_categories WHERE name_en = 'TRAVEL'), 5);

-- ============================================
-- 16. WEATHER (날씨) - 10개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('비', 'bi', 'Rain', (SELECT id FROM word_categories WHERE name_en = 'WEATHER'), 1),
('눈', 'nun', 'Snow', (SELECT id FROM word_categories WHERE name_en = 'WEATHER'), 1),
('바람', 'baram', 'Wind', (SELECT id FROM word_categories WHERE name_en = 'WEATHER'), 2),
('날씨', 'nalssi', 'Weather', (SELECT id FROM word_categories WHERE name_en = 'WEATHER'), 2),
('춥다', 'chupda', 'Cold (weather)', (SELECT id FROM word_categories WHERE name_en = 'WEATHER'), 2),
('덥다', 'deopda', 'Hot (weather)', (SELECT id FROM word_categories WHERE name_en = 'WEATHER'), 2),
('구름', 'gureum', 'Cloud', (SELECT id FROM word_categories WHERE name_en = 'WEATHER'), 2),
('하늘', 'haneul', 'Sky', (SELECT id FROM word_categories WHERE name_en = 'WEATHER'), 2),
('맑다', 'makda', 'Clear (weather)', (SELECT id FROM word_categories WHERE name_en = 'WEATHER'), 3),
('흐리다', 'heurida', 'Cloudy', (SELECT id FROM word_categories WHERE name_en = 'WEATHER'), 3);

-- ============================================
-- 17. NATURE (자연) - 15개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('산', 'san', 'Mountain', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('바다', 'bada', 'Sea/Ocean', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 2),
('강', 'gang', 'River', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('나무', 'namu', 'Tree', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 2),
('꽃', 'kkot', 'Flower', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('풀', 'pul', 'Grass', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('개', 'gae', 'Dog', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('고양이', 'goyangi', 'Cat', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('새', 'sae', 'Bird', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('물고기', 'mulgogi', 'Fish', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 2),
('소', 'so', 'Cow', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('돼지', 'dwaeji', 'Pig', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('말', 'mal', 'Horse', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('토끼', 'tokki', 'Rabbit', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 1),
('호랑이', 'horangi', 'Tiger', (SELECT id FROM word_categories WHERE name_en = 'NATURE'), 2);

-- ============================================
-- 18. SCHOOL (학교) - 12개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('학교', 'hakgyo', 'School', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 3),
('학생', 'haksaeng', 'Student', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 3),
('선생님', 'seonsaengnim', 'Teacher', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 3),
('공부', 'gongbu', 'Study', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 3),
('시험', 'siheom', 'Exam', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 3),
('숙제', 'sukje', 'Homework', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 3),
('책', 'chaek', 'Book', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 1),
('교실', 'gyosil', 'Classroom', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 4),
('도서관', 'doseogwan', 'Library', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 4),
('교과서', 'gyogwaseo', 'Textbook', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 5),
('성적', 'seongjeok', 'Grade/Score', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 4),
('졸업', 'joreop', 'Graduation', (SELECT id FROM word_categories WHERE name_en = 'SCHOOL'), 4);

-- ============================================
-- 19. WORK (직장) - 12개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('회사', 'hoesa', 'Company', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 3),
('일', 'il', 'Work/Job', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 1),
('직원', 'jigwon', 'Employee', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 4),
('사장', 'sajang', 'President/Boss', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 3),
('회의', 'hoeui', 'Meeting', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 4),
('출근', 'chulgeun', 'Going to work', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 4),
('퇴근', 'toegeun', 'Leaving work', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 4),
('휴가', 'hyuga', 'Vacation/Leave', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 3),
('월급', 'wolgeup', 'Monthly salary', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 4),
('야근', 'yageun', 'Overtime work', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 4),
('승진', 'seungjin', 'Promotion', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 5),
('프로젝트', 'peurojekteu', 'Project', (SELECT id FROM word_categories WHERE name_en = 'WORK'), 4);

-- ============================================
-- 20. HOSPITAL (병원) - 10개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('병원', 'byeongwon', 'Hospital', (SELECT id FROM word_categories WHERE name_en = 'HOSPITAL'), 3),
('의사', 'uisa', 'Doctor', (SELECT id FROM word_categories WHERE name_en = 'HOSPITAL'), 3),
('간호사', 'ganhosa', 'Nurse', (SELECT id FROM word_categories WHERE name_en = 'HOSPITAL'), 4),
('환자', 'hwanja', 'Patient', (SELECT id FROM word_categories WHERE name_en = 'HOSPITAL'), 3),
('아프다', 'apeuda', 'To be sick/hurt', (SELECT id FROM word_categories WHERE name_en = 'HOSPITAL'), 3),
('약', 'yak', 'Medicine', (SELECT id FROM word_categories WHERE name_en = 'HOSPITAL'), 2),
('주사', 'jusa', 'Injection', (SELECT id FROM word_categories WHERE name_en = 'HOSPITAL'), 3),
('감기', 'gamgi', 'Cold (illness)', (SELECT id FROM word_categories WHERE name_en = 'HOSPITAL'), 3),
('열', 'yeol', 'Fever', (SELECT id FROM word_categories WHERE name_en = 'HOSPITAL'), 2),
('진료', 'jillyo', 'Medical treatment', (SELECT id FROM word_categories WHERE name_en = 'HOSPITAL'), 4);

-- ============================================
-- 21. BANK (은행) - 10개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('은행', 'eunhaeng', 'Bank', (SELECT id FROM word_categories WHERE name_en = 'BANK'), 3),
('돈', 'don', 'Money', (SELECT id FROM word_categories WHERE name_en = 'BANK'), 1),
('계좌', 'gyejwa', 'Account', (SELECT id FROM word_categories WHERE name_en = 'BANK'), 4),
('입금', 'ipgeum', 'Deposit', (SELECT id FROM word_categories WHERE name_en = 'BANK'), 4),
('출금', 'chulgeum', 'Withdrawal', (SELECT id FROM word_categories WHERE name_en = 'BANK'), 4),
('송금', 'songgeum', 'Transfer', (SELECT id FROM word_categories WHERE name_en = 'BANK'), 4),
('대출', 'daechul', 'Loan', (SELECT id FROM word_categories WHERE name_en = 'BANK'), 4),
('이자', 'ija', 'Interest', (SELECT id FROM word_categories WHERE name_en = 'BANK'), 3),
('통장', 'tongjang', 'Bankbook', (SELECT id FROM word_categories WHERE name_en = 'BANK'), 3),
('신용카드', 'sinyongkadeu', 'Credit card', (SELECT id FROM word_categories WHERE name_en = 'BANK'), 5);

-- ============================================
-- 22. RESTAURANT (식당) - 10개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('식당', 'sikdang', 'Restaurant', (SELECT id FROM word_categories WHERE name_en = 'RESTAURANT'), 3),
('메뉴', 'menyu', 'Menu', (SELECT id FROM word_categories WHERE name_en = 'RESTAURANT'), 3),
('주문', 'jumun', 'Order', (SELECT id FROM word_categories WHERE name_en = 'RESTAURANT'), 3),
('맛있다', 'masitta', 'Delicious', (SELECT id FROM word_categories WHERE name_en = 'RESTAURANT'), 3),
('맵다', 'maepda', 'Spicy', (SELECT id FROM word_categories WHERE name_en = 'RESTAURANT'), 3),
('짜다', 'jjada', 'Salty', (SELECT id FROM word_categories WHERE name_en = 'RESTAURANT'), 2),
('달다', 'dalda', 'Sweet', (SELECT id FROM word_categories WHERE name_en = 'RESTAURANT'), 2),
('포장', 'pojang', 'Takeout/Packaging', (SELECT id FROM word_categories WHERE name_en = 'RESTAURANT'), 3),
('예약', 'yeyak', 'Reservation', (SELECT id FROM word_categories WHERE name_en = 'RESTAURANT'), 3),
('계산서', 'gyesanseo', 'Bill/Check', (SELECT id FROM word_categories WHERE name_en = 'RESTAURANT'), 4);

-- ============================================
-- 23. SPORTS (스포츠) - 12개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('축구', 'chukgu', 'Soccer', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 3),
('야구', 'yagu', 'Baseball', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 3),
('농구', 'nonggu', 'Basketball', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 3),
('수영', 'suyeong', 'Swimming', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 3),
('운동', 'undong', 'Exercise', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 3),
('달리기', 'dalligi', 'Running', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 3),
('태권도', 'taekwondo', 'Taekwondo', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 4),
('배구', 'baegu', 'Volleyball', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 3),
('테니스', 'teniseu', 'Tennis', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 3),
('경기', 'gyeonggi', 'Game/Match', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 4),
('선수', 'seonsu', 'Player/Athlete', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 4),
('이기다', 'igida', 'To win', (SELECT id FROM word_categories WHERE name_en = 'SPORTS'), 3);

-- ============================================
-- 24. HOBBIES (취미) - 10개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('취미', 'chwimi', 'Hobby', (SELECT id FROM word_categories WHERE name_en = 'HOBBIES'), 3),
('음악', 'eumak', 'Music', (SELECT id FROM word_categories WHERE name_en = 'HOBBIES'), 3),
('영화', 'yeonghwa', 'Movie', (SELECT id FROM word_categories WHERE name_en = 'HOBBIES'), 3),
('게임', 'geim', 'Game', (SELECT id FROM word_categories WHERE name_en = 'HOBBIES'), 3),
('독서', 'dokso', 'Reading', (SELECT id FROM word_categories WHERE name_en = 'HOBBIES'), 4),
('그림', 'geurim', 'Picture/Drawing', (SELECT id FROM word_categories WHERE name_en = 'HOBBIES'), 2),
('노래', 'norae', 'Song', (SELECT id FROM word_categories WHERE name_en = 'HOBBIES'), 2),
('춤', 'chum', 'Dance', (SELECT id FROM word_categories WHERE name_en = 'HOBBIES'), 1),
('사진', 'sajin', 'Photo', (SELECT id FROM word_categories WHERE name_en = 'HOBBIES'), 3),
('요리', 'yori', 'Cooking', (SELECT id FROM word_categories WHERE name_en = 'HOBBIES'), 2);

-- ============================================
-- 25. CULTURE (문화) - 10개
-- ============================================
INSERT INTO words (korean, pronunciation, english, category_id, base_difficulty) VALUES
('문화', 'munhwa', 'Culture', (SELECT id FROM word_categories WHERE name_en = 'CULTURE'), 4),
('예술', 'yesul', 'Art', (SELECT id FROM word_categories WHERE name_en = 'CULTURE'), 4),
('전통', 'jeontong', 'Tradition', (SELECT id FROM word_categories WHERE name_en = 'CULTURE'), 5),
('공연', 'gongyeon', 'Performance', (SELECT id FROM word_categories WHERE name_en = 'CULTURE'), 5),
('박물관', 'bangmulgwan', 'Museum', (SELECT id FROM word_categories WHERE name_en = 'CULTURE'), 5),
('미술관', 'misulgwan', 'Art gallery', (SELECT id FROM word_categories WHERE name_en = 'CULTURE'), 5),
('축제', 'chukje', 'Festival', (SELECT id FROM word_categories WHERE name_en = 'CULTURE'), 4),
('명절', 'myeongjeol', 'Holiday', (SELECT id FROM word_categories WHERE name_en = 'CULTURE'), 5),
('한복', 'hanbok', 'Hanbok (Korean dress)', (SELECT id FROM word_categories WHERE name_en = 'CULTURE'), 4),
('김치', 'gimchi', 'Kimchi', (SELECT id FROM word_categories WHERE name_en = 'CULTURE'), 1);


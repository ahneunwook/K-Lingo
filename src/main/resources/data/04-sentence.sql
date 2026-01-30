INSERT INTO sentence (chapter_id, english, korean, hint, difficulty_level, created_at, updated_at)
VALUES
    (1, 'I eat an apple.', '저는 사과{를:Obj} 먹어요.', 'Object particle (을/를)', 1, NOW(), NOW()),
    (1, 'The weather is good.', '날씨{가:Subj} 좋아요.', 'Subject particle (이/가)', 1, NOW(), NOW()),
    (1, 'I am a student.', '저{는:Topic} 학생입니다.', 'Topic particle (은/는)', 1, NOW(), NOW()),
    (1, 'I go to school.', '학교{에:Loc} 가요.', 'Location particle (to)', 1, NOW(), NOW()),
    (1, 'I study at the library.', '도서관{에서:Loc} 공부해요.', 'Location particle (at)', 2, NOW(), NOW())
ON CONFLICT (chapter_id, korean) DO NOTHING; -- 중복되면 무시

INSERT INTO sentence (chapter_id, english, korean, hint, difficulty_level, created_at, updated_at)
VALUES
    (2, 'I eat rice.', '밥을 {먹어요:Present}.', 'Present tense (polite)', 1, NOW(), NOW()),
    (2, 'I ate rice.', '밥을 {먹었어요:Past}.', 'Past tense', 2, NOW(), NOW()),
    (2, 'I will eat rice.', '밥을 {먹을 거예요:Future}.', 'Future tense', 2, NOW(), NOW()),
    (2, 'Because it is delicious...', '{맛있어서:Cause}...', 'Because ~', 3, NOW(), NOW()),
    (2, 'I want to go.', '{가고:Connect} 싶어요.', 'want to ~', 2, NOW(), NOW())
ON CONFLICT (chapter_id, korean) DO NOTHING;

INSERT INTO sentence (chapter_id, english, korean, hint, difficulty_level, created_at, updated_at)
VALUES
    (3, 'Did you sleep? (Honorific)', '{주무셨어요:Hon}?', 'Honorific form of "sleep"', 4, NOW(), NOW()),
    (3, 'Please eat this. (Honorific)', '이거 {드세요:Hon}.', 'Honorific form of "eat"', 3, NOW(), NOW()),
    (3, 'Thank you. (Casual)', '{고마워:Cas}.', 'Casual thanks', 1, NOW(), NOW()),
    (3, 'Are you okay? (Polite)', '{괜찮아요:Pol}?', 'Polite ending (Yo)', 2, NOW(), NOW()),
    (3, 'Hello. (Formal)', '{안녕하십니까:Formal}.', 'Formal greeting', 5, NOW(), NOW())
ON CONFLICT (chapter_id, korean) DO NOTHING;

INSERT INTO sentence (chapter_id, english, korean, hint, difficulty_level, created_at, updated_at)
VALUES
    (4, 'I gave a gift to my friend.', '저는 친구에게 선물을 주었어요.', 'S + I.O + D.O + V', 2, NOW(), NOW()),
    (4, 'Mom is watching TV at home.', '엄마는 집에서 TV를 보고 계세요.', 'Subject + Location + Object + Verb', 3, NOW(), NOW()),
    (4, 'The Korean language is very interesting.', '한국어는 정말 재미있어요.', 'Subject + Adverb + Adjective', 2, NOW(), NOW()),
    (4, 'What did you do yesterday?', '어제 무엇을 했어요?', 'Time + Object + Verb', 2, NOW(), NOW()),
    (4, 'I want to go to Korea next year.', '내년에 한국에 가고 싶어요.', 'Time + Location + Verb', 3, NOW(), NOW())
ON CONFLICT (chapter_id, korean) DO NOTHING;
ㄴㅁㅁㄹㄹㄹㅇ
INSERT INTO sentence (chapter_id, english, korean, hint, difficulty_level, created_at, updated_at)
VALUES
    (5, 'Where is the restroom?', '화장실이 {어디:Where}예요?', 'Question word for Place', 1, NOW(), NOW()),
    (5, 'Who are you?', '{누구:Who}세요?', 'Question word for Person', 1, NOW(), NOW()),
    (5, 'What is this?', '이게 {뭐:What}예요?', 'Question word for Thing', 1, NOW(), NOW()),
    (5, 'When is your birthday?', '생일이 {언제:When}예요?', 'Question word for Time', 2, NOW(), NOW()),
    (5, 'Why are you crying?', '{왜:Why} 울어요?', 'Question word for Reason', 2, NOW(), NOW()),
    (5, 'How do I go to Seoul?', '서울에 {어떻게:How} 가요?', 'Question word for Method', 3, NOW(), NOW())
ON CONFLICT (chapter_id, korean) DO NOTHING;ㄹaFA'Fㄴㅇㄴㄴㄴㅁ
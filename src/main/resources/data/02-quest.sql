-- 1. STAGE_CLEAR (Stage Completion) - By Difficulty
INSERT INTO quest (title, description, quest_type, period, target_count, reward_xp, active, created_at, updated_at)
VALUES ('Light Warm-up', 'Complete any stage once.', 'STAGE_CLEAR', 'DAILY', 1, 10, true, NOW(), NOW());

INSERT INTO quest (title, description, quest_type, period, target_count, reward_xp, active, created_at, updated_at)
VALUES ('Joy of Learning', 'Complete 3 stages to improve your skills.', 'STAGE_CLEAR', 'DAILY', 3, 30, true, NOW(), NOW());

INSERT INTO quest (title, description, quest_type, period, target_count, reward_xp, active, created_at, updated_at)
VALUES ('Burning Passion', 'Challenge: Complete 5 stages today!', 'STAGE_CLEAR', 'DAILY', 5, 50, true, NOW(), NOW());

-- 2. QUIZ_CORRECT (Correct Answers) - By Difficulty
INSERT INTO quest (title, description, quest_type, period, target_count, reward_xp, active, created_at, updated_at)
VALUES ('Quiz Starter', 'Answer 5 quiz questions correctly.', 'QUIZ_CORRECT', 'DAILY', 5, 10, true, NOW(), NOW());

INSERT INTO quest (title, description, quest_type, period, target_count, reward_xp, active, created_at, updated_at)
VALUES ('Concentration Test', 'Get 10 correct answers.', 'QUIZ_CORRECT', 'DAILY', 10, 20, true, NOW(), NOW());

INSERT INTO quest (title, description, quest_type, period, target_count, reward_xp, active, created_at, updated_at)
VALUES ('Sharp Shooter', 'Get 30 correct answers.', 'QUIZ_CORRECT', 'DAILY', 30, 60, true, NOW(), NOW());

-- 3. LOGIN (Login)
INSERT INTO quest (title, description, quest_type, period, target_count, reward_xp, active, created_at, updated_at)
VALUES ('Daily Check-in', 'Great to see you studying Korean today!', 'LOGIN', 'DAILY', 1, 5, true, NOW(), NOW());
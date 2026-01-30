package com.kdopamine.app.domain.word.entity;

public enum QuizType {
    CHOICE,    // 4지 선다 (객관식)
    WRITING,   // 스펠링 쓰기 (주관식)
    LISTENING, // 듣고 고르기
    SCRAMBLE,    // 단어 순서 맞추기
    BLANK,    // 받아쓰기/빈칸 채우기
    SPEAKING   // 말하기
}

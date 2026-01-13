package com.kdopamine.app.domain.quest.entity;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum QuestType {
    LOGIN("로그인 하기"),
    STAGE_CLEAR("스테이지 완료"),
    QUIZ_CORRECT("퀴즈 정답 맞추기");

    private final String description;
}

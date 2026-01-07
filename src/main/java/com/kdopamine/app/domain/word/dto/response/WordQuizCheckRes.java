package com.kdopamine.app.domain.word.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class WordQuizCheckRes {
    private boolean isCorrect;
    private String correctAnswer;
}

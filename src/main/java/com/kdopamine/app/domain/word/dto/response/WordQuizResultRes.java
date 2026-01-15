package com.kdopamine.app.domain.word.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class WordQuizResultRes {
    private int totalCount;
    private int correctCount;
    private int incorrectCount;
    private int score;
    private boolean isPassed;

    public static WordQuizResultRes of(int totalCount, int correctCount, int score, boolean isPassed) {
        return WordQuizResultRes.builder()
                .totalCount(totalCount)
                .correctCount(correctCount)
                .incorrectCount(totalCount - correctCount)
                .score(score)
                .isPassed(isPassed)
                .build();
    }

}

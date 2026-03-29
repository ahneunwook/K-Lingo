package com.kdopamine.app.domain.word.dto.request;

import com.kdopamine.app.domain.word.entity.QuizType;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class WordQuizCheckReq {
    private Long wordId;
    private String userAnswer;
    private Long studyTime;
    private QuizType quizType;
}

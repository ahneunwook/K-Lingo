package com.kdopamine.app.domain.word.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class WordQuizCheckReq {
    private Long wordId;
    private String userAnswer;
}

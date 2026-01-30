package com.kdopamine.app.domain.sentence.dto.response;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.kdopamine.app.domain.sentence.entity.Sentence;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SentenceSubmitRes {
    @JsonProperty("isCorrect")
    private boolean isCorrect;
    private String userAnswer;
    private String correctAnswer;
    private String voiceFileUrl;

    public static SentenceSubmitRes of(boolean isCorrect, String userAnswer, Sentence sentence){

        String cleanAnswer = sentence.getKorean().replaceAll("\\{([^:}]+):([^}]+)\\}", "$1");

        return SentenceSubmitRes.builder()
                .isCorrect(isCorrect)
                .userAnswer(userAnswer)
                .correctAnswer(cleanAnswer)
                .voiceFileUrl(sentence.getVoiceFileUrl())
                .build();
    }
}

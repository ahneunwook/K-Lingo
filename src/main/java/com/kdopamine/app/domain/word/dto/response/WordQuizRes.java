package com.kdopamine.app.domain.word.dto.response;

import com.kdopamine.app.domain.word.entity.QuizType;
import com.kdopamine.app.domain.word.entity.Word;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WordQuizRes {
    private Long wordId;
    private String content;     // 영어 단어 (Apple)
    private String meaning;     // 한글 뜻 (사과)
    private String pronunciation;
    private String audioUrl;    // 발음 URL
    private QuizType quizType;  // 이번 문제의 유형
    private List<String> options; // 객관식일 경우 보여줄 보기들 (정답 포함)

    public static WordQuizRes of(Word word, QuizType quizType, List<String> options) {
        return WordQuizRes.builder()
                .wordId(word.getId())
                .content(word.getEnglish())
                .meaning(word.getKorean())
                .pronunciation(word.getPronunciation())
                .audioUrl(word.getAudioUrl())
                .quizType(quizType)
                .options(options)
                .build();
    }
}

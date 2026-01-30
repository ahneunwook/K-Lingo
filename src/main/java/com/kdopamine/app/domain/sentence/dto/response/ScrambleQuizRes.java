package com.kdopamine.app.domain.sentence.dto.response;

import com.kdopamine.app.domain.sentence.entity.Sentence;
import lombok.Getter;
import lombok.experimental.SuperBuilder;

import java.util.List;

@Getter
@SuperBuilder
public class ScrambleQuizRes extends SentenceQuizRes {
    private List<String> shuffledWords;

    public static ScrambleQuizRes of(Sentence sentence, String originalSentence, List<String> shuffledWords) {
        return ScrambleQuizRes.builder()
                .sentenceId(sentence.getId())
                .question(sentence.getEnglish())
                .hint(sentence.getHint())
                .originalSentence(originalSentence) // 태그 제거된 깔끔한 원본
                .shuffledWords(shuffledWords)       // 섞인 단어 리스트
                .build();
    }
}

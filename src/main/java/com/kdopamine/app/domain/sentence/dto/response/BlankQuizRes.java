package com.kdopamine.app.domain.sentence.dto.response;

import com.kdopamine.app.domain.sentence.entity.Sentence;
import lombok.Getter;
import lombok.experimental.SuperBuilder;

@Getter
@SuperBuilder
public class BlankQuizRes extends SentenceQuizRes {
    private String blankSentence;
    private String blankAnswer;

    public static BlankQuizRes of(Sentence sentence, String originalSentence, String blankSentence, String blankAnswer) {
        return BlankQuizRes.builder()
                .sentenceId(sentence.getId())
                .question(sentence.getEnglish())
                .hint(sentence.getHint())
                .originalSentence(originalSentence) // 태그 제거된 깔끔한 원본
                .blankSentence(blankSentence)       // 빈칸이 뚫린 문장
                .blankAnswer(blankAnswer)           // 정답 단어
                .youtubeId(sentence.getYoutubeId())
                .startTime(sentence.getStartTime())
                .endTime(sentence.getEndTime())
                .build();
    }
}

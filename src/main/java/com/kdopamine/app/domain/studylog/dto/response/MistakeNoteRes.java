package com.kdopamine.app.domain.studylog.dto.response;

import com.kdopamine.app.domain.studylog.entity.MistakeNote;
import com.kdopamine.app.domain.word.entity.QuizType;
import com.kdopamine.app.global.entity.SectionType;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MistakeNoteRes {

    private Long id;
    private SectionType sectionType;   // TOPIC, KDRAMA, KPOP, SENTENCE
    private QuizType quizType;          // CHOICE, BLANK, SCRAMBLE...
    private String question;            // 문제 (단어: 한글, 문장: 한글 문장)
    private String userAnswer;          // 내가 쓴 답
    private String correctAnswer;       // 정답
    private String voiceFileUrl;        // 음성 파일 URL (문장용)

    public static MistakeNoteRes of(MistakeNote mistakeNote) {
        String voiceUrl = null;

        // 문장인 경우 음성 파일 URL 가져오기
        if (mistakeNote.getSentence() != null) {
            voiceUrl = mistakeNote.getSentence().getVoiceFileUrl();
        }

        return MistakeNoteRes.builder()
                .id(mistakeNote.getId())
                .sectionType(mistakeNote.getSectionType())
                .quizType(mistakeNote.getQuizType())
                .question(mistakeNote.getQuestion())
                .userAnswer(mistakeNote.getUserAnswer())
                .correctAnswer(mistakeNote.getCorrectAnswer())
                .voiceFileUrl(voiceUrl)
                .build();
    }
}


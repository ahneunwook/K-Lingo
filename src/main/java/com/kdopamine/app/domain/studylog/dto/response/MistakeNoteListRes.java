package com.kdopamine.app.domain.studylog.dto.response;

import com.kdopamine.app.domain.studylog.entity.MistakeNote;
import lombok.Builder;
import lombok.Getter;

import java.util.List;
import java.util.stream.Collectors;

@Getter
@Builder
public class MistakeNoteListRes {

    private List<MistakeNoteRes> words;      // 단어 오답 (WORD)
    private List<MistakeNoteRes> sentences;  // 문장 오답 (SENTENCE)

    public static MistakeNoteListRes of(List<MistakeNote> mistakeNotes) {
        // 단어 오답: word가 null이 아닌 것들
        List<MistakeNoteRes> wordMistakes = mistakeNotes.stream()
                .filter(m -> m.getWord() != null)
                .map(MistakeNoteRes::of)
                .collect(Collectors.toList());

        // 문장 오답: sentence가 null이 아닌 것들
        List<MistakeNoteRes> sentenceMistakes = mistakeNotes.stream()
                .filter(m -> m.getSentence() != null)
                .map(MistakeNoteRes::of)
                .collect(Collectors.toList());

        return MistakeNoteListRes.builder()
                .words(wordMistakes)
                .sentences(sentenceMistakes)
                .build();
    }
}


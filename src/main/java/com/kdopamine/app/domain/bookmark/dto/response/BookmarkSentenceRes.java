package com.kdopamine.app.domain.bookmark.dto.response;

import com.kdopamine.app.domain.bookmark.entity.Bookmark;
import com.kdopamine.app.domain.sentence.entity.Sentence;
import com.kdopamine.app.global.entity.SectionType;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class BookmarkSentenceRes {

    private Long bookmarkId;
    private Long sentenceId;
    private String english;         // 영어 문장 (Why don't you take a rain check on that?)
    private String korean;          // 한국어 번역 (그건 다음 기회로 미루는 게 어때?)
    private String hint;            // 힌트
    private String voiceFileUrl;    // 음성 파일
    private SectionType sectionType; // 카테고리 (KDRAMA, KPOP, SENTENCE 등)

    public static BookmarkSentenceRes of(Bookmark bookmark) {
        Sentence sentence = bookmark.getSentence();
        return BookmarkSentenceRes.builder()
                .bookmarkId(bookmark.getId())
                .sentenceId(sentence.getId())
                .english(sentence.getEnglish())
                .korean(cleanKorean(sentence.getKorean()))
                .hint(sentence.getHint())
                .voiceFileUrl(sentence.getVoiceFileUrl())
                .sectionType(sentence.getChapter().getType())
                .build();
    }

    // {word:tag} 형식 제거
    private static String cleanKorean(String raw) {
        if (raw == null) return null;
        return raw.replaceAll("\\{([^:}]+):([^}]+)\\}", "$1");
    }
}


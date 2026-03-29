package com.kdopamine.app.domain.bookmark.dto.response;

import com.kdopamine.app.domain.bookmark.entity.Bookmark;
import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.global.entity.SectionType;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class BookmarkWordRes {

    private Long bookmarkId;
    private Long wordId;
    private String korean;          // 한국어 (사과)
    private String english;         // 영어 (Apple)
    private String pronunciation;   // 발음
    private String audioUrl;        // 음성 파일
    private SectionType sectionType; // 카테고리 (TOPIC 등)

    public static BookmarkWordRes of(Bookmark bookmark) {
        Word word = bookmark.getWord();
        return BookmarkWordRes.builder()
                .bookmarkId(bookmark.getId())
                .wordId(word.getId())
                .korean(word.getKorean())
                .english(word.getEnglish())
                .pronunciation(word.getPronunciation())
                .audioUrl(word.getAudioUrl())
                .sectionType(word.getStage().getChapter().getType())
                .build();
    }
}


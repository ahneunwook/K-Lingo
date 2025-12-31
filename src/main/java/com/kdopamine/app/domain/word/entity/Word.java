package com.kdopamine.app.domain.word.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "words",
    uniqueConstraints = {
        @UniqueConstraint(name = "word_korean_category",
                         columnNames = {"korean", "category_id"})
    })
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class Word extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String korean;

    @Column(length = 100)
    private String pronunciation;

    @Column(nullable = false, length = 200)
    private String english;

    @Column(name = "audio_url")
    private String audioUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private WordCategory category;

    @Column(name = "base_difficulty", nullable = false)
    private Integer baseDifficulty;

    /**
     * 기본 단어 생성
     */
    public static Word createWord(String korean, String english, WordCategory category, Integer baseDifficulty) {
        return Word.builder()
            .korean(korean)
            .english(english)
            .category(category)
            .baseDifficulty(baseDifficulty)
            .build();
    }

    /**
     * 발음 포함 단어 생성
     */
    public static Word createWordWithPronunciation(
        String korean,
        String pronunciation,
        String english,
        WordCategory category,
        Integer baseDifficulty
    ) {
        return Word.builder()
            .korean(korean)
            .pronunciation(pronunciation)
            .english(english)
            .category(category)
            .baseDifficulty(baseDifficulty)
            .build();
    }

    /**
     * 오디오 URL 추가
     */
    public void addAudioUrl(String audioUrl) {
        this.audioUrl = audioUrl;
    }
}

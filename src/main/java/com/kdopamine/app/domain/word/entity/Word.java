package com.kdopamine.app.domain.word.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "word",
    uniqueConstraints = {
            @UniqueConstraint(
                    name = "uk_word_stage_korean",
                    columnNames = {"stage_id", "korean"}
            )
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
    @JoinColumn(name = "stage_id", nullable = false)
    private Stage stage;

    /**
     * 기본 단어 생성
     */
    public static Word createWord(Stage stage, String korean, String english) {
        return Word.builder()
            .stage(stage)
            .korean(korean)
            .english(english)
            .build();
    }

    /**
     * 발음 포함 단어 생성
     */
    public static Word createWordWithPronunciation(
        Stage stage,
        String korean,
        String pronunciation,
        String english
    ) {
        return Word.builder()
            .stage(stage)
            .korean(korean)
            .pronunciation(pronunciation)
            .english(english)
            .build();
    }

    /**
     * 오디오 URL 추가
     */
    public void addAudioUrl(String audioUrl) {
        this.audioUrl = audioUrl;
    }
}

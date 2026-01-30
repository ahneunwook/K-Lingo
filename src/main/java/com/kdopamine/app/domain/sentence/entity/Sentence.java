package com.kdopamine.app.domain.sentence.entity;

import com.kdopamine.app.domain.word.entity.Chapter;
import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Table(name = "sentence",
        uniqueConstraints = {
        @UniqueConstraint(
                name = "uk_sentence_chapter_korean",
                columnNames = {"chapter_id", "korean"}
        )
})
public class Sentence extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 문제로 보여질 문장 (예: "Where is the restroom?")
    @Column(nullable = false)
    private String english;

    // 정답/학습할 문장 (예: "화장실이 어디예요?")
    @Column(nullable = false)
    private String korean;

    // 결정적인 힌트 (예: "Place + Where")
    private String hint;

    // 랜덤 뽑기할 때 쌩뚱맞은 난이도 방지용 (1~5)
    @Column(nullable = false)
    private Integer difficultyLevel;

    private String voiceFileUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chapter_id", nullable = false)
    private Chapter chapter;

    @Column(name = "youtube_id")
    private String youtubeId;   // 영상 ID (예: dQw4w9WgXcQ)

    @Column(name = "start_time")
    private Integer startTime;  // 시작(초)

    @Column(name = "end_time")
    private Integer endTime;

    @Builder
    public Sentence(String english, String korean, String hint, Integer difficultyLevel, String voiceFileUrl, Chapter chapter, String youtubeId, Integer startTime, Integer endTime) {
        this.english = english;
        this.korean = korean;
        this.hint = hint;
        this.difficultyLevel = difficultyLevel;
        this.voiceFileUrl = voiceFileUrl;
        this.chapter = chapter;
        this.youtubeId = youtubeId;
        this.startTime = startTime;
        this.endTime = endTime;
    }
}
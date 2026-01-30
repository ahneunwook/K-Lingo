package com.kdopamine.app.domain.studylog.entity;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.word.entity.Chapter;
import com.kdopamine.app.domain.word.entity.Stage;
import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "member_sentence_progress",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_member_chapter_progress",
                        columnNames = {"member_id", "chapter_id"} // 유저당 챕터별 기록은 딱 1줄만 존재
                )
        })
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class MemberSentenceProgress extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chapter_id", nullable = false)
    private Chapter chapter;

    // 누적 정답 수 (이게 곧 경험치 XP)
    @Column(name = "total_solved_count", nullable = false)
    private Integer totalSolvedCount;

    // 현재 레벨 (보여주기용)
    @Column(name = "current_level", nullable = false)
    private Integer currentLevel;

    // 통계용: 틀린 횟수 (정답률 계산용: solved / (solved + wrong))
    @Column(name = "wrong_count", nullable = false)
    private Integer wrongCount;

    // 최근 학습 시간
    @Column(name = "last_studied_at")
    private LocalDateTime lastStudiedAt;

    @Builder
    private MemberSentenceProgress(Member member, Chapter chapter, Integer totalSolvedCount, Integer currentLevel, Integer wrongCount, LocalDateTime lastStudiedAt) {
        this.member = member;
        this.chapter = chapter;
        this.totalSolvedCount = totalSolvedCount;
        this.currentLevel = currentLevel;
        this.wrongCount = wrongCount;
        this.lastStudiedAt = lastStudiedAt;
    }

    public static MemberSentenceProgress create(Member member, Chapter chapter) {
        return MemberSentenceProgress.builder()
                .member(member)
                .chapter(chapter)
                .totalSolvedCount(0)        // 처음엔 0개
                .currentLevel(1)            // 레벨은 1부터 시작
                .wrongCount(0)
                .lastStudiedAt(LocalDateTime.now()) // 생성하자마자 공부 시작한 것으로 간주
                .build();
    }


    // 정답 맞췄을 때 (경험치 획득 & 레벨업 체크)
    public void addCorrectCount() {
        this.totalSolvedCount++;
        this.lastStudiedAt = LocalDateTime.now();

        int newLevel = (this.totalSolvedCount / 50) + 1;
        if (newLevel > this.currentLevel) {
            this.currentLevel = newLevel;
        }
    }

    // 틀렸을 때 (오답 카운트만 증가)
    public void addWrongCount() {
        this.wrongCount++;
        this.lastStudiedAt = LocalDateTime.now();
    }
}

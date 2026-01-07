package com.kdopamine.app.domain.studylog.entity;

import com.kdopamine.app.domain.member.entity.Member;
import com.kdopamine.app.domain.word.entity.WordStage;
import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "member_stage_progress")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class MemberStageProgress extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "word_stage_id", nullable = false)
    private WordStage wordStage;

    @Builder.Default
    @Column(name = "is_cleared", nullable = false)
    private Boolean isCleared = false;

    @Builder.Default
    @Column(name = "best_score", nullable = false)
    private Integer bestScore = 0;

    public static MemberStageProgress create(Member member, WordStage stage) {
        return MemberStageProgress.builder()
                .member(member)
                .wordStage(stage)
                .build();
    }
}

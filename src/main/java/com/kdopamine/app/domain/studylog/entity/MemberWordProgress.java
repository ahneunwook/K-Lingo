package com.kdopamine.app.domain.studylog.entity;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.word.entity.Stage;
import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "member_word_progress")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class MemberWordProgress extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stage_id", nullable = false)
    private Stage stage;

    @Builder.Default
    @Column(name = "is_cleared", nullable = false)
    private Boolean isCleared = false;

    @Builder.Default
    @Column(name = "best_score", nullable = false)
    private Integer bestScore = 0;

    public static MemberWordProgress create(Member member, Stage stage) {
        return MemberWordProgress.builder()
                .member(member)
                .stage(stage)
                .build();
    }

    public void updateProgress(Integer score, boolean passed) {
        if (score > this.bestScore) {
            this.bestScore = score;
        }

        if (passed) {
            this.isCleared = true;
        }
    }
}


//uniqueConstraints = {
//@UniqueConstraint(
//        name = "uk_member_stage",
//        columnNames = {"member_id", "stage_id"} // 유저당 스테이지 기록은 하나뿐
//)
//        })
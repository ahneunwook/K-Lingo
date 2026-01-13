package com.kdopamine.app.domain.quest.entity;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.global.entity.BaseEntity;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "member_quest",
        uniqueConstraints = {
                @UniqueConstraint(
                        columnNames = {"member_id", "quest_id", "quest_date"}
                )
        })
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class MemberQuest extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quest_id", nullable = false)
    private Quest quest;

    // 현재 진행도
    @Column(nullable = false)
    private Integer currentCount = 0;

    // 완료 여부
    @Column(nullable = false)
    private boolean isCompleted = false;

    // 보상 수령 여부
    @Column(nullable = false)
    private boolean rewardClaimed = false;

    // 퀘스트 날짜 (일일 구분)
    @Column(name = "quest_date", nullable = false)
    private LocalDate questDate;

    public static MemberQuest create(Member member, Quest quest, LocalDate questDate) {
        return MemberQuest.builder()
                .member(member)
                .quest(quest)
                .questDate(questDate)
                .currentCount(0)
                .isCompleted(false)
                .rewardClaimed(false)
                .build();
    }

    public void increaseProgress(int amount) {
        if (isCompleted) return;

        this.currentCount += amount;

        if (this.currentCount >= quest.getTargetCount()){
            this.currentCount = quest.getTargetCount();
            this.isCompleted = true;
        }
    }

    public void claimReward() {
        if (!isCompleted) {
            throw new BusinessException(ErrorCode.QUEST_IS_NOT_COMPLETE);
        }

        if (rewardClaimed){
            throw new BusinessException(ErrorCode.ALREADY_GET_REWARD);
        }

        this.rewardClaimed = true;
    }

    public boolean isOwnedBy(Long memberId){
        return this.getMember().getId().equals(memberId);
    }
}

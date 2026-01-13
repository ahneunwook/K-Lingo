package com.kdopamine.app.domain.quest.dto.response;

import com.kdopamine.app.domain.auth.entity.Member;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class QuestRewardResponse {
    private Integer rewardXp;           // 획득한 경험치
    private Integer currentXp;          // 현재 총 경험치
    private Integer currentLevel;       // 현재 레벨
    private Boolean isLevelUp;          // 레벨업 했는지
    private Integer previousLevel;      // 이전 레벨 (레벨업 시)

    public static QuestRewardResponse of(int rewardXp, Member member, boolean isLevelUp, int previousLevel) {
        return QuestRewardResponse.builder()
                .rewardXp(rewardXp)
                .currentXp(member.getCurrentXp())
                .currentLevel(member.getLevel())
                .isLevelUp(isLevelUp)
                .previousLevel(isLevelUp ? previousLevel : null)
                .build();
    }
}

package com.kdopamine.app.domain.quest.dto.response;

import com.kdopamine.app.domain.quest.entity.MemberQuest;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class QuestResponse {

    private Long id;

    private String title;
    private String description;
    private int rewardXp;

    private int currentCount;
    private int targetCount;
    private boolean isCompleted;
    private boolean rewardClaimed;

    public static QuestResponse from(MemberQuest memberQuest){
        return QuestResponse.builder()
                .id(memberQuest.getId())
                .title(memberQuest.getQuest().getTitle())
                .description(memberQuest.getQuest().getDescription())
                .rewardXp(memberQuest.getQuest().getRewardXp())
                .currentCount(memberQuest.getCurrentCount())
                .targetCount(memberQuest.getQuest().getTargetCount())
                .isCompleted(memberQuest.isCompleted())
                .rewardClaimed(memberQuest.isRewardClaimed())
                .build();
    }
}

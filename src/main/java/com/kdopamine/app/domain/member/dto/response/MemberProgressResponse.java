package com.kdopamine.app.domain.member.dto.response;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.dailytip.dto.response.DailyTipRes;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MemberProgressResponse {
    private String nickname;
    private Integer level;
    private Integer currentXp;
    private Integer requiredXp;
    private Integer remainingXp;
    private Integer xpPercentage;
    private Integer streakDays;
    private Integer totalAttendanceDays;
    private Integer totalCompletedQuests;

    private DailyTipRes dailyTipRes;

    public static MemberProgressResponse from(Member member, DailyTipRes dailyTips) {
        int requiredXp = member.getRequiredXpForNextLevel();
        int remainingXp = requiredXp - member.getCurrentXp();
        int percentage = (int) ((double) member.getCurrentXp() / requiredXp * 100);

        return MemberProgressResponse.builder()
                .nickname(member.getNickname())
                .level(member.getLevel())
                .currentXp(member.getCurrentXp())
                .requiredXp(requiredXp)
                .remainingXp(remainingXp)
                .xpPercentage(percentage)
                .streakDays(member.getStreakDays())
                .totalAttendanceDays(member.getTotalAttendanceDays())
                .totalCompletedQuests(member.getTotalCompletedQuests())
                .dailyTipRes(dailyTips)
                .build();
    }
}

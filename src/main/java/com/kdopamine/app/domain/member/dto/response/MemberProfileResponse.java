package com.kdopamine.app.domain.member.dto.response;

import com.kdopamine.app.domain.auth.entity.Member;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class MemberProfileResponse {

    // 기본 정보
    private String nickname;
    private String profileImageUrl;
    private String role; // "Passionate Learner" 같은 칭호용 (없으면 제외)

    // 통계 정보 (프로필 카드용)
    private String totalStudyTime;
    private int totalQuizCount;
    private String topikLevel;

    public static MemberProfileResponse from(Member member) {
        return MemberProfileResponse.builder()
                .nickname(member.getNickname())
                .profileImageUrl(member.getProfileImageUrl())
                .role("Passionate Learner")

                // DB에 값이 저장되어 있다고 가정 (없으면 0 처리)
                .totalStudyTime(convertSecondsToTime(member.getTotalStudyTime()))
                .totalQuizCount(member.getTotalQuizCount())
                .topikLevel(member.getTopikLevel() == null ? "Lv.1" : member.getTopikLevel())
                .build();
    }

    // 시간 변환 유틸 (초 -> 시간)
    private static String convertSecondsToTime(Long totalSeconds) {
        if (totalSeconds == null || totalSeconds == 0) return "0h 0m";
        long hours = totalSeconds / 3600;
        long minutes = (totalSeconds % 3600) / 60;
        return hours + "h " + minutes + "m";
    }
}

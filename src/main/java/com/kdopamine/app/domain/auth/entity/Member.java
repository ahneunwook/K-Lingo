package com.kdopamine.app.domain.auth.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.ZoneId;

@Entity
@Table(name = "members")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class Member extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100, unique = true)
    private String email;

    @Column(nullable = false, length = 100)
    private String nickname;

    @Column(nullable = false, length = 10)
    private String provider;

    @Column(nullable = false)
    private String providerId;

    @Enumerated(EnumType.STRING)
    private Role role;

    @Column(length = 500)
    private String profileImageUrl;

    @Builder.Default
    @Column(nullable = false)
    private Integer level = 1;

    @Builder.Default
    @Column(name = "current_xp", nullable = false)
    private Integer currentXp = 0;

    @Builder.Default
    @Column(nullable = false)
    private Integer streakDays = 0;

    @Builder.Default
    @Column(nullable = false)
    private Integer totalAttendanceDays = 0;

    private LocalDate lastAttendanceDate;

    @Builder.Default
    @Column(nullable = false)
    private Integer totalCompletedQuests = 0;

    /**
     * 총 학습 시간 (초 단위 저장)
     */
    @Builder.Default
    @Column(nullable = false, columnDefinition = "bigint default 0")
    private Long totalStudyTime = 0L;

    /**
     * 총 푼 퀴즈/문장 갯수 (단어 + 문장 통합)
     */
    @Builder.Default
    @Column(nullable = false)
    private Integer totalQuizCount = 0;

    /**
     * 목표/현재 TOPIK 레벨
     */
    @Builder.Default
    @Column(length = 20)
    private String topikLevel = "Lv.1";


    public static Member createSocialMember(String email, String nickname, String provider, String providerId) {
        return Member.builder()
                .email(email)
                .nickname(nickname)
                .provider(provider)
                .providerId(providerId)
                .role(Role.USER)
                .build();
    }

    public void gainXp(int amount) {
        this.currentXp += amount;

        while (this.currentXp >= getRequiredXpForNextLevel()) {
            this.currentXp -= getRequiredXpForNextLevel();
            this.level++;
        }
    }

    public int getRequiredXpForNextLevel() {
        return (int) (100 * Math.pow(1.2, this.level - 1));
    }

    public void increaseCompletedQuestCount() {
        this.totalCompletedQuests++;
    }

    public void checkAttendance(){
        LocalDate today = LocalDate.now();

        if (lastAttendanceDate != null && lastAttendanceDate.isEqual(today)){
            return;
        }

        if (lastAttendanceDate != null && lastAttendanceDate.isEqual(today.minusDays(1))){
            this.streakDays++;
        } else {
            this.streakDays = 1;
        }

        this.totalAttendanceDays++;
        this.lastAttendanceDate = today;
    }

    public void updateStudyTime(Long seconds) {
        this.totalStudyTime += seconds;
    }

    public void increaseQuizCount(int count) {
        this.totalQuizCount += count;
    }

    public void updateTopikLevel(String newLevel) {
        this.topikLevel = newLevel;
    }

    public void updateProfileImage(String imageUrl) {
        this.profileImageUrl = imageUrl;
    }
}

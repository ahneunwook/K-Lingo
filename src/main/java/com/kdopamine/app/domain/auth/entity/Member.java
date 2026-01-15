package com.kdopamine.app.domain.auth.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

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
}

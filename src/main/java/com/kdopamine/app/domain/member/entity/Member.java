package com.kdopamine.app.domain.member.entity;

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
    private String provider;   // GOOGLE, APPLE

    @Column(nullable = false)
    private String providerId; // 소셜 서비스에서 제공하는 고유 식별값 (PK 역할)

    @Enumerated(EnumType.STRING)
    private Role role; // USER, ADMIN

    @Column(nullable = false)
    private Integer level = 1;

    @Column(nullable = false)
    private Integer currentXp = 0;

    @Column(nullable = false)
    private Integer streakDays = 0;

    @Column(nullable = false)
    private Integer totalAttendanceDays = 0;

    private LocalDate lastAttendanceDate;

    // 소셜 로그인 신규 회원 생성용
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
}

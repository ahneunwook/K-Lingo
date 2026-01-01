package com.kdopamine.app.domain.member.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

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

}

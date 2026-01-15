package com.kdopamine.app.domain.dailytip.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "tips")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class Tip extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100, unique = true)
    private String title;

    @Column(nullable = false, length = 100)
    private String content;

    @Column(nullable = false, length = 10)
    private String tag;

    @Column(nullable = false)
    private String icon;

    @Enumerated(EnumType.STRING)
    private TipCategory tipCategory; // USER, ADMIN


}
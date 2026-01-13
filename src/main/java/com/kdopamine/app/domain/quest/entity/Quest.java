package com.kdopamine.app.domain.quest.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "quest")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class Quest extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private QuestType questType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private QuestPeriod period;

    @Column(nullable = false)
    private Integer targetCount;

    @Column(nullable = false)
    private Integer rewardXp;

    // 노출 여부 (이벤트 퀘스트 대비)
    @Column(nullable = false)
    private boolean active = true;

    public static Quest create(QuestType questType, QuestPeriod period, int targetCount, int rewardXp) {
        return Quest.builder()
                .questType(questType)
                .period(period)
                .targetCount(targetCount)
                .rewardXp(rewardXp)
                .active(true)
                .build();
    }
}

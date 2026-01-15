package com.kdopamine.app.domain.word.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "stages",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_stage_category_order",
                        columnNames = {"chapter_id", "stage_order"}
                )
        })
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class Stage extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chapter_id", nullable = false)
    private Chapter chapter;

    @Column(nullable = false)
    private Integer stageOrder;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private Integer passScore; // 7점 이상

    @Column(nullable = false)
    private Integer xpReward;

    public static Stage create(Chapter chapter, Integer stageOrder, String title, Integer passScore, Integer xpReward) {
        return Stage.builder()
                .chapter(chapter)
                .stageOrder(stageOrder)
                .title(title)
                .passScore(passScore)
                .xpReward(xpReward)
                .build();
    }
}

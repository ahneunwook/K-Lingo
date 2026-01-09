package com.kdopamine.app.domain.word.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "word_stage",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_stage_category_order",
                        columnNames = {"word_category_id", "stage_order"}
                )
        })
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class WordStage extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "word_category_id", nullable = false)
    private WordCategory wordCategory;

    @Column(nullable = false)
    private Integer stageOrder;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private Integer passScore; // 7점 이상

    public static WordStage createStage(WordCategory category, Integer order, String title, Integer passScore) {
        return WordStage.builder()
                .wordCategory(category)
                .stageOrder(order)
                .title(title)
                .passScore(passScore)
                .build();
    }
}

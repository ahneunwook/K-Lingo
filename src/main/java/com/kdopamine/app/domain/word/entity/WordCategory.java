package com.kdopamine.app.domain.word.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "word_category")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class WordCategory extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name_en", nullable = false, unique = true)
    private String nameEn;

    @Column(name = "name_kr", nullable = false, unique = true)
    private String nameKr;

    @Column(name = "icon", length = 200)
    private String icon;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    /**
     * 카테고리 생성
     */
    public static WordCategory createWordCategory(String nameEn, String nameKr, Integer displayOrder, String description) {
        return WordCategory.builder()
            .nameEn(nameEn)
            .nameKr(nameKr)
            .displayOrder(displayOrder)
            .description(description)
            .build();
    }
}

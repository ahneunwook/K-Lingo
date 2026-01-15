package com.kdopamine.app.domain.word.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import com.kdopamine.app.global.entity.SectionType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chapters")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class Chapter extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name_en", nullable = false, unique = true)
    private String nameEn;

    @Column(name = "name_kr", nullable = false, unique = true)
    private String nameKr;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SectionType type;

    @Column(name = "icon", length = 200)
    private String icon;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

}

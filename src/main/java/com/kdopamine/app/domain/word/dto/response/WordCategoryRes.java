package com.kdopamine.app.domain.word.dto.response;

import com.kdopamine.app.domain.word.entity.WordCategory;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WordCategoryRes {
    private Long id;
    private String nameKr;
    private String nameEn;
    private String description;
    private Integer displayOrder;
    private String icon;

    public static WordCategoryRes from(WordCategory wordCategory){
        return WordCategoryRes.builder()
                .id(wordCategory.getId())
                .nameKr(wordCategory.getNameKr())
                .nameEn(wordCategory.getNameEn())
                .description(wordCategory.getDescription())
                .displayOrder(wordCategory.getDisplayOrder())
                .icon(wordCategory.getIcon())
                .build();
    }
}

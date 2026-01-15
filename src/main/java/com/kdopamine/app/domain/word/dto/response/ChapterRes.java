package com.kdopamine.app.domain.word.dto.response;

import com.kdopamine.app.domain.word.entity.Chapter;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChapterRes {
    private Long id;
    private String nameKr;
    private String nameEn;
    private String description;
    private Integer displayOrder;
    private String icon;

    public static ChapterRes from(Chapter chapter){
        return ChapterRes.builder()
                .id(chapter.getId())
                .nameKr(chapter.getNameKr())
                .nameEn(chapter.getNameEn())
                .description(chapter.getDescription())
                .displayOrder(chapter.getDisplayOrder())
                .icon(chapter.getIcon())
                .build();
    }
}

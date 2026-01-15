package com.kdopamine.app.domain.member.dto.response;

import com.kdopamine.app.global.entity.SectionType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SectionProgressRes {
    private String title;
    private String description;
    private SectionType type;
    private int progress;

    public static SectionProgressRes of(String title, String description, SectionType type, int progress){
        return SectionProgressRes.builder()
                .title(title)
                .description(description)
                .type(type)
                .progress(progress)
                .build();
    }

}

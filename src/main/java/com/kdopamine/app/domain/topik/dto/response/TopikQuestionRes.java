package com.kdopamine.app.domain.topik.dto.response;

import com.kdopamine.app.domain.topik.entity.TopikQuestion;
import lombok.Builder;
import lombok.Getter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Builder
public class TopikQuestionRes {

    private Long id;
    private String level;
    private String section;
    private String question;
    private String passage;
    private String audioUrl;
    private String imageUrl;
    private List<String> options;

    public static TopikQuestionRes from(TopikQuestion q) {
        List<String> options = new ArrayList<>();
        if (q.getOption1() != null) options.add(q.getOption1());
        if (q.getOption2() != null) options.add(q.getOption2());
        if (q.getOption3() != null) options.add(q.getOption3());
        if (q.getOption4() != null) options.add(q.getOption4());

        return TopikQuestionRes.builder()
                .id(q.getId())
                .level(q.getLevel().name())
                .section(q.getSection().name())
                .question(q.getQuestion())
                .passage(q.getPassage())
                .audioUrl(q.getAudioUrl())
                .imageUrl(q.getImageUrl())
                .options(options)
                .build();
    }
}
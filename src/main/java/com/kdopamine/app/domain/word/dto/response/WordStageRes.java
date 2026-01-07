package com.kdopamine.app.domain.word.dto.response;

import com.kdopamine.app.domain.studylog.entity.MemberStageProgress;
import com.kdopamine.app.domain.word.entity.WordStage;
import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Builder
public class WordStageRes {
    private Long id;
    private Integer stageOrder;
    private String title;
    private Integer bestScore;
    private Boolean isCleared;

    @Setter
    private Boolean isLocked;


    public static WordStageRes from(WordStage wordStage, MemberStageProgress progress, Boolean isLocked){
        return WordStageRes.builder()
                .id(wordStage.getId())
                .stageOrder(wordStage.getStageOrder())
                .title(wordStage.getTitle())
                .bestScore(progress != null ? progress.getBestScore() : 0)
                .isCleared(progress != null && progress.getIsCleared())
                .isLocked(isLocked)
                .build();
    }
}

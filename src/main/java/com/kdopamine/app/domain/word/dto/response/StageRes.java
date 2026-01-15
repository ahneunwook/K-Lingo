package com.kdopamine.app.domain.word.dto.response;

import com.kdopamine.app.domain.studylog.entity.MemberStageProgress;
import lombok.*;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Builder
public class StageRes {
    private Long id;
    private Integer stageOrder;
    private String title;
    private Integer xpReward;
    private Integer bestScore;
    private Boolean isCleared;

    @Setter
    private Boolean isLocked;


    public static StageRes from(StageRes stage, MemberStageProgress progress, Boolean isLocked){
        return StageRes.builder()
                .id(stage.getId())
                .stageOrder(stage.getStageOrder())
                .title(stage.getTitle())
                .bestScore(progress != null ? progress.getBestScore() : 0)
                .isCleared(progress != null && progress.getIsCleared())
                .isLocked(isLocked)
                .build();
    }
}

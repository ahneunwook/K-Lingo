package com.kdopamine.app.domain.sentence.dto.request;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class SentenceSubmitReq {

    @NotNull(message = "챕터 ID는 필수입니다.")
    private Long chapterId;

    @NotNull(message = "문장 ID는 필수입니다.")
    private Long sentenceId;

    @NotBlank(message = "답안을 입력해주세요.")
    private String userAnswer;

    private Long studyTime;
}

package com.kdopamine.app.domain.sentence.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import lombok.Getter;
import lombok.experimental.SuperBuilder;

@Getter
@SuperBuilder
@JsonTypeInfo(
        use = JsonTypeInfo.Id.NAME,
        include = JsonTypeInfo.As.PROPERTY,
        property = "type" // JSON에 "type": "BLANK" 형태로 자동 포함됨
)
@JsonSubTypes({
        @JsonSubTypes.Type(value = BlankQuizRes.class, name = "BLANK"),
        @JsonSubTypes.Type(value = ScrambleQuizRes.class, name = "SCRAMBLE")
})
@JsonInclude(JsonInclude.Include.NON_NULL)
public abstract class SentenceQuizRes {
    private Long sentenceId;
    private String question;   // 문제(한국어 뜻)
    private String hint;
    private String originalSentence; // 정답 확인용 원본

    private String youtubeId;
    private Integer startTime;
    private Integer endTime;
}

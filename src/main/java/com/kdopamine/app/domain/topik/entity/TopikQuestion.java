package com.kdopamine.app.domain.topik.entity;

import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "topik_questions")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@Getter
public class TopikQuestion extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TopikLevel level; // 1~6급

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TopikSection section; // READING, LISTENING, WRITING

    // 문제 지문 (제목이나 질문 내용)
    @Column(nullable = false, length = 1000)
    private String question;

    // 긴 지문 (독해 지문 등) - 없을 수도 있으니 nullable 허용 추천
    @Column(columnDefinition = "TEXT")
    private String passage;

    // 이미지나 도표가 들어가는 문제를 위해 (S3 URL 등 저장)
    @Column(length = 2083)
    private String imageUrl;

    // 듣기 평가를 위한 오디오 파일 (S3 URL 등 저장)
    @Column(length = 2083)
    private String audioUrl;

    @Column(nullable = true)
    private String option1;

    @Column(nullable = true)
    private String option2;

    @Column(nullable = true)
    private String option3;

    @Column(nullable = true)
    private String option4;

    @Column(nullable = true)
    private Integer correctAnswer; // 정답 (쓰기는 정답 번호가 없을 수 있음)

    @Column(columnDefinition = "TEXT")
    private String explanation; // 해설

    @Builder
    public TopikQuestion(TopikLevel level, TopikSection section, String question, String passage,
                         String imageUrl, String audioUrl,
                         String option1, String option2, String option3, String option4,
                         Integer correctAnswer, String explanation) {
        this.level = level;
        this.section = section;
        this.question = question;
        this.passage = passage;
        this.imageUrl = imageUrl;
        this.audioUrl = audioUrl;
        this.option1 = option1;
        this.option2 = option2;
        this.option3 = option3;
        this.option4 = option4;
        this.correctAnswer = correctAnswer;
        this.explanation = explanation;
    }

    public void updateQuestion(String question, String passage) {
        this.question = question;
        this.passage = passage;
    }
}


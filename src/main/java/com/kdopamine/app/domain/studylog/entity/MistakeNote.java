package com.kdopamine.app.domain.studylog.entity;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.sentence.entity.Sentence;
import com.kdopamine.app.domain.word.entity.QuizType;
import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.global.entity.BaseEntity;
import com.kdopamine.app.global.entity.SectionType;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "mistake_note")
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class MistakeNote extends BaseEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    // 1. 데이터의 출처 (뱃지용: K-Pop, Drama, Word...)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SectionType sectionType;

    // 2. 문제 유형 (레이아웃용: 객관식, 빈칸, 스크램블...)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private QuizType quizType;

    // 3. 실제 데이터 연결 (둘 중 하나는 null)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "word_id", nullable = true)
    private Word word;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sentence_id", nullable = true)
    private Sentence sentence;

    // 문제 원문 및 답안
    private String question;
    private String userAnswer;
    private String correctAnswer;

    @Builder
    public MistakeNote(Member member, SectionType sectionType, QuizType quizType,
                       Word word, Sentence sentence,
                       String question, String userAnswer, String correctAnswer) {
        this.member = member;
        this.sectionType = sectionType;
        this.quizType = quizType;
        this.word = word;
        this.sentence = sentence;
        this.question = question;
        this.userAnswer = userAnswer;
        this.correctAnswer = correctAnswer;
    }

    // 1. 단어 오답 생성 메서드
    public static MistakeNote createForWord(Member member, Word word, SectionType sectionType, QuizType quizType, String userAnswer) {
        return MistakeNote.builder()
                .member(member)
                .sectionType(sectionType) // 예: TOPIC (단어장)
                .quizType(quizType)       // 예: CHOICE (객관식), WRITING (쓰기)
                .word(word)
                .sentence(null)
                .question(word.getEnglish())
                .userAnswer(userAnswer)
                .correctAnswer(word.getKorean())
                .build();
    }

    public static MistakeNote createForSentence(Member member, Sentence sentence, SectionType sectionType, QuizType quizType, String question, String userAnswer, String correctAnswer) {
        return MistakeNote.builder()
                .member(member)
                .sectionType(sectionType) // 예: KDRAMA, KPOP, SENTENCE
                .quizType(quizType)       // 예: BLANK (빈칸), SCRAMBLE (어순)
                .word(null)
                .sentence(sentence)
                .question(question)
                .userAnswer(userAnswer)
                .correctAnswer(correctAnswer)
                .build();
    }
}


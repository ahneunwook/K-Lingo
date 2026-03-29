package com.kdopamine.app.domain.bookmark.entity;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.sentence.entity.Sentence;
import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "bookmark",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_member_word", columnNames = {"member_id", "word_id"}),
                @UniqueConstraint(name = "uk_member_sentence", columnNames = {"member_id", "sentence_id"})
        })
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
@Builder(access = AccessLevel.PRIVATE)
@Getter
public class Bookmark extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    // 단어 북마크 (둘 중 하나만 사용)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "word_id")
    private Word word;

    // 문장 북마크 (둘 중 하나만 사용)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sentence_id")
    private Sentence sentence;

    // 단어 북마크 생성
    public static Bookmark createForWord(Member member, Word word) {
        return Bookmark.builder()
                .member(member)
                .word(word)
                .sentence(null)
                .build();
    }

    // 문장 북마크 생성
    public static Bookmark createForSentence(Member member, Sentence sentence) {
        return Bookmark.builder()
                .member(member)
                .word(null)
                .sentence(sentence)
                .build();
    }
}


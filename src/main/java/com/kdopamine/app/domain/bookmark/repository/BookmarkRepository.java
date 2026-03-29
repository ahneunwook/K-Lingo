package com.kdopamine.app.domain.bookmark.repository;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.bookmark.entity.Bookmark;
import com.kdopamine.app.domain.sentence.entity.Sentence;
import com.kdopamine.app.domain.word.entity.Word;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface BookmarkRepository extends JpaRepository<Bookmark, Long> {

    // 단어 북마크 중복 체크
    boolean existsByMemberAndWord(Member member, Word word);

    // 문장 북마크 중복 체크
    boolean existsByMemberAndSentence(Member member, Sentence sentence);

    // 단어 북마크 찾기 (삭제용)
    Optional<Bookmark> findByMemberAndWord(Member member, Word word);

    // 문장 북마크 찾기 (삭제용)
    Optional<Bookmark> findByMemberAndSentence(Member member, Sentence sentence);

    // 단어 북마크 목록 조회
    @Query("SELECT b FROM Bookmark b JOIN FETCH b.word w JOIN FETCH w.stage s WHERE b.member.id = :memberId AND b.word IS NOT NULL")
    List<Bookmark> findAllWordBookmarksByMemberId(@Param("memberId") Long memberId);

    // 문장 북마크 목록 조회
    @Query("SELECT b FROM Bookmark b JOIN FETCH b.sentence s JOIN FETCH s.chapter c WHERE b.member.id = :memberId AND b.sentence IS NOT NULL")
    List<Bookmark> findAllSentenceBookmarksByMemberId(@Param("memberId") Long memberId);
}


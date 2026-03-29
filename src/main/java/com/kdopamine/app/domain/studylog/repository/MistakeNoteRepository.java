package com.kdopamine.app.domain.studylog.repository;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.sentence.entity.Sentence;
import com.kdopamine.app.domain.studylog.entity.MistakeNote;
import com.kdopamine.app.domain.word.entity.Word;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MistakeNoteRepository extends JpaRepository<MistakeNote, Long> {
    // 문장 오답 중복 체크용
    boolean existsByMemberAndSentence(Member member, Sentence sentence);

    // 단어 오답 중복 체크용
    boolean existsByMemberAndWord(Member member, Word word);

    // 오답 노트 목록 조회할 때
    List<MistakeNote> findAllByMemberId(Long memberId);
}

package com.kdopamine.app.domain.studylog.service;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.auth.repository.MemberRepository;
import com.kdopamine.app.domain.studylog.entity.MemberSentenceProgress;
import com.kdopamine.app.domain.studylog.repository.MemberSentenceProgressRepository;
import com.kdopamine.app.domain.word.entity.Chapter;
import com.kdopamine.app.domain.word.repository.ChapterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class MemberSentenceProgressService {

    private final MemberSentenceProgressRepository progressRepository;
    private final MemberRepository memberRepository;
    private final ChapterRepository chapterRepository;

    public void increaseProgress(Long memberId, Long chapterId) {
        MemberSentenceProgress progress = progressRepository.findByMemberIdAndChapterId(memberId, chapterId)
                .orElseGet(() -> {
                    Member member = memberRepository.getReferenceById(memberId);
                    Chapter chapter = chapterRepository.getReferenceById(chapterId);
                    return progressRepository.save(MemberSentenceProgress.create(member, chapter));
                });

        progress.addCorrectCount();
    }
}

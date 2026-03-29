package com.kdopamine.app.domain.studylog.service;

import com.kdopamine.app.domain.studylog.dto.response.MistakeNoteListRes;
import com.kdopamine.app.domain.studylog.entity.MistakeNote;
import com.kdopamine.app.domain.studylog.repository.MistakeNoteRepository;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MistakeNoteService {

    private final MistakeNoteRepository mistakeNoteRepository;

    /**
     * 오답노트 전체 조회 (단어 + 문장)
     */
    public MistakeNoteListRes getMistakeNotes(Long memberId) {
        List<MistakeNote> mistakeNotes = mistakeNoteRepository.findAllByMemberId(memberId);
        return MistakeNoteListRes.of(mistakeNotes);
    }

    /**
     * 오답노트 삭제 (복습 완료 시)
     */
    @Transactional
    public void deleteMistakeNote(Long memberId, Long mistakeNoteId) {
        MistakeNote mistakeNote = mistakeNoteRepository.findById(mistakeNoteId)
                .orElseThrow(() -> new BusinessException(ErrorCode.MISTAKE_NOTE_NOT_FOUND));

        // 본인 오답노트인지 확인
        if (!mistakeNote.getMember().getId().equals(memberId)) {
            throw new BusinessException(ErrorCode.MISTAKE_NOTE_FORBIDDEN);
        }

        mistakeNoteRepository.delete(mistakeNote);
    }
}


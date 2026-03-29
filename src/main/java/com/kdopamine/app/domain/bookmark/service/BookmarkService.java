package com.kdopamine.app.domain.bookmark.service;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.auth.service.MemberReader;
import com.kdopamine.app.domain.bookmark.dto.response.BookmarkSentenceRes;
import com.kdopamine.app.domain.bookmark.dto.response.BookmarkWordRes;
import com.kdopamine.app.domain.bookmark.entity.Bookmark;
import com.kdopamine.app.domain.bookmark.repository.BookmarkRepository;
import com.kdopamine.app.domain.sentence.entity.Sentence;
import com.kdopamine.app.domain.sentence.repository.SentenceRepository;
import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.repository.WordRepository;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BookmarkService {

    private final BookmarkRepository bookmarkRepository;
    private final WordRepository wordRepository;
    private final SentenceRepository sentenceRepository;
    private final MemberReader memberReader;

    /**
     * 단어 북마크 목록만 조회
     */
    public List<BookmarkWordRes> getWordBookmarks(Long memberId) {
        return bookmarkRepository.findAllWordBookmarksByMemberId(memberId).stream()
                .map(BookmarkWordRes::of)
                .collect(Collectors.toList());
    }

    /**
     * 문장 북마크 목록만 조회
     */
    public List<BookmarkSentenceRes> getSentenceBookmarks(Long memberId) {
        return bookmarkRepository.findAllSentenceBookmarksByMemberId(memberId).stream()
                .map(BookmarkSentenceRes::of)
                .collect(Collectors.toList());
    }

    /**
     * 단어 북마크 추가
     */
    @Transactional
    public void addWordBookmark(Long memberId, Long wordId) {
        Member member = memberReader.getMember(memberId);
        Word word = wordRepository.findById(wordId)
                .orElseThrow(() -> new BusinessException(ErrorCode.WORD_NOT_FOUND));

        // 이미 북마크 되어있으면 무시
        if (bookmarkRepository.existsByMemberAndWord(member, word)) {
            return;
        }

        Bookmark bookmark = Bookmark.createForWord(member, word);
        bookmarkRepository.save(bookmark);
    }

    /**
     * 문장 북마크 추가
     */
    @Transactional
    public void addSentenceBookmark(Long memberId, Long sentenceId) {
        Member member = memberReader.getMember(memberId);
        Sentence sentence = sentenceRepository.findById(sentenceId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SENTENCE_NOT_FOUND));

        // 이미 북마크 되어있으면 무시
        if (bookmarkRepository.existsByMemberAndSentence(member, sentence)) {
            return;
        }

        Bookmark bookmark = Bookmark.createForSentence(member, sentence);
        bookmarkRepository.save(bookmark);
    }

    /**
     * 단어 북마크 삭제
     */
    @Transactional
    public void removeWordBookmark(Long memberId, Long wordId) {
        Member member = memberReader.getMember(memberId);
        Word word = wordRepository.findById(wordId)
                .orElseThrow(() -> new BusinessException(ErrorCode.WORD_NOT_FOUND));

        bookmarkRepository.findByMemberAndWord(member, word)
                .ifPresent(bookmarkRepository::delete);
    }

    /**
     * 문장 북마크 삭제
     */
    @Transactional
    public void removeSentenceBookmark(Long memberId, Long sentenceId) {
        Member member = memberReader.getMember(memberId);
        Sentence sentence = sentenceRepository.findById(sentenceId)
                .orElseThrow(() -> new BusinessException(ErrorCode.SENTENCE_NOT_FOUND));

        bookmarkRepository.findByMemberAndSentence(member, sentence)
                .ifPresent(bookmarkRepository::delete);
    }
}


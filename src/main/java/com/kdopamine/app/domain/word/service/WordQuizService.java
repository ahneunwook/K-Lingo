package com.kdopamine.app.domain.word.service;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.auth.service.MemberReader;
import com.kdopamine.app.domain.quest.entity.QuestType;
import com.kdopamine.app.domain.quest.service.QuestService;
import com.kdopamine.app.domain.studylog.entity.MistakeNote;
import com.kdopamine.app.domain.studylog.repository.MistakeNoteRepository;
import com.kdopamine.app.domain.studylog.service.MemberStageProgressService;
import com.kdopamine.app.domain.word.dto.request.WordQuizCheckReq;
import com.kdopamine.app.domain.word.dto.response.WordQuizRes;
import com.kdopamine.app.domain.word.dto.response.WordQuizResultRes;
import com.kdopamine.app.domain.word.entity.QuizType;
import com.kdopamine.app.domain.word.entity.Stage;
import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.repository.WordRepository;
import com.kdopamine.app.domain.word.repository.StageRepository;
import com.kdopamine.app.global.entity.SectionType;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WordQuizService {

    private final WordRepository wordRepository;
    private final StageRepository stageRepository;
    private final MemberStageProgressService memberStageProgressService;
    private final QuestService questService;
    private final MemberReader memberReader;
    private final Random random = new Random();

    // 오답 노트 저장소
    private final MistakeNoteRepository mistakeNoteRepository;

    // --- [조회 로직] 퀴즈 출제 ---
    @Transactional(readOnly = true)
    public List<WordQuizRes> getWordQuiz(Long stageId) {
        List<Word> words = wordRepository.findAllByStageId(stageId);
        Collections.shuffle(words);

        int limit = Math.min(words.size(), 10);
        List<Word> targetWords = words.subList(0, limit);

        List<WordQuizRes> responseList = new ArrayList<>();

        for (Word word : targetWords) {
            QuizType type = decideQuizType(word);
            List<String> options = null;
            if (isMultipleChoice(type)) {
                options = createOptions(word, words);
            }
            responseList.add(WordQuizRes.of(word, type, options));
        }

        return responseList;
    }

    private QuizType decideQuizType(Word word) {
        boolean hasAudio = word.getAudioUrl() != null && !word.getAudioUrl().isBlank();
        if (hasAudio) {
            int pick = random.nextInt(3);
            if (pick == 0) return QuizType.CHOICE;
            if (pick == 1) return QuizType.WRITING;
            return QuizType.LISTENING;
        } else {
            return random.nextBoolean() ? QuizType.CHOICE : QuizType.WRITING;
        }
    }

    private boolean isMultipleChoice(QuizType type) {
        return type == QuizType.CHOICE || type == QuizType.LISTENING;
    }

    private List<String> createOptions(Word correctWord, List<Word> allStageWords) {
        List<String> wrongCandidates = allStageWords.stream()
                .filter(w -> !w.getId().equals(correctWord.getId()))
                .filter(w -> !w.getKorean().equals(correctWord.getKorean()))
                .map(Word::getKorean)
                .collect(Collectors.toList());

        Collections.shuffle(wrongCandidates);
        int distractorCount = Math.min(wrongCandidates.size(), 3);
        List<String> options = new ArrayList<>(wrongCandidates.subList(0, distractorCount));
        options.add(correctWord.getKorean());
        Collections.shuffle(options);
        return options;
    }

    // --- [핵심 로직] 퀴즈 제출 및 채점 ---
    @Transactional
    public WordQuizResultRes submitQuiz(Long memberId, Long stageId, List<WordQuizCheckReq> answers) {
        Member member = memberReader.getMember(memberId);

        if (answers != null && !answers.isEmpty() && answers.get(0).getStudyTime() != null) {
            member.updateStudyTime(answers.get(0).getStudyTime());
        }

        Stage stage = stageRepository.findById(stageId)
                .orElseThrow(() -> new BusinessException(ErrorCode.STAGE_NOT_FOUND));

        List<Long> wordIds = answers.stream()
                .map(WordQuizCheckReq::getWordId)
                .collect(Collectors.toList());

        List<Word> words = wordRepository.findAllById(wordIds);

        // ID로 Word 객체를 바로 찾을 수 있게 Map 변환
        Map<Long, Word> wordMap = words.stream()
                .collect(Collectors.toMap(Word::getId, Function.identity()));

        int totalCount = answers.size();
        int correctCount = 0;

        for (WordQuizCheckReq req : answers) {
            Word word = wordMap.get(req.getWordId());
            if (word == null) {
                throw new BusinessException(ErrorCode.WORD_NOT_FOUND);
            }

            String realAnswer = word.getKorean();

            // 정답 체크
            if (isCorrect(realAnswer, req.getUserAnswer())) {
                correctCount++;
            } else {
                // 중복 방지: 이미 오답 노트에 있는 단어면 저장 건너뜀
                if (mistakeNoteRepository.existsByMemberAndWord(member, word)) {
                    continue;
                }

                // 퀴즈 타입 가져오기 (없으면 기본값 WRITING)
                QuizType type = req.getQuizType() != null ? req.getQuizType() : QuizType.WRITING;

                // 오답 노트 저장
                mistakeNoteRepository.save(
                        MistakeNote.createForWord(
                                member,
                                word,
                                SectionType.TOPIC,  // 단어장은 TOPIC
                                type,
                                req.getUserAnswer()
                        )
                );
            }
        }

        if (correctCount > 0) {
            member.increaseQuizCount(correctCount);
            member.gainXp(correctCount * 10);
            questService.handleAction(memberId, QuestType.QUIZ_CORRECT, correctCount);
        }

        int score = correctCount;
        boolean isPassed = score >= stage.getPassScore();

        memberStageProgressService.saveOrUpdateProgress(memberId, stage, score, isPassed);

        return WordQuizResultRes.of(totalCount, correctCount, score, isPassed);
    }

    private boolean isCorrect(String real, String user) {
        if (user == null) return false;
        return real.replace(" ", "").trim().equals(user.replace(" ", "").trim());
    }
}
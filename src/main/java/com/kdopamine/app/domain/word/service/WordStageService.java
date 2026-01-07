package com.kdopamine.app.domain.word.service;

import com.kdopamine.app.domain.word.dto.response.WordQuizRes;
import com.kdopamine.app.domain.word.dto.response.WordStageRes;
import com.kdopamine.app.domain.word.entity.QuizType;
import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.repository.WordCategoryRepository;
import com.kdopamine.app.domain.word.repository.WordRepository;
import com.kdopamine.app.domain.word.repository.WordStageRepositoryCustom;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import com.kdopamine.app.global.security.CustomUserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WordStageService {

    private final WordStageRepositoryCustom wordStageRepositoryCustom;
    private final WordCategoryRepository wordCategoryRepository;
    private final WordRepository wordRepository;
    private final Random random = new Random();

    @Transactional(readOnly = true)
    public List<WordStageRes> getStages(Long categoryId, CustomUserPrincipal user) {
        if (!wordCategoryRepository.existsById(categoryId)) {
            throw new BusinessException(ErrorCode.CATEGORY_NOT_FOUND);
        }

        List<WordStageRes> wordStageRes = wordStageRepositoryCustom.findStagesWithProgress(categoryId, user.getId());

        // 첫 스테이지는 항상 잠금 해제 정책
        boolean isPreviousCleared = true;

        for (WordStageRes stage : wordStageRes) {
            if (!isPreviousCleared) {
                stage.setIsLocked(true);
            }

            if (Boolean.TRUE.equals(stage.getIsCleared())) {
                isPreviousCleared = true;
            } else {
                isPreviousCleared = false;
            }
        }
        return wordStageRes;
    }

    @Transactional(readOnly = true)
    public List<WordQuizRes> getWordQuiz(Long stageId) {
        List<Word> words = wordRepository.findByWordStageId(stageId);

        Collections.shuffle(words);

        int limit = Math.min(words.size(), 10);
        List<Word> targetWords = words.subList(0, limit);

        List<WordQuizRes> responseList = new ArrayList<>();

        for (Word word : targetWords) {
            // 문제를 어떤 유형으로 낼지
            QuizType type = decideQuizType(word);

            // 객관식이라면 보기가 필요 (로직 호출)
            List<String> options = null;
            if (isMultipleChoice(type)) {
                // 전체 단어 리스트(words)를 넘겨서 오답을 뽑아오게 시킴
                options = createOptions(word, words);
            }

            responseList.add(WordQuizRes.of(word, type, options));
        }

        return responseList;
    }

    // 퀴즈 타입 결정 로직
    private QuizType decideQuizType(Word word) {
        boolean hasAudio = word.getAudioUrl() != null && !word.getAudioUrl().isBlank();

        if (hasAudio) {
            // 오디오 있음: 객관식, 쓰기, 리스닝 중 랜덤
            int pick = random.nextInt(3);
            if (pick == 0) return QuizType.CHOICE;
            if (pick == 1) return QuizType.WRITING;
            return QuizType.LISTENING;
        } else {
            // 오디오 없음: 객관식, 쓰기 중 랜덤
            return random.nextBoolean() ? QuizType.CHOICE : QuizType.WRITING;
        }
    }

    // 객관식인지 확인하는 헬퍼 메서드
    private boolean isMultipleChoice(QuizType type) {
        return type == QuizType.CHOICE || type == QuizType.LISTENING;
    }

    // 보기(정답 1개 + 오답 3개) 생성 로직
    private List<String> createOptions(Word correctWord, List<Word> allStageWords) {
        // 정답을 제외한 나머지 단어들의 뜻(English)을 모음
        List<String> wrongCandidates = allStageWords.stream()
                .filter(w -> !w.getId().equals(correctWord.getId())) // 정답 단어 빼고
                .filter(w -> !w.getEnglish().equals(correctWord.getEnglish()))
                .map(Word::getEnglish) // 뜻(Meaning)만 추출 (예: Hello, Thanks...)
                .collect(Collectors.toList());

        // 오답 후보들도 섞음
        Collections.shuffle(wrongCandidates);

        // 오답 3개를 앞에서부터 가져옴 (후보가 부족하면 있는 만큼만)
        int distractorCount = Math.min(wrongCandidates.size(), 3);
        List<String> options = new ArrayList<>(wrongCandidates.subList(0, distractorCount));

        // 정답(English)도 보기에 추가
        options.add(correctWord.getEnglish());

        // 마지막으로 보기 순서(1~4번)를 섞음
        Collections.shuffle(options);

        return options;
    }
}

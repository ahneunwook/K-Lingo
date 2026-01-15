package com.kdopamine.app.domain.word.service;

import com.kdopamine.app.domain.quest.entity.QuestType;
import com.kdopamine.app.domain.quest.service.QuestService;
import com.kdopamine.app.domain.studylog.service.MemberStageProgressService;
import com.kdopamine.app.domain.word.dto.request.WordQuizCheckReq;
import com.kdopamine.app.domain.word.dto.response.WordQuizRes;
import com.kdopamine.app.domain.word.dto.response.WordQuizResultRes;
import com.kdopamine.app.domain.word.entity.QuizType;
import com.kdopamine.app.domain.word.entity.Stage;
import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.repository.WordRepository;
import com.kdopamine.app.domain.word.repository.StageRepository;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WordQuizService {

    private final WordRepository wordRepository;
    private final StageRepository stageRepository;
    private final MemberStageProgressService memberStageProgressService;
    private final QuestService questService;
    private final Random random = new Random();

    @Transactional(readOnly = true)
    public List<WordQuizRes> getWordQuiz(Long stageId) {
        List<Word> words = wordRepository.findAllByStageId(stageId);

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
                .filter(w -> !w.getId().equals(correctWord.getId())) // 자기 자신 제외
                .filter(w -> !w.getKorean().equals(correctWord.getKorean())) // 혹시나 같은 한국어 뜻이 있다면 제외
                .map(Word::getKorean)
                .collect(Collectors.toList());

        // 오답 후보들도 섞음
        Collections.shuffle(wrongCandidates);

        // 오답 3개를 앞에서부터 가져옴 (후보가 부족하면 있는 만큼만)
        int distractorCount = Math.min(wrongCandidates.size(), 3);
        List<String> options = new ArrayList<>(wrongCandidates.subList(0, distractorCount));

        // 정답(English)도 보기에 추가
        options.add(correctWord.getKorean());

        // 마지막으로 보기 순서(1~4번)를 섞음
        Collections.shuffle(options);

        return options;
    }

    @Transactional
    public WordQuizResultRes submitQuiz(Long memberId, Long stageId, List<WordQuizCheckReq> answers) {
        Stage stage = stageRepository.findById(stageId)
                .orElseThrow(() -> new BusinessException(ErrorCode.STAGE_NOT_FOUND));

        List<Long> wordIds = answers.stream().map(WordQuizCheckReq::getWordId).collect(Collectors.toList());

        // DB에서 단어들을 한방에 가져옵니다
        List<Word> words = wordRepository.findAllById(wordIds);

        // 채점하기 편하게 [WordId : 정답(String)] 형태의 Map으로 바꿉니다.
        // 이렇게 하면 나중에 찾을 때 반복문 없이 map.get(id)로 바로 찾을 수 있습니다.
        Map<Long, String> answerMap = words.stream()
                .collect(Collectors.toMap(Word::getId, Word::getKorean));

        // 채점 시작
        int totalCount = answers.size();
        int correctCount = 0;

        for (WordQuizCheckReq req : answers) {
            // Map에서 정답 꺼내오기 (DB 조회 아님, 메모리 조회라 엄청 빠름)
            String realAnswer = answerMap.get(req.getWordId());

            // 혹시 DB에 없는 단어 ID가 요청으로 왔을 경우 예외처리
            if (realAnswer == null) {
                throw new BusinessException(ErrorCode.WORD_NOT_FOUND);
            }

            // 정답 비교
            if (isCorrect(realAnswer, req.getUserAnswer())) {
                correctCount++;
            }
        }

        if (correctCount > 0) {
            questService.handleAction(memberId, QuestType.QUIZ_CORRECT, correctCount);
        }

        int score = correctCount;
        boolean isPassed = score >= stage.getPassScore();

        memberStageProgressService.saveOrUpdateProgress(memberId, stage, score, isPassed);

        // 결과 반환
        return WordQuizResultRes.of(totalCount, correctCount, score, isPassed);
    }

    private boolean isCorrect(String real, String user) {
        if (user == null) return false;
        return real.replace(" ", "").trim().equals(user.replace(" ", "").trim());
    }
}

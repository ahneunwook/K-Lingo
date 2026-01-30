package com.kdopamine.app.domain.word.service;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.auth.service.MemberReader;
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
    private final MemberReader memberReader;
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
        // 멤버 조회
        Member member = memberReader.getMember(memberId);

        if (answers != null && !answers.isEmpty() && answers.get(0).getStudyTime() != null) {
            member.updateStudyTime(answers.get(0).getStudyTime());
        }

        Stage stage = stageRepository.findById(stageId)
                .orElseThrow(() -> new BusinessException(ErrorCode.STAGE_NOT_FOUND));

        // 단어 ID 추출
        List<Long> wordIds = answers.stream()
                .map(WordQuizCheckReq::getWordId)
                .collect(Collectors.toList());

        // 단어 조회
        List<Word> words = wordRepository.findAllById(wordIds);
        Map<Long, String> answerMap = words.stream()
                .collect(Collectors.toMap(Word::getId, Word::getKorean));

        int totalCount = answers.size();
        int correctCount = 0;

        // 채점 루프
        for (WordQuizCheckReq req : answers) {
            String realAnswer = answerMap.get(req.getWordId());

            if (realAnswer == null) {
                throw new BusinessException(ErrorCode.WORD_NOT_FOUND);
            }

            if (isCorrect(realAnswer, req.getUserAnswer())) {
                correctCount++;
            }
        }

        // [추가된 부분] 맞춘 개수만큼 퀴즈 카운트 & 경험치 증가
        if (correctCount > 0) {
            member.increaseQuizCount(correctCount); // 맞춘 개수만큼 올림
            member.gainXp(correctCount * 10);       // 경험치도 개수 * 10

            questService.handleAction(memberId, QuestType.QUIZ_CORRECT, correctCount);
        }

        int score = correctCount;
        boolean isPassed = score >= stage.getPassScore();

        memberStageProgressService.saveOrUpdateProgress(memberId, stage, score, isPassed);

        return WordQuizResultRes.of(totalCount, correctCount, score, isPassed);
    }

    // 정답 체크 (기존 유지)
    private boolean isCorrect(String real, String user) {
        if (user == null) return false;
        return real.replace(" ", "").trim().equals(user.replace(" ", "").trim());
    }
}

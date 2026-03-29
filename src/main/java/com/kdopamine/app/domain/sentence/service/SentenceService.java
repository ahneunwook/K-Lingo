package com.kdopamine.app.domain.sentence.service;

import com.kdopamine.app.domain.auth.entity.Member;
import com.kdopamine.app.domain.auth.service.MemberReader;
import com.kdopamine.app.domain.sentence.dto.request.SentenceSubmitReq;
import com.kdopamine.app.domain.sentence.dto.response.BlankQuizRes;
import com.kdopamine.app.domain.sentence.dto.response.ScrambleQuizRes;
import com.kdopamine.app.domain.sentence.dto.response.SentenceQuizRes;
import com.kdopamine.app.domain.sentence.dto.response.SentenceSubmitRes;
import com.kdopamine.app.domain.sentence.entity.Sentence;
import com.kdopamine.app.domain.sentence.repository.SentenceRepository;
import com.kdopamine.app.domain.studylog.entity.MistakeNote;
import com.kdopamine.app.domain.studylog.repository.MistakeNoteRepository;
import com.kdopamine.app.domain.studylog.service.MemberSentenceProgressService;
import com.kdopamine.app.domain.word.entity.QuizType;
import com.kdopamine.app.domain.word.service.ChapterService;
import com.kdopamine.app.global.entity.SectionType;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SentenceService {

    private final SentenceRepository sentenceRepository;
    private final ChapterService chapterService;
    private final MemberReader memberReader;
    private final MemberSentenceProgressService progressService;

    private final MistakeNoteRepository mistakeNoteRepository;

    private static final Pattern TAG_PATTERN = Pattern.compile("\\{([^:}]+):([^}]+)\\}");

    // --- [조회 로직] 전체 랜덤 가져오기 ---
    @Transactional(readOnly = true)
    public List<SentenceQuizRes> getRandomQuizzes(Long memberId, int count) {
        List<Sentence> sentences = sentenceRepository.findRandomSentences(count);
        return convertToQuizList(sentences);
    }

    // --- [조회 로직] 특정 챕터 랜덤 가져오기 ---
    @Transactional(readOnly = true)
    public List<SentenceQuizRes> getChapterQuizzes(Long memberId, Long chapterId, int count) {
        chapterService.findChapterId(chapterId);
        List<Sentence> sentences = sentenceRepository.findByChapterRandom(chapterId, count);
        return convertToQuizList(sentences);
    }

    private List<SentenceQuizRes> convertToQuizList(List<Sentence> sentences) {
        return sentences.stream()
                .map(this::generateQuiz)
                .collect(Collectors.toList());
    }

    // --- 퀴즈 생성기 (빈칸 vs 스크램블 분기) ---
    private SentenceQuizRes generateQuiz(Sentence sentence) {
        boolean hasTag = sentence.getKorean().contains("{");

        // 태그가 있으면 50% 확률로 빈칸 문제, 아니면 스크램블 문제
        if (hasTag && Math.random() > 0.5) {
            return createBlankQuiz(sentence);
        } else {
            return createScrambleQuiz(sentence);
        }
    }

    // 1. 빈칸 채우기 생성
    private SentenceQuizRes createBlankQuiz(Sentence sentence) {
        String rawKorean = sentence.getKorean();
        Matcher matcher = TAG_PATTERN.matcher(rawKorean);

        List<MatchResult> matches = new ArrayList<>();
        while (matcher.find()) {
            matches.add(matcher.toMatchResult());
        }

        if (matches.isEmpty()) return null; // 태그 없으면 null or fallback

        MatchResult targetMatch = matches.get((int) (Math.random() * matches.size()));
        String answerWord = targetMatch.group(1);

        StringBuilder sb = new StringBuilder();
        int lastEnd = 0;
        Matcher replaceMatcher = TAG_PATTERN.matcher(rawKorean);

        while (replaceMatcher.find()) {
            sb.append(rawKorean, lastEnd, replaceMatcher.start());
            if (replaceMatcher.start() == targetMatch.start()) {
                sb.append("_______");
            } else {
                sb.append(replaceMatcher.group(1));
            }
            lastEnd = replaceMatcher.end();
        }
        sb.append(rawKorean.substring(lastEnd));

        String blankSentence = sb.toString();
        String cleanOriginal = cleanSentence(rawKorean);

        return BlankQuizRes.of(sentence, cleanOriginal, blankSentence, answerWord);
    }

    // 2. 어순 맞추기 생성
    private ScrambleQuizRes createScrambleQuiz(Sentence sentence) {
        String cleanKorean = cleanSentence(sentence.getKorean());
        // 공백 기준 분리 (단순화)
        List<String> words = new ArrayList<>(List.of(cleanKorean.split("\\s+")));
        Collections.shuffle(words);

        return ScrambleQuizRes.of(sentence, cleanKorean, words);
    }

    // --- 퀴즈 제출 및 채점 ---
    @Transactional
    public SentenceSubmitRes submitQuiz(Long memberId, SentenceSubmitReq request) {
        Member member = memberReader.getMember(memberId);

        // 학습 시간 기록
        long studyTime = request.getStudyTime() != null ? request.getStudyTime() : 0L;
        member.updateStudyTime(studyTime);

        Sentence sentence = sentenceRepository.findById(request.getSentenceId())
                .orElseThrow(() -> new BusinessException(ErrorCode.SENTENCE_NOT_FOUND));

        // 정답 체크
        boolean isCorrect = checkAnswer(sentence.getKorean(), request.getUserAnswer());

        if (isCorrect) {
            // 정답 시: 경험치 & 챕터 숙련도 상승
            updateMemberXp(member);
            progressService.increaseProgress(memberId, request.getChapterId());
        } else {
            // 오답 노트 저장
            saveMistakeNote(member, sentence, request);
        }

        return SentenceSubmitRes.of(isCorrect, request.getUserAnswer(), sentence);
    }

    /**
     * 오답 노트 저장 헬퍼 메서드
     */
    private void saveMistakeNote(Member member, Sentence sentence, SentenceSubmitReq request) {

        if (mistakeNoteRepository.existsByMemberAndSentence(member, sentence)) {
            return;
        }

        // 1. 퀴즈 타입 추론 (Request에 quizType이 있으면 좋지만, 없다면 로직으로 추론)
        QuizType quizType = request.getQuizType();
        if (quizType == null) {
            // 태그가 있고 사용자가 쓴 답이 짧으면(단어) BLANK일 확률 높음 -> 로직 보완 필요
            // 여기서는 태그 여부로 단순 판단
            quizType = sentence.getKorean().contains("{") ? QuizType.BLANK : QuizType.SCRAMBLE;
        }

        // 2. 섹션 타입 (문장 엔티티에 없다면 기본값 SENTENCE 설정)
        // Sentence 엔티티에 getSectionType()이 있다고 가정합니다. 없다면 기본값 사용.
        SectionType sectionType = SectionType.SENTENCE;
        // if (sentence.getSectionType() != null) sectionType = sentence.getSectionType();

        // 3. 문제 저장 (복습용)
        // 형광펜 UI를 위해 태그가 포함된 원문(rawKorean)을 그대로 저장하는 것을 추천!
        String questionForReview = sentence.getKorean();

        // 4. 저장
        mistakeNoteRepository.save(
                MistakeNote.createForSentence(
                        member,
                        sentence,
                        sectionType,      // 예: KPOP, KDRAMA
                        quizType,         // 예: BLANK, SCRAMBLE
                        questionForReview,// 예: "I {want:V} pizza." (프론트가 파싱해서 보여줌)
                        request.getUserAnswer(),
                        cleanSentence(sentence.getKorean()) // 정답: "I want pizza."
                )
        );
    }

    private boolean checkAnswer(String dbKorean, String userAnswer) {
        String cleanInput = userAnswer.trim().replaceAll("\\s+", " ");

        // 1. 빈칸 퀴즈용 체크
        Matcher matcher = TAG_PATTERN.matcher(dbKorean);
        if (matcher.find()) {
            String blankAnswer = matcher.group(1); // 태그 내부 정답 단어
            if (cleanInput.equals(blankAnswer)) {
                return true;
            }
        }

        // 2. 스크램블 퀴즈용 체크 (전체 문장 비교)
        String fullSentence = matcher.replaceAll("$1"); // 태그 제거한 원문

        String inputNoDot = cleanInput.replace(".", "");
        String answerNoDot = fullSentence.replace(".", "");

        return inputNoDot.equals(answerNoDot);
    }

    private void updateMemberXp(Member member) {
        member.gainXp(10);
        member.increaseQuizCount(1);
    }

    private String cleanSentence(String raw) {
        // {word:tag} -> word 변환
        return TAG_PATTERN.matcher(raw).replaceAll("$1");
    }
}
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
import com.kdopamine.app.domain.studylog.service.MemberSentenceProgressService;
import com.kdopamine.app.domain.word.service.ChapterService;
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

    private static final Pattern TAG_PATTERN = Pattern.compile("\\{([^:}]+):([^}]+)\\}");

    // 전체 랜덤 가져오기
    public List<SentenceQuizRes> getRandomQuizzes(Long memberId, int count) {

        List<Sentence> sentences = sentenceRepository.findRandomSentences(count);

        return convertToQuizList(sentences);
    }

    // 특정 챕터 랜덤 가져오기
    public List<SentenceQuizRes> getChapterQuizzes(Long memberId, Long chapterId, int count) {
        chapterService.findChapterId(chapterId);

        List<Sentence> sentences = sentenceRepository.findByChapterRandom(chapterId, count);

        return convertToQuizList(sentences);
    }

    private List<SentenceQuizRes> convertToQuizList(List<Sentence> sentences) {
        return sentences.stream()
                .map(this::generateQuiz) // 아래의 퀴즈 생성 로직을 태움
                .collect(Collectors.toList());
    }

    private SentenceQuizRes generateQuiz(Sentence sentence) {
        // 태그가 있는지 확인 ({가 포함되어 있는지)
        boolean hasTag = sentence.getKorean().contains("{");

        // 태그가 있으면 50% 확률로 빈칸 문제, 아니면 스크램블 문제
        if (hasTag && Math.random() > 0.5) {
            return createBlankQuiz(sentence);
        } else {
            return createScrambleQuiz(sentence);
        }
    }

    private SentenceQuizRes createBlankQuiz(Sentence sentence) {
        String rawKorean = sentence.getKorean();
        Matcher matcher = TAG_PATTERN.matcher(rawKorean);

        // 모든 태그 위치와 정보를 리스트에 담기
        List<MatchResult> matches = new ArrayList<>();
        while (matcher.find()) {
            matches.add(matcher.toMatchResult());
        }

        // 태그가 없으면 -> 그냥 스크램블로 돌리거나 null 처리
        if (matches.isEmpty()) return null;

        // 여러 태그 중 하나를 랜덤 선택
        MatchResult targetMatch = matches.get((int) (Math.random() * matches.size()));

        String answerWord = targetMatch.group(1);
        String hintTag = targetMatch.group(2);

        //문장 변환 로직
        //선택된 타겟은 빈칸(_______)으로 교체
        //선택 안 된 나머지 태그들은 그냥 단어로 복원
        StringBuilder sb = new StringBuilder();
        int lastEnd = 0;

        Matcher replaceMatcher = TAG_PATTERN.matcher(rawKorean);
        while (replaceMatcher.find()) {
            // 태그 앞부분 문장 붙이기
            sb.append(rawKorean, lastEnd, replaceMatcher.start());

            // 현재 태그가 정답 타겟이면 빈칸, 아니면 그냥 단어
            if (replaceMatcher.start() == targetMatch.start()) {
                sb.append("_______");
            } else {
                sb.append(replaceMatcher.group(1)); // 태그 떼고 단어만
            }
            lastEnd = replaceMatcher.end();
        }
        sb.append(rawKorean.substring(lastEnd)); // 남은 뒷부분 붙이기

        String blankSentence = sb.toString(); // "I want to eat _______."
        String cleanOriginal = cleanSentence(rawKorean); // "I want to eat pizza."

        return BlankQuizRes.of(sentence, cleanOriginal, blankSentence, answerWord);

    }

    // --- 어순 맞추기 퀴즈 생성기 ---
    private ScrambleQuizRes createScrambleQuiz(Sentence sentence) {
        // 태그를 다 떼고 순수 문장으로 만듦: "I {want:V} pizza." -> "I want pizza."
        String cleanKorean = cleanSentence(sentence.getKorean());

        // 단어 쪼개기 (공백 및 구두점 기준인데, 일단 공백 기준으로 심플하게)
        // 구두점(.,?) 등을 단어와 분리할지 포함할지는 기획 결정 필요. 여기선 포함해서 쪼갬.
        List<String> words = new ArrayList<>(List.of(cleanKorean.split("\\s+")));

        Collections.shuffle(words);

        return ScrambleQuizRes.of(sentence, cleanKorean, words);
    }

    // --- 유틸리티 메서드: 문장에서 {word:tag}를 word로 변환 ---
    private String cleanSentence(String raw) {
        // 모든 {word:tag} 패턴을 word로 바꿈
        return TAG_PATTERN.matcher(raw).replaceAll("$1");
    }

    @Transactional
    public SentenceSubmitRes submitQuiz(Long memberId, SentenceSubmitReq request) {
        Member member = memberReader.getMember(memberId);

        long studyTime = request.getStudyTime() != null ? request.getStudyTime() : 0L;
        member.updateStudyTime(studyTime);

        Sentence sentence = sentenceRepository.findById(request.getSentenceId())
                .orElseThrow(() -> new BusinessException(ErrorCode.SENTENCE_NOT_FOUND));

        boolean isCorrect = checkAnswer(sentence.getKorean(), request.getUserAnswer());

        if (isCorrect) {
            // 캐릭터 전체 성장
            updateMemberXp(member);

            // 해당 챕터 숙련도 성장
            progressService.increaseProgress(memberId, request.getChapterId());
        }

        return SentenceSubmitRes.of(isCorrect, request.getUserAnswer(), sentence);
    }

    private boolean checkAnswer(String dbKorean, String userAnswer) {
        // 공백/띄어쓰기 실수 보정 (앞뒤 공백 제거, 두칸 공백->한칸으로)
        String cleanInput = userAnswer.trim().replaceAll("\\s+", " ");

        // 빈칸 퀴즈용
        Matcher matcher = TAG_PATTERN.matcher(dbKorean); // {좋아요:Adj} 찾기
        if (matcher.find()) {
            String blankAnswer = matcher.group(1); // 좋아요
            if (cleanInput.equals(blankAnswer)) {
                return true; // 빈칸만 맞춰도 정답!
            }
        }

        // 스크램블 퀴즈용
        String fullSentence = matcher.replaceAll("$1");

        String inputNoDot = cleanInput.replace(".", "");
        String answerNoDot = fullSentence.replace(".", "");

        if (inputNoDot.equals(answerNoDot)) {
            return true;
        }

        return false;
    }

    private void updateMemberXp(Member member) {
        member.gainXp(10);
        member.increaseQuizCount(1); // 여기도 1을 넣어줌
    }
}

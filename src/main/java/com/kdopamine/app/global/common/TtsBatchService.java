package com.kdopamine.app.global.common;

import com.kdopamine.app.domain.word.entity.Word;
import com.kdopamine.app.domain.word.repository.WordRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TtsBatchService {

    private final WordRepository wordRepository;
    private final GoogleTtsClient googleTtsClient;

    public void generateMissingAudio() {

        List<Word> words = wordRepository.findAll();

        for (Word word : words) {
            if (word.getAudioUrl() != null) continue;

            try {
                String audioUrl = googleTtsClient.createTts(word);
                word.addAudioUrl(audioUrl);
                wordRepository.save(word);

                System.out.println("✅ 생성 완료: " + word.getKorean());

            } catch (Exception e) {
                System.err.println("❌ 실패 wordId=" + word.getId());
                e.printStackTrace();
            }
        }
    }
}

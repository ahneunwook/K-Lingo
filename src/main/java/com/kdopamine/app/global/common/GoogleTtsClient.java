package com.kdopamine.app.global.common;

import com.kdopamine.app.domain.word.entity.Word;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Base64;

@Component
public class GoogleTtsClient {

    @Value("${google.tts.api-key}")
    private String apiKey;

    private final RestTemplate restTemplate = new RestTemplate();

    public String createTts(Word word) throws Exception {

        String apiUrl = "https://texttospeech.googleapis.com/v1/text:synthesize?key=" + apiKey;

        // 요청 JSON
        JSONObject requestBody = new JSONObject();

        requestBody.put("input",
                new JSONObject().put("text", word.getKorean()));

        requestBody.put("voice",
                new JSONObject()
                        .put("languageCode", "ko-KR")
                        .put("name", "ko-KR-Neural2-A"));

        requestBody.put("audioConfig",
                new JSONObject().put("audioEncoding", "MP3"));

        // HTTP 요청
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<String> entity =
                new HttpEntity<>(requestBody.toString(), headers);

        String response =
                restTemplate.postForObject(apiUrl, entity, String.class);

        // Base64 → MP3
        JSONObject json = new JSONObject(response);
        byte[] audioBytes =
                Base64.getDecoder().decode(json.getString("audioContent"));

        // 파일 저장
        File dir = new File("audio");
        if (!dir.exists()) dir.mkdirs();

        String fileName = "tts_" + word.getId() + ".mp3";
        File file = new File(dir, fileName);

        try (FileOutputStream fos = new FileOutputStream(file)) {
            fos.write(audioBytes);
        }

        return "/audio/" + fileName;
    }
}

package com.kdopamine.app.domain.dailytip.service;

import com.kdopamine.app.domain.dailytip.dto.response.DailyTipRes;
import com.kdopamine.app.domain.dailytip.entity.Tip;
import com.kdopamine.app.domain.dailytip.repository.TipRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TipService {
    private final TipRepository tipRepository;

    public DailyTipRes dailyTipRes(){
        Tip randomTip = tipRepository.findRandomTip().orElse(null);

        if (randomTip == null) {
            return null;
        }

        return DailyTipRes.from(randomTip);
    }
}

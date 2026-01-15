package com.kdopamine.app.domain.dailytip.dto.response;

import com.kdopamine.app.domain.dailytip.entity.Tip;
import com.kdopamine.app.domain.dailytip.entity.TipCategory;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DailyTipRes {
    private Long tipId;
    private String title;
    private TipCategory category;
    private String content;
    private String tag;
    private String icon;

    public static DailyTipRes from(Tip tip){
        return DailyTipRes.builder()
                .tipId(tip.getId())
                .title(tip.getTitle())
                .category(tip.getTipCategory())
                .content(tip.getContent())
                .tag(tip.getTag())
                .icon(tip.getIcon())
                .build();
    }
}

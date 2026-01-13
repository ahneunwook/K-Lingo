package com.kdopamine.app.domain.member.service;

import com.kdopamine.app.domain.member.entity.Member;
import com.kdopamine.app.domain.member.repository.MemberRepository;
import com.kdopamine.app.global.exception.BusinessException;
import com.kdopamine.app.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberReader {

    private final MemberRepository memberRepository;

    public Member getMember(Long memberId) {
        return memberRepository.findById(memberId)
                .orElseThrow(() -> new BusinessException(ErrorCode.MEMBER_NOT_FOUND));
    }
}

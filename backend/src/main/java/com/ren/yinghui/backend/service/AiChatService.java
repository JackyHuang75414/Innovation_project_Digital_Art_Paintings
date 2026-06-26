package com.ren.yinghui.backend.service;

import com.ren.yinghui.backend.dto.AiChatRequestDTO;
import com.ren.yinghui.backend.vo.AiChatVO;

public interface AiChatService {
    AiChatVO chat(AiChatRequestDTO dto);
}

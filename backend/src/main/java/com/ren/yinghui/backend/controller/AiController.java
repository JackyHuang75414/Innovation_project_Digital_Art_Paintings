package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.dto.AiChatRequestDTO;
import com.ren.yinghui.backend.service.AiChatService;
import com.ren.yinghui.backend.vo.AiChatVO;
import com.ren.yinghui.backend.vo.Result;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/ai")
public class AiController {
    private final AiChatService aiChatService;

    public AiController(AiChatService aiChatService) {
        this.aiChatService = aiChatService;
    }

    @PostMapping("/chat")
    public Result<AiChatVO> chat(@RequestBody @Valid AiChatRequestDTO dto) {
        return Result.success(aiChatService.chat(dto));
    }
}

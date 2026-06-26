package com.ren.yinghui.backend.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

import java.util.List;

@Data
public class AiChatRequestDTO {
    private String model;

    @NotEmpty
    @Valid
    private List<AiChatMessageDTO> messages;
}

package com.ren.yinghui.backend.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddWishlistDTO {
    @NotNull(message = "Artwork id is required")
    private Long artworkId;
}

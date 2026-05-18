package com.ren.yinghui.backend.pojo;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class WishlistItem {
    private Long userId;
    private Long artworkId;
    private LocalDateTime createdAt;

}

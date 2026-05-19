package com.ren.yinghui.backend.entity;

import lombok.Data;

import java.time.LocalDateTime;
@Data
public class Artist {
    private Long id;
    private String name;
    private String country;
    private String bio;
    private String avatarUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

}

package com.ren.yinghui.backend.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface WishListMapper {
    int existsActiveArtwork(Long artworkId);

    int insertIfNotExists(@Param("userId") Long userId, @Param("artworkId") Long artworkId);
}

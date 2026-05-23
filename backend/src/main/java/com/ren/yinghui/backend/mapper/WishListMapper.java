package com.ren.yinghui.backend.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface WishListMapper {
    int existsActiveArtwork(Long artworkId);

    int insertIfNotExists(@Param("userId") Long userId, @Param("artworkId") Long artworkId);
    //insert和delete在mybatis执行, 默认就会返回影响的行数, 0, 1, 2, 等等
    int deleteByUserIdAndArtworkId(@Param("userId") Long userId, @Param("artworkId") Long artworkId);
}

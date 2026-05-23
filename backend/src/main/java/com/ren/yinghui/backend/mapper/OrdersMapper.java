package com.ren.yinghui.backend.mapper;

import com.ren.yinghui.backend.entity.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface OrdersMapper {
    Artwork findArtworkById(Long artworkId);

    Artist findArtistById(Long artistId);

    ArtworkSize findArtworkSizeByArtworkIdAndSizeName(@Param("artworkId") Long artworkId, @Param("sizeName") String sizeName);

    SizeOption findSizeById(Long sizeId);

    int insertOrder(Order order);

    int insertOrderItem(OrderItem orderItem);
}

package com.ren.yinghui.backend.mapper;

import com.ren.yinghui.backend.entity.*;
import com.ren.yinghui.backend.vo.OrderDetailItemVO;
import com.ren.yinghui.backend.vo.OrderDetailVO;
import com.ren.yinghui.backend.vo.OrderListVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface OrdersMapper {
    Artwork findArtworkById(Long artworkId);

    Artist findArtistById(Long artistId);

    ArtworkSize findArtworkSizeByArtworkIdAndSizeName(@Param("artworkId") Long artworkId, @Param("sizeName") String sizeName);

    SizeOption findSizeById(Long sizeId);

    int insertOrder(Order order);

    int insertOrderItem(OrderItem orderItem);

    OrderDetailVO findDetailById(Long id);

    List<OrderDetailItemVO> findItemsByOrderId(Long orderId);

    List<OrderListVO> findByUserId(Long userId);
}

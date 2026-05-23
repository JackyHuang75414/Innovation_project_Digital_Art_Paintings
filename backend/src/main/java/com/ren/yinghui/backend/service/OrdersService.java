package com.ren.yinghui.backend.service;

import com.ren.yinghui.backend.dto.CreateOrderDTO;
import com.ren.yinghui.backend.vo.OrderCreateVO;
import com.ren.yinghui.backend.vo.OrderDetailVO;
import com.ren.yinghui.backend.vo.OrderListVO;

import java.util.List;

public interface OrdersService {
    //create order
    OrderCreateVO createOrder(CreateOrderDTO dto);

    //get order detail
    OrderDetailVO findDetailById(Long id);

    //get my orders
    List<OrderListVO> findMyOrders();
}

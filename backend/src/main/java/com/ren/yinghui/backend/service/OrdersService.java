package com.ren.yinghui.backend.service;

import com.ren.yinghui.backend.dto.CreateOrderDTO;
import com.ren.yinghui.backend.vo.OrderCreateVO;

public interface OrdersService {
    //create order
    OrderCreateVO createOrder(CreateOrderDTO dto);
}

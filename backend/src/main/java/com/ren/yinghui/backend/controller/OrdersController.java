package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.dto.CreateOrderDTO;
import com.ren.yinghui.backend.service.OrdersService;
import com.ren.yinghui.backend.vo.OrderCreateVO;
import com.ren.yinghui.backend.vo.OrderDetailVO;
import com.ren.yinghui.backend.vo.OrderListVO;
import com.ren.yinghui.backend.vo.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/orders")
public class OrdersController {
    //constructor injection
    private final OrdersService ordersService;
    @Autowired
    public OrdersController(OrdersService ordersService) {
        this.ordersService = ordersService;
    }
    //create order
    @PostMapping
    public Result<OrderCreateVO> createOrder(@RequestBody @Validated CreateOrderDTO dto){
        OrderCreateVO order = ordersService.createOrder(dto);
        return Result.success(order);
    }

    //get order detail
    @GetMapping("/{id}")
    public Result<OrderDetailVO> detail(@PathVariable Long id) {
        OrderDetailVO order = ordersService.findDetailById(id);
        if (order == null) {
            return Result.error("order not found");
        }
        return Result.success(order);
    }

    //get my orders
    @GetMapping("/me")
    public Result<List<OrderListVO>> myOrders() {
        List<OrderListVO> list = ordersService.findMyOrders();
        return Result.success(list);
    }

}

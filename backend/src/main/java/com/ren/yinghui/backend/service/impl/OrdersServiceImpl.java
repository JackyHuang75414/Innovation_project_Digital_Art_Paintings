package com.ren.yinghui.backend.service.impl;

import com.ren.yinghui.backend.dto.CreateOrderDTO;
import com.ren.yinghui.backend.dto.CreateOrderItemDTO;
import com.ren.yinghui.backend.entity.*;
import com.ren.yinghui.backend.mapper.OrdersMapper;
import com.ren.yinghui.backend.service.OrdersService;
import com.ren.yinghui.backend.vo.OrderCreateVO;
import com.ren.yinghui.backend.vo.OrderDetailVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

@Service
public class OrdersServiceImpl implements OrdersService {
    //constructor injection
    private final OrdersMapper ordersMapper;

    @Autowired
    public OrdersServiceImpl(OrdersMapper ordersMapper) {
        this.ordersMapper = ordersMapper;
    }

    @Override
    @Transactional
    public OrderCreateVO createOrder(CreateOrderDTO dto) {
        List<CreateOrderItemDTO> items = dto.getItems();

        List<OrderItem> orderItems = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        LocalDateTime now = LocalDateTime.now();

        for (CreateOrderItemDTO item : items) {
            Artwork artwork = ordersMapper.findArtworkById(item.getArtworkId());
            if (artwork == null || !artwork.getActive()) {
                throw new RuntimeException("Artwork not available");
            }
            if (artwork.getStockQuantity() < item.getQuantity()) {
                throw new RuntimeException("Insufficient stock");
            }
            //组装orderitem
            OrderItem orderItem = new OrderItem();
            orderItem.setArtworkId(artwork.getId());
            orderItem.setArtworkTitle(artwork.getTitle());
            orderItem.setArtworkImageUrl(artwork.getImageUrl());
            Artist artist = ordersMapper.findArtistById(artwork.getArtistId());
            if (artist == null) {
                throw new RuntimeException("Artist not found");
            }
            orderItem.setArtistName(artist.getName());
            ArtworkSize artworkSize = ordersMapper.findArtworkSizeByArtworkIdAndSizeName(artwork.getId(), item.getSize());
            if (artworkSize == null || !artworkSize.getAvailable()) {
                throw new RuntimeException("Artwork size not available");
            }
            SizeOption size = ordersMapper.findSizeById(artworkSize.getSizeId());
            if (size == null) {
                throw new RuntimeException("Size not found");
            }
            orderItem.setSizeName(size.getName());
            orderItem.setQuantity(item.getQuantity());
            //priceOverride是某个作品某个尺寸的特殊价格, 如果不为空那unitprice就是这个固定的特殊价格
            BigDecimal unitPrice = artworkSize.getPriceOverride() != null
                    ? artworkSize.getPriceOverride()
                    : artwork.getPrice().add(size.getPriceDelta());
            orderItem.setUnitPrice(unitPrice);
            orderItem.setSubtotal(unitPrice.multiply(BigDecimal.valueOf(item.getQuantity())));
            orderItem.setCreatedAt(now);

            subtotal = subtotal.add(orderItem.getSubtotal());
            orderItems.add(orderItem);
        }

        //组装order
        Order order = new Order();
        order.setOrderNo(generateOrderNo(now));
        order.setStatus("pending");
        order.setCustomerName(dto.getCustomerName());
        order.setCustomerEmail(dto.getCustomerEmail());
        order.setCustomerPhone(dto.getCustomerPhone());
        order.setShippingCountry(dto.getShippingCountry());
        order.setShippingCity(dto.getShippingCity());
        order.setShippingAddressLine1(dto.getShippingAddressLine1());
        order.setShippingAddressLine2(dto.getShippingAddressLine2());
        order.setShippingPostalCode(dto.getShippingPostalCode());
        order.setPaymentMethod(dto.getPaymentMethod());
        order.setSubtotal(subtotal);
        order.setShippingFee(calculateShippingFee(subtotal));
        order.setTotal(order.getSubtotal().add(order.getShippingFee()));
        order.setCreatedAt(now);
        order.setUpdatedAt(now);

        ordersMapper.insertOrder(order);

        for (OrderItem orderItem : orderItems) {
            orderItem.setOrderId(order.getId());
            ordersMapper.insertOrderItem(orderItem);
        }

        //组装响应数据对象
        OrderCreateVO vo = new OrderCreateVO();
        vo.setId(order.getId());
        vo.setOrderNo(order.getOrderNo());
        vo.setStatus(order.getStatus());
        vo.setSubtotal(order.getSubtotal());
        vo.setShippingFee(order.getShippingFee());
        vo.setTotal(order.getTotal());
        vo.setCreatedAt(order.getCreatedAt());
        return vo;
    }

    @Override
    public OrderDetailVO findDetailById(Long id) {
        OrderDetailVO order = ordersMapper.findDetailById(id);
        if (order == null) {
            return null;
        }
        order.setItems(ordersMapper.findItemsByOrderId(id));
        return order;
    }

    private BigDecimal calculateShippingFee(BigDecimal subtotal) {
        if (subtotal.compareTo(new BigDecimal("80.00")) >= 0) {
            return BigDecimal.ZERO;
        }
        return new BigDecimal("9.90");
    }

    private String generateOrderNo(LocalDateTime now) {
        int suffix = ThreadLocalRandom.current().nextInt(1000);
        return "AC" + now.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss")) + String.format("%03d", suffix);
    }
}

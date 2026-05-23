package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.dto.AddWishlistDTO;
import com.ren.yinghui.backend.service.WishListService;
import com.ren.yinghui.backend.vo.Result;
import com.ren.yinghui.backend.vo.WishlistStatusVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/wishlist")
public class WishListController {
    private final WishListService wishListService;
    @Autowired
    public WishListController(WishListService wishListService) {
        this.wishListService = wishListService;
    }

    //add wishlist
    @PostMapping
    public Result<WishlistStatusVO> add(@RequestBody @Validated AddWishlistDTO dto) {
        WishlistStatusVO result = wishListService.add(dto);
        return Result.success(result);
    }
}

package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.service.WishListService;
import com.ren.yinghui.backend.vo.ArtworkListVO;
import com.ren.yinghui.backend.vo.Result;
import com.ren.yinghui.backend.vo.WishlistStatusVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

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
    public Result<WishlistStatusVO> add(@RequestParam Long artworkId) {
        WishlistStatusVO result = wishListService.add(artworkId);
        return Result.success(result);
    }

    //remove wishlist
    @DeleteMapping
    public Result<WishlistStatusVO> remove(@RequestParam Long artworkId) {
        WishlistStatusVO result = wishListService.remove(artworkId);
        return Result.success(result);
    }

    //get my wishlist
    @GetMapping("/me")
    public Result<List<ArtworkListVO>> myWishlist() {
        List<ArtworkListVO> list = wishListService.findMyWishlist();
        return Result.success(list);
    }
}

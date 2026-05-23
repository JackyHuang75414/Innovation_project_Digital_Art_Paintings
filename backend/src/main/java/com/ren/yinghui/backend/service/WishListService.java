package com.ren.yinghui.backend.service;

import com.ren.yinghui.backend.vo.ArtworkListVO;
import com.ren.yinghui.backend.vo.WishlistStatusVO;

import java.util.List;

public interface WishListService {
    //add wishlist
    WishlistStatusVO add(Long artworkId);

    //remove wishlist
    WishlistStatusVO remove(Long artworkId);

    //get my wishlist
    List<ArtworkListVO> findMyWishlist();
}

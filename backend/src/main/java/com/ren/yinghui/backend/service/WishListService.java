package com.ren.yinghui.backend.service;

import com.ren.yinghui.backend.dto.AddWishlistDTO;
import com.ren.yinghui.backend.vo.WishlistStatusVO;

public interface WishListService {
    //add wishlist
    WishlistStatusVO add(AddWishlistDTO dto);

    //remove wishlist
    WishlistStatusVO remove(Long artworkId);
}

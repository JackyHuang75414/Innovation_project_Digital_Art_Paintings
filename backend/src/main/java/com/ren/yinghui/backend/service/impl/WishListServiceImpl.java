package com.ren.yinghui.backend.service.impl;

import com.ren.yinghui.backend.dto.AddWishlistDTO;
import com.ren.yinghui.backend.mapper.WishListMapper;
import com.ren.yinghui.backend.service.WishListService;
import com.ren.yinghui.backend.utils.ThreadLocalUtil;
import com.ren.yinghui.backend.vo.WishlistStatusVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class WishListServiceImpl implements WishListService {
    private final WishListMapper wishListMapper;
    @Autowired
    public WishListServiceImpl(WishListMapper wishListMapper) {
        this.wishListMapper = wishListMapper;
    }

    @Override
    public WishlistStatusVO add(AddWishlistDTO dto) {
        if (wishListMapper.existsActiveArtwork(dto.getArtworkId()) == 0) {
            throw new RuntimeException("artwork not found");
        }

        wishListMapper.insertIfNotExists(getCurrentUserId(), dto.getArtworkId());

        WishlistStatusVO vo = new WishlistStatusVO();
        vo.setArtworkId(dto.getArtworkId());
        vo.setWishlisted(true);
        return vo;
    }

    @Override
    public WishlistStatusVO remove(Long artworkId) {
        wishListMapper.deleteByUserIdAndArtworkId(getCurrentUserId(), artworkId);

        WishlistStatusVO vo = new WishlistStatusVO();
        vo.setArtworkId(artworkId);
        vo.setWishlisted(false);
        return vo;
    }

    private Long getCurrentUserId() {
        Map<String, Object> claims = ThreadLocalUtil.get();
        Object userId = claims.get("id");
        if (userId instanceof Number number) {
            return number.longValue();
        }
        return Long.valueOf(userId.toString());
    }
}

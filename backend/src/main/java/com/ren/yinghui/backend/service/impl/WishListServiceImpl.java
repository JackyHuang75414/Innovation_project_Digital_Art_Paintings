package com.ren.yinghui.backend.service.impl;

import com.ren.yinghui.backend.mapper.WishListMapper;
import com.ren.yinghui.backend.service.WishListService;
import com.ren.yinghui.backend.utils.ThreadLocalUtil;
import com.ren.yinghui.backend.vo.ArtworkListVO;
import com.ren.yinghui.backend.vo.WishlistStatusVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class WishListServiceImpl implements WishListService {
    private final WishListMapper wishListMapper;
    @Autowired
    public WishListServiceImpl(WishListMapper wishListMapper) {
        this.wishListMapper = wishListMapper;
    }

    @Override
    public WishlistStatusVO add(Long artworkId) {
        if (wishListMapper.existsActiveArtwork(artworkId) == 0) {
            throw new RuntimeException("artwork not found");
        }

        wishListMapper.insertIfNotExists(getCurrentUserId(), artworkId);

        WishlistStatusVO vo = new WishlistStatusVO();
        vo.setArtworkId(artworkId);
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

    @Override
    public List<ArtworkListVO> findMyWishlist() {
        return wishListMapper.findByUserId(getCurrentUserId());
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

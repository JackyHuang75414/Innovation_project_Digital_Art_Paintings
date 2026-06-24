package com.ren.yinghui.backend.service.impl;


import com.ren.yinghui.backend.mapper.ArtworksMapper;
import com.ren.yinghui.backend.dto.ArtworkQueryDTO;
import com.ren.yinghui.backend.service.ArtworksService;
import com.ren.yinghui.backend.vo.ArtworkDetailVO;
import com.ren.yinghui.backend.vo.ArtworkListVO;
import com.ren.yinghui.backend.vo.ArtworkRecommendationVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ArtworksServiceImpl implements ArtworksService {
    //constructor injection
    private final ArtworksMapper artworksMapper;
    @Autowired
    public ArtworksServiceImpl(ArtworksMapper artworksMapper) {
        this.artworksMapper = artworksMapper;
    }

    //list artworks
    @Override
    public List<ArtworkListVO> list(ArtworkQueryDTO query) {
        return artworksMapper.list(query);
    }
    //get artwork detail
    @Override
    public ArtworkDetailVO findDetailById(Long id) {
        ArtworkDetailVO artworkDetail = artworksMapper.findDetailById(id);
        if (artworkDetail == null) {
            return null;
        }

        artworkDetail.setTags(artworksMapper.findTagsByArtworkId(id));
        artworkDetail.setAvailableSizes(artworksMapper.findAvailableSizesByArtworkId(id));
        return artworkDetail;
    }

    //get artwork recommendations
    @Override
    public List<ArtworkRecommendationVO> findRecommendations(Long id, Integer limit) {
        if (limit == null || limit <= 0) {
            limit = 4;
        }
        if (limit > 20) {
            limit = 20;
        }
        return artworksMapper.findRecommendations(id, limit);
    }
}

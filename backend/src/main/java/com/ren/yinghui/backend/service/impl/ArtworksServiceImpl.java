package com.ren.yinghui.backend.service.impl;


import com.ren.yinghui.backend.mapper.ArtworksMapper;
import com.ren.yinghui.backend.entity.Artwork;
import com.ren.yinghui.backend.dto.ArtworkQueryDTO;
import com.ren.yinghui.backend.service.ArtworksService;
import com.ren.yinghui.backend.vo.ArtworkDetailVO;
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
    public List<Artwork> list(ArtworkQueryDTO query) {
        return artworksMapper.list(query);
    }
    //get artwork detail
    @Override
    public ArtworkDetailVO findDetailById(Integer id) {
        ArtworkDetailVO artworkDetail = artworksMapper.findDetailById(id);
        if (artworkDetail == null) {
            return null;
        }

        artworkDetail.setTags(artworksMapper.findTagsByArtworkId(id));
        artworkDetail.setAvailableSizes(artworksMapper.findAvailableSizesByArtworkId(id));
        return artworkDetail;
    }
}

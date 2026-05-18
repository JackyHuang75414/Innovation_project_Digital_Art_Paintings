package com.ren.yinghui.backend.service.impl;


import com.ren.yinghui.backend.mapper.ArtworksMapper;
import com.ren.yinghui.backend.pojo.Artwork;
import com.ren.yinghui.backend.pojo.ArtworkQueryDTO;
import com.ren.yinghui.backend.service.ArtworksService;
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
    public Artwork findById(Integer id) {
        Artwork artwork = artworksMapper.findById(id);
        return artwork;
    }
}

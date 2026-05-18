package com.ren.yinghui.backend.service;


import com.ren.yinghui.backend.pojo.Artwork;
import com.ren.yinghui.backend.pojo.ArtworkQueryDTO;
import org.springframework.stereotype.Service;

import java.util.List;


public interface ArtworksService {
    //list artworks
    List<Artwork> list(ArtworkQueryDTO query);
    //get artwork detail
    Artwork findById(Integer id);
}

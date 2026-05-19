package com.ren.yinghui.backend.service;


import com.ren.yinghui.backend.entity.Artwork;
import com.ren.yinghui.backend.dto.ArtworkQueryDTO;
import com.ren.yinghui.backend.vo.ArtworkDetailVO;

import java.util.List;


public interface ArtworksService {
    //list artworks
    List<Artwork> list(ArtworkQueryDTO query);

    //get artwork detail
    ArtworkDetailVO findDetailById(Integer id);
}

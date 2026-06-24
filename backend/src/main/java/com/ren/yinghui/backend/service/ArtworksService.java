package com.ren.yinghui.backend.service;


import com.ren.yinghui.backend.dto.ArtworkQueryDTO;
import com.ren.yinghui.backend.vo.ArtworkDetailVO;
import com.ren.yinghui.backend.vo.ArtworkListVO;
import com.ren.yinghui.backend.vo.ArtworkRecommendationVO;

import java.util.List;


public interface ArtworksService {
    //list artworks
    List<ArtworkListVO> list(ArtworkQueryDTO query);

    //get artwork detail
    ArtworkDetailVO findDetailById(Long id);

    //get artwork recommendations
    List<ArtworkRecommendationVO> findRecommendations(Long id, Integer limit);
}

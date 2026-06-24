package com.ren.yinghui.backend.mapper;

import com.ren.yinghui.backend.dto.ArtworkQueryDTO;
import com.ren.yinghui.backend.vo.ArtworkDetailVO;
import com.ren.yinghui.backend.vo.ArtworkListVO;
import com.ren.yinghui.backend.vo.ArtworkRecommendationVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ArtworksMapper {
    //list artworks
//    @Select("select * from artworks")
    List<ArtworkListVO> list(ArtworkQueryDTO query);

    //get artwork detail
    ArtworkDetailVO findDetailById(Long id);

    //get artwork tags
    List<String> findTagsByArtworkId(Long id);

    //get artwork available sizes
    List<String> findAvailableSizesByArtworkId(Long id);

    //get artwork recommendations
    List<ArtworkRecommendationVO> findRecommendations(@Param("id") Long id, @Param("limit") Integer limit);
}

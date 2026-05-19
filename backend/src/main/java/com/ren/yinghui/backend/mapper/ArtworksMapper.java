package com.ren.yinghui.backend.mapper;

import com.ren.yinghui.backend.entity.Artwork;
import com.ren.yinghui.backend.dto.ArtworkQueryDTO;
import com.ren.yinghui.backend.vo.ArtworkDetailVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ArtworksMapper {
    //list artworks
//    @Select("select * from artworks")
    List<Artwork> list(ArtworkQueryDTO query);

    //get artwork detail
    ArtworkDetailVO findDetailById(Integer id);

    //get artwork tags
    List<String> findTagsByArtworkId(Integer id);

    //get artwork available sizes
    List<String> findAvailableSizesByArtworkId(Integer id);
}

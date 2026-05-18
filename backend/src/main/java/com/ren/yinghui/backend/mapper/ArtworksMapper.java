package com.ren.yinghui.backend.mapper;

import com.ren.yinghui.backend.pojo.Artwork;
import com.ren.yinghui.backend.pojo.ArtworkQueryDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ArtworksMapper {
    //list artworks
//    @Select("select * from artworks")
    List<Artwork> list(ArtworkQueryDTO query);
    //get artwork detail
    @Select("select * from artworks where id=#{id}")
    Artwork findById(Integer id);
}

package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.entity.Artwork;
import com.ren.yinghui.backend.dto.ArtworkQueryDTO;
import com.ren.yinghui.backend.vo.ArtworkDetailVO;
import com.ren.yinghui.backend.vo.Result;
import com.ren.yinghui.backend.service.ArtworksService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/artworks")
public class ArtworksController {
    //constructor injection
    private final ArtworksService artworksService;
    @Autowired
    public ArtworksController(ArtworksService artworksService) {
        this.artworksService = artworksService;
    }

    //list artworks with filter
    @GetMapping("list")
    public Result<List<Artwork>> list(ArtworkQueryDTO query){
        List<Artwork> list = artworksService.list(query);
        return Result.success(list);
    }

    //get artwork detail
    @GetMapping("detail")
    public Result<ArtworkDetailVO> detail(Integer id){
        ArtworkDetailVO artworkDetail = artworksService.findDetailById(id);
        if (artworkDetail == null) {
            return Result.error("artwork not found");
        }
        return Result.success(artworkDetail);
    }



}

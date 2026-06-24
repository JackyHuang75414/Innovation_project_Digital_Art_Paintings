package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.dto.ArtworkQueryDTO;
import com.ren.yinghui.backend.vo.ArtworkDetailVO;
import com.ren.yinghui.backend.vo.ArtworkListVO;
import com.ren.yinghui.backend.vo.ArtworkRecommendationVO;
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
    public Result<List<ArtworkListVO>> list(ArtworkQueryDTO query){
        List<ArtworkListVO> list = artworksService.list(query);
        return Result.success(list);
    }

    //get artwork detail
    @GetMapping("detail")
    public Result<ArtworkDetailVO> detail(Long id){
        ArtworkDetailVO artworkDetail = artworksService.findDetailById(id);
        if (artworkDetail == null) {
            return Result.error("artwork not found");
        }
        return Result.success(artworkDetail);
    }
    //get recommendations
    @GetMapping("/recommendations")
    public Result<List<ArtworkRecommendationVO>> findRecommendations(Long id, Integer limit){
        //把当前页面的作品的id传进来,然后再根据对应的score找相似作品
        List<ArtworkRecommendationVO> list = artworksService.findRecommendations(id, limit);
        return Result.success(list);
    }



}

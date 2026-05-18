package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.pojo.Artwork;
import com.ren.yinghui.backend.pojo.ArtworkQueryDTO;
import com.ren.yinghui.backend.pojo.Result;
import com.ren.yinghui.backend.service.ArtworksService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class ArtworksController {
    //constructor injection
    private final ArtworksService artworksService;
    @Autowired
    public ArtworksController(ArtworksService artworksService) {
        this.artworksService = artworksService;
    }

    //list artworks with filter
    @GetMapping
    public Result<List<Artwork>> list(ArtworkQueryDTO query){
        List<Artwork> list = artworksService.list(query);
        return Result.success(list);
    }

    //get artwork detail
    @GetMapping("/detail")
    public Result<Artwork> detail(@RequestParam Integer id){
        Artwork artwork = artworksService.findById(id);
        return Result.success(artwork);
    }



}

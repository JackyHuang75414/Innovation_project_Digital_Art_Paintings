package com.ren.yinghui.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class DigitalArtPaintingsApplication {

    public static void main(String[] args) {
        SpringApplication.run(DigitalArtPaintingsApplication.class, args);
    }

}

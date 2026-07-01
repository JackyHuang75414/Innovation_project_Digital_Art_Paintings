package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.service.VmmService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

/**
 * VMM real-time streaming endpoint.
 * Price snapshots and history are served by MarketController (/market/artworks/*).
 * This controller only handles the SSE stream used for live chart updates.
 */
@RestController
@RequestMapping("/vmm")
public class VmmController {

    private final VmmService vmmService;

    public VmmController(VmmService vmmService) {
        this.vmmService = vmmService;
    }

    /**
     * SSE stream — emits a 'vmm' event every 2 s with updated prices.
     * Frontend connects with: new EventSource('/api/vmm/stream')
     * No auth required (public market data).
     */
    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter stream() {
        return vmmService.subscribe();
    }
}

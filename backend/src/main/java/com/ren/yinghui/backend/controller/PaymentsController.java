package com.ren.yinghui.backend.controller;

import com.ren.yinghui.backend.dto.CreateBitcoinPaymentDTO;
import com.ren.yinghui.backend.dto.DemoPaymentConfirmDTO;
import com.ren.yinghui.backend.service.PaymentsService;
import com.ren.yinghui.backend.vo.BitcoinPaymentVO;
import com.ren.yinghui.backend.vo.PaymentConfirmVO;
import com.ren.yinghui.backend.vo.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/payments")
public class PaymentsController {
    private final PaymentsService paymentsService;

    public PaymentsController(PaymentsService paymentsService) {
        this.paymentsService = paymentsService;
    }

    @PostMapping("/demo/confirm")
    public Result<PaymentConfirmVO> confirmDemoPayment(@RequestBody @Validated DemoPaymentConfirmDTO dto) {
        return Result.success(paymentsService.confirmDemoPayment(dto));
    }

    @PostMapping("/bitcoin/address")
    public Result<BitcoinPaymentVO> createBitcoinPayment(@RequestBody @Validated CreateBitcoinPaymentDTO dto) {
        return Result.success(paymentsService.createBitcoinPayment(dto));
    }

    @GetMapping("/bitcoin/{paymentId}")
    public Result<BitcoinPaymentVO> getBitcoinPayment(@PathVariable Long paymentId) {
        return Result.success(paymentsService.getBitcoinPayment(paymentId));
    }
}

package com.ren.yinghui.backend.service;

import com.ren.yinghui.backend.dto.DemoPaymentConfirmDTO;
import com.ren.yinghui.backend.dto.CreateBitcoinPaymentDTO;
import com.ren.yinghui.backend.vo.BitcoinPaymentVO;
import com.ren.yinghui.backend.vo.PaymentConfirmVO;

public interface PaymentsService {
    PaymentConfirmVO confirmDemoPayment(DemoPaymentConfirmDTO dto);

    BitcoinPaymentVO createBitcoinPayment(CreateBitcoinPaymentDTO dto);

    BitcoinPaymentVO getBitcoinPayment(Long paymentId);
}

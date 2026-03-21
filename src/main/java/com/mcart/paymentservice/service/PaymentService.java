package com.mcart.paymentservice.service;

import com.mcart.paymentservice.model.Payment;
import com.mcart.paymentservice.model.PaymentRequest;
import com.mcart.paymentservice.repository.PaymentRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class PaymentService {

    private final PaymentRepository paymentRepository;

    public PaymentService(PaymentRepository paymentRepository) {
        this.paymentRepository = paymentRepository;
    }

    public Payment processPayment(PaymentRequest request) {
        Payment payment = new Payment();
        payment.setTransactionId("TXN-" + UUID.randomUUID().toString()
            .substring(0, 8).toUpperCase());
        payment.setOrderId(request.getOrderId());
        payment.setUserId(request.getUserId());
        payment.setAmount(request.getAmount());
        payment.setMethod(request.getMethod() != null ? request.getMethod() : "CARD");
        payment.setStatus("SUCCESS");
        payment.setMessage("Payment processed successfully");
        return paymentRepository.save(payment);
    }

    public Payment getByTransactionId(String transactionId) {
        return paymentRepository.findByTransactionId(transactionId)
            .orElseThrow(() -> new RuntimeException("Payment not found: " + transactionId));
    }

    public List<Payment> getByOrderId(String orderId) {
        return paymentRepository.findByOrderId(orderId);
    }

    public List<Payment> getByUserId(String userId) {
        return paymentRepository.findByUserId(userId);
    }
}
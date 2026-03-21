package com.mcart.paymentservice.repository;

import com.mcart.paymentservice.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, String> {
    Optional<Payment> findByTransactionId(String transactionId);
    List<Payment> findByOrderId(String orderId);
    List<Payment> findByUserId(String userId);
}
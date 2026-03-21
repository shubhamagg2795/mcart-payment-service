# ================================================================
# MCart Payment Service - File Generator
# Run from: D:\ECOM Case Study\mcart-payment-service\
# Command: powershell -ExecutionPolicy Bypass -File create-files.ps1
# ================================================================

Write-Host "Creating folders..." -ForegroundColor Cyan

New-Item -ItemType Directory -Force -Path "src\main\java\com\mcart\paymentservice" | Out-Null
New-Item -ItemType Directory -Force -Path "src\main\java\com\mcart\paymentservice\controller" | Out-Null
New-Item -ItemType Directory -Force -Path "src\main\java\com\mcart\paymentservice\model" | Out-Null
New-Item -ItemType Directory -Force -Path "src\main\java\com\mcart\paymentservice\service" | Out-Null
New-Item -ItemType Directory -Force -Path "src\main\java\com\mcart\paymentservice\repository" | Out-Null
New-Item -ItemType Directory -Force -Path "src\main\resources" | Out-Null

Write-Host "Folders created. Creating Java files..." -ForegroundColor Cyan

$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# PaymentServiceApplication.java
[System.IO.File]::WriteAllText("src\main\java\com\mcart\paymentservice\PaymentServiceApplication.java", @"
package com.mcart.paymentservice;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class PaymentServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(PaymentServiceApplication.class, args);
    }
}
"@, $utf8NoBom)

# Payment.java
[System.IO.File]::WriteAllText("src\main\java\com\mcart\paymentservice\model\Payment.java", @"
package com.mcart.paymentservice.model;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "payments")
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(name = "transaction_id", unique = true, nullable = false)
    private String transactionId;

    @Column(name = "order_id", nullable = false)
    private String orderId;

    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(nullable = false)
    private double amount;

    @Column(nullable = false)
    private String method;

    @Column(nullable = false)
    private String status;

    @Column(nullable = false)
    private String message;

    @Column(name = "processed_at")
    private Instant processedAt = Instant.now();

    public Payment() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Instant getProcessedAt() { return processedAt; }
    public void setProcessedAt(Instant processedAt) { this.processedAt = processedAt; }
}
"@, $utf8NoBom)

# PaymentRequest.java
[System.IO.File]::WriteAllText("src\main\java\com\mcart\paymentservice\model\PaymentRequest.java", @"
package com.mcart.paymentservice.model;

public class PaymentRequest {
    private String orderId;
    private String userId;
    private double amount;
    private String method;

    public PaymentRequest() {}

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }
}
"@, $utf8NoBom)

# PaymentRepository.java
[System.IO.File]::WriteAllText("src\main\java\com\mcart\paymentservice\repository\PaymentRepository.java", @"
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
"@, $utf8NoBom)

# PaymentService.java
[System.IO.File]::WriteAllText("src\main\java\com\mcart\paymentservice\service\PaymentService.java", @"
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
"@, $utf8NoBom)

# PaymentController.java
[System.IO.File]::WriteAllText("src\main\java\com\mcart\paymentservice\controller\PaymentController.java", @"
package com.mcart.paymentservice.controller;

import com.mcart.paymentservice.model.Payment;
import com.mcart.paymentservice.model.PaymentRequest;
import com.mcart.paymentservice.service.PaymentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/payments")
@CrossOrigin(origins = "*")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Payment Service OK");
    }

    @PostMapping
    public ResponseEntity<Payment> processPayment(@RequestBody PaymentRequest request) {
        return ResponseEntity.ok(paymentService.processPayment(request));
    }

    @GetMapping("/transaction/{transactionId}")
    public ResponseEntity<Payment> getByTransaction(@PathVariable String transactionId) {
        return ResponseEntity.ok(paymentService.getByTransactionId(transactionId));
    }

    @GetMapping("/order/{orderId}")
    public ResponseEntity<List<Payment>> getByOrder(@PathVariable String orderId) {
        return ResponseEntity.ok(paymentService.getByOrderId(orderId));
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Payment>> getByUser(@PathVariable String userId) {
        return ResponseEntity.ok(paymentService.getByUserId(userId));
    }
}
"@, $utf8NoBom)

# application.properties
[System.IO.File]::WriteAllText("src\main\resources\application.properties", @"
spring.application.name=mcart-payment-service
server.port=8083

# PostgreSQL
spring.datasource.url=jdbc:postgresql://`${DB_HOST:localhost}:5432/mcart_payments
spring.datasource.username=`${DB_USER:postgres}
spring.datasource.password=`${DB_PASS:postgres}
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
"@, $utf8NoBom)

# Dockerfile
[System.IO.File]::WriteAllText("Dockerfile", @"
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn clean package -DskipTests -q

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
RUN addgroup -S mcart && adduser -S mcart -G mcart
USER mcart
EXPOSE 8083
ENTRYPOINT [""java"", ""-jar"", ""app.jar""]
"@, $utf8NoBom)

Write-Host ""
Write-Host "All Payment Service files created!" -ForegroundColor Green
Write-Host ""
Get-ChildItem -Recurse -Filter "*.java" | Select-Object Name
Write-Host ""
Write-Host "Now replace pom.xml and compile in IntelliJ" -ForegroundColor Yellow

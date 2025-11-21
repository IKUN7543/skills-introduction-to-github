package com.honey.traceability.controller;

import com.honey.traceability.dto.ProductDTO;
import com.honey.traceability.dto.ResponseDTO;
import com.honey.traceability.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@Tag(name = "产品管理", description = "蜂蜜产品注册和管理接口")
@RestController
@RequestMapping("/api/product")
@RequiredArgsConstructor
@Validated
public class ProductController {
    
    private final ProductService productService;
    
    @Operation(summary = "注册蜂蜜产品")
    @PostMapping("/register")
    public ResponseDTO<String> registerProduct(@Valid @RequestBody ProductDTO productDTO) {
        try {
            String transactionHash = productService.registerProduct(productDTO);
            return ResponseDTO.success("产品注册成功", transactionHash);
        } catch (Exception e) {
            return ResponseDTO.error("产品注册失败: " + e.getMessage());
        }
    }
    
    @Operation(summary = "查询产品信息")
    @GetMapping("/{productId}")
    public ResponseDTO<ProductDTO> getProduct(@PathVariable String productId) {
        try {
            ProductDTO product = productService.getProduct(productId);
            return ResponseDTO.success(product);
        } catch (Exception e) {
            return ResponseDTO.error("查询失败: " + e.getMessage());
        }
    }
    
    @Operation(summary = "获取所有产品列表")
    @GetMapping("/list")
    public ResponseDTO<List<ProductDTO>> getAllProducts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            List<ProductDTO> products = productService.getAllProducts(page, size);
            return ResponseDTO.success(products);
        } catch (Exception e) {
            return ResponseDTO.error("查询失败: " + e.getMessage());
        }
    }
    
    @Operation(summary = "按生产者查询产品")
    @GetMapping("/producer/{producerAddress}")
    public ResponseDTO<List<ProductDTO>> getProductsByProducer(
            @PathVariable String producerAddress) {
        try {
            List<ProductDTO> products = productService.getProductsByProducer(producerAddress);
            return ResponseDTO.success(products);
        } catch (Exception e) {
            return ResponseDTO.error("查询失败: " + e.getMessage());
        }
    }
    
    @Operation(summary = "验证产品真伪")
    @GetMapping("/verify/{productId}")
    public ResponseDTO<VerificationResultDTO> verifyProduct(@PathVariable String productId) {
        try {
            VerificationResultDTO result = productService.verifyProduct(productId);
            return ResponseDTO.success(result);
        } catch (Exception e) {
            return ResponseDTO.error("验证失败: " + e.getMessage());
        }
    }
    
    @Operation(summary = "生成产品溯源二维码")
    @GetMapping("/qrcode/{productId}")
    public ResponseDTO<String> generateQRCode(@PathVariable String productId) {
        try {
            String qrCodeBase64 = productService.generateQRCode(productId);
            return ResponseDTO.success("二维码生成成功", qrCodeBase64);
        } catch (Exception e) {
            return ResponseDTO.error("二维码生成失败: " + e.getMessage());
        }
    }
    
    @Operation(summary = "获取产品统计信息")
    @GetMapping("/statistics")
    public ResponseDTO<StatisticsDTO> getStatistics() {
        try {
            StatisticsDTO statistics = productService.getStatistics();
            return ResponseDTO.success(statistics);
        } catch (Exception e) {
            return ResponseDTO.error("查询失败: " + e.getMessage());
        }
    }
}

// DTO类定义

class VerificationResultDTO {
    private boolean verified;
    private String message;
    private ProductDTO product;
    // getters and setters
}

class StatisticsDTO {
    private long totalProducts;
    private long qualifiedProducts;
    private long soldProducts;
    private long inTransitProducts;
    // getters and setters
}

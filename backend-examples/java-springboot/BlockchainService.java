package com.honey.traceability.service;

import com.honey.traceability.contract.HoneyTraceability;
import lombok.extern.slf4j.Slf4j;
import org.fisco.bcos.sdk.v3.BcosSDK;
import org.fisco.bcos.sdk.v3.client.Client;
import org.fisco.bcos.sdk.v3.crypto.keypair.CryptoKeyPair;
import org.fisco.bcos.sdk.v3.model.TransactionReceipt;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.math.BigInteger;

/**
 * 区块链服务 - FISCO BCOS交互
 */
@Slf4j
@Service
public class BlockchainService {
    
    @Value("${fisco.config-file}")
    private String configFile;
    
    @Value("${fisco.group-id}")
    private String groupId;
    
    @Value("${fisco.contract.address}")
    private String contractAddress;
    
    private BcosSDK bcosSDK;
    private Client client;
    private CryptoKeyPair cryptoKeyPair;
    private HoneyTraceability contract;
    
    @PostConstruct
    public void init() {
        try {
            // 初始化SDK
            bcosSDK = BcosSDK.build(configFile);
            
            // 获取Client对象
            client = bcosSDK.getClient(groupId);
            
            // 获取密钥对
            cryptoKeyPair = client.getCryptoSuite().getCryptoKeyPair();
            
            // 加载合约
            contract = HoneyTraceability.load(contractAddress, client, cryptoKeyPair);
            
            log.info("区块链服务初始化成功");
            log.info("当前区块高度: {}", client.getBlockNumber().getBlockNumber());
        } catch (Exception e) {
            log.error("区块链服务初始化失败", e);
            throw new RuntimeException("区块链服务初始化失败", e);
        }
    }
    
    /**
     * 注册产品
     */
    public TransactionReceipt registerProduct(
            String productId,
            String batchNo,
            String honeyType,
            BigInteger weight,
            String location,
            String qualityGrade) throws Exception {
        
        log.info("注册产品: {}", productId);
        
        TransactionReceipt receipt = contract.registerProduct(
                productId, batchNo, honeyType, weight, location, qualityGrade);
        
        if (receipt.isStatusOK()) {
            log.info("产品注册成功, 交易哈希: {}", receipt.getTransactionHash());
        } else {
            log.error("产品注册失败, 状态码: {}, 消息: {}", 
                    receipt.getStatus(), receipt.getMessage());
            throw new RuntimeException("产品注册失败: " + receipt.getMessage());
        }
        
        return receipt;
    }
    
    /**
     * 添加生产记录
     */
    public TransactionReceipt addProductionRecord(
            String productId,
            String apiary,
            String weather,
            BigInteger temperature,
            BigInteger humidity,
            String notes) throws Exception {
        
        log.info("添加生产记录: {}", productId);
        
        TransactionReceipt receipt = contract.addProductionRecord(
                productId, apiary, weather, temperature, humidity, notes);
        
        if (!receipt.isStatusOK()) {
            throw new RuntimeException("添加生产记录失败: " + receipt.getMessage());
        }
        
        return receipt;
    }
    
    /**
     * 添加质检记录
     */
    public TransactionReceipt addQualityRecord(
            String productId,
            String moisture,
            String fructose,
            String glucose,
            Boolean antibioticTest,
            Boolean pesticideTest,
            Boolean qualified,
            String reportUrl) throws Exception {
        
        log.info("添加质检记录: {}, 是否合格: {}", productId, qualified);
        
        TransactionReceipt receipt = contract.addQualityRecord(
                productId, moisture, fructose, glucose, 
                antibioticTest, pesticideTest, qualified, reportUrl);
        
        if (!receipt.isStatusOK()) {
            throw new RuntimeException("添加质检记录失败: " + receipt.getMessage());
        }
        
        return receipt;
    }
    
    /**
     * 添加物流记录
     */
    public TransactionReceipt addLogisticsRecord(
            String productId,
            String from,
            String to,
            String trackingNo) throws Exception {
        
        log.info("添加物流记录: {}, 物流单号: {}", productId, trackingNo);
        
        TransactionReceipt receipt = contract.addLogisticsRecord(
                productId, from, to, trackingNo);
        
        if (!receipt.isStatusOK()) {
            throw new RuntimeException("添加物流记录失败: " + receipt.getMessage());
        }
        
        return receipt;
    }
    
    /**
     * 更新物流状态
     */
    public TransactionReceipt updateLogisticsStatus(
            String productId,
            BigInteger recordIndex,
            BigInteger status) throws Exception {
        
        log.info("更新物流状态: {}, 记录索引: {}, 状态: {}", 
                productId, recordIndex, status);
        
        TransactionReceipt receipt = contract.updateLogisticsStatus(
                productId, recordIndex, status);
        
        if (!receipt.isStatusOK()) {
            throw new RuntimeException("更新物流状态失败: " + receipt.getMessage());
        }
        
        return receipt;
    }
    
    /**
     * 添加销售记录
     */
    public TransactionReceipt addSalesRecord(
            String productId,
            String buyer,
            BigInteger price,
            String channel) throws Exception {
        
        log.info("添加销售记录: {}, 价格: {}", productId, price);
        
        TransactionReceipt receipt = contract.addSalesRecord(
                productId, buyer, price, channel);
        
        if (!receipt.isStatusOK()) {
            throw new RuntimeException("添加销售记录失败: " + receipt.getMessage());
        }
        
        return receipt;
    }
    
    /**
     * 查询产品信息
     */
    public HoneyTraceability.HoneyProduct getProduct(String productId) throws Exception {
        log.info("查询产品信息: {}", productId);
        return contract.getProduct(productId);
    }
    
    /**
     * 验证产品
     */
    public HoneyTraceability.VerifyProductOutput verifyProduct(String productId) throws Exception {
        log.info("验证产品: {}", productId);
        return contract.verifyProduct(productId);
    }
    
    /**
     * 获取生产记录数量
     */
    public BigInteger getProductionRecordCount(String productId) throws Exception {
        return contract.getProductionRecordCount(productId);
    }
    
    /**
     * 获取质检记录数量
     */
    public BigInteger getQualityRecordCount(String productId) throws Exception {
        return contract.getQualityRecordCount(productId);
    }
    
    /**
     * 获取物流记录数量
     */
    public BigInteger getLogisticsRecordCount(String productId) throws Exception {
        return contract.getLogisticsRecordCount(productId);
    }
    
    /**
     * 获取销售记录数量
     */
    public BigInteger getSalesRecordCount(String productId) throws Exception {
        return contract.getSalesRecordCount(productId);
    }
    
    /**
     * 获取所有产品ID
     */
    public java.util.List<String> getAllProductIds() throws Exception {
        return contract.getAllProductIds();
    }
    
    /**
     * 获取产品总数
     */
    public BigInteger getTotalProducts() throws Exception {
        return contract.getTotalProducts();
    }
    
    /**
     * 分配用户角色（仅管理员）
     */
    public TransactionReceipt assignUserRole(
            String userAddress,
            BigInteger role,
            String userName) throws Exception {
        
        log.info("分配用户角色: 地址={}, 角色={}, 名称={}", userAddress, role, userName);
        
        TransactionReceipt receipt = contract.assignUserRole(userAddress, role, userName);
        
        if (!receipt.isStatusOK()) {
            throw new RuntimeException("分配用户角色失败: " + receipt.getMessage());
        }
        
        return receipt;
    }
    
    /**
     * 获取当前区块高度
     */
    public BigInteger getBlockNumber() throws Exception {
        return client.getBlockNumber().getBlockNumber();
    }
    
    /**
     * 根据交易哈希查询交易回执
     */
    public TransactionReceipt getTransactionReceipt(String transactionHash) throws Exception {
        return client.getTransactionReceipt(transactionHash).getTransactionReceipt().orElse(null);
    }
}

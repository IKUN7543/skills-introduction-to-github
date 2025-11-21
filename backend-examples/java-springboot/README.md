# 蜂蜜溯源系统 - Spring Boot 后端示例

## 项目结构

```
honey-traceability-backend/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── honey/
│   │   │           └── traceability/
│   │   │               ├── HoneyTraceabilityApplication.java
│   │   │               ├── config/
│   │   │               │   ├── FiscoBcosConfig.java
│   │   │               │   ├── SecurityConfig.java
│   │   │               │   └── SwaggerConfig.java
│   │   │               ├── contract/
│   │   │               │   └── HoneyTraceability.java  # 自动生成
│   │   │               ├── controller/
│   │   │               │   ├── ProductController.java
│   │   │               │   ├── ProductionController.java
│   │   │               │   ├── QualityController.java
│   │   │               │   ├── LogisticsController.java
│   │   │               │   └── TraceController.java
│   │   │               ├── service/
│   │   │               │   ├── BlockchainService.java
│   │   │               │   ├── ProductService.java
│   │   │               │   ├── ProductionService.java
│   │   │               │   ├── QualityService.java
│   │   │               │   └── LogisticsService.java
│   │   │               ├── entity/
│   │   │               │   ├── Product.java
│   │   │               │   ├── ProductionRecord.java
│   │   │               │   ├── QualityRecord.java
│   │   │               │   └── LogisticsRecord.java
│   │   │               ├── dto/
│   │   │               │   ├── ProductDTO.java
│   │   │               │   └── TraceResultDTO.java
│   │   │               ├── mapper/
│   │   │               │   └── ProductMapper.java
│   │   │               └── util/
│   │   │                   ├── QRCodeUtil.java
│   │   │                   └── BlockchainUtil.java
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       └── contracts/
│   │           └── HoneyTraceability.sol
│   └── test/
└── pom.xml
```

## 依赖配置 (pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.7.14</version>
        <relativePath/>
    </parent>
    
    <groupId>com.honey</groupId>
    <artifactId>traceability-backend</artifactId>
    <version>1.0.0</version>
    <name>Honey Traceability Backend</name>
    
    <properties>
        <java.version>11</java.version>
        <fisco-bcos.version>3.4.0</fisco-bcos.version>
    </properties>
    
    <dependencies>
        <!-- Spring Boot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        
        <!-- FISCO BCOS Java SDK -->
        <dependency>
            <groupId>org.fisco-bcos.java-sdk</groupId>
            <artifactId>fisco-bcos-java-sdk</artifactId>
            <version>${fisco-bcos.version}</version>
        </dependency>
        
        <!-- MyBatis Plus -->
        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-boot-starter</artifactId>
            <version>3.5.3.1</version>
        </dependency>
        
        <!-- MySQL -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.33</version>
        </dependency>
        
        <!-- JWT -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.11.5</version>
        </dependency>
        
        <!-- QRCode -->
        <dependency>
            <groupId>com.google.zxing</groupId>
            <artifactId>core</artifactId>
            <version>3.5.1</version>
        </dependency>
        <dependency>
            <groupId>com.google.zxing</groupId>
            <artifactId>javase</artifactId>
            <version>3.5.1</version>
        </dependency>
        
        <!-- Swagger/OpenAPI -->
        <dependency>
            <groupId>org.springdoc</groupId>
            <artifactId>springdoc-openapi-ui</artifactId>
            <version>1.7.0</version>
        </dependency>
        
        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        
        <!-- Validation -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <!-- Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

## 配置文件说明

详见代码示例文件。

## 快速开始

### 1. 编译智能合约生成Java类

```bash
# 下载FISCO BCOS控制台
bash <(curl -s https://raw.githubusercontent.com/FISCO-BCOS/console/master/tools/download_console.sh)

# 编译合约
cd console && bash sol2java.sh -s contracts/HoneyTraceability.sol -p com.honey.traceability.contract
```

### 2. 配置application.yml

```yaml
# 见配置文件示例
```

### 3. 启动应用

```bash
mvn clean install
mvn spring-boot:run
```

### 4. 访问API文档

```
http://localhost:8080/swagger-ui.html
```

## API接口示例

### 注册产品
```http
POST /api/product/register
Content-Type: application/json

{
  "productId": "HN20231201001",
  "batchNo": "BATCH001",
  "honeyType": "洋槐蜜",
  "weight": 500,
  "location": "河南省新乡市",
  "qualityGrade": "一级"
}
```

### 添加质检记录
```http
POST /api/quality/add
Content-Type: application/json

{
  "productId": "HN20231201001",
  "moisture": "18.5%",
  "fructose": "42%",
  "glucose": "35%",
  "antibioticTest": true,
  "pesticideTest": true,
  "qualified": true,
  "reportUrl": "ipfs://Qm..."
}
```

### 溯源查询
```http
GET /api/trace/{productId}
```

响应示例：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "product": {...},
    "productionRecords": [...],
    "qualityRecords": [...],
    "logisticsRecords": [...],
    "salesRecords": [...],
    "verified": true,
    "traceabilityChain": [...]
  }
}
```

## 开发建议

1. **异步处理**：链上交易可能耗时，建议使用异步处理
2. **缓存策略**：高频查询数据使用Redis缓存
3. **事务管理**：链上和链下数据保持一致性
4. **异常处理**：完善的异常捕获和日志记录
5. **安全防护**：接口鉴权、数据验证、防重放攻击

## 注意事项

- 确保FISCO BCOS节点正常运行
- 配置正确的节点连接信息和证书
- 生产环境需要更完善的安全机制
- 建议使用连接池管理区块链连接

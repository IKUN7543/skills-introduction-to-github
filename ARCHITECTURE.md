# 蜂蜜溯源系统架构设计

## 一、总体架构

本系统采用分层架构设计，自上而下分为：展示层、应用层、中间件层、区块链层和存储层。

```
┌───────────────────────────────────────────────────────────────┐
│                         展示层 (Presentation Layer)             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │管理后台PC │  │ 移动H5页面│  │微信小程序 │  │  原生APP  │     │
│  │ Vue 3    │  │  Vue 3   │  │uni-app   │  │  Flutter │     │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘     │
└───────────────────────────────────────────────────────────────┘
                              ↓ HTTPS/WSS
┌───────────────────────────────────────────────────────────────┐
│                    网关层 (API Gateway Layer)                   │
│  ┌──────────────────────────────────────────────────────┐    │
│  │         Nginx / Spring Cloud Gateway                  │    │
│  │  - 路由转发   - 负载均衡   - 限流   - 认证   - 日志   │    │
│  └──────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────┘
                              ↓
┌───────────────────────────────────────────────────────────────┐
│                     应用服务层 (Application Layer)              │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐    │
│  │产品服务 │ │生产服务 │ │质检服务 │ │物流服务 │ │销售服务 │    │
│  │Product │ │Productn│ │Quality │ │Logistic│ │  Sale  │    │
│  │Service │ │Service │ │Service │ │Service │ │Service │    │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘    │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐    │
│  │溯源服务 │ │用户服务 │ │通知服务 │ │统计服务 │ │文件服务 │    │
│  │ Trace  │ │  User  │ │ Notify │ │ Stats  │ │  File  │    │
│  │Service │ │Service │ │Service │ │Service │ │Service │    │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘    │
│                     Spring Boot / Node.js                     │
└───────────────────────────────────────────────────────────────┘
                              ↓
┌───────────────────────────────────────────────────────────────┐
│                区块链中间件层 (Blockchain Middleware)            │
│  ┌──────────────────────────────────────────────────────┐    │
│  │            FISCO BCOS Java/Node.js SDK                │    │
│  │  - 交易提交   - 事件监听   - 合约调用   - 密钥管理    │    │
│  └──────────────────────────────────────────────────────┘    │
│  ┌──────────────────────────────────────────────────────┐    │
│  │                  WeBASE 管理平台（可选）               │    │
│  │  - 合约管理   - 节点监控   - 链管理   - 数据浏览      │    │
│  └──────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────┘
                              ↓
┌───────────────────────────────────────────────────────────────┐
│               区块链底层 (FISCO BCOS Blockchain)                │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐          │
│  │Node 0│  │Node 1│  │Node 2│  │Node 3│  │Node N│          │
│  │Sealer│  │Sealer│  │Sealer│  │Sealer│  │Observer         │
│  └──────┘  └──────┘  └──────┘  └──────┘  └──────┘          │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │              智能合约 (Smart Contracts)             │     │
│  │  HoneyTraceability.sol   |   AccessControl.sol    │     │
│  └────────────────────────────────────────────────────┘     │
└───────────────────────────────────────────────────────────────┘
                              ↓
┌───────────────────────────────────────────────────────────────┐
│                    数据存储层 (Storage Layer)                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │区块链存储 │  │  MySQL   │  │  Redis   │  │   IPFS   │    │
│  │ RocksDB  │  │业务数据库 │  │缓存/队列 │  │文件存储   │    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
└───────────────────────────────────────────────────────────────┘
```

## 二、核心模块设计

### 2.1 产品服务 (Product Service)

**职责**：
- 产品注册与基本信息管理
- 产品批次管理
- 产品状态流转
- 二维码生成

**核心API**：
```
POST   /api/product/register          # 注册产品
GET    /api/product/{id}              # 查询产品
PUT    /api/product/{id}              # 更新产品
GET    /api/product/list              # 产品列表
GET    /api/product/{id}/qrcode       # 生成二维码
DELETE /api/product/{id}              # 删除产品
```

**数据流**：
```
用户请求 → Controller → Service → BlockchainService → FISCO BCOS
                               ↓
                          MySQL (缓存产品信息)
                               ↓
                          Redis (热点数据)
```

### 2.2 生产服务 (Production Service)

**职责**：
- 生产记录管理
- 蜂场信息管理
- 环境数据记录
- 蜂农信息管理

**核心API**：
```
POST   /api/production/record         # 添加生产记录
GET    /api/production/{productId}    # 查询生产记录
GET    /api/production/apiary/list    # 蜂场列表
POST   /api/production/apiary         # 注册蜂场
```

### 2.3 质检服务 (Quality Service)

**职责**：
- 质检记录管理
- 质检报告上传
- 质量分析
- 不合格品处理

**核心API**：
```
POST   /api/quality/inspect           # 添加质检记录
GET    /api/quality/{productId}       # 查询质检记录
POST   /api/quality/report/upload     # 上传质检报告
GET    /api/quality/statistics        # 质量统计
```

### 2.4 物流服务 (Logistics Service)

**职责**：
- 物流信息管理
- 物流状态跟踪
- 温湿度监控
- 物流轨迹查询

**核心API**：
```
POST   /api/logistics/create          # 创建物流记录
PUT    /api/logistics/{id}/status     # 更新物流状态
GET    /api/logistics/{productId}     # 查询物流信息
POST   /api/logistics/temperature     # 上报温湿度数据
```

### 2.5 溯源服务 (Trace Service)

**职责**：
- 聚合溯源数据
- 溯源链展示
- 区块链验证
- 溯源报告生成

**核心API**：
```
GET    /api/trace/{productId}         # 完整溯源查询
GET    /api/trace/{productId}/verify  # 验证产品真伪
GET    /api/trace/{productId}/report  # 生成溯源报告
GET    /api/trace/qrcode/{code}       # 扫码溯源
```

**数据聚合流程**：
```
溯源请求
    ↓
查询产品基本信息
    ↓
并行查询：
    - 生产记录
    - 质检记录
    - 物流记录
    - 销售记录
    ↓
数据整合
    ↓
区块链验证
    ↓
返回溯源结果
```

## 三、智能合约设计

### 3.1 主合约：HoneyTraceability.sol

**核心数据结构**：
```solidity
struct HoneyProduct {
    string productId;
    string batchNo;
    address producer;
    uint256 productionDate;
    string honeyType;
    uint256 weight;
    string location;
    string qualityGrade;
    ProductStatus status;
    bool exists;
}

struct ProductionRecord {
    string productId;
    address beekeeper;
    string apiary;
    uint256 harvestDate;
    string weather;
    uint256 temperature;
    uint256 humidity;
    string notes;
    uint256 timestamp;
}

struct QualityRecord {
    string productId;
    address inspector;
    uint256 inspectionDate;
    string moisture;
    string fructose;
    string glucose;
    bool antibioticTest;
    bool pesticideTest;
    bool qualified;
    string reportUrl;
    uint256 timestamp;
}
```

**核心函数**：
```solidity
// 产品管理
function registerProduct(...) public onlyProducer
function getProduct(string productId) public view returns (HoneyProduct)

// 生产管理
function addProductionRecord(...) public onlyProducer
function getProductionRecordCount(string productId) public view returns (uint256)

// 质检管理
function addQualityRecord(...) public onlyInspector
function getQualityRecordCount(string productId) public view returns (uint256)

// 物流管理
function addLogisticsRecord(...) public onlyCarrier
function updateLogisticsStatus(...) public onlyCarrier

// 验证功能
function verifyProduct(string productId) public view returns (bool, string)

// 权限管理
function assignUserRole(address user, UserRole role, string name) public onlyAdmin
```

### 3.2 访问控制合约

**角色定义**：
```solidity
enum UserRole {
    None,        // 无权限
    Producer,    // 生产者（蜂农）
    Inspector,   // 质检员
    Carrier,     // 承运商
    Seller,      // 销售商
    Consumer,    // 消费者
    Admin        // 管理员
}
```

**权限验证**：
```solidity
modifier onlyRole(UserRole role) {
    require(userRoles[msg.sender] == role || userRoles[msg.sender] == UserRole.Admin,
            "Insufficient permissions");
    _;
}
```

## 四、数据流设计

### 4.1 产品注册流程

```
┌─────────┐      ┌─────────┐      ┌──────────┐      ┌────────┐
│生产者前端│ ───▶ │后端API  │ ───▶ │区块链SDK │ ───▶ │FISCO   │
│         │      │         │      │          │      │BCOS    │
└─────────┘      └─────────┘      └──────────┘      └────────┘
    │                 │                  │                │
    │ 1.提交产品信息   │                  │                │
    │────────────────▶│                  │                │
    │                 │ 2.参数验证        │                │
    │                 │ 3.生成产品ID      │                │
    │                 │──────────────────▶│                │
    │                 │                  │ 4.调用智能合约  │
    │                 │                  │────────────────▶│
    │                 │                  │                │ 5.上链
    │                 │                  │◀────────────────│
    │                 │                  │ 6.交易回执      │
    │                 │◀──────────────────│                │
    │                 │ 7.保存到MySQL     │                │
    │                 │ 8.缓存到Redis     │                │
    │◀────────────────│ 9.返回结果        │                │
    │                 │                  │                │
```

### 4.2 溯源查询流程

```
┌─────────┐      ┌─────────┐      ┌──────────┐      ┌────────┐
│消费者前端│ ───▶ │后端API  │ ───▶ │区块链SDK │ ───▶ │FISCO   │
│(扫码)   │      │         │      │          │      │BCOS    │
└─────────┘      └─────────┘      └──────────┘      └────────┘
    │                 │                  │                │
    │ 1.扫描二维码     │                  │                │
    │────────────────▶│                  │                │
    │                 │ 2.解析产品ID      │                │
    │                 │ 3.查询Redis缓存   │                │
    │                 │   (如命中直接返回)│                │
    │                 │                  │                │
    │                 │ 4.查询链上数据    │                │
    │                 │──────────────────▶│                │
    │                 │                  │ 5.查询合约      │
    │                 │                  │────────────────▶│
    │                 │                  │◀────────────────│
    │                 │◀──────────────────│ 6.返回数据      │
    │                 │                  │                │
    │                 │ 7.并行查询：      │                │
    │                 │   - 生产记录      │                │
    │                 │   - 质检记录      │                │
    │                 │   - 物流记录      │                │
    │                 │   - 销售记录      │                │
    │                 │                  │                │
    │                 │ 8.数据聚合        │                │
    │                 │ 9.区块链验证      │                │
    │                 │10.缓存结果        │                │
    │◀────────────────│11.返回溯源信息    │                │
    │                 │                  │                │
```

## 五、数据库设计

### 5.1 MySQL表结构

**用户表 (users)**
```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    blockchain_address VARCHAR(64),
    real_name VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    status TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_blockchain_address (blockchain_address)
);
```

**产品缓存表 (products_cache)**
```sql
CREATE TABLE products_cache (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id VARCHAR(64) UNIQUE NOT NULL,
    batch_no VARCHAR(64),
    honey_type VARCHAR(50),
    weight INT,
    location VARCHAR(100),
    quality_grade VARCHAR(20),
    status TINYINT,
    producer_address VARCHAR(64),
    production_date TIMESTAMP,
    block_number BIGINT,
    transaction_hash VARCHAR(66),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_id (product_id),
    INDEX idx_batch_no (batch_no),
    INDEX idx_producer (producer_address),
    INDEX idx_status (status)
);
```

**蜂场表 (apiaries)**
```sql
CREATE TABLE apiaries (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    apiary_id VARCHAR(64) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(200),
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    owner_address VARCHAR(64),
    area DECIMAL(10, 2),
    hive_count INT,
    status TINYINT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### 5.2 Redis缓存设计

**Key命名规范**：
```
honey:product:{productId}              # 产品信息
honey:trace:{productId}                # 完整溯源数据
honey:user:{address}                   # 用户信息
honey:statistics:daily                 # 每日统计
honey:hot:products                     # 热门产品排行
```

**缓存策略**：
- 产品基本信息：TTL 1小时
- 溯源完整数据：TTL 30分钟
- 统计数据：TTL 5分钟
- 热门产品：实时更新，TTL 10分钟

## 六、安全设计

### 6.1 身份认证

**JWT Token认证**：
```
用户登录 → 验证用户名密码 → 生成JWT Token → 返回Token
    ↓
后续请求携带Token → 验证Token → 解析用户信息 → 执行业务逻辑
```

**Token结构**：
```json
{
  "sub": "user_id",
  "username": "producer001",
  "role": "PRODUCER",
  "blockchain_address": "0x...",
  "exp": 1234567890,
  "iat": 1234567890
}
```

### 6.2 权限控制

**三层权限控制**：
1. **前端路由权限**：根据角色显示不同菜单
2. **后端接口权限**：@PreAuthorize注解控制
3. **智能合约权限**：modifier控制函数调用权限

### 6.3 数据安全

**敏感数据处理**：
- 用户密码：BCrypt加密
- 传输数据：HTTPS加密
- 链上数据：仅存储哈希值
- 文件存储：IPFS + 加密

## 七、性能优化

### 7.1 缓存策略

```
请求 → 查询Redis → 命中？
         ↓ 否           ↓ 是
    查询区块链/数据库   直接返回
         ↓
    写入Redis缓存
         ↓
      返回结果
```

### 7.2 异步处理

**消息队列**：
- 使用RabbitMQ/Kafka处理异步任务
- 链上交易异步化
- 数据同步异步化
- 通知推送异步化

### 7.3 数据库优化

- 读写分离
- 分库分表（产品量大时）
- 索引优化
- 慢查询监控

## 八、监控告警

### 8.1 监控指标

**系统指标**：
- CPU、内存、磁盘使用率
- 网络流量
- JVM堆内存

**业务指标**：
- API请求量/响应时间
- 区块链交易成功率
- 数据库连接池
- Redis命中率

**区块链指标**：
- 节点状态
- 区块高度
- TPS
- 合约Gas消耗

### 8.2 日志管理

**日志分类**：
```
logs/
├── application.log          # 应用日志
├── access.log              # 访问日志
├── error.log               # 错误日志
├── blockchain.log          # 区块链交易日志
└── audit.log               # 审计日志
```

## 九、灾备方案

### 9.1 数据备份

- **MySQL**：每日全量备份 + 实时binlog备份
- **Redis**：RDB + AOF持久化
- **区块链**：节点数据定期备份
- **IPFS**：多副本存储

### 9.2 高可用

- **应用层**：多实例 + 负载均衡
- **数据库**：主从复制
- **Redis**：哨兵模式/集群模式
- **区块链**：多节点共识

---

## 附录：技术选型对比

| 层级 | 方案A | 方案B | 推荐 |
|-----|-------|-------|------|
| 后端框架 | Spring Boot | Node.js | Spring Boot（企业级稳定） |
| 前端框架 | Vue 3 | React | Vue 3（学习曲线平缓） |
| 数据库 | MySQL | PostgreSQL | MySQL（生态丰富） |
| 缓存 | Redis | Memcached | Redis（功能丰富） |
| 消息队列 | RabbitMQ | Kafka | RabbitMQ（中小规模） |

---

**文档版本**: v1.0  
**最后更新**: 2024-12  
**维护者**: Honey Trace Team

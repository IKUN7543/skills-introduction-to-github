# 🍯 基于FISCO BCOS的蜂蜜溯源系统

<div align="center">

![Blockchain](https://img.shields.io/badge/Blockchain-FISCO%20BCOS-blue)
![Java](https://img.shields.io/badge/Java-11+-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7+-green)
![Vue](https://img.shields.io/badge/Vue-3.0+-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

**一个完整的区块链溯源解决方案，确保蜂蜜产品从生产到销售的全流程透明可追溯**

[快速开始](./QUICK-START.md) • [技术栈](./FISCO-BCOS-HONEY-TRACEABILITY-TECH-STACK.md) • [部署指南](./DEPLOYMENT-GUIDE.md) • [代码示例](#代码示例)

</div>

---

## 📋 目录

- [项目简介](#项目简介)
- [核心特性](#核心特性)
- [系统架构](#系统架构)
- [技术栈](#技术栈)
- [快速开始](#快速开始)
- [功能模块](#功能模块)
- [代码示例](#代码示例)
- [部署指南](#部署指南)
- [路线图](#路线图)
- [贡献指南](#贡献指南)
- [许可证](#许可证)

---

## 🎯 项目简介

本项目是一个基于 **FISCO BCOS** 联盟链的蜂蜜溯源系统，通过区块链技术确保蜂蜜产品信息的真实性和不可篡改性。系统记录蜂蜜从养殖、采集、加工、质检、物流到销售的全流程数据，消费者可通过扫描二维码查询产品的完整溯源信息。

### 为什么选择区块链溯源？

- ✅ **数据不可篡改**：所有溯源数据上链后无法修改
- ✅ **透明可追溯**：完整记录产品生命周期
- ✅ **多方协作**：蜂农、加工商、质检机构、经销商共同参与
- ✅ **消费者信任**：增强产品可信度和品牌价值

### 为什么选择FISCO BCOS？

- 🚀 **高性能**：TPS可达数万，满足企业级应用需求
- 🔒 **安全可控**：国产自主可控的联盟链平台
- 🛠️ **易于开发**：完善的SDK和工具链
- 🏢 **企业级**：已在金融、政务、医疗等多个领域落地

---

## ✨ 核心特性

### 区块链能力
- 🔗 智能合约管理产品全生命周期
- 🔐 多角色权限控制（生产者、质检员、物流商等）
- 📝 不可篡改的链上记录
- ✔️ 产品真伪验证

### 业务功能
- 📦 产品注册与批次管理
- 🏭 生产记录（蜂场信息、采蜜时间、环境数据）
- 🔬 质检记录（成分检测、质量报告）
- 🚚 物流追踪（实时位置、温湿度监控）
- 💰 销售记录
- 📱 移动端扫码溯源

### 技术特性
- 🎨 现代化前端界面（Vue 3 + TypeScript）
- ⚡ 高性能后端服务（Spring Boot）
- 💾 链上链下数据协同
- 📊 数据可视化与统计分析
- 🔔 异常告警机制

---

## 🏗️ 系统架构

```
┌─────────────────────────────────────────────────────────┐
│                    用户层 (User Layer)                   │
├──────────────┬──────────────┬──────────────┬────────────┤
│  管理后台(PC)  │  移动端H5     │  微信小程序   │   APP      │
└──────────────┴──────────────┴──────────────┴────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│              应用服务层 (Application Layer)               │
├─────────────────────────────────────────────────────────┤
│  产品服务  │  质检服务  │  物流服务  │  溯源服务  │ 用户服务 │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│            区块链中间件层 (Middleware Layer)              │
├─────────────────────────────────────────────────────────┤
│   FISCO BCOS Java SDK   │   智能合约接口   │   WeBASE    │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│         区块链底层 (FISCO BCOS Blockchain)               │
├─────────────────────────────────────────────────────────┤
│    节点1    │    节点2    │    节点3    │    节点4      │
└─────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────┐
│              数据存储层 (Storage Layer)                  │
├───────────────┬──────────────┬──────────────┬───────────┤
│  区块链存储    │   MySQL      │    Redis     │   IPFS    │
└───────────────┴──────────────┴──────────────┴───────────┘
```

---

## 🛠️ 技术栈

### 区块链层
- **FISCO BCOS 3.x** - 联盟链平台
- **Solidity** - 智能合约开发语言
- **WeBASE** - 区块链管理平台（可选）

### 后端
- **Spring Boot 2.7+** - 应用框架
- **FISCO BCOS Java SDK** - 区块链SDK
- **MyBatis Plus** - ORM框架
- **MySQL 8.0** - 关系型数据库
- **Redis** - 缓存
- **JWT** - 认证授权

### 前端
- **Vue 3** - 渐进式框架
- **TypeScript** - 类型安全
- **Element Plus** - UI组件库
- **Vite** - 构建工具
- **Pinia** - 状态管理
- **ECharts** - 数据可视化

### 开发运维
- **Docker** - 容器化
- **Nginx** - 反向代理
- **Maven** - 项目管理
- **Git** - 版本控制

---

## 🚀 快速开始

### 前置条件

确保你的开发环境已安装：

- Java JDK 11+
- Node.js 16+
- MySQL 8.0+
- Redis 6.0+
- Git

### 30分钟快速部署

```bash
# 1. 部署FISCO BCOS区块链（5分钟）
curl -#LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v3.6.0/build_chain.sh
bash build_chain.sh -l 127.0.0.1:4 -p 30300,20200
bash nodes/127.0.0.1/start_all.sh

# 2. 部署智能合约（3分钟）
# 下载控制台并部署合约
bash <(curl -s https://raw.githubusercontent.com/FISCO-BCOS/console/master/tools/download_console.sh)
cd console && bash start.sh
# 在控制台执行: deploy HoneyTraceability

# 3. 准备数据库（2分钟）
mysql -u root -p
CREATE DATABASE honey_traceability CHARACTER SET utf8mb4;
CREATE USER 'honey_user'@'localhost' IDENTIFIED BY 'honey123';
GRANT ALL PRIVILEGES ON honey_traceability.* TO 'honey_user'@'localhost';

# 4. 启动后端（10分钟）
cd backend
mvn clean install
mvn spring-boot:run

# 5. 启动前端（10分钟）
cd frontend
npm install
npm run dev
```

🎉 访问 http://localhost:5173 开始使用！

详细步骤请参考：[📖 快速开始指南](./QUICK-START.md)

---

## 📦 功能模块

### 1️⃣ 产品管理模块
- 产品注册（产品ID、批次号、蜂蜜类型、产地等）
- 产品列表与搜索
- 产品详情查看
- 二维码生成

### 2️⃣ 生产管理模块
- 蜂场信息管理
- 采蜜记录（时间、天气、温湿度）
- 蜂农信息管理
- 生产日志

### 3️⃣ 质检管理模块
- 质检记录录入（水分、糖分、抗生素、农残等）
- 质检报告上传（IPFS）
- 质检结果管理
- 不合格品处理

### 4️⃣ 物流管理模块
- 物流信息录入
- 物流状态更新
- 物流轨迹追踪
- 温湿度监控（物联网设备）

### 5️⃣ 销售管理模块
- 销售记录
- 渠道管理
- 订单追踪

### 6️⃣ 溯源查询模块
- 扫码查询（二维码/条形码）
- 产品ID查询
- 溯源信息展示（时间轴）
- 区块链验证

### 7️⃣ 数据统计模块
- 产品统计分析
- 质量分析报表
- 销售数据统计
- 可视化看板

### 8️⃣ 用户权限模块
- 多角色管理（管理员、生产者、质检员、物流商、销售商）
- 权限控制
- 操作日志

---

## 💻 代码示例

### 智能合约示例

完整的Solidity智能合约：[HoneyTraceability.sol](./smart-contract-examples/HoneyTraceability.sol)

```solidity
// 产品注册
function registerProduct(
    string memory _productId,
    string memory _batchNo,
    string memory _honeyType,
    uint256 _weight,
    string memory _location,
    string memory _qualityGrade
) public onlyProducer {
    // 注册逻辑
}

// 添加质检记录
function addQualityRecord(
    string memory _productId,
    string memory _moisture,
    string memory _fructose,
    string memory _glucose,
    bool _qualified,
    string memory _reportUrl
) public onlyInspector {
    // 质检记录逻辑
}

// 验证产品真伪
function verifyProduct(string memory _productId) 
    public view returns (bool, string memory) {
    // 验证逻辑
}
```

### 后端服务示例

Spring Boot服务代码：
- [产品控制器](./backend-examples/java-springboot/ProductController.java)
- [区块链服务](./backend-examples/java-springboot/BlockchainService.java)
- [项目说明](./backend-examples/java-springboot/README.md)

```java
@RestController
@RequestMapping("/api/product")
public class ProductController {
    
    @PostMapping("/register")
    public ResponseDTO<String> registerProduct(@RequestBody ProductDTO dto) {
        String txHash = productService.registerProduct(dto);
        return ResponseDTO.success("注册成功", txHash);
    }
    
    @GetMapping("/{productId}")
    public ResponseDTO<ProductDTO> getProduct(@PathVariable String productId) {
        ProductDTO product = productService.getProduct(productId);
        return ResponseDTO.success(product);
    }
}
```

### 前端界面示例

Vue 3 + TypeScript溯源查询页面：
- [溯源查询页面](./frontend-examples/vue3-typescript/TraceQuery.vue)
- [项目说明](./frontend-examples/vue3-typescript/README.md)

```vue
<template>
  <div class="trace-query">
    <el-input v-model="productId" placeholder="输入产品ID" />
    <el-button @click="queryTrace">查询溯源</el-button>
    
    <el-timeline v-if="traceData">
      <el-timeline-item v-for="record in traceData" :key="record.id">
        <!-- 溯源时间轴 -->
      </el-timeline-item>
    </el-timeline>
  </div>
</template>
```

---

## 📚 文档导航

| 文档 | 说明 |
|------|------|
| [📖 技术栈详解](./FISCO-BCOS-HONEY-TRACEABILITY-TECH-STACK.md) | 完整的技术选型和架构设计 |
| [⚡ 快速开始](./QUICK-START.md) | 30分钟快速搭建开发环境 |
| [🚀 部署指南](./DEPLOYMENT-GUIDE.md) | 生产环境完整部署流程 |
| [💻 智能合约](./smart-contract-examples/) | Solidity合约完整代码 |
| [⚙️ 后端示例](./backend-examples/) | Spring Boot后端实现 |
| [🎨 前端示例](./frontend-examples/) | Vue 3前端实现 |

---

## 🗺️ 路线图

### Phase 1: 基础功能（已完成）✅
- [x] 智能合约开发
- [x] 基础API接口
- [x] 管理后台UI
- [x] 溯源查询功能

### Phase 2: 增强功能（进行中）🚧
- [ ] 移动端H5/小程序
- [ ] 物联网设备接入
- [ ] IPFS分布式存储
- [ ] 高级数据分析

### Phase 3: 企业级功能（规划中）📋
- [ ] 多链协同
- [ ] 隐私计算
- [ ] AI质量检测
- [ ] 供应链金融

---

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 贡献者

感谢所有为这个项目做出贡献的开发者！

---

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](./LICENSE) 文件。

---

## 📞 联系我们

- 📧 Email: support@honey-trace.com
- 💬 Issues: [GitHub Issues](https://github.com/yourusername/honey-traceability/issues)
- 📖 Wiki: [项目Wiki](https://github.com/yourusername/honey-traceability/wiki)

---

## 🌟 Star History

如果这个项目对你有帮助，请给我们一个 ⭐️ Star！

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/honey-traceability&type=Date)](https://star-history.com/#yourusername/honey-traceability&Date)

---

## 🙏 致谢

- [FISCO BCOS](https://github.com/FISCO-BCOS/FISCO-BCOS) - 提供优秀的区块链底层平台
- [Spring Boot](https://spring.io/projects/spring-boot) - 强大的Java应用框架
- [Vue.js](https://vuejs.org/) - 渐进式JavaScript框架
- [Element Plus](https://element-plus.org/) - 精美的UI组件库

---

<div align="center">

**用区块链技术守护每一滴蜂蜜的品质** 🍯

Made with ❤️ by Honey Trace Team

</div>

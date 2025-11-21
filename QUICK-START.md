# 蜂蜜溯源系统 - 快速开始指南

本指南将帮助你在30分钟内快速搭建一个基于FISCO BCOS的蜂蜜溯源系统开发环境。

## 前置条件

- 操作系统：Ubuntu 20.04+ / macOS / Windows (WSL2)
- Java JDK 11+
- Node.js 16+
- MySQL 8.0+
- Redis 6.0+
- Git

## 第一步：部署FISCO BCOS区块链 (10分钟)

```bash
# 1. 创建工作目录
mkdir -p ~/honey-trace && cd ~/honey-trace

# 2. 下载并部署区块链
curl -#LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v3.6.0/build_chain.sh
chmod +x build_chain.sh

# 3. 搭建4节点联盟链
bash build_chain.sh -l 127.0.0.1:4 -p 30300,20200

# 4. 启动所有节点
bash nodes/127.0.0.1/start_all.sh

# 5. 验证节点运行
ps aux | grep fisco-bcos
# 应该看到4个进程在运行
```

## 第二步：部署智能合约 (5分钟)

```bash
# 1. 下载控制台
cd ~/honey-trace
bash <(curl -s https://raw.githubusercontent.com/FISCO-BCOS/console/master/tools/download_console.sh)

# 2. 复制合约文件
cd console
# 将 HoneyTraceability.sol 复制到 contracts/ 目录

# 3. 启动控制台并部署合约
bash start.sh
```

在控制台中执行：
```bash
[group0]: /> deploy HoneyTraceability
# 记录返回的合约地址！例如: 0xabcd1234...
```

## 第三步：准备数据库 (5分钟)

```bash
# 1. 登录MySQL
mysql -u root -p

# 2. 创建数据库和用户
CREATE DATABASE honey_traceability CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'honey_user'@'localhost' IDENTIFIED BY 'honey123';
GRANT ALL PRIVILEGES ON honey_traceability.* TO 'honey_user'@'localhost';
FLUSH PRIVILEGES;
exit;

# 3. 启动Redis（如果未运行）
redis-server --daemonize yes
```

## 第四步：启动后端服务 (5分钟)

```bash
# 1. 克隆或创建后端项目
cd ~/honey-trace
mkdir backend && cd backend

# 2. 创建Spring Boot项目结构
# 使用 https://start.spring.io/ 生成基础项目
# 或使用IDE（IntelliJ IDEA/Eclipse）创建

# 3. 配置application.yml
cat > src/main/resources/application.yml << 'EOF'
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/honey_traceability
    username: honey_user
    password: honey123
  redis:
    host: localhost
    port: 6379

fisco:
  config-file: classpath:fisco/config.toml
  group-id: group0
  contract:
    address: 0xabcd1234...  # 替换为你的合约地址
EOF

# 4. 配置FISCO BCOS连接
mkdir -p src/main/resources/fisco
# 复制节点SDK配置文件和证书
cp ~/honey-trace/nodes/127.0.0.1/sdk/* src/main/resources/fisco/

# 5. 编译并运行
mvn clean install
mvn spring-boot:run
```

后端服务将在 http://localhost:8080 启动

## 第五步：启动前端服务 (5分钟)

```bash
# 1. 创建Vue 3项目
cd ~/honey-trace
npm create vite@latest frontend -- --template vue-ts

# 2. 安装依赖
cd frontend
npm install
npm install axios element-plus vue-router pinia

# 3. 配置环境变量
cat > .env.development << 'EOF'
VITE_API_BASE_URL=http://localhost:8080/api
VITE_APP_TITLE=蜂蜜溯源系统
EOF

# 4. 启动开发服务器
npm run dev
```

前端服务将在 http://localhost:5173 启动

## 第六步：测试系统功能 (5分钟)

### 6.1 测试API接口

使用curl或Postman测试：

```bash
# 1. 注册产品
curl -X POST http://localhost:8080/api/product/register \
  -H "Content-Type: application/json" \
  -d '{
    "productId": "HN20231201001",
    "batchNo": "BATCH001",
    "honeyType": "洋槐蜜",
    "weight": 500,
    "location": "河南省新乡市",
    "qualityGrade": "一级"
  }'

# 2. 查询产品
curl http://localhost:8080/api/product/HN20231201001

# 3. 添加质检记录
curl -X POST http://localhost:8080/api/quality/add \
  -H "Content-Type: application/json" \
  -d '{
    "productId": "HN20231201001",
    "moisture": "18.5%",
    "fructose": "42%",
    "glucose": "35%",
    "antibioticTest": true,
    "pesticideTest": true,
    "qualified": true,
    "reportUrl": "https://example.com/report.pdf"
  }'

# 4. 溯源查询
curl http://localhost:8080/api/trace/HN20231201001
```

### 6.2 通过前端测试

1. 打开浏览器访问 http://localhost:5173
2. 注册一个新产品
3. 添加生产记录
4. 添加质检记录
5. 查看溯源信息

## 快速命令参考

### 区块链操作

```bash
# 启动区块链节点
cd ~/honey-trace/nodes/127.0.0.1
bash start_all.sh

# 停止区块链节点
bash stop_all.sh

# 查看节点日志
tail -f node0/log/log_*

# 查看区块高度
cd ~/honey-trace/console
bash start.sh
# 在控制台执行: getBlockNumber
```

### 后端操作

```bash
# 启动后端
cd ~/honey-trace/backend
mvn spring-boot:run

# 查看日志
tail -f logs/application.log

# 重新编译
mvn clean package
```

### 前端操作

```bash
# 启动开发服务器
cd ~/honey-trace/frontend
npm run dev

# 构建生产版本
npm run build

# 预览生产构建
npm run preview
```

## 常见问题

### Q1: 区块链节点启动失败？

**检查端口占用**
```bash
netstat -tuln | grep -E '30300|20200'
# 如果端口被占用，停止占用进程或更换端口
```

**查看日志**
```bash
tail -f ~/honey-trace/nodes/127.0.0.1/node0/log/log_*
```

### Q2: 后端无法连接区块链？

**检查证书路径**
```bash
ls src/main/resources/fisco/
# 应该包含: ca.crt, sdk.crt, sdk.key
```

**检查config.toml配置**
```toml
[network]
peers = ["127.0.0.1:20200", "127.0.0.1:20201"]
```

### Q3: 数据库连接失败？

**测试连接**
```bash
mysql -u honey_user -p honey_traceability
# 输入密码：honey123
```

**检查用户权限**
```sql
SHOW GRANTS FOR 'honey_user'@'localhost';
```

### Q4: 前端API请求跨域？

**后端添加CORS配置**
```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("http://localhost:5173")
                .allowedMethods("*")
                .allowCredentials(true);
    }
}
```

## 下一步

完成快速开始后，你可以：

1. 📖 阅读 [技术栈详细文档](./FISCO-BCOS-HONEY-TRACEABILITY-TECH-STACK.md)
2. 🔧 查看 [完整部署指南](./DEPLOYMENT-GUIDE.md)
3. 💻 参考 [代码示例](./backend-examples/)和[前端示例](./frontend-examples/)
4. 🎨 自定义UI设计和业务流程
5. 📱 开发移动端或小程序版本

## 学习资源

- [FISCO BCOS官方文档](https://fisco-bcos-doc.readthedocs.io/)
- [Spring Boot文档](https://spring.io/projects/spring-boot)
- [Vue 3文档](https://vuejs.org/)
- [Element Plus组件库](https://element-plus.org/)
- [Solidity文档](https://docs.soliditylang.org/)

## 获取帮助

- GitHub Issues: 提交问题和建议
- 技术论坛: FISCO BCOS社区
- 开发文档: 查看项目Wiki

---

🎉 恭喜！你已经成功搭建了蜂蜜溯源系统开发环境！

现在可以开始开发你的区块链溯源应用了。

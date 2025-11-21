# FISCO BCOS 蜂蜜溯源系统部署指南

## 一、环境准备

### 1.1 硬件要求

**开发环境**
- CPU: 2核及以上
- 内存: 4GB及以上
- 硬盘: 40GB及以上

**生产环境**
- CPU: 4核及以上
- 内存: 8GB及以上
- 硬盘: 100GB及以上（建议SSD）

### 1.2 软件要求

```bash
# 操作系统
Ubuntu 18.04/20.04/22.04 或 CentOS 7/8

# Java环境
OpenJDK 11+ 或 Oracle JDK 11+

# Node.js环境（前端）
Node.js 16+ 
npm 8+ 或 yarn

# 数据库
MySQL 8.0+
Redis 6.0+

# 其他工具
Git
Docker (可选)
Nginx
```

## 二、FISCO BCOS链部署

### 2.1 下载建链脚本

```bash
# 创建工作目录
mkdir -p ~/fisco && cd ~/fisco

# 下载建链脚本
curl -#LO https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v3.6.0/build_chain.sh

# 添加执行权限
chmod +x build_chain.sh
```

### 2.2 单机4节点部署（开发/测试）

```bash
# 生成4节点联盟链
bash build_chain.sh -l 127.0.0.1:4 -p 30300,20200

# 启动所有节点
bash nodes/127.0.0.1/start_all.sh

# 检查节点状态
ps aux | grep fisco-bcos

# 查看节点日志
tail -f nodes/127.0.0.1/node0/log/log* | grep "g:1"
```

### 2.3 多机部署（生产环境）

创建节点配置文件 `node_deployment.ini`：

```ini
[group]
group_id=1

# 节点列表
[node0]
p2p_ip=192.168.1.101
rpc_ip=127.0.0.1
p2p_listen_port=30300
channel_listen_port=20200
jsonrpc_listen_port=8545

[node1]
p2p_ip=192.168.1.102
rpc_ip=127.0.0.1
p2p_listen_port=30300
channel_listen_port=20200
jsonrpc_listen_port=8545

[node2]
p2p_ip=192.168.1.103
rpc_ip=127.0.0.1
p2p_listen_port=30300
channel_listen_port=20200
jsonrpc_listen_port=8545

[node3]
p2p_ip=192.168.1.104
rpc_ip=127.0.0.1
p2p_listen_port=30300
channel_listen_port=20200
jsonrpc_listen_port=8545
```

执行建链：

```bash
bash build_chain.sh -f node_deployment.ini -e /usr/local/bin/fisco-bcos
```

### 2.4 验证链运行状态

```bash
# 下载控制台
cd ~/fisco && bash <(curl -s https://raw.githubusercontent.com/FISCO-BCOS/console/master/tools/download_console.sh)

# 配置控制台
cd console && cp -n conf/config-example.toml conf/config.toml

# 启动控制台
bash start.sh

# 在控制台中执行
[group0]: /> getBlockNumber
# 输出: 0 或更大的数字表示链正常运行

[group0]: /> getPeers
# 查看连接的节点
```

## 三、智能合约部署

### 3.1 准备合约

```bash
# 将合约复制到控制台contracts目录
cp smart-contract-examples/HoneyTraceability.sol ~/fisco/console/contracts/
```

### 3.2 编译合约

```bash
cd ~/fisco/console

# 编译合约
bash sol2java.sh -s contracts/HoneyTraceability.sol -p com.honey.traceability.contract
```

### 3.3 部署合约

在控制台中执行：

```bash
[group0]: /> deploy HoneyTraceability
# 记录返回的合约地址，例如：0x1234567890abcdef...
```

或使用Java代码部署：

```java
// 在后端项目中
HoneyTraceability contract = HoneyTraceability.deploy(client, cryptoKeyPair);
String contractAddress = contract.getContractAddress();
System.out.println("合约地址: " + contractAddress);
```

## 四、数据库部署

### 4.1 MySQL安装与配置

```bash
# Ubuntu安装MySQL
sudo apt update
sudo apt install mysql-server

# 启动MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# 安全配置
sudo mysql_secure_installation
```

### 4.2 创建数据库

```sql
-- 登录MySQL
mysql -u root -p

-- 创建数据库
CREATE DATABASE honey_traceability CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建用户并授权
CREATE USER 'honey_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON honey_traceability.* TO 'honey_user'@'localhost';
FLUSH PRIVILEGES;

-- 使用数据库
USE honey_traceability;

-- 创建用户表
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL,
  `blockchain_address` varchar(64),
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建产品缓存表（链下数据）
CREATE TABLE `products_cache` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `product_id` varchar(64) NOT NULL,
  `batch_no` varchar(64),
  `honey_type` varchar(50),
  `weight` int,
  `location` varchar(100),
  `quality_grade` varchar(20),
  `status` tinyint,
  `producer_address` varchar(64),
  `production_date` timestamp,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_product_id` (`product_id`),
  KEY `idx_producer` (`producer_address`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 4.3 Redis安装与配置

```bash
# Ubuntu安装Redis
sudo apt install redis-server

# 配置Redis
sudo nano /etc/redis/redis.conf

# 修改以下配置：
# bind 127.0.0.1
# requirepass your_strong_password
# maxmemory 512mb
# maxmemory-policy allkeys-lru

# 重启Redis
sudo systemctl restart redis
sudo systemctl enable redis

# 测试连接
redis-cli
> AUTH your_strong_password
> PING
# 返回 PONG 表示正常
```

## 五、后端部署

### 5.1 配置文件

编辑 `application-prod.yml`：

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/honey_traceability?useSSL=true&characterEncoding=utf8
    username: honey_user
    password: strong_password
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  redis:
    host: localhost
    port: 6379
    password: your_strong_password
    database: 0

fisco:
  config-file: classpath:fisco/config.toml
  group-id: group0
  contract:
    address: 0x1234567890abcdef...  # 替换为实际合约地址

# 日志配置
logging:
  level:
    root: INFO
    com.honey.traceability: DEBUG
  file:
    name: /var/log/honey-trace/application.log
```

配置FISCO BCOS连接 `config.toml`：

```toml
[cryptoMaterial]
certPath = "conf"

[network]
peers = ["127.0.0.1:20200", "127.0.0.1:20201"]

[account]
keyStoreDir = "account"
accountAddress = ""
accountFileFormat = "pem"
password = ""
accountFilePath = ""

[threadPool]
channelProcessorThreadSize = 16
receiptProcessorThreadSize = 16
maxBlockingQueueSize = 102400
```

### 5.2 编译和打包

```bash
# 编译项目
mvn clean package -DskipTests

# 或使用Gradle
./gradlew clean build
```

### 5.3 部署运行

```bash
# 创建部署目录
sudo mkdir -p /opt/honey-trace
sudo chown -R $USER:$USER /opt/honey-trace

# 复制jar包
cp target/honey-traceability-1.0.0.jar /opt/honey-trace/

# 复制配置文件和证书
cp -r src/main/resources/fisco /opt/honey-trace/conf/

# 创建启动脚本
cat > /opt/honey-trace/start.sh << 'EOF'
#!/bin/bash
APP_NAME="honey-traceability"
JAR_NAME="honey-traceability-1.0.0.jar"
JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"

nohup java $JAVA_OPTS -jar $JAR_NAME --spring.profiles.active=prod > application.log 2>&1 &
echo $! > app.pid
echo "Application started with PID: $(cat app.pid)"
EOF

chmod +x /opt/honey-trace/start.sh

# 创建停止脚本
cat > /opt/honey-trace/stop.sh << 'EOF'
#!/bin/bash
if [ -f app.pid ]; then
    kill $(cat app.pid)
    rm -f app.pid
    echo "Application stopped"
else
    echo "PID file not found"
fi
EOF

chmod +x /opt/honey-trace/stop.sh

# 启动应用
cd /opt/honey-trace
./start.sh

# 查看日志
tail -f application.log
```

### 5.4 配置systemd服务（推荐）

```bash
# 创建服务文件
sudo nano /etc/systemd/system/honey-trace.service

# 添加以下内容：
[Unit]
Description=Honey Traceability Backend Service
After=network.target mysql.service redis.service

[Service]
Type=simple
User=honey
WorkingDirectory=/opt/honey-trace
ExecStart=/usr/bin/java -Xms512m -Xmx1024m -jar /opt/honey-trace/honey-traceability-1.0.0.jar --spring.profiles.active=prod
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target

# 重载systemd
sudo systemctl daemon-reload

# 启动服务
sudo systemctl start honey-trace
sudo systemctl enable honey-trace

# 查看状态
sudo systemctl status honey-trace

# 查看日志
sudo journalctl -u honey-trace -f
```

## 六、前端部署

### 6.1 编译前端

```bash
cd frontend

# 安装依赖
npm install

# 配置生产环境变量
cat > .env.production << 'EOF'
VITE_API_BASE_URL=https://api.honey-trace.com/api
VITE_APP_TITLE=蜂蜜溯源系统
EOF

# 构建生产版本
npm run build

# 构建产物在 dist 目录
```

### 6.2 Nginx配置

```bash
# 安装Nginx
sudo apt install nginx

# 创建站点配置
sudo nano /etc/nginx/sites-available/honey-trace

# 添加以下配置：
server {
    listen 80;
    server_name honey-trace.com www.honey-trace.com;
    
    # 重定向到HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name honey-trace.com www.honey-trace.com;
    
    # SSL证书配置
    ssl_certificate /etc/nginx/ssl/honey-trace.crt;
    ssl_certificate_key /etc/nginx/ssl/honey-trace.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # 前端静态文件
    root /var/www/honey-trace/dist;
    index index.html;
    
    # Gzip压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API代理
    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket支持（如需要）
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # 静态资源缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}

# 启用站点
sudo ln -s /etc/nginx/sites-available/honey-trace /etc/nginx/sites-enabled/

# 创建前端目录
sudo mkdir -p /var/www/honey-trace

# 复制构建产物
sudo cp -r dist/* /var/www/honey-trace/

# 测试Nginx配置
sudo nginx -t

# 重启Nginx
sudo systemctl restart nginx
```

## 七、Docker部署（可选）

### 7.1 创建Dockerfile

**后端Dockerfile**:

```dockerfile
FROM openjdk:11-jre-slim
WORKDIR /app
COPY target/honey-traceability-1.0.0.jar app.jar
COPY src/main/resources/fisco /app/conf/fisco
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar", "--spring.profiles.active=prod"]
```

**前端Dockerfile**:

```dockerfile
FROM node:16-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 7.2 Docker Compose配置

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: honey-mysql
    environment:
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: honey_traceability
      MYSQL_USER: honey_user
      MYSQL_PASSWORD: strong_password
    volumes:
      - mysql-data:/var/lib/mysql
    ports:
      - "3306:3306"
    networks:
      - honey-network

  redis:
    image: redis:6-alpine
    container_name: honey-redis
    command: redis-server --requirepass your_strong_password
    volumes:
      - redis-data:/data
    ports:
      - "6379:6379"
    networks:
      - honey-network

  backend:
    build: ./backend
    container_name: honey-backend
    environment:
      SPRING_PROFILES_ACTIVE: prod
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/honey_traceability
      SPRING_REDIS_HOST: redis
    ports:
      - "8080:8080"
    depends_on:
      - mysql
      - redis
    networks:
      - honey-network
    volumes:
      - ./fisco:/app/conf/fisco

  frontend:
    build: ./frontend
    container_name: honey-frontend
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
    networks:
      - honey-network

volumes:
  mysql-data:
  redis-data:

networks:
  honey-network:
    driver: bridge
```

启动所有服务：

```bash
docker-compose up -d
```

## 八、监控与运维

### 8.1 日志管理

```bash
# 后端日志
tail -f /opt/honey-trace/application.log

# Nginx访问日志
tail -f /var/log/nginx/access.log

# Nginx错误日志
tail -f /var/log/nginx/error.log

# FISCO BCOS节点日志
tail -f ~/fisco/nodes/127.0.0.1/node0/log/log*
```

### 8.2 性能监控

使用Prometheus + Grafana:

```bash
# 在Spring Boot中添加actuator依赖
# pom.xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>

# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
```

### 8.3 备份策略

```bash
# MySQL备份脚本
#!/bin/bash
BACKUP_DIR="/backup/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u honey_user -p honey_traceability > $BACKUP_DIR/backup_$DATE.sql
# 保留最近7天的备份
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete

# 区块链数据备份
tar -czf /backup/fisco_$(date +%Y%m%d).tar.gz ~/fisco/nodes
```

## 九、安全加固

### 9.1 防火墙配置

```bash
# Ubuntu UFW
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# FISCO BCOS节点端口（仅内网）
sudo ufw allow from 192.168.1.0/24 to any port 30300
sudo ufw allow from 192.168.1.0/24 to any port 20200
```

### 9.2 SSL证书

```bash
# 使用Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d honey-trace.com -d www.honey-trace.com
```

## 十、故障排查

### 10.1 常见问题

**问题1: 无法连接区块链节点**
```bash
# 检查节点是否运行
ps aux | grep fisco-bcos

# 检查端口是否开放
netstat -tuln | grep 20200

# 查看节点日志
tail -f ~/fisco/nodes/127.0.0.1/node0/log/log*
```

**问题2: 智能合约调用失败**
```bash
# 检查合约地址是否正确
# 检查账户权限
# 查看交易回执错误信息
```

**问题3: 数据库连接失败**
```bash
# 检查MySQL是否运行
sudo systemctl status mysql

# 测试连接
mysql -u honey_user -p -h localhost honey_traceability
```

---

## 附录：完整部署检查清单

- [ ] FISCO BCOS链启动正常
- [ ] 智能合约部署成功
- [ ] MySQL数据库创建并配置
- [ ] Redis启动正常
- [ ] 后端服务启动成功
- [ ] 前端构建并部署
- [ ] Nginx配置正确
- [ ] SSL证书配置
- [ ] 防火墙规则设置
- [ ] 日志轮转配置
- [ ] 备份脚本配置
- [ ] 监控告警配置

祝部署顺利！🎉

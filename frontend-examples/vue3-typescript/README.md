# 蜂蜜溯源系统 - Vue 3 + TypeScript 前端

## 技术栈

- **Vue 3** - 渐进式框架
- **TypeScript** - 类型安全
- **Vite** - 构建工具
- **Element Plus** - UI组件库
- **Vue Router** - 路由管理
- **Pinia** - 状态管理
- **Axios** - HTTP客户端
- **ECharts** - 数据可视化

## 项目结构

```
honey-trace-frontend/
├── public/
│   └── favicon.ico
├── src/
│   ├── api/                    # API接口
│   │   ├── product.ts
│   │   ├── quality.ts
│   │   ├── logistics.ts
│   │   └── trace.ts
│   ├── assets/                 # 静态资源
│   │   ├── logo.png
│   │   └── styles/
│   ├── components/             # 公共组件
│   │   ├── Header.vue
│   │   ├── Sidebar.vue
│   │   ├── QRCodeScanner.vue
│   │   └── TraceTimeline.vue
│   ├── views/                  # 页面视图
│   │   ├── Dashboard.vue
│   │   ├── ProductList.vue
│   │   ├── ProductRegister.vue
│   │   ├── QualityInspection.vue
│   │   ├── LogisticsTracking.vue
│   │   ├── TraceQuery.vue
│   │   └── Statistics.vue
│   ├── router/                 # 路由配置
│   │   └── index.ts
│   ├── stores/                 # 状态管理
│   │   ├── user.ts
│   │   └── product.ts
│   ├── types/                  # TypeScript类型定义
│   │   ├── product.ts
│   │   └── api.ts
│   ├── utils/                  # 工具函数
│   │   ├── request.ts
│   │   ├── auth.ts
│   │   └── format.ts
│   ├── App.vue
│   └── main.ts
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 开发环境运行

```bash
npm run dev
```

### 3. 生产构建

```bash
npm run build
```

## 主要功能模块

### 1. 产品管理
- 产品注册
- 产品列表
- 产品详情

### 2. 质检管理
- 质检记录录入
- 质检报告上传
- 质检结果查询

### 3. 物流跟踪
- 物流信息录入
- 物流状态更新
- 物流轨迹展示

### 4. 溯源查询
- 扫码查询
- 产品ID查询
- 溯源信息展示
- 区块链验证

### 5. 数据统计
- 产品统计
- 质量分析
- 销售报表

## 环境变量配置

创建 `.env.development` 文件：

```env
VITE_API_BASE_URL=http://localhost:8080/api
VITE_APP_TITLE=蜂蜜溯源系统
```

创建 `.env.production` 文件：

```env
VITE_API_BASE_URL=https://api.honey-trace.com/api
VITE_APP_TITLE=蜂蜜溯源系统
```

## 核心代码示例

详见具体代码文件。

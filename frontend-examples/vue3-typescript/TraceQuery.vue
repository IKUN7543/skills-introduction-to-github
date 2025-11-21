<template>
  <div class="trace-query">
    <el-card class="search-card">
      <el-row :gutter="20">
        <el-col :span="18">
          <el-input
            v-model="productId"
            placeholder="请输入产品ID或扫描二维码"
            size="large"
            clearable
            @keyup.enter="queryTrace"
          >
            <template #prepend>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </el-col>
        <el-col :span="3">
          <el-button 
            type="primary" 
            size="large" 
            @click="queryTrace"
            :loading="loading"
          >
            查询溯源
          </el-button>
        </el-col>
        <el-col :span="3">
          <el-button 
            size="large" 
            @click="openQRScanner"
            :icon="CameraFilled"
          >
            扫码
          </el-button>
        </el-col>
      </el-row>
    </el-card>

    <!-- 产品基本信息 -->
    <el-card v-if="traceData" class="info-card" style="margin-top: 20px;">
      <template #header>
        <div class="card-header">
          <span class="title">
            <el-icon><Box /></el-icon>
            产品基本信息
          </span>
          <el-tag 
            :type="getStatusType(traceData.product.status)" 
            size="large"
          >
            {{ getStatusText(traceData.product.status) }}
          </el-tag>
        </div>
      </template>

      <el-row :gutter="20">
        <el-col :span="12">
          <el-descriptions :column="1" border>
            <el-descriptions-item label="产品ID">
              {{ traceData.product.productId }}
            </el-descriptions-item>
            <el-descriptions-item label="批次号">
              {{ traceData.product.batchNo }}
            </el-descriptions-item>
            <el-descriptions-item label="蜂蜜类型">
              {{ traceData.product.honeyType }}
            </el-descriptions-item>
            <el-descriptions-item label="重量">
              {{ traceData.product.weight }}g
            </el-descriptions-item>
          </el-descriptions>
        </el-col>
        <el-col :span="12">
          <el-descriptions :column="1" border>
            <el-descriptions-item label="产地">
              {{ traceData.product.location }}
            </el-descriptions-item>
            <el-descriptions-item label="质量等级">
              <el-rate 
                v-model="gradeValue" 
                disabled 
                show-text
                :texts="['差', '一般', '良好', '优秀', '特级']"
              />
            </el-descriptions-item>
            <el-descriptions-item label="生产日期">
              {{ formatDate(traceData.product.productionDate) }}
            </el-descriptions-item>
            <el-descriptions-item label="生产者">
              {{ traceData.product.producer }}
            </el-descriptions-item>
          </el-descriptions>
        </el-col>
      </el-row>

      <!-- 区块链验证结果 -->
      <el-alert
        v-if="traceData.verified"
        title="✓ 区块链验证通过"
        type="success"
        :description="traceData.verificationMessage"
        show-icon
        :closable="false"
        style="margin-top: 20px;"
      />
      <el-alert
        v-else
        title="✗ 验证失败"
        type="error"
        :description="traceData.verificationMessage"
        show-icon
        :closable="false"
        style="margin-top: 20px;"
      />
    </el-card>

    <!-- 溯源时间轴 -->
    <el-card v-if="traceData" class="timeline-card" style="margin-top: 20px;">
      <template #header>
        <span class="title">
          <el-icon><Clock /></el-icon>
          溯源时间轴
        </span>
      </template>

      <el-timeline>
        <!-- 生产记录 -->
        <el-timeline-item
          v-for="(record, index) in traceData.productionRecords"
          :key="`prod-${index}`"
          :timestamp="formatDate(record.timestamp)"
          placement="top"
          type="success"
          :icon="Sunrise"
        >
          <el-card>
            <h4>生产记录</h4>
            <p><strong>蜂场：</strong>{{ record.apiary }}</p>
            <p><strong>采蜜日期：</strong>{{ formatDate(record.harvestDate) }}</p>
            <p><strong>天气：</strong>{{ record.weather }}</p>
            <p><strong>温度：</strong>{{ record.temperature }}°C</p>
            <p><strong>湿度：</strong>{{ record.humidity }}%</p>
            <p><strong>蜂农：</strong>{{ record.beekeeper }}</p>
            <p v-if="record.notes"><strong>备注：</strong>{{ record.notes }}</p>
          </el-card>
        </el-timeline-item>

        <!-- 质检记录 -->
        <el-timeline-item
          v-for="(record, index) in traceData.qualityRecords"
          :key="`qual-${index}`"
          :timestamp="formatDate(record.timestamp)"
          placement="top"
          :type="record.qualified ? 'success' : 'danger'"
          :icon="DocumentChecked"
        >
          <el-card>
            <h4>
              质检记录
              <el-tag :type="record.qualified ? 'success' : 'danger'" style="margin-left: 10px;">
                {{ record.qualified ? '合格' : '不合格' }}
              </el-tag>
            </h4>
            <el-row :gutter="10">
              <el-col :span="12">
                <p><strong>水分含量：</strong>{{ record.moisture }}</p>
                <p><strong>果糖含量：</strong>{{ record.fructose }}</p>
                <p><strong>葡萄糖含量：</strong>{{ record.glucose }}</p>
              </el-col>
              <el-col :span="12">
                <p>
                  <strong>抗生素检测：</strong>
                  <el-tag :type="record.antibioticTest ? 'success' : 'danger'" size="small">
                    {{ record.antibioticTest ? '通过' : '未通过' }}
                  </el-tag>
                </p>
                <p>
                  <strong>农药残留检测：</strong>
                  <el-tag :type="record.pesticideTest ? 'success' : 'danger'" size="small">
                    {{ record.pesticideTest ? '通过' : '未通过' }}
                  </el-tag>
                </p>
                <p><strong>质检员：</strong>{{ record.inspector }}</p>
              </el-col>
            </el-row>
            <el-button 
              v-if="record.reportUrl" 
              type="primary" 
              link 
              @click="viewReport(record.reportUrl)"
            >
              查看质检报告
            </el-button>
          </el-card>
        </el-timeline-item>

        <!-- 物流记录 -->
        <el-timeline-item
          v-for="(record, index) in traceData.logisticsRecords"
          :key="`log-${index}`"
          :timestamp="formatDate(record.timestamp)"
          placement="top"
          type="primary"
          :icon="Van"
        >
          <el-card>
            <h4>
              物流记录
              <el-tag :type="getLogisticsStatusType(record.status)" style="margin-left: 10px;">
                {{ getLogisticsStatusText(record.status) }}
              </el-tag>
            </h4>
            <p><strong>物流单号：</strong>{{ record.trackingNo }}</p>
            <p><strong>发货地：</strong>{{ record.from }}</p>
            <p><strong>目的地：</strong>{{ record.to }}</p>
            <p><strong>发货时间：</strong>{{ formatDate(record.departureTime) }}</p>
            <p v-if="record.arrivalTime">
              <strong>到达时间：</strong>{{ formatDate(record.arrivalTime) }}
            </p>
            <p><strong>承运商：</strong>{{ record.carrier }}</p>
          </el-card>
        </el-timeline-item>

        <!-- 销售记录 -->
        <el-timeline-item
          v-for="(record, index) in traceData.salesRecords"
          :key="`sale-${index}`"
          :timestamp="formatDate(record.timestamp)"
          placement="top"
          type="warning"
          :icon="ShoppingCart"
        >
          <el-card>
            <h4>销售记录</h4>
            <p><strong>销售日期：</strong>{{ formatDate(record.saleDate) }}</p>
            <p><strong>销售价格：</strong>¥{{ (record.price / 100).toFixed(2) }}</p>
            <p><strong>销售渠道：</strong>{{ record.channel }}</p>
            <p><strong>销售商：</strong>{{ record.seller }}</p>
            <p v-if="record.buyer"><strong>购买者：</strong>{{ record.buyer }}</p>
          </el-card>
        </el-timeline-item>
      </el-timeline>
    </el-card>

    <!-- 区块链交易信息 -->
    <el-card v-if="traceData" class="blockchain-card" style="margin-top: 20px;">
      <template #header>
        <span class="title">
          <el-icon><Link /></el-icon>
          区块链交易信息
        </span>
      </template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="区块链网络">FISCO BCOS</el-descriptions-item>
        <el-descriptions-item label="合约地址">
          <el-link type="primary" @click="viewContract">
            {{ contractAddress }}
          </el-link>
        </el-descriptions-item>
        <el-descriptions-item label="数据哈希">
          {{ traceData.dataHash }}
        </el-descriptions-item>
        <el-descriptions-item label="上链时间">
          {{ formatDate(traceData.onChainTime) }}
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 二维码扫描对话框 -->
    <el-dialog 
      v-model="scannerVisible" 
      title="扫描产品二维码" 
      width="500px"
      center
    >
      <qr-code-scanner @scan="onScan" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  Search, CameraFilled, Box, Clock, Sunrise, 
  DocumentChecked, Van, ShoppingCart, Link 
} from '@element-plus/icons-vue'
import { getTraceInfo } from '@/api/trace'
import QRCodeScanner from '@/components/QRCodeScanner.vue'
import type { TraceData } from '@/types/trace'

const productId = ref('')
const loading = ref(false)
const traceData = ref<TraceData | null>(null)
const scannerVisible = ref(false)
const contractAddress = '0x1234567890abcdef...'

const gradeValue = computed(() => {
  const grade = traceData.value?.product.qualityGrade
  const gradeMap: Record<string, number> = {
    '三级': 2,
    '二级': 3,
    '一级': 4,
    '特级': 5
  }
  return gradeMap[grade || ''] || 3
})

const queryTrace = async () => {
  if (!productId.value) {
    ElMessage.warning('请输入产品ID')
    return
  }

  loading.value = true
  try {
    const response = await getTraceInfo(productId.value)
    if (response.code === 200) {
      traceData.value = response.data
      ElMessage.success('查询成功')
    } else {
      ElMessage.error(response.message || '查询失败')
    }
  } catch (error) {
    ElMessage.error('查询失败，请稍后重试')
  } finally {
    loading.value = false
  }
}

const openQRScanner = () => {
  scannerVisible.value = true
}

const onScan = (code: string) => {
  productId.value = code
  scannerVisible.value = false
  queryTrace()
}

const formatDate = (timestamp: number) => {
  return new Date(timestamp * 1000).toLocaleString('zh-CN')
}

const getStatusType = (status: number) => {
  const types = ['', 'success', 'primary', 'warning', '']
  return types[status] || ''
}

const getStatusText = (status: number) => {
  const texts = ['已生产', '已质检', '运输中', '已入库', '已售出']
  return texts[status] || '未知'
}

const getLogisticsStatusType = (status: number) => {
  const types = ['info', 'primary', 'success']
  return types[status] || 'info'
}

const getLogisticsStatusText = (status: number) => {
  const texts = ['待发货', '运输中', '已送达']
  return texts[status] || '未知'
}

const viewReport = (url: string) => {
  window.open(url, '_blank')
}

const viewContract = () => {
  // 打开区块链浏览器查看合约
  window.open(`https://fisco-bcos-browser.com/contract/${contractAddress}`, '_blank')
}
</script>

<style scoped lang="scss">
.trace-query {
  padding: 20px;

  .search-card {
    margin-bottom: 20px;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .title {
      display: flex;
      align-items: center;
      font-size: 18px;
      font-weight: bold;

      .el-icon {
        margin-right: 8px;
      }
    }
  }

  .el-timeline-item {
    padding-bottom: 30px;

    h4 {
      margin: 0 0 15px 0;
      display: flex;
      align-items: center;
    }

    p {
      margin: 8px 0;
      line-height: 1.6;
    }
  }

  .blockchain-card {
    .el-link {
      font-family: monospace;
    }
  }
}
</style>

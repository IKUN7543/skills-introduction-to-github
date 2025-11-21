// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 蜂蜜溯源智能合约
 * @dev 实现蜂蜜从生产到销售的全流程追溯
 */
contract HoneyTraceability {
    
    // 蜂蜜产品结构
    struct HoneyProduct {
        string productId;           // 产品ID
        string batchNo;             // 批次号
        address producer;           // 生产者地址
        uint256 productionDate;     // 生产日期时间戳
        string honeyType;           // 蜂蜜类型（洋槐蜜、枣花蜜等）
        uint256 weight;             // 重量（克）
        string location;            // 产地
        string qualityGrade;        // 质量等级
        ProductStatus status;       // 产品状态
        bool exists;                // 是否存在
    }
    
    // 生产记录
    struct ProductionRecord {
        string productId;
        address beekeeper;          // 蜂农
        string apiary;              // 蜂场
        uint256 harvestDate;        // 采蜜日期
        string weather;             // 天气状况
        uint256 temperature;        // 温度
        uint256 humidity;           // 湿度
        string notes;               // 备注
        uint256 timestamp;
    }
    
    // 质检记录
    struct QualityRecord {
        string productId;
        address inspector;          // 质检员
        uint256 inspectionDate;     // 质检日期
        string moisture;            // 水分含量
        string fructose;            // 果糖含量
        string glucose;             // 葡萄糖含量
        bool antibioticTest;        // 抗生素检测
        bool pesticideTest;         // 农药残留检测
        bool qualified;             // 是否合格
        string reportUrl;           // 质检报告URL（IPFS）
        uint256 timestamp;
    }
    
    // 物流记录
    struct LogisticsRecord {
        string productId;
        address carrier;            // 承运商
        string from;                // 发货地
        string to;                  // 目的地
        uint256 departureTime;      // 发货时间
        uint256 arrivalTime;        // 到达时间
        string trackingNo;          // 物流单号
        LogisticsStatus status;     // 物流状态
        uint256 timestamp;
    }
    
    // 销售记录
    struct SalesRecord {
        string productId;
        address seller;             // 销售商
        address buyer;              // 购买者（可选）
        uint256 saleDate;           // 销售日期
        uint256 price;              // 销售价格
        string channel;             // 销售渠道
        uint256 timestamp;
    }
    
    // 产品状态枚举
    enum ProductStatus {
        Produced,       // 已生产
        QualityChecked, // 已质检
        InTransit,      // 运输中
        InStock,        // 已入库
        Sold            // 已售出
    }
    
    // 物流状态枚举
    enum LogisticsStatus {
        Pending,        // 待发货
        InTransit,      // 运输中
        Delivered       // 已送达
    }
    
    // 用户角色
    enum UserRole {
        None,
        Producer,       // 生产者
        Inspector,      // 质检员
        Carrier,        // 承运商
        Seller,         // 销售商
        Consumer,       // 消费者
        Admin           // 管理员
    }
    
    // 状态变量
    mapping(string => HoneyProduct) public products;
    mapping(string => ProductionRecord[]) public productionRecords;
    mapping(string => QualityRecord[]) public qualityRecords;
    mapping(string => LogisticsRecord[]) public logisticsRecords;
    mapping(string => SalesRecord[]) public salesRecords;
    mapping(address => UserRole) public userRoles;
    mapping(address => string) public userNames;
    
    address public admin;
    string[] public productIds;
    
    // 事件
    event ProductRegistered(string indexed productId, address indexed producer, uint256 timestamp);
    event ProductionRecordAdded(string indexed productId, address indexed beekeeper, uint256 timestamp);
    event QualityRecordAdded(string indexed productId, address indexed inspector, bool qualified, uint256 timestamp);
    event LogisticsRecordAdded(string indexed productId, address indexed carrier, string trackingNo, uint256 timestamp);
    event SalesRecordAdded(string indexed productId, address indexed seller, uint256 timestamp);
    event StatusUpdated(string indexed productId, ProductStatus status, uint256 timestamp);
    event UserRoleAssigned(address indexed user, UserRole role, uint256 timestamp);
    
    // 修饰器
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
    
    modifier onlyProducer() {
        require(userRoles[msg.sender] == UserRole.Producer || userRoles[msg.sender] == UserRole.Admin, 
                "Only producer can call this function");
        _;
    }
    
    modifier onlyInspector() {
        require(userRoles[msg.sender] == UserRole.Inspector || userRoles[msg.sender] == UserRole.Admin,
                "Only inspector can call this function");
        _;
    }
    
    modifier onlyCarrier() {
        require(userRoles[msg.sender] == UserRole.Carrier || userRoles[msg.sender] == UserRole.Admin,
                "Only carrier can call this function");
        _;
    }
    
    modifier onlySeller() {
        require(userRoles[msg.sender] == UserRole.Seller || userRoles[msg.sender] == UserRole.Admin,
                "Only seller can call this function");
        _;
    }
    
    modifier productExists(string memory _productId) {
        require(products[_productId].exists, "Product does not exist");
        _;
    }
    
    // 构造函数
    constructor() {
        admin = msg.sender;
        userRoles[msg.sender] = UserRole.Admin;
        userNames[msg.sender] = "System Administrator";
    }
    
    /**
     * @dev 分配用户角色（仅管理员）
     */
    function assignUserRole(address _user, UserRole _role, string memory _name) public onlyAdmin {
        require(_user != address(0), "Invalid address");
        userRoles[_user] = _role;
        userNames[_user] = _name;
        emit UserRoleAssigned(_user, _role, block.timestamp);
    }
    
    /**
     * @dev 注册蜂蜜产品
     */
    function registerProduct(
        string memory _productId,
        string memory _batchNo,
        string memory _honeyType,
        uint256 _weight,
        string memory _location,
        string memory _qualityGrade
    ) public onlyProducer {
        require(!products[_productId].exists, "Product already exists");
        require(bytes(_productId).length > 0, "Product ID cannot be empty");
        
        products[_productId] = HoneyProduct({
            productId: _productId,
            batchNo: _batchNo,
            producer: msg.sender,
            productionDate: block.timestamp,
            honeyType: _honeyType,
            weight: _weight,
            location: _location,
            qualityGrade: _qualityGrade,
            status: ProductStatus.Produced,
            exists: true
        });
        
        productIds.push(_productId);
        
        emit ProductRegistered(_productId, msg.sender, block.timestamp);
        emit StatusUpdated(_productId, ProductStatus.Produced, block.timestamp);
    }
    
    /**
     * @dev 添加生产记录
     */
    function addProductionRecord(
        string memory _productId,
        string memory _apiary,
        string memory _weather,
        uint256 _temperature,
        uint256 _humidity,
        string memory _notes
    ) public onlyProducer productExists(_productId) {
        ProductionRecord memory record = ProductionRecord({
            productId: _productId,
            beekeeper: msg.sender,
            apiary: _apiary,
            harvestDate: block.timestamp,
            weather: _weather,
            temperature: _temperature,
            humidity: _humidity,
            notes: _notes,
            timestamp: block.timestamp
        });
        
        productionRecords[_productId].push(record);
        
        emit ProductionRecordAdded(_productId, msg.sender, block.timestamp);
    }
    
    /**
     * @dev 添加质检记录
     */
    function addQualityRecord(
        string memory _productId,
        string memory _moisture,
        string memory _fructose,
        string memory _glucose,
        bool _antibioticTest,
        bool _pesticideTest,
        bool _qualified,
        string memory _reportUrl
    ) public onlyInspector productExists(_productId) {
        QualityRecord memory record = QualityRecord({
            productId: _productId,
            inspector: msg.sender,
            inspectionDate: block.timestamp,
            moisture: _moisture,
            fructose: _fructose,
            glucose: _glucose,
            antibioticTest: _antibioticTest,
            pesticideTest: _pesticideTest,
            qualified: _qualified,
            reportUrl: _reportUrl,
            timestamp: block.timestamp
        });
        
        qualityRecords[_productId].push(record);
        
        if (_qualified) {
            products[_productId].status = ProductStatus.QualityChecked;
            emit StatusUpdated(_productId, ProductStatus.QualityChecked, block.timestamp);
        }
        
        emit QualityRecordAdded(_productId, msg.sender, _qualified, block.timestamp);
    }
    
    /**
     * @dev 添加物流记录
     */
    function addLogisticsRecord(
        string memory _productId,
        string memory _from,
        string memory _to,
        string memory _trackingNo
    ) public onlyCarrier productExists(_productId) {
        LogisticsRecord memory record = LogisticsRecord({
            productId: _productId,
            carrier: msg.sender,
            from: _from,
            to: _to,
            departureTime: block.timestamp,
            arrivalTime: 0,
            trackingNo: _trackingNo,
            status: LogisticsStatus.InTransit,
            timestamp: block.timestamp
        });
        
        logisticsRecords[_productId].push(record);
        products[_productId].status = ProductStatus.InTransit;
        
        emit LogisticsRecordAdded(_productId, msg.sender, _trackingNo, block.timestamp);
        emit StatusUpdated(_productId, ProductStatus.InTransit, block.timestamp);
    }
    
    /**
     * @dev 更新物流状态
     */
    function updateLogisticsStatus(
        string memory _productId,
        uint256 _recordIndex,
        LogisticsStatus _status
    ) public onlyCarrier productExists(_productId) {
        require(_recordIndex < logisticsRecords[_productId].length, "Invalid record index");
        
        logisticsRecords[_productId][_recordIndex].status = _status;
        
        if (_status == LogisticsStatus.Delivered) {
            logisticsRecords[_productId][_recordIndex].arrivalTime = block.timestamp;
            products[_productId].status = ProductStatus.InStock;
            emit StatusUpdated(_productId, ProductStatus.InStock, block.timestamp);
        }
    }
    
    /**
     * @dev 添加销售记录
     */
    function addSalesRecord(
        string memory _productId,
        address _buyer,
        uint256 _price,
        string memory _channel
    ) public onlySeller productExists(_productId) {
        SalesRecord memory record = SalesRecord({
            productId: _productId,
            seller: msg.sender,
            buyer: _buyer,
            saleDate: block.timestamp,
            price: _price,
            channel: _channel,
            timestamp: block.timestamp
        });
        
        salesRecords[_productId].push(record);
        products[_productId].status = ProductStatus.Sold;
        
        emit SalesRecordAdded(_productId, msg.sender, block.timestamp);
        emit StatusUpdated(_productId, ProductStatus.Sold, block.timestamp);
    }
    
    /**
     * @dev 查询产品信息
     */
    function getProduct(string memory _productId) public view returns (HoneyProduct memory) {
        require(products[_productId].exists, "Product does not exist");
        return products[_productId];
    }
    
    /**
     * @dev 获取生产记录数量
     */
    function getProductionRecordCount(string memory _productId) public view returns (uint256) {
        return productionRecords[_productId].length;
    }
    
    /**
     * @dev 获取质检记录数量
     */
    function getQualityRecordCount(string memory _productId) public view returns (uint256) {
        return qualityRecords[_productId].length;
    }
    
    /**
     * @dev 获取物流记录数量
     */
    function getLogisticsRecordCount(string memory _productId) public view returns (uint256) {
        return logisticsRecords[_productId].length;
    }
    
    /**
     * @dev 获取销售记录数量
     */
    function getSalesRecordCount(string memory _productId) public view returns (uint256) {
        return salesRecords[_productId].length;
    }
    
    /**
     * @dev 获取所有产品ID
     */
    function getAllProductIds() public view returns (string[] memory) {
        return productIds;
    }
    
    /**
     * @dev 获取产品总数
     */
    function getTotalProducts() public view returns (uint256) {
        return productIds.length;
    }
    
    /**
     * @dev 验证产品真伪
     */
    function verifyProduct(string memory _productId) public view returns (bool, string memory) {
        if (!products[_productId].exists) {
            return (false, "Product not found in blockchain");
        }
        
        if (qualityRecords[_productId].length == 0) {
            return (false, "No quality inspection record");
        }
        
        bool hasPassedInspection = false;
        for (uint256 i = 0; i < qualityRecords[_productId].length; i++) {
            if (qualityRecords[_productId][i].qualified) {
                hasPassedInspection = true;
                break;
            }
        }
        
        if (!hasPassedInspection) {
            return (false, "Product failed quality inspection");
        }
        
        return (true, "Product is authentic and qualified");
    }
}

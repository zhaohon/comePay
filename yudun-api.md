# YuDun (优盾钱包) API 文档

## 概述

优盾钱包 API 提供加密货币地址管理、充值、提币等功能。所有接口（除回调外）都需要 JWT 认证。

**Base URL:** `/api/v1/yudun`

**认证方式:** Bearer Token
```
Authorization: Bearer <JWT_TOKEN>
```

---

## 1. 地址管理

### 1.1 创建充值地址

创建指定链的充值地址，地址会自动关联当前登录用户。

**请求**
```
POST /api/v1/yudun/address/create
```

**请求体**
```json
{
  "main_coin_type": "195",
  "call_url": "https://yourdomain.com/callback",
  "alias": "my-trx-address"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| main_coin_type | string | 是 | 主链类型 (见下方币种表) |
| call_url | string | 否 | 自定义回调地址，默认使用配置文件中的地址 |
| alias | string | 否 | 地址别名 |

**主链类型 (mainCoinType)**

| 值 | 链 | 说明 |
|----|-----|------|
| 0 | BTC | 比特币 |
| 2 | LTC | 莱特币 |
| 60 | ETH | 以太坊 (支持 ETH 和 ERC20 代币) |
| 195 | TRX | 波场 (支持 TRX 和 TRC20 代币) |
| 714 | BSC | 币安智能链 |

**响应**
```json
{
  "ok": true,
  "data": {
    "coinType": 195,
    "address": "TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }
}
```

---

### 1.2 获取用户所有充值地址

获取当前登录用户的所有充值地址。

**请求**
```
GET /api/v1/yudun/addresses
```

**响应**
```json
{
  "ok": true,
  "addresses": [
    {
      "id": 1,
      "chain": "ETH",
      "main_coin_type": 60,
      "coin_type": 60,
      "address": "0x2dfb423b989c236fb755f7acbd80ee1c6fa231d9",
      "alias": "user_1_ETH",
      "created_at": "2025-12-20 10:30:00"
    },
    {
      "id": 2,
      "chain": "TRX",
      "main_coin_type": 195,
      "coin_type": 195,
      "address": "TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "alias": "user_1_TRX",
      "created_at": "2025-12-20 10:30:00"
    }
  ],
  "total": 2
}
```

---

### 1.3 获取用户指定链的充值地址

获取当前用户在指定链上的充值地址。

**请求**
```
GET /api/v1/yudun/addresses/:chain
```

**路径参数**

| 参数 | 说明 |
|------|------|
| chain | 链名称: BTC, ETH, TRX, BSC, LTC |

**示例**
```
GET /api/v1/yudun/addresses/ETH
```

**响应**
```json
{
  "ok": true,
  "address": {
    "id": 1,
    "chain": "ETH",
    "main_coin_type": 60,
    "coin_type": 60,
    "address": "0x2dfb423b989c236fb755f7acbd80ee1c6fa231d9",
    "alias": "user_1_ETH",
    "created_at": "2025-12-20 10:30:00"
  }
}
```

---

### 1.4 校验地址合法性

校验指定地址格式是否合法。

**请求**
```
POST /api/v1/yudun/address/check
```

**请求体**
```json
{
  "main_coin_type": "60",
  "address": "0x2dfb423b989c236fb755f7acbd80ee1c6fa231d9"
}
```

**响应**
```json
{
  "ok": true,
  "valid": true
}
```

---

### 1.5 检查地址是否存在

检查地址是否已在优盾系统中创建。

**请求**
```
POST /api/v1/yudun/address/exists
```

**请求体**
```json
{
  "main_coin_type": "60",
  "address": "0x2dfb423b989c236fb755f7acbd80ee1c6fa231d9"
}
```

**响应**
```json
{
  "ok": true,
  "exists": true
}
```

---

## 2. 提币

### 2.1 提交提币申请

从优盾钱包提币到外部地址。

**请求**
```
POST /api/v1/yudun/withdraw
```

**请求体**
```json
{
  "address": "TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "amount": "100",
  "main_coin_type": "195",
  "coin_type": "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t",
  "business_id": "withdraw_20251221_001",
  "memo": "用户提币"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| address | string | 是 | 目标地址 |
| amount | string | 是 | 提币金额 |
| main_coin_type | string | 是 | 主链类型 |
| coin_type | string | 是 | 币种类型 (主币与 main_coin_type 相同，代币为合约地址) |
| business_id | string | 是 | 业务ID (用于幂等性，不可重复) |
| memo | string | 否 | 备注 |

**币种类型 (coinType) 示例**

| 币种 | mainCoinType | coinType |
|------|--------------|----------|
| BTC | 0 | 0 |
| ETH | 60 | 60 |
| USDT-ERC20 | 60 | 0xdac17f958d2ee523a2206206994597c13d831ec7 |
| TRX | 195 | 195 |
| USDT-TRC20 | 195 | TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t |

**响应**
```json
{
  "ok": true,
  "message": "Withdrawal submitted successfully"
}
```

---

## 3. 币种信息

### 3.1 获取支持的币种

获取商户支持的所有币种列表。

**请求**
```
GET /api/v1/yudun/coins?show_balance=true
```

**查询参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| show_balance | boolean | 是否显示余额 (默认 false) |

**响应**
```json
{
  "ok": true,
  "coins": [
    {
      "name": "BTC",
      "coinName": "Bitcoin",
      "symbol": "BTC",
      "mainCoinType": "0",
      "coinType": "0",
      "decimals": "8",
      "tokenStatus": 0,
      "mainSymbol": "",
      "balance": 0,
      "logo": "https://img.udresource.com/public/coin/BTC.png"
    },
    {
      "name": "USDT-TRC20",
      "coinName": "USDT-TRC20",
      "symbol": "TRCUSDT",
      "mainCoinType": "195",
      "coinType": "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t",
      "decimals": "6",
      "tokenStatus": 1,
      "mainSymbol": "TRX",
      "balance": 0,
      "logo": "https://img.udresource.com/public/coin/USDT.png"
    }
  ]
}
```

**字段说明**

| 字段 | 说明 |
|------|------|
| tokenStatus | 0=主币, 1=代币 |
| mainSymbol | 代币所在主链的符号 (主币为空) |

---

## 4. 交易记录

### 4.1 获取交易记录

获取充值/提币交易记录。

**请求**
```
GET /api/v1/yudun/transactions?page=1&page_size=20
```

**查询参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| coin_type | string | 币种类型筛选 |
| status | string | 状态筛选 (0=待确认, 2=已确认) |
| trade_type | string | 交易类型 (1=充值, 2=提币) |
| start_date | string | 开始日期 |
| end_date | string | 结束日期 |
| page | int | 页码 (默认 1) |
| page_size | int | 每页数量 (默认 20, 最大 100) |

**响应**
```json
{
  "ok": true,
  "transactions": [
    {
      "id": 1,
      "trade_id": "YD20251221001",
      "tx_id": "0x...",
      "address": "0x2dfb423b989c236fb755f7acbd80ee1c6fa231d9",
      "amount": "10000000",
      "actual_amount": "10",
      "fee": "0",
      "decimals": 6,
      "main_coin_type": 195,
      "coin_type": 0,
      "status": 2,
      "trade_type": 1,
      "created_at": "2025-12-21T06:40:04Z"
    }
  ],
  "total": 1,
  "page": 1,
  "page_size": 20
}
```

---

## 5. 回调接口 (无需认证)

### 5.1 充值/提币回调

优盾系统在充值确认或提币状态变更时调用此接口。

**请求**
```
POST /api/v1/yudun/callback
Content-Type: application/x-www-form-urlencoded
```

**请求参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| timestamp | int64 | 时间戳 (秒) |
| nonce | int64 | 随机数 |
| sign | string | 签名 |
| body | string | JSON 格式的回调内容 |

**body 内容**
```json
{
  "address": "0x2dfb423b989c236fb755f7acbd80ee1c6fa231d9",
  "amount": "10000000",
  "blockHigh": "12345678",
  "coinType": "195",
  "decimals": "6",
  "fee": "0",
  "mainCoinType": "195",
  "status": 2,
  "tradeId": "YD20251221001",
  "tradeType": 1,
  "txId": "0x...",
  "businessId": "",
  "memo": ""
}
```

**回调状态 (充值)**

| status | 说明 |
|--------|------|
| 0 | 待确认 |
| 1 | 确认中 |
| 2 | 已确认 (充值成功) |

**回调状态 (提币)**

| status | 说明 |
|--------|------|
| 0 | 待审核 |
| 1 | 审核成功 |
| 2 | 审核驳回 |
| 3 | 交易成功 |
| 4 | 交易失败 |

**响应**
```json
{
  "code": 200,
  "message": "SUCCESS"
}
```

---

## 错误响应

所有接口在出错时返回以下格式：

```json
{
  "ok": false,
  "error": "error_code",
  "message": "错误描述"
}
```

**常见错误码**

| error | 说明 |
|-------|------|
| invalid_request | 请求参数错误 |
| unauthorized | 未认证或 Token 无效 |
| create_failed | 创建地址失败 |
| withdraw_failed | 提币失败 |
| duplicate_business_id | 业务ID重复 |
| not_found | 资源不存在 |
| invalid_chain | 不支持的链 |

---

## 附录：支持的币种

| 币种 | mainCoinType | coinType | decimals |
|------|--------------|----------|----------|
| BTC | 0 | 0 | 8 |
| LTC | 2 | 2 | 8 |
| ETH | 60 | 60 | 18 |
| USDT-ERC20 | 60 | 0xdac17f958d2ee523a2206206994597c13d831ec7 | 6 |
| TRX | 195 | 195 | 6 |
| USDT-TRC20 | 195 | TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t | 6 |
| BNB | 714 | 714 | 18 |

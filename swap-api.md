# 货币兑换 API 文档

## 概述

本文档描述了 ComeComePay 平台的货币兑换（Swap）相关 API 接口。这些接口支持用户在不同货币之间进行兑换，并与 PokePay 卡片系统集成。

**Base URL:** `http://31.97.222.142:8010/api/v1`

**支持的货币:** ETH, USDC, USD, USDT, BTC, HKD

**认证方式:** Bearer Token (JWT)

---

## 目录

1. [汇率接口](#1-汇率接口)
   - [获取所有汇率](#11-获取所有汇率)
   - [获取特定货币对汇率](#12-获取特定货币对汇率)
2. [兑换接口](#2-兑换接口)
   - [创建兑换预览](#21-创建兑换预览)
   - [执行兑换](#22-执行兑换)
   - [获取兑换历史](#23-获取兑换历史)


---

## 1. 汇率接口

### 1.1 获取所有汇率

获取系统支持的所有货币对的汇率信息。

**请求**

```
GET /wallet/exchange-rates
```

**请求头**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Authorization | string | 否 | Bearer Token（可选） |

**响应示例**

```json
{
  "status": "success",
  "data": {
    "rates": [
      {
        "from_currency": "USD",
        "to_currency": "HKD",
        "rate": 7.82,
        "inverse_rate": 0.1279
      },
      {
        "from_currency": "USDT",
        "to_currency": "HKD",
        "rate": 7.80,
        "inverse_rate": 0.1282
      }
    ],
    "timestamp": "2025-12-21T00:00:00Z",
    "valid_until": "2025-12-21T00:05:00Z",
    "source": "pokepay",
    "from_cache": false
  }
}
```

---

### 1.2 获取特定货币对汇率

获取指定货币对的汇率信息。

**请求**

```
GET /wallet/exchange-rate?from={from_currency}&to={to_currency}
```

**查询参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| from | string | 是 | 源货币代码（如 USD, USDT, ETH） |
| to | string | 是 | 目标货币代码（如 HKD） |

**响应示例**

```json
{
  "status": "success",
  "data": {
    "from_currency": "USDT",
    "to_currency": "HKD",
    "rate": 7.80,
    "timestamp": "2025-12-21T00:00:00Z",
    "valid_until": "2025-12-21T00:05:00Z"
  }
}
```

**错误响应**

```json
{
  "status": "error",
  "error": {
    "code": "SAME_CURRENCY",
    "message": "Source and target currency cannot be the same"
  }
}
```

---

## 2. 兑换接口

### 2.1 创建兑换预览

创建兑换报价，获取预估的兑换结果。报价有效期为 5 分钟。

**请求**

```
POST /wallet/swap/preview
```

**请求头**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Authorization | string | 是 | Bearer {access_token} |
| Content-Type | string | 是 | application/json |

**请求体**

```json
{
  "from_currency": "USDT",
  "to_currency": "HKD",
  "amount": 100
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| from_currency | string | 是 | 源货币代码 |
| to_currency | string | 是 | 目标货币代码 |
| amount | number | 是 | 兑换金额（必须大于 0） |

**响应示例**

```json
{
  "status": "success",
  "data": {
    "quote_id": "quote_3f43213a-9070-4885-8ad0-4e8ea5c3aeb2",
    "from_currency": "USDT",
    "to_currency": "HKD",
    "from_amount": 100,
    "to_amount": 780,
    "exchange_rate": 7.80,
    "fee": 0,
    "net_amount": 780,
    "expires_at": "2025-12-21T00:05:00Z"
  }
}
```

---

### 2.2 执行兑换

执行货币兑换操作。如果涉及 HKD，会自动触发 PokePay 卡片充值/提现。

**请求**

```
POST /wallet/swap
```

**请求头**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Authorization | string | 是 | Bearer {access_token} |
| Content-Type | string | 是 | application/json |

**请求体**

```json
{
  "from_currency": "USDT",
  "to_currency": "HKD",
  "amount": 100,
  "quote_id": "quote_3f43213a-9070-4885-8ad0-4e8ea5c3aeb2"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| from_currency | string | 是 | 源货币代码 |
| to_currency | string | 是 | 目标货币代码 |
| amount | number | 是 | 兑换金额 |
| quote_id | string | 否 | 报价 ID（可选，使用报价可锁定汇率） |

**响应示例**

```json
{
  "status": "success",
  "data": {
    "transaction_id": 123,
    "from_currency": "USDT",
    "to_currency": "HKD",
    "from_amount": 100,
    "to_amount": 780,
    "exchange_rate": 7.80,
    "fee": 0,
    "pokepay_reference": "recharge_123783020",
    "new_balances": {
      "USDT": 400,
      "HKD": 780
    }
  }
}
```

**业务逻辑说明**

| 兑换方向 | PokePay 操作 | 说明 |
|----------|--------------|------|
| X → HKD | 卡片充值 | 将其他货币兑换为 HKD，充值到 PokePay 卡片 |
| HKD → X | 卡片提现 | 从 PokePay 卡片提现 HKD，兑换为其他货币 |
| X → Y | 无 | 不涉及 HKD 的普通兑换 |

---

### 2.3 获取兑换历史

获取用户的兑换交易历史记录。

**请求**

```
GET /wallet/swap/history?page={page}&limit={limit}
```

**请求头**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Authorization | string | 是 | Bearer {access_token} |

**查询参数**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | number | 否 | 1 | 页码 |
| limit | number | 否 | 20 | 每页数量（最大 100） |

**响应示例**

```json
{
  "status": "success",
  "data": {
    "transactions": [
      {
        "id": 123,
        "user_id": 7,
        "wallet_id": 7,
        "from_currency": "USDT",
        "to_currency": "HKD",
        "from_amount": 100,
        "to_amount": 780,
        "exchange_rate": 7.80,
        "fee": 0,
        "status": "completed",
        "quote_id": "quote_xxx",
        "poke_pay_ref": "recharge_123783020",
        "poke_pay_type": "recharge",
        "created_at": "2025-12-21T00:00:00Z",
        "completed_at": "2025-12-21T00:00:05Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50
    }
  }
}
```


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
    "to_amount": 762.84,
    "exchange_rate": 7.80,
    "fee": 0,
    "fee_rate": 0.022,
    "fee_amount": 17.16,
    "net_amount": 762.84,
    "expires_at": "2025-12-21T00:05:00Z"
  }
}
```

**响应字段说明**

| 字段 | 类型 | 说明 |
|------|------|------|
| quote_id | string | 报价唯一标识符 |
| from_currency | string | 源货币代码 |
| to_currency | string | 目标货币代码 |
| from_amount | number | 源货币金额 |
| to_amount | number | 目标货币金额（扣除手续费后的净到账金额） |
| exchange_rate | number | 汇率 |
| fee | number | 旧版手续费字段（保留兼容性，值为0） |
| fee_rate | number | 手续费率（如0.022表示2.2%） |
| fee_amount | number | 手续费金额（HKD） |
| net_amount | number | 净到账金额（等于to_amount） |
| expires_at | string | 报价过期时间 |

**手续费计算说明**

- **其他币种 → HKD**: `净到账 = 数量 × (1 - 2.2%) × HKD汇率`
- **HKD → 其他币种**: `净到账 = HKD金额 × (1 - 2.2%) × 目标币种汇率`
- 手续费金额以HKD计价
- 手续费率可由管理员配置，默认为2.2%

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
{"from_currency":"USDT-TRC20","to_currency":"HKD","amount":100,"card_id":12,"quote_id":"quote_4e760921-7294-4218-b0a9-b6b1b84d03b3"}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| from_currency | string | 是 | 源货币代码 |
| to_currency | string | 是 | 目标货币代码 |
| amount | number | 是 | 兑换金额 |
| quote_id | string | 否 | 报价 ID（可选，使用报价可锁定汇率） |
| card_id | number | 是 | PokePay 卡片 ID |
**响应示例**

```json
{
  "status": "success",
  "data": {
    "transaction_id": 123,
    "from_currency": "USDT",
    "to_currency": "HKD",
    "from_amount": 100,
    "to_amount": 762.84,
    "exchange_rate": 7.80,
    "fee": 0,
    "fee_rate": 0.022,
    "fee_amount": 17.16,
    "net_amount": 762.84,
    "pokepay_reference": "recharge_123783020",
    "new_balances": {
      "USDT": 400,
      "HKD": 762.84
    }
  }
}
```

**响应字段说明**

| 字段 | 类型 | 说明 |
|------|------|------|
| transaction_id | number | 交易ID |
| from_currency | string | 源货币代码 |
| to_currency | string | 目标货币代码 |
| from_amount | number | 源货币金额 |
| to_amount | number | 目标货币金额（扣除手续费后） |
| exchange_rate | number | 汇率 |
| fee | number | 旧版手续费字段（保留兼容性） |
| fee_rate | number | 手续费率（如0.022表示2.2%） |
| fee_amount | number | 手续费金额（HKD） |
| net_amount | number | 净到账金额 |
| pokepay_reference | string | PokePay交易参考号 |
| new_balances | object | 更新后的余额 |

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



---

## 3. 管理员接口

### 3.1 获取当前手续费配置

获取当前激活的SWAP手续费配置。

**请求**

```
GET /admin/swap-fee-config
```

**请求头**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Authorization | string | 是 | Bearer {access_token} (需要管理员权限) |

**响应示例**

```json
{
  "status": "success",
  "data": {
    "id": 1,
    "fee_rate": 0.022,
    "is_active": true,
    "created_by": 1,
    "created_at": "2025-12-21T00:00:00Z",
    "updated_at": "2025-12-21T00:00:00Z"
  }
}
```

**响应字段说明**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | number | 配置ID |
| fee_rate | number | 手续费率（0.022表示2.2%） |
| is_active | boolean | 是否激活 |
| created_by | number | 创建者用户ID |
| created_at | string | 创建时间 |
| updated_at | string | 更新时间 |

---

### 3.2 更新手续费配置

更新SWAP手续费率配置。更新后，旧配置将被设为非激活状态，新配置立即生效。

**请求**

```
PUT /admin/swap-fee-config
```

**请求头**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Authorization | string | 是 | Bearer {access_token} (需要管理员权限) |
| Content-Type | string | 是 | application/json |

**请求体**

```json
{
  "fee_rate": 0.025
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| fee_rate | number | 是 | 手续费率（0-1之间，如0.025表示2.5%） |

**响应示例**

```json
{
  "status": "success",
  "message": "Fee configuration updated successfully",
  "data": {
    "id": 2,
    "fee_rate": 0.025,
    "is_active": true,
    "created_by": 1,
    "created_at": "2025-12-21T01:00:00Z",
    "updated_at": "2025-12-21T01:00:00Z"
  }
}
```

**错误响应**

```json
{
  "status": "error",
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Key: 'fee_rate' Error:Field validation for 'fee_rate' failed on the 'lte' tag"
  }
}
```

---

### 3.3 获取手续费配置历史

获取手续费配置的历史记录，支持分页。

**请求**

```
GET /admin/swap-fee-config/history?page=1&limit=20
```

**请求头**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| Authorization | string | 是 | Bearer {access_token} (需要管理员权限) |

**查询参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | number | 否 | 页码（默认1） |
| limit | number | 否 | 每页数量（默认20） |

**响应示例**

```json
{
  "status": "success",
  "data": {
    "configs": [
      {
        "id": 2,
        "fee_rate": 0.025,
        "is_active": true,
        "created_by": 1,
        "created_at": "2025-12-21T01:00:00Z",
        "updated_at": "2025-12-21T01:00:00Z"
      },
      {
        "id": 1,
        "fee_rate": 0.022,
        "is_active": false,
        "created_by": 1,
        "created_at": "2025-12-21T00:00:00Z",
        "updated_at": "2025-12-21T01:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 2
    }
  }
}
```

---

## 4. 手续费与提成说明

### 4.1 手续费计算

SWAP交易会收取手续费，手续费率可由管理员配置（默认2.2%）：

- **其他币种 → HKD**: 
  - 公式：`净到账HKD = 数量 × (1 - 手续费率) × HKD汇率`
  - 示例：100 USDT → HKD，汇率7.80，手续费率2.2%
    - 手续费金额 = 100 × 7.80 × 2.2% = 17.16 HKD
    - 净到账 = 100 × 7.80 × (1 - 2.2%) = 762.84 HKD

- **HKD → 其他币种**:
  - 公式：`净到账 = HKD金额 × (1 - 手续费率) × 目标币种汇率`
  - 示例：780 HKD → USDT，汇率0.1282，手续费率2.2%
    - 手续费金额 = 780 × 2.2% = 17.16 HKD
    - 净到账 = 780 × (1 - 2.2%) × 0.1282 = 97.84 USDT

### 4.2 分销提成

SWAP手续费会用于计算推荐人的提成：

- **一级推荐人**: 手续费金额 × 一级提成比例
- **二级推荐人**: 手续费金额 × 二级提成比例

提成比例由系统配置决定，提成金额会自动发放到推荐人的HKD钱包余额。

---

## 5. 错误代码

| 错误代码 | HTTP状态码 | 说明 |
|----------|-----------|------|
| INSUFFICIENT_BALANCE | 400 | 余额不足 |
| SAME_CURRENCY | 400 | 源货币和目标货币相同 |
| QUOTE_EXPIRED | 400 | 报价已过期 |
| QUOTE_NOT_FOUND | 404 | 报价不存在 |
| QUOTE_ALREADY_USED | 400 | 报价已被使用 |
| WALLET_NOT_ACTIVE | 400 | 钱包未激活 |
| WALLET_NOT_FOUND | 404 | 钱包不存在 |
| AMOUNT_TOO_SMALL | 400 | 金额低于最小限制 |
| AMOUNT_TOO_LARGE | 400 | 金额超过最大限制 |
| NO_POKEPAY_CARD | 400 | 用户未开通PokePay卡片 |
| POKEPAY_CARD_NOT_ACTIVE | 400 | PokePay卡片未激活 |
| POKEPAY_RECHARGE_FAILED | 503 | PokePay充值失败 |
| POKEPAY_WITHDRAW_FAILED | 503 | PokePay提现失败 |
| EXCHANGE_RATE_UNAVAILABLE | 500 | 汇率服务不可用 |
| UNAUTHORIZED | 401 | 未授权或token无效 |
| INVALID_REQUEST | 400 | 请求参数无效 |
| INTERNAL_ERROR | 500 | 服务器内部错误 |

---

## 6. 注意事项

1. **报价有效期**: 兑换预览生成的报价有效期为5分钟，过期后需要重新获取
2. **汇率波动**: 不使用报价时，将使用实时汇率，可能与预览时不同
3. **PokePay集成**: 涉及HKD的兑换会自动触发PokePay卡片操作
4. **手续费**: 所有SWAP交易都会收取手续费，手续费以HKD计价
5. **提成发放**: 手续费提成会异步处理，不影响兑换主流程
6. **余额同步**: HKD余额与PokePay卡片余额保持同步
7. **管理员权限**: 手续费配置接口需要管理员权限

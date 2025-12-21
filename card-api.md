# PokePay 卡片管理 API 文档

基础路径: `/api/v1/card`

所有接口需要认证，请在请求头中添加:
```
Authorization: Bearer <access_token>
```

---

## 1. 卡片状态管理

### 1.1 获取卡片状态
**GET** `/api/v1/card/status`

获取用户卡片的当前状态信息。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "public_token": "card_abc123",
    "status": "normal",
    "card_no": "4000****1234",
    "currency_code": "HKD",
    "is_recharge": 1,
    "is_withdraw": 1,
    "created_time": 1703145600
  }
}
```

**状态值说明**
- `unactivate`: 未激活
- `normal`: 正常
- `frozen`: 冻结
- `cancelled`: 已注销

---

### 1.2 修改卡片状态
**PUT** `/api/v1/card/status`

修改卡片状态（冻结/解冻/注销）。

**请求体**
```json
{
  "public_token": "card_abc123",
  "status": "frozen"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |
| status | string | 是 | 目标状态: normal/frozen/cancelled |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "message": "卡片状态已更新",
  "data": {
    "public_token": "card_abc123",
    "status": "frozen"
  }
}
```

---

## 2. CVV 管理

### 2.1 获取 CVV
**GET** `/api/v1/card/cvv`

获取卡片的 CVV 安全码。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "cvv": "123",
    "expires_in": 60
  }
}
```

---

### 2.2 获取 CVV 状态
**GET** `/api/v1/card/cvv/status`

获取 CVV 的锁定状态。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "is_locked": false,
    "lock_reason": null,
    "unlock_available": true
  }
}
```

---

### 2.3 解锁 CVV
**PATCH** `/api/v1/card/cvv/unlock`

解锁被锁定的 CVV。

**请求体**
```json
{
  "public_token": "card_abc123"
}
```

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "message": "CVV 已解锁"
}
```

---

## 3. PIN 管理

### 3.1 获取 PIN
**GET** `/api/v1/card/pin`

获取卡片的 PIN 码。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "pin": "1234",
    "expires_in": 60
  }
}
```

---

### 3.2 获取 PIN 状态
**GET** `/api/v1/card/pin/status`

获取 PIN 的锁定状态。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "is_locked": false,
    "lock_reason": null,
    "retry_count": 0,
    "max_retry": 3
  }
}
```

---

### 3.3 解锁 PIN
**PATCH** `/api/v1/card/pin/unlock`

解锁被锁定的 PIN。

**请求体**
```json
{
  "public_token": "card_abc123"
}
```

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "message": "PIN 已解锁"
}
```

---

### 3.4 设置 PIN
**PATCH** `/api/v1/card/pin/set`

设置或修改卡片 PIN 码。

**请求体**
```json
{
  "public_token": "card_abc123",
  "new_pin": "1234"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |
| new_pin | string | 是 | 新 PIN 码 (4-6位数字) |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "message": "PIN 设置成功"
}
```

---

## 4. 批量操作

### 4.1 批量开卡
**POST** `/api/v1/card/batch-issuance`

批量申请开卡。

**请求体**
```json
{
  "quantity": 10,
  "product_id": 1,
  "kyc_ids": [101, 102, 103]
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| quantity | int | 是 | 开卡数量 |
| product_id | int | 是 | 卡片产品 ID |
| kyc_ids | array | 否 | 绑定的 KYC ID 列表 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "batch_id": "batch_20231221_001",
    "quantity": 10,
    "status": "processing"
  }
}
```

---

### 4.2 获取批量开卡进度
**GET** `/api/v1/card/batch-issuance/status`

查询批量开卡的处理进度。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| batch_id | string | 是 | 批次 ID |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "batch_id": "batch_20231221_001",
    "total": 10,
    "completed": 8,
    "failed": 0,
    "pending": 2,
    "status": "processing",
    "cards": [
      {
        "public_token": "card_001",
        "status": "completed"
      }
    ]
  }
}
```

---

## 5. 交易操作

### 5.1 获取交易历史
**GET** `/api/v1/card/transaction-history`

获取卡片的交易历史记录。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |
| page | int | 否 | 页码，默认 1 |
| limit | int | 否 | 每页条数，默认 20 |
| start_date | string | 否 | 开始日期 (YYYY-MM-DD) |
| end_date | string | 否 | 结束日期 (YYYY-MM-DD) |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "transactions": [
      {
        "id": "txn_001",
        "type": "purchase",
        "amount": 100.00,
        "currency": "HKD",
        "merchant": "Amazon",
        "status": "completed",
        "created_at": "2023-12-21T10:30:00Z"
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

### 5.2 获取交易详情
**GET** `/api/v1/card/transaction-details`

获取单笔交易的详细信息。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| transaction_id | string | 是 | 交易 ID |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "id": "txn_001",
    "type": "purchase",
    "amount": 100.00,
    "currency": "HKD",
    "merchant": "Amazon",
    "merchant_category": "Online Shopping",
    "status": "completed",
    "fee": 0,
    "balance_after": 900.00,
    "created_at": "2023-12-21T10:30:00Z",
    "completed_at": "2023-12-21T10:30:05Z"
  }
}
```

---

## 6. 卡片操作

### 6.1 获取完整卡号
**POST** `/api/v1/card/full-number`

获取卡片的完整卡号（需要额外验证）。

**请求体**
```json
{
  "public_token": "card_abc123"
}
```

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "card_number": "4000123456781234",
    "expires_in": 60
  }
}
```

---

### 6.2 卡片充值
**POST** `/api/v1/card/recharge`

向卡片充值（从代理商资金账户向卡内转账）。

**请求体**
```json
{
  "public_token": "card_abc123",
  "amount": 1000.00
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |
| amount | float | 是 | 充值金额 (HKD) |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "message": "充值成功",
  "data": {
    "public_token": "card_abc123",
    "amount": 1000.00,
    "new_balance": 2000.00
  }
}
```

---

### 6.3 卡片提现 (Payouts)
**POST** `/api/v1/card/payouts`

从卡片提现到外部账户。

**请求体**
```json
{
  "public_token": "card_abc123",
  "amount": 500.00,
  "destination": {
    "type": "bank_account",
    "account_number": "1234567890",
    "bank_code": "HSBC"
  }
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |
| amount | float | 是 | 提现金额 |
| destination | object | 是 | 目标账户信息 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "message": "提现申请已提交",
  "data": {
    "payout_id": "payout_001",
    "amount": 500.00,
    "status": "processing",
    "estimated_time": "1-3 business days"
  }
}
```

---

### 6.4 获取账户详情
**GET** `/api/v1/card/account-details`

获取卡片账户的详细信息。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "public_token": "card_abc123",
    "account_id": "acc_001",
    "balance": 1000.00,
    "currency": "HKD",
    "status": "normal",
    "name_on_card": "ZHANG SAN",
    "card_number": "4000****1234",
    "expires_at": "2027-12",
    "recharge_min": 100,
    "recharge_max": 50000,
    "withdraw_min": 100,
    "withdraw_max": 10000
  }
}
```

---

### 6.5 获取账户详情（含货币转换）
**GET** `/api/v1/card/account-details-currency-conversion`

获取卡片账户详情，包含多币种余额转换。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "public_token": "card_abc123",
    "balance": 1000.00,
    "currency": "HKD",
    "converted_balances": [
      {
        "currency": "HKD",
        "amount": 1000.00,
        "exchange_rate": 1.0
      },
      {
        "currency": "USD",
        "amount": 128.21,
        "exchange_rate": 0.12821
      },
      {
        "currency": "USDT",
        "amount": 128.00,
        "exchange_rate": 0.128
      }
    ],
    "supported_currencies": [
      {"currency_code": "USD", "exchange_rate": 0.12821},
      {"currency_code": "USDT", "exchange_rate": 0.128}
    ]
  }
}
```

---

### 6.6 获取账户账单
**GET** `/api/v1/card/account-statement`

获取卡片账户的账单明细。

**请求参数 (Query)**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |
| start_date | string | 否 | 开始日期 |
| end_date | string | 否 | 结束日期 |
| page | int | 否 | 页码 |
| limit | int | 否 | 每页条数 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "data": {
    "statements": [
      {
        "date": "2023-12-21",
        "description": "Card Recharge",
        "amount": 1000.00,
        "type": "credit",
        "balance": 2000.00
      },
      {
        "date": "2023-12-20",
        "description": "Purchase - Amazon",
        "amount": -100.00,
        "type": "debit",
        "balance": 1000.00
      }
    ],
    "summary": {
      "opening_balance": 1100.00,
      "total_credits": 1000.00,
      "total_debits": 100.00,
      "closing_balance": 2000.00
    }
  }
}
```

---

### 6.7 申请开卡
**POST** `/api/v1/card/apply`

申请开通新卡片。

**请求体**
```json
{
  "product_id": 1,
  "kyc_id": 101,
  "card_holder_name": "ZHANG SAN"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| product_id | int | 是 | 卡片产品 ID |
| kyc_id | int | 否 | 绑定的 KYC ID |
| card_holder_name | string | 是 | 持卡人姓名 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "message": "开卡申请已提交",
  "data": {
    "public_token": "card_new123",
    "card_no": "4000****5678",
    "status": "unactivate",
    "currency_code": "HKD"
  }
}
```

---

### 6.8 修改卡片信息
**PUT** `/api/v1/card/modify`

修改卡片的基本信息。

**请求体**
```json
{
  "public_token": "card_abc123",
  "card_holder_name": "ZHANG SAN",
  "daily_limit": 5000,
  "monthly_limit": 50000
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |
| card_holder_name | string | 否 | 持卡人姓名 |
| daily_limit | float | 否 | 每日限额 |
| monthly_limit | float | 否 | 每月限额 |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "message": "卡片信息已更新"
}
```

---

### 6.9 卡片提现（到资金账户）
**POST** `/api/v1/card/withdraw`

从卡片提现到代理商资金账户。

**请求体**
```json
{
  "public_token": "card_abc123",
  "amount": 500.00
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片公开令牌 |
| amount | float | 是 | 提现金额 (HKD) |

**响应示例**
```json
{
  "success": true,
  "status": "success",
  "message": "提现成功",
  "data": {
    "public_token": "card_abc123",
    "amount": 500.00,
    "new_balance": 500.00
  }
}
```

---

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 400 | 请求参数错误 |
| 401 | 未授权/Token 无效 |
| 403 | 权限不足 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 500 | 服务器内部错误 |

**错误响应示例**
```json
{
  "success": false,
  "status": "error",
  "error": "卡片不存在",
  "code": 404
}
```

---

## 注意事项

1. 所有金额单位默认为 HKD（港币）
2. CVV 和 PIN 获取后有效期为 60 秒
3. 卡片充值/提现有最小和最大限额限制
4. 批量开卡操作为异步处理，需要轮询查询进度
5. 敏感操作（如获取完整卡号、CVV、PIN）会记录审计日志

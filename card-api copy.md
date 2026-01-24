# 卡片管理 API 文档

## 概述

本文档描述了卡片管理相关的 API 接口，包括申请卡片、查询卡片信息、获取敏感信息等功能。

**基础地址**: `http://149.88.65.193:8010`

**认证方式**: 所有接口都需要在请求头中携带 JWT Token
```
Authorization: Bearer <your_jwt_token>
```

---

## 1. 申请卡片

申请一张新的虚拟卡或实体卡。

**请求**
```
POST /api/v1/card/apply
Content-Type: application/json
Authorization: Bearer <token>
```

**请求参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| physical | boolean | 否 | 是否申请实体卡，默认 false（虚拟卡）|
| name_on_card | string | 实体卡必填 | 卡面姓名（英文大写）|
| recipient | string | 实体卡必填 | 收件人姓名 |
| area_code | string | 实体卡必填 | 电话区号，如 "+86" |
| phone | string | 实体卡必填 | 电话号码 |
| postal_address | string | 实体卡必填 | 邮寄地址 |
| postal_city | string | 实体卡必填 | 城市 |
| postal_code | string | 实体卡必填 | 邮编 |
| postal_country | string | 实体卡必填 | 国家代码，如 "CN" |

**请求示例（虚拟卡）**
```json
{
  "physical": false
}
```

**请求示例（实体卡）**
```json
{
  "physical": true,
  "name_on_card": "ZHANG SAN",
  "recipient": "张三",
  "area_code": "+86",
  "phone": "13800138000",
  "postal_address": "北京市朝阳区xxx街道xxx号",
  "postal_city": "北京",
  "postal_code": "100000",
  "postal_country": "CN"
}
```

**响应示例**
```json
{
  "status": "success",
  "data": {
    "task_id": 430,
    "message": "Card application submitted successfully"
  }
}
```

**说明**: 申请成功后会返回 `task_id`，可用于查询开卡进度。

---

## 2. 查询开卡进度

根据任务ID查询开卡申请的处理进度。

**请求**
```
GET /api/v1/card/apply/progress/{task_id}
Authorization: Bearer <token>
```

**路径参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| task_id | integer | 申请卡片时返回的任务ID |

**响应示例**
```json
{
  "status": "success",
  "data": {
    "task_id": 430,
    "status": "completed",
    "total": 1,
    "succeed": 1,
    "failed": 0,
    "created_at": "2025-12-25T03:10:22.546347Z",
    "completed_at": "2025-12-25T03:10:36.717106Z",
    "last_polled_at": "2025-12-25T03:10:36.676728Z",
    "list": [
      {
        "public_token": "123791920",
        "masked_pan": "441353******1149",
        "currency": "HKD",
        "kyc_id": 450,
        "status": "succeed"
      },
      {
        "public_token": "123791921",
        "masked_pan": "441353******6135",
        "currency": "HKD",
        "kyc_id": 450,
        "status": "succeed"
      }
    ]
  }
}
```

**状态说明**

| status | 说明 |
|--------|------|
| pending | 等待处理 |
| processing | 处理中 |
| completed | 已完成 |
| failed | 失败 |

---

## 3. 获取卡片列表

获取当前用户的所有卡片。

**请求**
```
GET /api/v1/card/list
Authorization: Bearer <token>
```

**响应示例**
```json
{
  "status": "success",
  "data": {
    "total": 2,
    "cards": [
      {
        "id": 1,
        "public_token": "123791920",
        "card_no": "441353******1149",
        "card_scheme": "visa",
        "currency": "HKD",
        "status": "active",
        "is_physical": false,
        "kyc_id": 450,
        "created_at": "2025-12-25T03:04:56.722613Z"
      },
      {
        "id": 2,
        "public_token": "123791921",
        "card_no": "441353******6135",
        "card_scheme": "visa",
        "currency": "HKD",
        "status": "active",
        "is_physical": false,
        "kyc_id": 450,
        "created_at": "2025-12-25T03:10:36.714866Z"
      }
    ]
  }
}
```

**字段说明**

| 字段 | 说明 |
|------|------|
| public_token | 卡片唯一标识，用于后续操作 |
| card_no | 脱敏卡号 |
| card_scheme | 卡组织（visa/mastercard）|
| currency | 卡片币种 |
| status | 卡片状态 |
| is_physical | 是否为实体卡 |

---

## 4. 获取卡片详情（含余额）

获取指定卡片的详细信息，包括余额、限额等。

**请求**
```
GET /api/v1/card/account-details?public_token={public_token}
Authorization: Bearer <token>
```

**查询参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片唯一标识 |

**响应示例**
```json
{
  "status": "success",
  "message": "Card account details retrieved successfully",
  "data": {
    "id": 1063,
    "public_token": "123791920",
    "card_no": "441353******1149",
    "card_scheme": "visa",
    "currency_code": "HKD",
    "balance": 0,
    "status": "normal",
    "expiry_date": "2030-12-31 08:00:00",
    "activate_time": 1766631893,
    "physical": false,
    "recharge_min": 10,
    "recharge_max": 10000,
    "recharge_fee": 1,
    "withdraw_min": 50,
    "withdraw_max": 0,
    "withdraw_fee": 2,
    "single_quota": 10000,
    "day_quota": 10000,
    "month_quota": 350000,
    "transaction_fee": 1,
    "cross_border_fee": 0,
    "upgrade_amount": 40
  }
}
```

**重要字段说明**

| 字段 | 说明 |
|------|------|
| balance | 卡片余额 |
| status | 卡片状态：normal(正常)、frozen(冻结)、cancelled(注销) |
| recharge_min/max | 充值最小/最大限额 |
| recharge_fee | 充值手续费率 (%) |
| withdraw_min/max | 提现最小/最大限额 |
| withdraw_fee | 提现手续费率 (%) |
| single_quota | 单笔消费限额 |
| day_quota | 日消费限额 |
| month_quota | 月消费限额 |
| transaction_fee | 消费手续费率 (%) |
| upgrade_amount | 升级实体卡费用 |

---

## 5. 查询卡片状态

查询卡片的当前状态。

**请求**
```
GET /api/v1/card/status?public_token={public_token}
Authorization: Bearer <token>
```

**查询参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片唯一标识 |

**响应示例**
```json
{
  "status": "success",
  "message": "Card status retrieved successfully",
  "data": {
    "card_id": "123791920",
    "status": "Active",
    "card_status_code": "00",
    "card_status_description": "00 (Active)"
  }
}
```

---

## 6. 获取交易记录

获取卡片的交易流水记录。

**请求**
```
GET /api/v1/card/transaction-history?public_token={public_token}&page={page}&limit={limit}
Authorization: Bearer <token>
```

**查询参数**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| public_token | string | 是 | - | 卡片唯一标识 |
| page | integer | 否 | 1 | 页码 |
| limit | integer | 否 | 20 | 每页数量（最大100）|

**响应示例**
```json
{
  "status": "success",
  "message": "Transaction history retrieved successfully",
  "data": {
    "public_token": "123791920",
    "page": 1,
    "page_size": 20,
    "total": 0,
    "transactions": []
  }
}
```

---

## 7. 获取 CVV

获取卡片的 CVV 安全码。

**请求**
```
GET /api/v1/card/cvv?public_token={public_token}
Authorization: Bearer <token>
```

**查询参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片唯一标识 |

**响应示例**
```json
{
  "status": "success",
  "message": "CVV retrieved successfully",
  "request_id": "",
  "data": {
    "cvv": "583",
    "result_status": "Success"
  }
}
```

⚠️ **安全提示**: CVV 是敏感信息，请勿存储或记录。

---

## 8. 获取 PIN

获取卡片的 PIN 码。

**请求**
```
GET /api/v1/card/pin?public_token={public_token}
Authorization: Bearer <token>
```

**查询参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片唯一标识 |

**响应示例**
```json
{
  "status": "success",
  "message": "PIN retrieved successfully",
  "data": {
    "pin": "4059"
  }
}
```

⚠️ **安全提示**: PIN 是敏感信息，请勿存储或记录。

---

## 9. 获取完整卡号

获取卡片的完整卡号和 CVV。

**请求**
```
POST /api/v1/card/full-number
Content-Type: application/json
Authorization: Bearer <token>
```

**请求参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片唯一标识 |

**请求示例**
```json
{
  "public_token": "123791920"
}
```

**响应示例**
```json
{
  "status": "success",
  "message": "Full card number retrieved successfully",
  "data": {
    "public_token": "123791920",
    "card_number": "4413539934681149",
    "cvv": "583"
  }
}
```

⚠️ **安全提示**: 完整卡号和 CVV 是敏感信息，请勿存储或记录。

---

## 10. 卡片充值

向卡片充值。

**请求**
```
POST /api/v1/card/recharge
Content-Type: application/json
Authorization: Bearer <token>
```

**请求参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片唯一标识 |
| amount | number | 是 | 充值金额 |

**请求示例**
```json
{
  "public_token": "123791920",
  "amount": 100.00
}
```

---

## 11. 卡片提现

从卡片提现到账户。

**请求**
```
POST /api/v1/card/withdraw
Content-Type: application/json
Authorization: Bearer <token>
```

**请求参数**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| public_token | string | 是 | 卡片唯一标识 |
| amount | number | 是 | 提现金额 |

**请求示例**
```json
{
  "public_token": "123791920",
  "amount": 50.00
}
```

---

## 错误响应

所有接口在发生错误时返回统一格式：

```json
{
  "error": "错误信息描述"
}
```

**常见错误码**

| HTTP 状态码 | 说明 |
|-------------|------|
| 400 | 请求参数错误 |
| 401 | 未授权（Token 无效或过期）|
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 500 | 服务器内部错误 |

---

## 注意事项

1. **认证**: 所有接口都需要有效的 JWT Token
2. **敏感信息**: CVV、PIN、完整卡号等敏感信息请勿存储
3. **限额**: 充值和提现有最小/最大限额限制，请先查询卡片详情
4. **手续费**: 充值、提现、消费都可能产生手续费，费率在卡片详情中返回
5. **public_token**: 是卡片的唯一标识，所有卡片操作都需要使用此参数

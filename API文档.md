# ComePay 项目 API 接口文档

> **文档说明**：本文档分为概览和详细信息两部分。概览部分快速浏览所有接口功能，详细信息部分提供每个接口的完整参数和返回值。

---

## 📋 目录

- [接口概览](#接口概览)
  - [用户认证模块](#用户认证模块)
  - [推荐邀请模块](#推荐邀请模块)
  - [开卡费支付模块](#开卡费支付模块)
  - [KYC 资格模块](#kyc-资格模块)
- [接口详细信息](#接口详细信息)

---

## 接口概览

### 用户认证模块

| 接口名称       | 方法 | 路径                        | 功能描述                           |
| -------------- | ---- | --------------------------- | ---------------------------------- |
| 发送注册验证码 | POST | `/api/v1/auth/signup`       | 发送验证码到用户邮箱，开始注册流程 |
| 验证 OTP 码    | POST | `/api/v1/auth/verifyz`      | 验证邮箱 OTP 验证码                |
| 设置密码       | POST | `/api/v1/auth/set-password` | 完成注册，设置密码并返回 token     |

### 推荐邀请模块

| 接口名称       | 方法 | 路径                          | 功能描述                     |
| -------------- | ---- | ----------------------------- | ---------------------------- |
| 查询我的邀请码 | GET  | `/api/v1/user/referral-code`  | 获取当前用户的邀请码         |
| 查询邀请统计   | GET  | `/api/v1/user/referral-stats` | 获取邀请人数、佣金等统计数据 |
| 查询邀请列表   | GET  | `/api/v1/user/referrals`      | 分页查询邀请的用户列表       |
| 查询佣金记录   | GET  | `/api/v1/user/commissions`    | 分页查询佣金明细记录         |
| 查询推荐人     | GET  | `/api/v1/user/my-referrer`    | 查询我的推荐人信息           |

### 开卡费支付模块

| 接口名称       | 方法 | 路径                                   | 功能描述                         |
| -------------- | ---- | -------------------------------------- | -------------------------------- |
| 获取开卡费配置 | GET  | `/api/v1/CardFee/GetConfig`            | 获取虚拟卡/实体卡的开卡费配置    |
| 获取支付币种   | GET  | `/api/v1/CardFee/GetCurrencies`        | 获取支持的 USDT/USDC 支付币种    |
| 创建开卡费支付 | POST | `/api/v1/CardFee/CreatePayment`        | 创建开卡费支付订单（支持优惠券） |
| 完成支付       | POST | `/api/v1/CardFee/CompletePayment/:ref` | 使用钱包余额完成支付             |
| 查询支付状态   | GET  | `/api/v1/CardFee/GetPaymentStatus`     | 查询当前用户的支付状态           |
| 查询支付历史   | GET  | `/api/v1/CardFee/GetPaymentHistory`    | 分页查询支付历史记录             |

### KYC 资格模块

| 接口名称     | 方法 | 路径                      | 功能描述                               |
| ------------ | ---- | ------------------------- | -------------------------------------- |
| 检查开卡资格 | GET  | `/api/v1/kyc/eligibility` | 检查用户是否已支付开卡费，可否进行 KYC |

---

## 接口详细信息

### 1. 用户认证模块

#### 1.1 发送注册验证码

**接口地址**

```
POST http://149.88.65.193:8010/api/v1/auth/signup
```

**请求参数**

```json
{
  "email": "15702125951@qq.com",
  "referral_code": "GEYSDNS1"
}
```

| 参数          | 类型   | 必填 | 说明         |
| ------------- | ------ | ---- | ------------ |
| email         | string | 是   | 用户邮箱地址 |
| referral_code | string | 否   | 推荐人邀请码 |

**返回示例**

```json
{
  "email": "15702125951@qq.com",
  "message": "OTP sent to your email. Please verify to continue registration.",
  "otp": "79460",
  "status": "success"
}
```

**返回字段说明**

| 字段    | 类型   | 说明                     |
| ------- | ------ | ------------------------ |
| email   | string | 用户邮箱                 |
| message | string | 提示信息                 |
| otp     | string | 验证码（仅开发环境返回） |
| status  | string | 状态：success/error      |

---

#### 1.2 验证 OTP 码

**接口地址**

```
POST http://149.88.65.193:8010/api/v1/auth/verifyz
```

**请求参数**

```json
{
  "email": "15702125951@qq.com",
  "otp_code": "79460"
}
```

| 参数     | 类型   | 必填 | 说明         |
| -------- | ------ | ---- | ------------ |
| email    | string | 是   | 用户邮箱地址 |
| otp_code | string | 是   | 收到的验证码 |

**返回示例**

```json
{
  "email": "15702125951@qq.com",
  "message": "Email verified successfully. Please set your password to complete registration.",
  "next_step": "set_password",
  "referral_code": "",
  "status": "success"
}
```

**返回字段说明**

| 字段      | 类型   | 说明                     |
| --------- | ------ | ------------------------ |
| email     | string | 用户邮箱                 |
| message   | string | 提示信息                 |
| next_step | string | 下一步操作：set_password |
| status    | string | 状态：success/error      |

---

#### 1.3 设置密码

**接口地址**

```
POST http://149.88.65.193:8010/api/v1/auth/set-password
```

**请求参数**

```json
{
  "email": "22222@test.com",
  "password": "zzzz1111",
  "referral_code": "GEYSDNS1"
}
```

| 参数          | 类型   | 必填 | 说明         |
| ------------- | ------ | ---- | ------------ |
| email         | string | 是   | 用户邮箱地址 |
| password      | string | 是   | 用户密码     |
| referral_code | string | 否   | 推荐人邀请码 |

**返回示例**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "message": "Registration completed successfully. Please complete your profile.",
  "next_step": "complete_profile",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "status": "success",
  "user": {
    "account_type": "personal",
    "created_at": "2025-12-23T03:09:45.077068332Z",
    "email": "15702125951@qq.com",
    "first_name": "",
    "id": 2,
    "kyc_level": 0,
    "kyc_status": "pending",
    "last_name": "",
    "phone": null,
    "referral_code": "D8MEZ73N",
    "status": "active",
    "wallet_id": "CCP17664593850018"
  }
}
```

**返回字段说明**

| 字段               | 类型   | 说明                     |
| ------------------ | ------ | ------------------------ |
| access_token       | string | 访问令牌                 |
| refresh_token      | string | 刷新令牌                 |
| message            | string | 提示信息                 |
| next_step          | string | 下一步：complete_profile |
| user               | object | 用户信息对象             |
| user.id            | number | 用户 ID                  |
| user.email         | string | 用户邮箱                 |
| user.referral_code | string | 用户自己的邀请码         |
| user.wallet_id     | string | 钱包 ID                  |
| user.kyc_status    | string | KYC 状态                 |

---

### 2. 推荐邀请模块

#### 2.1 查询我的邀请码

**接口地址**

```
GET http://149.88.65.193:8010/api/v1/user/referral-code
```

**请求头**

```
Authorization: Bearer <access_token>
```

**返回示例**

```json
{
  "referral_code": "GEYSDNS1",
  "status": "success"
}
```

---

#### 2.2 查询邀请统计

**接口地址**

```
GET http://149.88.65.193:8010/api/v1/user/referral-stats
```

**请求头**

```
Authorization: Bearer <access_token>
```

**返回示例**

```json
{
  "stats": {
    "level1_count": 1,
    "level2_count": 0,
    "total_referrals": 1,
    "total_commission": 0,
    "pending_commission": 0,
    "this_month_commission": 0
  },
  "status": "success"
}
```

**返回字段说明**

| 字段                  | 类型   | 说明         |
| --------------------- | ------ | ------------ |
| level1_count          | number | 一级邀请人数 |
| level2_count          | number | 二级邀请人数 |
| total_referrals       | number | 总邀请人数   |
| total_commission      | number | 总佣金       |
| pending_commission    | number | 待结算佣金   |
| this_month_commission | number | 本月佣金     |

---

#### 2.3 查询邀请列表

**接口地址**

```
GET http://149.88.65.193:8010/api/v1/user/referrals?level=0&page=1&page_size=50
```

**请求头**

```
Authorization: Bearer <access_token>
```

**查询参数**

| 参数      | 类型   | 必填 | 说明                             |
| --------- | ------ | ---- | -------------------------------- |
| level     | number | 否   | 邀请层级：0=全部, 1=一级, 2=二级 |
| page      | number | 是   | 页码，从 1 开始                  |
| page_size | number | 是   | 每页条数                         |

**返回示例**

```json
{
  "pagination": {
    "page": 1,
    "page_size": 50,
    "total": 1,
    "total_pages": 1
  },
  "referrals": [
    {
      "created_at": "2025-12-23T03:23:30.111964Z",
      "email": "22***@test.com",
      "first_name": "",
      "id": 4,
      "last_name": ""
    }
  ],
  "status": "success"
}
```

---

#### 2.4 查询佣金记录

**接口地址**

```
GET http://149.88.65.193:8010/api/v1/user/commissions?page=1&page_size=50
```

**请求头**

```
Authorization: Bearer <access_token>
```

**查询参数**

| 参数      | 类型   | 必填 | 说明            |
| --------- | ------ | ---- | --------------- |
| page      | number | 是   | 页码，从 1 开始 |
| page_size | number | 是   | 每页条数        |

**返回示例**

```json
{
  "commissions": [],
  "pagination": {
    "page": 1,
    "page_size": 50,
    "total": 0,
    "total_pages": 0
  },
  "status": "success"
}
```

---

#### 2.5 查询推荐人

**接口地址**

```
GET http://149.88.65.193:8010/api/v1/user/my-referrer
```

**请求头**

```
Authorization: Bearer <access_token>
```

**返回示例**

```json
{
  "has_referrer": true,
  "level1_referrer": {
    "email": "15***@qq.com",
    "first_name": "",
    "id": 1,
    "last_name": ""
  },
  "level2_referrer": null,
  "status": "success"
}
```

**返回字段说明**

| 字段            | 类型        | 说明           |
| --------------- | ----------- | -------------- |
| has_referrer    | boolean     | 是否有推荐人   |
| level1_referrer | object/null | 一级推荐人信息 |
| level2_referrer | object/null | 二级推荐人信息 |

---

### 3. 开卡费支付模块

#### 3.1 获取开卡费配置

**接口地址**

```
GET http://149.88.65.193:8010/api/v1/CardFee/GetConfig?card_type=virtual
```

**请求头**

```
Authorization: Bearer <access_token>
```

**查询参数**

| 参数      | 类型   | 必填 | 说明                                      |
| --------- | ------ | ---- | ----------------------------------------- |
| card_type | string | 是   | 卡片类型：virtual=虚拟卡, physical=实体卡 |

**返回示例**

```json
{
  "config": {
    "id": 1,
    "card_type": "virtual",
    "fee_type": "flat",
    "fee_amount": 5,
    "IsActive": true,
    "description": "开卡费",
    "created_by": 1,
    "created_at": "2025-12-23T04:45:58.367215Z",
    "updated_at": "2025-12-23T04:45:58.367215Z"
  },
  "status": "success"
}
```

**返回字段说明**

| 字段       | 类型    | 说明                    |
| ---------- | ------- | ----------------------- |
| fee_type   | string  | 费用类型：flat=固定费用 |
| fee_amount | number  | 费用金额（USD）         |
| IsActive   | boolean | 是否启用                |

---

#### 3.2 获取支付币种

**接口地址**

```
GET http://149.88.65.193:8010/api/v1/CardFee/GetCurrencies
```

**请求头**

```
Authorization: Bearer <access_token>
```

**返回示例**

```json
{
  "currencies": [
    {
      "name": "USDT-TRC20",
      "symbol": "USDT",
      "coin_name": "TRC20-USDT",
      "logo": ""
    },
    {
      "name": "USDT-ERC20",
      "symbol": "USDT",
      "coin_name": "ERC20-USDT",
      "logo": ""
    }
  ],
  "status": "success"
}
```

**返回字段说明**

| 字段      | 类型   | 说明                       |
| --------- | ------ | -------------------------- |
| name      | string | 币种名称（用于支付时传参） |
| symbol    | string | 币种符号                   |
| coin_name | string | 币种全称                   |

---

#### 3.3 创建开卡费支付

**接口地址**

```
POST http://149.88.65.193:8010/api/v1/CardFee/CreatePayment
```

**请求头**

```
Authorization: Bearer <access_token>
```

**请求参数**

```json
{
  "card_type": "virtual",
  "coupon_code": "CPC59BAW69"
}
```

| 参数        | 类型   | 必填 | 说明                       |
| ----------- | ------ | ---- | -------------------------- |
| card_type   | string | 是   | 卡片类型：virtual/physical |
| coupon_code | string | 否   | 优惠券码                   |

**返回示例**

```json
{
  "message": "Payment created successfully",
  "payment": {
    "id": 1,
    "user_id": 1,
    "card_type": "virtual",
    "original_fee": 5,
    "coupon_discount": 1,
    "actual_payment": 4,
    "status": "pending",
    "transaction_ref": "CFP176646553143361",
    "created_at": "2025-12-23T04:52:11.54803641Z"
  },
  "status": "success"
}
```

**返回字段说明**

| 字段            | 类型   | 说明                       |
| --------------- | ------ | -------------------------- |
| transaction_ref | string | 交易参考号（用于完成支付） |
| original_fee    | number | 原始费用                   |
| coupon_discount | number | 优惠券折扣金额             |
| actual_payment  | number | 实际支付金额               |
| status          | string | 支付状态：pending=待支付   |

---

#### 3.4 完成支付

**接口地址**

```
POST http://149.88.65.193:8010/api/v1/CardFee/CompletePayment/:transaction_ref
```

**路径参数**

| 参数            | 说明                             |
| --------------- | -------------------------------- |
| transaction_ref | 交易参考号（从创建支付接口返回） |

**请求头**

```
Authorization: Bearer <access_token>
```

**请求参数**

```json
{
  "payment_currency": "USDT-TRC20"
}
```

| 参数             | 类型   | 必填 | 说明                                  |
| ---------------- | ------ | ---- | ------------------------------------- |
| payment_currency | string | 是   | 支付币种名称（从 GetCurrencies 获取） |

**说明**

- 支付币种对应 `yudun_supported_coins` 表的 `name` 字段
- 支持币种：USDT-TRC20, USDT-ERC20, USDC-TRC20, USDC-ERC20 等
- 系统会从用户对应币种的钱包余额中扣除（1:1 等值）

**返回示例**

```json
{
  "message": "Payment completed successfully",
  "payment": {
    "id": 1,
    "user_id": 1,
    "card_type": "virtual",
    "original_fee": 5,
    "coupon_discount": 1,
    "actual_payment": 4,
    "coupon_code": "CPC59BAW69",
    "coupon_name": "testame",
    "status": "completed",
    "payment_method": "USDT-TRC20",
    "transaction_ref": "CFP176646553143361",
    "paid_at": "2025-12-23T04:54:13.536069Z",
    "created_at": "2025-12-23T04:52:11.548036Z"
  },
  "status": "success"
}
```

**返回字段说明**

| 字段           | 类型   | 说明                       |
| -------------- | ------ | -------------------------- |
| status         | string | 支付状态：completed=已完成 |
| payment_method | string | 使用的支付方式             |
| paid_at        | string | 支付完成时间               |

---

#### 3.5 查询支付状态

**接口地址**

```
GET http://149.88.65.193:8010/api/v1/CardFee/GetPaymentStatus
```

**请求头**

```
Authorization: Bearer <access_token>
```

**返回示例**

```json
{
  "has_payment": true,
  "payment": {
    "id": 1,
    "user_id": 1,
    "card_type": "virtual",
    "original_fee": 5,
    "coupon_discount": 1,
    "actual_payment": 4,
    "coupon_code": "CPC59BAW69",
    "coupon_name": "testame",
    "status": "completed",
    "payment_method": "USDT-TRC20",
    "transaction_ref": "CFP176646553143361",
    "paid_at": "2025-12-23T04:54:13.536069Z",
    "created_at": "2025-12-23T04:52:11.548036Z"
  },
  "status": "success"
}
```

**返回字段说明**

| 字段        | 类型        | 说明           |
| ----------- | ----------- | -------------- |
| has_payment | boolean     | 是否有支付记录 |
| payment     | object/null | 支付信息对象   |

---

#### 3.6 查询支付历史

**接口地址**

```
GET http://149.88.65.193:8010/api/v1/CardFee/GetPaymentHistory?page=1&page_size=10
```

**请求头**

```
Authorization: Bearer <access_token>
```

**查询参数**

| 参数      | 类型   | 必填 | 说明            |
| --------- | ------ | ---- | --------------- |
| page      | number | 是   | 页码，从 1 开始 |
| page_size | number | 是   | 每页条数        |

**返回示例**

```json
{
  "page": 1,
  "page_size": 10,
  "payments": [
    {
      "id": 1,
      "user_id": 1,
      "card_type": "virtual",
      "original_fee": 5,
      "coupon_discount": 1,
      "actual_payment": 4,
      "coupon_code": "CPC59BAW69",
      "coupon_name": "testame",
      "status": "completed",
      "payment_method": "USDT-TRC20",
      "transaction_ref": "CFP176646553143361",
      "paid_at": "2025-12-23T04:54:13.536069Z",
      "created_at": "2025-12-23T04:52:11.548036Z"
    }
  ],
  "status": "success",
  "total": 1
}
```

---

### 4. KYC 资格模块

#### 4.1 检查开卡资格

**接口地址**

```
GET http://149.88.65.193:8010/api/v1/kyc/eligibility
```

**请求头**

```
Authorization: Bearer <access_token>
```

**返回示例**

```json
{
  "eligible": false,
  "payment_status": "none",
  "reason": "Card fee payment required before KYC verification",
  "required_action": "create_payment",
  "status": "success"
}
```

**返回字段说明**

| 字段            | 类型    | 说明                                    |
| --------------- | ------- | --------------------------------------- |
| eligible        | boolean | 是否有资格进行 KYC                      |
| payment_status  | string  | 支付状态：none=未支付, completed=已支付 |
| reason          | string  | 不符合资格的原因                        |
| required_action | string  | 需要采取的操作                          |

---

## 附录

### 基础信息

**基础 URL**

```
http://149.88.65.193:8010
```

**通用请求头**

```
Content-Type: application/json
Authorization: Bearer <access_token>
```

### 状态码说明

| 状态码 | 说明                       |
| ------ | -------------------------- |
| 200    | 请求成功                   |
| 400    | 请求参数错误               |
| 401    | 未授权（token 无效或过期） |
| 403    | 禁止访问                   |
| 404    | 资源不存在                 |
| 500    | 服务器内部错误             |

### 支付流程说明

1. **获取开卡费配置** - 确认需要支付的金额
2. **创建支付订单** - 可选使用优惠券，获得交易参考号
3. **完成支付** - 使用交易参考号和选择的币种完成支付
4. **查询支付状态** - 确认支付是否成功
5. **检查 KYC 资格** - 确认可以进行 KYC 认证

### 注册流程说明

1. **发送验证码** - 提供邮箱和邀请码（可选）
2. **验证 OTP** - 输入收到的验证码
3. **设置密码** - 完成注册，获得 access_token 和用户信息

---

_文档生成时间：2025-12-24_

---
title: 默认模块
language_tabs:
  - shell: Shell
  - http: HTTP
  - javascript: JavaScript
  - ruby: Ruby
  - python: Python
  - php: PHP
  - java: Java
  - go: Go
toc_footers: []
includes: []
search: true
code_clipboard: true
highlight_theme: darkula
headingLevel: 2
generator: "@tarslib/widdershins v4.0.30"

---

# 默认模块

ComeComePay 后端 API 服务 - 提供用户认证、钱包管理、卡片管理、KYC验证等功能

Base URLs:

# Authentication

* API Key (BearerAuth)
    - Parameter Name: **Authorization**, in: header. Bearer token 认证，格式: Bearer {token}

# 卡片

## GET 获取卡片账户详情

GET /card/account-details

卡片账户详情数据结构
获取指定卡片的账户详情，支持通过 public_token 或 card_id 查询

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|public_token|query|string| 否 |卡片公开 Token|
|card_id|query|string| 否 |卡片 ID，与 public_token 二选一|

> 返回示例

> 200 Response

```json
{
  "data": {
    "activate_time": 1757407090,
    "agent_id": 8,
    "amount": 2,
    "balance": 0,
    "bill_address": "",
    "card_expiry": 0,
    "card_id": 1,
    "card_no": "441353******0696",
    "card_scheme": "visa",
    "created_time": 1757407089,
    "cross_border_fee": 0,
    "currency_code": "HKD",
    "currency_id": 5,
    "day_quota": 10000,
    "deleted_time": 0,
    "expiry_date": "2030-09-30 08:00:00",
    "id": 764,
    "is_recharge": 1,
    "is_withdraw": 1,
    "kyc_id": 206,
    "member_name": "CVKI",
    "month_quota": 350000,
    "physical": false,
    "postal_code": "",
    "public_token": "123777693",
    "recharge_fee": 1,
    "recharge_max": 10000,
    "recharge_min": 10,
    "single_quota": 10000,
    "status": "normal",
    "transaction_fee": 1,
    "update_physical": false,
    "updated_time": 1757407090,
    "upgrade_amount": 40,
    "withdraw_fee": 2,
    "withdraw_max": 0,
    "withdraw_min": 50
  },
  "message": "Card account details retrieved successfully",
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|获取成功|[internal_handlers.GetCardAccountDetailsResponse](#schemainternal_handlers.getcardaccountdetailsresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

# 数据模型

<h2 id="tocS_internal_handlers.ErrorResponse">internal_handlers.ErrorResponse</h2>

<a id="schemainternal_handlers.errorresponse"></a>
<a id="schema_internal_handlers.ErrorResponse"></a>
<a id="tocSinternal_handlers.errorresponse"></a>
<a id="tocsinternal_handlers.errorresponse"></a>

```json
{
  "details": "详细错误信息",
  "error": "Invalid credentials"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|details|string|false|none||none|
|error|string|false|none||none|

<h2 id="tocS_internal_handlers.CardAccountDetailsData">internal_handlers.CardAccountDetailsData</h2>

<a id="schemainternal_handlers.cardaccountdetailsdata"></a>
<a id="schema_internal_handlers.CardAccountDetailsData"></a>
<a id="tocSinternal_handlers.cardaccountdetailsdata"></a>
<a id="tocsinternal_handlers.cardaccountdetailsdata"></a>

```json
{
  "activate_time": 1757407090,
  "agent_id": 8,
  "amount": 2,
  "balance": 0,
  "bill_address": "",
  "card_expiry": 0,
  "card_id": 1,
  "card_no": "441353******0696",
  "card_scheme": "visa",
  "created_time": 1757407089,
  "cross_border_fee": 0,
  "currency_code": "HKD",
  "currency_id": 5,
  "day_quota": 10000,
  "deleted_time": 0,
  "expiry_date": "2030-09-30 08:00:00",
  "id": 764,
  "is_recharge": 1,
  "is_withdraw": 1,
  "kyc_id": 206,
  "member_name": "CVKI",
  "month_quota": 350000,
  "physical": false,
  "postal_code": "",
  "public_token": "123777693",
  "recharge_fee": 1,
  "recharge_max": 10000,
  "recharge_min": 10,
  "single_quota": 10000,
  "status": "normal",
  "transaction_fee": 1,
  "update_physical": false,
  "updated_time": 1757407090,
  "upgrade_amount": 40,
  "withdraw_fee": 2,
  "withdraw_max": 0,
  "withdraw_min": 50
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|activate_time|integer|false|none||ActivateTime 激活时间，Unix 时间戳。|
|agent_id|integer|false|none||AgentID 代理商 ID。|
|amount|number|false|none||Amount 开卡费用。|
|balance|number|false|none||Balance 账户余额。|
|bill_address|string|false|none||BillAddress 账单地址。|
|card_expiry|integer|false|none||CardExpiry 有效期月份数。|
|card_id|integer|false|none||CardID 卡产品 ID。|
|card_no|string|false|none||CardNo 脱敏后的卡号。|
|card_scheme|string|false|none||CardScheme 卡组织，如 visa。|
|created_time|integer|false|none||CreatedTime 创建时间，Unix 时间戳。|
|cross_border_fee|number|false|none||CrossBorderFee 跨境手续费。|
|currency_code|string|false|none||CurrencyCode 币种代码。|
|currency_id|integer|false|none||CurrencyID 币种 ID。|
|day_quota|number|false|none||DayQuota 日消费额度。|
|deleted_time|integer|false|none||DeletedTime 删除时间，Unix 时间戳，未删除时通常为 0。|
|expiry_date|string|false|none||ExpiryDate 卡片过期时间。|
|id|integer|false|none||ID 卡记录 ID。|
|is_recharge|integer|false|none||IsRecharge 是否允许充值，1 表示允许。|
|is_withdraw|integer|false|none||IsWithdraw 是否允许提现，1 表示允许。|
|kyc_id|integer|false|none||KycID 关联的 KYC ID。|
|member_name|string|false|none||MemberName 持卡人或会员名称。|
|month_quota|number|false|none||MonthQuota 月消费额度。|
|physical|boolean|false|none||Physical 是否为实体卡。|
|postal_code|string|false|none||PostalCode 账单邮编。|
|public_token|string|false|none||PublicToken 卡片公开标识。|
|recharge_fee|number|false|none||RechargeFee 充值手续费率。|
|recharge_max|number|false|none||RechargeMax 充值最大限额。|
|recharge_min|number|false|none||RechargeMin 充值最小限额。|
|single_quota|number|false|none||SingleQuota 单笔消费额度。|
|status|string|false|none||Status 卡片状态。|
|transaction_fee|number|false|none||TransactionFee 消费手续费率。|
|update_physical|boolean|false|none||UpdatePhysical 是否已升级为实体卡。|
|updated_time|integer|false|none||UpdatedTime 更新时间，Unix 时间戳。|
|upgrade_amount|number|false|none||UpgradeAmount 升级实体卡费用。|
|withdraw_fee|number|false|none||WithdrawFee 提现手续费率。|
|withdraw_max|number|false|none||WithdrawMax 提现最大限额。|
|withdraw_min|number|false|none||WithdrawMin 提现最小限额。|

<h2 id="tocS_internal_handlers.GetCardAccountDetailsResponse">internal_handlers.GetCardAccountDetailsResponse</h2>

<a id="schemainternal_handlers.getcardaccountdetailsresponse"></a>
<a id="schema_internal_handlers.GetCardAccountDetailsResponse"></a>
<a id="tocSinternal_handlers.getcardaccountdetailsresponse"></a>
<a id="tocsinternal_handlers.getcardaccountdetailsresponse"></a>

```json
{
  "data": {
    "activate_time": 1757407090,
    "agent_id": 8,
    "amount": 2,
    "balance": 0,
    "bill_address": "",
    "card_expiry": 0,
    "card_id": 1,
    "card_no": "441353******0696",
    "card_scheme": "visa",
    "created_time": 1757407089,
    "cross_border_fee": 0,
    "currency_code": "HKD",
    "currency_id": 5,
    "day_quota": 10000,
    "deleted_time": 0,
    "expiry_date": "2030-09-30 08:00:00",
    "id": 764,
    "is_recharge": 1,
    "is_withdraw": 1,
    "kyc_id": 206,
    "member_name": "CVKI",
    "month_quota": 350000,
    "physical": false,
    "postal_code": "",
    "public_token": "123777693",
    "recharge_fee": 1,
    "recharge_max": 10000,
    "recharge_min": 10,
    "single_quota": 10000,
    "status": "normal",
    "transaction_fee": 1,
    "update_physical": false,
    "updated_time": 1757407090,
    "upgrade_amount": 40,
    "withdraw_fee": 2,
    "withdraw_max": 0,
    "withdraw_min": 50
  },
  "message": "Card account details retrieved successfully",
  "status": "success"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|data|[internal_handlers.CardAccountDetailsData](#schemainternal_handlers.cardaccountdetailsdata)|false|none||Data 卡片账户详情数据。|
|message|string|false|none||Message 响应消息。|
|status|string|false|none||Status 响应状态。|


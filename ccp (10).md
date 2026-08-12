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

## POST 用户确认实体卡收货

POST /card/physical-application/{id}/confirm-delivery

用户确认已收到实体卡，申请必须处于已发货状态；重复确认已签收申请会幂等返回成功

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|id|path|integer| 是 |实体卡申请ID|

> 返回示例

> 200 Response

```json
{
  "application": {
    "created_at": "2024-01-01T00:00:00Z",
    "delivered_at": "2024-01-08T00:00:00Z",
    "id": 1,
    "reject_reason": "地址信息不完整",
    "shipped_at": "2024-01-05T00:00:00Z",
    "status": "pending",
    "status_text": "待审核",
    "tracking_number": "SF1234567890"
  },
  "message": "Delivery confirmed successfully",
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|确认收货成功|[internal_handlers.ConfirmPhysicalCardDeliveryResponse](#schemainternal_handlers.confirmphysicalcarddeliveryresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|申请不存在或不属于当前用户|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|409|[Conflict](https://tools.ietf.org/html/rfc7231#section-6.5.8)|当前状态不能确认收货|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

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

<h2 id="tocS_internal_handlers.ConfirmPhysicalCardDeliveryResponse">internal_handlers.ConfirmPhysicalCardDeliveryResponse</h2>

<a id="schemainternal_handlers.confirmphysicalcarddeliveryresponse"></a>
<a id="schema_internal_handlers.ConfirmPhysicalCardDeliveryResponse"></a>
<a id="tocSinternal_handlers.confirmphysicalcarddeliveryresponse"></a>
<a id="tocsinternal_handlers.confirmphysicalcarddeliveryresponse"></a>

```json
{
  "application": {
    "created_at": "2024-01-01T00:00:00Z",
    "delivered_at": "2024-01-08T00:00:00Z",
    "id": 1,
    "reject_reason": "地址信息不完整",
    "shipped_at": "2024-01-05T00:00:00Z",
    "status": "pending",
    "status_text": "待审核",
    "tracking_number": "SF1234567890"
  },
  "message": "Delivery confirmed successfully",
  "status": "success"
}

```

用户确认实体卡已收货后的申请状态

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|application|[internal_handlers.PhysicalCardApplicationResponse](#schemainternal_handlers.physicalcardapplicationresponse)|false|none||实体卡申请详情|
|message|string|false|none||none|
|status|string|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalCardApplicationResponse">internal_handlers.PhysicalCardApplicationResponse</h2>

<a id="schemainternal_handlers.physicalcardapplicationresponse"></a>
<a id="schema_internal_handlers.PhysicalCardApplicationResponse"></a>
<a id="tocSinternal_handlers.physicalcardapplicationresponse"></a>
<a id="tocsinternal_handlers.physicalcardapplicationresponse"></a>

```json
{
  "created_at": "2024-01-01T00:00:00Z",
  "delivered_at": "2024-01-08T00:00:00Z",
  "id": 1,
  "reject_reason": "地址信息不完整",
  "shipped_at": "2024-01-05T00:00:00Z",
  "status": "pending",
  "status_text": "待审核",
  "tracking_number": "SF1234567890"
}

```

实体卡申请详情

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|created_at|string|false|none||创建时间|
|delivered_at|string|false|none||签收时间|
|id|integer|false|none||申请ID|
|reject_reason|string|false|none||拒绝原因（被拒绝时返回）|
|shipped_at|string|false|none||发货时间|
|status|string|false|none||申请状态：pending/approved/rejected/shipped/delivered|
|status_text|string|false|none||状态中文描述|
|tracking_number|string|false|none||快递单号（已发货/已签收时返回）|


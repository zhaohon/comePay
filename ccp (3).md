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

# 3DS用户

## GET 获取我的3DS验证码记录

GET /3ds/my-records

查询当前登录用户的3DS验证码记录，支持分页。只返回必要信息（验证码、金额、商户、有效期、接收时间），保护用户隐私。

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|page|query|integer| 否 |页码|
|page_size|query|integer| 否 |每页数量|

> 返回示例

> 200 Response

```json
{
  "data": {
    "page": 1,
    "page_size": 20,
    "records": [
      {
        "amount": "100.00",
        "currency": "USD",
        "expires_after": 300,
        "id": 1,
        "merchant_name": "Amazon",
        "passcode": "123456",
        "received_at": "2026-01-20T10:30:00Z"
      }
    ],
    "total": 50,
    "total_pages": 3
  },
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|查询成功|[handlers.GetMyThreeDSRecordsResponseSwagger](#schemahandlers.getmythreedsrecordsresponseswagger)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器错误|[handlers.ErrorResponse](#schemahandlers.errorresponse)|

# 数据模型

<h2 id="tocS_handlers.ErrorResponse">handlers.ErrorResponse</h2>

<a id="schemahandlers.errorresponse"></a>
<a id="schema_handlers.ErrorResponse"></a>
<a id="tocShandlers.errorresponse"></a>
<a id="tocshandlers.errorresponse"></a>

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

<h2 id="tocS_handlers.GetMyThreeDSRecordsResponseSwagger">handlers.GetMyThreeDSRecordsResponseSwagger</h2>

<a id="schemahandlers.getmythreedsrecordsresponseswagger"></a>
<a id="schema_handlers.GetMyThreeDSRecordsResponseSwagger"></a>
<a id="tocShandlers.getmythreedsrecordsresponseswagger"></a>
<a id="tocshandlers.getmythreedsrecordsresponseswagger"></a>

```json
{
  "data": {
    "page": 1,
    "page_size": 20,
    "records": [
      {
        "amount": "100.00",
        "currency": "USD",
        "expires_after": 300,
        "id": 1,
        "merchant_name": "Amazon",
        "passcode": "123456",
        "received_at": "2026-01-20T10:30:00Z"
      }
    ],
    "total": 50,
    "total_pages": 3
  },
  "status": "success"
}

```

用户端3DS记录查询响应

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|data|[handlers.ThreeDSRecordSimpleQueryResponseSwagger](#schemahandlers.threedsrecordsimplequeryresponseswagger)|false|none||记录数据|
|status|string|false|none||响应状态|

<h2 id="tocS_handlers.ThreeDSRecordSimpleQueryResponseSwagger">handlers.ThreeDSRecordSimpleQueryResponseSwagger</h2>

<a id="schemahandlers.threedsrecordsimplequeryresponseswagger"></a>
<a id="schema_handlers.ThreeDSRecordSimpleQueryResponseSwagger"></a>
<a id="tocShandlers.threedsrecordsimplequeryresponseswagger"></a>
<a id="tocshandlers.threedsrecordsimplequeryresponseswagger"></a>

```json
{
  "page": 1,
  "page_size": 20,
  "records": [
    {
      "amount": "100.00",
      "currency": "USD",
      "expires_after": 300,
      "id": 1,
      "merchant_name": "Amazon",
      "passcode": "123456",
      "received_at": "2026-01-20T10:30:00Z"
    }
  ],
  "total": 50,
  "total_pages": 3
}

```

用户端3DS记录查询响应，包含分页信息

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|page|integer|false|none||当前页码|
|page_size|integer|false|none||每页数量|
|records|[[handlers.ThreeDSRecordSimpleSwagger](#schemahandlers.threedsrecordsimpleswagger)]|false|none||记录列表|
|total|integer|false|none||总记录数|
|total_pages|integer|false|none||总页数|

<h2 id="tocS_handlers.ThreeDSRecordSimpleSwagger">handlers.ThreeDSRecordSimpleSwagger</h2>

<a id="schemahandlers.threedsrecordsimpleswagger"></a>
<a id="schema_handlers.ThreeDSRecordSimpleSwagger"></a>
<a id="tocShandlers.threedsrecordsimpleswagger"></a>
<a id="tocshandlers.threedsrecordsimpleswagger"></a>

```json
{
  "amount": "100.00",
  "currency": "USD",
  "expires_after": 300,
  "id": 1,
  "merchant_name": "Amazon",
  "passcode": "123456",
  "received_at": "2026-01-20T10:30:00Z"
}

```

用户端3DS验证码记录，只包含必要信息

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|amount|string|false|none||交易金额|
|currency|string|false|none||货币代码|
|expires_after|integer|false|none||有效期(秒)|
|id|integer|false|none||记录ID|
|merchant_name|string|false|none||商户名称|
|passcode|string|false|none||验证码|
|received_at|string|false|none||接收时间|


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

## GET 查询卡片PIN码

GET /card/{publicToken}/pin

通过 publicToken 查询卡片的PIN码。虚拟卡和实体卡都可使用，且必须先发送邮箱验证码并携带 otp_code。合规要求：请勿存储返回的PIN码。

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|publicToken|path|string| 是 |卡片公开Token|
|otp_code|query|string| 是 |邮箱验证码（需先调用发送验证码接口，purpose=card_pin_query）|

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": {
    "pin": "3814"
  },
  "errstr": "SUCCESS",
  "request_id": ""
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|查询成功|[internal_handlers.GetCardPinByTokenSwaggerResponse](#schemainternal_handlers.getcardpinbytokenswaggerresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|卡片不属于当前用户|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|502|[Bad Gateway](https://tools.ietf.org/html/rfc7231#section-6.6.3)|PokePay API 错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

## POST 设置卡片PIN码

POST /card/{publicToken}/pin

设置卡片PIN码。虚拟卡和实体卡都可使用。需先调用发送验证码接口并传 purpose=card_pin_activate 获取验证码，请求体须包含 otp_code 进行校验。

> Body 请求参数

```json
{
  "otp_code": "12345",
  "pin": "1234"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|publicToken|path|string| 是 |卡片公开Token|
|body|body|[internal_handlers.SetCardPinActivateSwaggerRequest](#schemainternal_handlers.setcardpinactivateswaggerrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": null,
  "errstr": "SUCCESS",
  "request_id": ""
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|设置成功|[internal_handlers.SetCardPinActivateSwaggerResponse](#schemainternal_handlers.setcardpinactivateswaggerresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|卡片不属于当前用户|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|502|[Bad Gateway](https://tools.ietf.org/html/rfc7231#section-6.6.3)|PokePay API 错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

## POST 发送卡片PIN邮箱验证码

POST /card/{publicToken}/pin/code/send

向用户注册邮箱发送5位验证码，用于查询PIN或设置PIN。虚拟卡和实体卡都可使用。验证码有效期10分钟，60秒内不可重复发送。

> Body 请求参数

```json
{
  "purpose": "card_pin_query"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|publicToken|path|string| 是 |卡片公开Token|
|body|body|[internal_handlers.SendCardPinCodeSwaggerRequest](#schemainternal_handlers.sendcardpincodeswaggerrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": {
    "public_token": "123774296",
    "purpose": "card_pin_query",
    "sent": true
  },
  "errstr": "SUCCESS",
  "request_id": "pin_code_10001_1709445600"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|发送成功|[internal_handlers.SendCardPinCodeSwaggerResponse](#schemainternal_handlers.sendcardpincodeswaggerresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|卡片不属于当前用户|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|429|[Too Many Requests](https://tools.ietf.org/html/rfc6585#section-4)|发送频率受限（60秒内仅可发送一次）|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
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

<h2 id="tocS_internal_handlers.GetCardPinByTokenData">internal_handlers.GetCardPinByTokenData</h2>

<a id="schemainternal_handlers.getcardpinbytokendata"></a>
<a id="schema_internal_handlers.GetCardPinByTokenData"></a>
<a id="tocSinternal_handlers.getcardpinbytokendata"></a>
<a id="tocsinternal_handlers.getcardpinbytokendata"></a>

```json
{
  "pin": "3814"
}

```

合规要求：请勿存储返回的PIN码

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|pin|string|false|none||PIN码，合规要求请勿存储|

<h2 id="tocS_internal_handlers.GetCardPinByTokenSwaggerResponse">internal_handlers.GetCardPinByTokenSwaggerResponse</h2>

<a id="schemainternal_handlers.getcardpinbytokenswaggerresponse"></a>
<a id="schema_internal_handlers.GetCardPinByTokenSwaggerResponse"></a>
<a id="tocSinternal_handlers.getcardpinbytokenswaggerresponse"></a>
<a id="tocsinternal_handlers.getcardpinbytokenswaggerresponse"></a>

```json
{
  "code": 200,
  "data": {
    "pin": "3814"
  },
  "errstr": "SUCCESS",
  "request_id": ""
}

```

通过 publicToken 查询卡片PIN码的响应

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||成功均为200，非200为失败|
|data|[internal_handlers.GetCardPinByTokenData](#schemainternal_handlers.getcardpinbytokendata)|false|none||返回数据|
|errstr|string|false|none||状态描述|
|request_id|string|false|none||请求ID|

<h2 id="tocS_internal_handlers.SendCardPinCodeData">internal_handlers.SendCardPinCodeData</h2>

<a id="schemainternal_handlers.sendcardpincodedata"></a>
<a id="schema_internal_handlers.SendCardPinCodeData"></a>
<a id="tocSinternal_handlers.sendcardpincodedata"></a>
<a id="tocsinternal_handlers.sendcardpincodedata"></a>

```json
{
  "public_token": "123774296",
  "purpose": "card_pin_query",
  "sent": true
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|public_token|string|false|none||卡片 public_token|
|purpose|string|false|none||验证码用途|
|sent|boolean|false|none||是否发送成功|

<h2 id="tocS_internal_handlers.SendCardPinCodeSwaggerRequest">internal_handlers.SendCardPinCodeSwaggerRequest</h2>

<a id="schemainternal_handlers.sendcardpincodeswaggerrequest"></a>
<a id="schema_internal_handlers.SendCardPinCodeSwaggerRequest"></a>
<a id="tocSinternal_handlers.sendcardpincodeswaggerrequest"></a>
<a id="tocsinternal_handlers.sendcardpincodeswaggerrequest"></a>

```json
{
  "purpose": "card_pin_query"
}

```

发送验证码到用户注册邮箱，用于查询PIN或设置PIN

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|purpose|string|true|none||用途：card_pin_query 或 card_pin_activate|

<h2 id="tocS_internal_handlers.SendCardPinCodeSwaggerResponse">internal_handlers.SendCardPinCodeSwaggerResponse</h2>

<a id="schemainternal_handlers.sendcardpincodeswaggerresponse"></a>
<a id="schema_internal_handlers.SendCardPinCodeSwaggerResponse"></a>
<a id="tocSinternal_handlers.sendcardpincodeswaggerresponse"></a>
<a id="tocsinternal_handlers.sendcardpincodeswaggerresponse"></a>

```json
{
  "code": 200,
  "data": {
    "public_token": "123774296",
    "purpose": "card_pin_query",
    "sent": true
  },
  "errstr": "SUCCESS",
  "request_id": "pin_code_10001_1709445600"
}

```

发送验证码成功后返回的响应

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||成功均为200，非200为失败|
|data|[internal_handlers.SendCardPinCodeData](#schemainternal_handlers.sendcardpincodedata)|false|none||返回数据|
|errstr|string|false|none||状态描述|
|request_id|string|false|none||请求ID|

<h2 id="tocS_internal_handlers.SetCardPinActivateSwaggerRequest">internal_handlers.SetCardPinActivateSwaggerRequest</h2>

<a id="schemainternal_handlers.setcardpinactivateswaggerrequest"></a>
<a id="schema_internal_handlers.SetCardPinActivateSwaggerRequest"></a>
<a id="tocSinternal_handlers.setcardpinactivateswaggerrequest"></a>
<a id="tocsinternal_handlers.setcardpinactivateswaggerrequest"></a>

```json
{
  "otp_code": "12345",
  "pin": "1234"
}

```

设置卡片PIN码，需提供用于设置PIN的邮箱验证码和4-6位纯数字PIN

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|otp_code|string|true|none||邮箱验证码|
|pin|string|true|none||PIN码，4-6位纯数字|

<h2 id="tocS_internal_handlers.SetCardPinActivateSwaggerResponse">internal_handlers.SetCardPinActivateSwaggerResponse</h2>

<a id="schemainternal_handlers.setcardpinactivateswaggerresponse"></a>
<a id="schema_internal_handlers.SetCardPinActivateSwaggerResponse"></a>
<a id="tocSinternal_handlers.setcardpinactivateswaggerresponse"></a>
<a id="tocsinternal_handlers.setcardpinactivateswaggerresponse"></a>

```json
{
  "code": 200,
  "data": null,
  "errstr": "SUCCESS",
  "request_id": ""
}

```

设置卡片PIN成功后返回的响应

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||成功均为200，非200为失败|
|data|any|false|none||返回数据，成功时为null|
|errstr|string|false|none||状态描述|
|request_id|string|false|none||请求ID|


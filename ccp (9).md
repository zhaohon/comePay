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

## GET 查询实体卡PIN码

GET /card/{publicToken}/pin

通过 publicToken 查询实体卡的PIN码。合规要求：请勿存储返回的PIN码。

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|publicToken|path|string| 是 |卡片公开Token|

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

通过 publicToken 查询实体卡PIN码的响应

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||成功均为200，非200为失败|
|data|[internal_handlers.GetCardPinByTokenData](#schemainternal_handlers.getcardpinbytokendata)|false|none||返回数据|
|errstr|string|false|none||状态描述|
|request_id|string|false|none||请求ID|


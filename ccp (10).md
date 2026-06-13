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

## PUT 修改卡片3DS认证方式

PUT /card/3ds

修改当前用户持有卡片的3DS认证方式，支持 OTP、BIO 或 ALL。只有PokePay接受变更后才更新本地卡片状态。

> Body 请求参数

```json
{
  "plan": "BIO",
  "public_token": "123456"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[handlers.UpdateCardThreeDSPlanRequest](#schemahandlers.updatecardthreedsplanrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "data": {
    "public_token": "123456",
    "request_id": "req_123",
    "three_ds_auth_plan": "BIO"
  },
  "message": "Card 3DS authentication plan updated successfully",
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|修改成功|[handlers.UpdateCardThreeDSPlanResponse](#schemahandlers.updatecardthreedsplanresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|卡片不存在|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|502|[Bad Gateway](https://tools.ietf.org/html/rfc7231#section-6.6.3)|PokePay API 错误|[handlers.ErrorResponse](#schemahandlers.errorresponse)|

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

<h2 id="tocS_handlers.UpdateCardThreeDSPlanRequest">handlers.UpdateCardThreeDSPlanRequest</h2>

<a id="schemahandlers.updatecardthreedsplanrequest"></a>
<a id="schema_handlers.UpdateCardThreeDSPlanRequest"></a>
<a id="tocShandlers.updatecardthreedsplanrequest"></a>
<a id="tocshandlers.updatecardthreedsplanrequest"></a>

```json
{
  "plan": "BIO",
  "public_token": "123456"
}

```

将当前用户持有卡片的3DS认证方式切换为 OTP、BIO 或 ALL

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|plan|string|true|none||认证方式: OTP=验证码, BIO=App推送确认, ALL=两者都支持|
|public_token|string|true|none||卡片 Public Token|

#### 枚举值

|属性|值|
|---|---|
|plan|OTP|
|plan|BIO|
|plan|ALL|

<h2 id="tocS_handlers.UpdateCardThreeDSPlanResponse">handlers.UpdateCardThreeDSPlanResponse</h2>

<a id="schemahandlers.updatecardthreedsplanresponse"></a>
<a id="schema_handlers.UpdateCardThreeDSPlanResponse"></a>
<a id="tocShandlers.updatecardthreedsplanresponse"></a>
<a id="tocshandlers.updatecardthreedsplanresponse"></a>

```json
{
  "data": {
    "public_token": "123456",
    "request_id": "req_123",
    "three_ds_auth_plan": "BIO"
  },
  "message": "Card 3DS authentication plan updated successfully",
  "status": "success"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|data|[handlers.UpdateCardThreeDSPlanResponseData](#schemahandlers.updatecardthreedsplanresponsedata)|false|none||none|
|message|string|false|none||none|
|status|string|false|none||none|

<h2 id="tocS_handlers.UpdateCardThreeDSPlanResponseData">handlers.UpdateCardThreeDSPlanResponseData</h2>

<a id="schemahandlers.updatecardthreedsplanresponsedata"></a>
<a id="schema_handlers.UpdateCardThreeDSPlanResponseData"></a>
<a id="tocShandlers.updatecardthreedsplanresponsedata"></a>
<a id="tocshandlers.updatecardthreedsplanresponsedata"></a>

```json
{
  "public_token": "123456",
  "request_id": "req_123",
  "three_ds_auth_plan": "BIO"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|public_token|string|false|none||none|
|request_id|string|false|none||none|
|three_ds_auth_plan|string|false|none||none|

#### 枚举值

|属性|值|
|---|---|
|three_ds_auth_plan|OTP|
|three_ds_auth_plan|BIO|
|three_ds_auth_plan|ALL|


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

# 钱包

## POST UID转账

POST /wallet/transfer-by-uid

通过收款用户UID向其他用户钱包转账，需校验交易密码

> Body 请求参数

```json
{
  "amount": 100,
  "currency": "USD",
  "description": "Internal transfer",
  "recipient_uid": 100001,
  "transaction_password": "123456"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[internal_handlers.TransferMoneyByUIDRequest](#schemainternal_handlers.transfermoneybyuidrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "currency": "USD",
  "message": "Transfer completed successfully",
  "new_balance": 900,
  "recipient_uid": 100001,
  "recipient_wallet_id": "CCP1234567890",
  "status": "success",
  "transaction_id": 1
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|转账成功|[internal_handlers.TransferMoneyByUIDResponse](#schemainternal_handlers.transfermoneybyuidresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误、交易密码错误、钱包未激活或余额不足|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|收款用户或钱包不存在|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
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

<h2 id="tocS_internal_handlers.TransferMoneyByUIDRequest">internal_handlers.TransferMoneyByUIDRequest</h2>

<a id="schemainternal_handlers.transfermoneybyuidrequest"></a>
<a id="schema_internal_handlers.TransferMoneyByUIDRequest"></a>
<a id="tocSinternal_handlers.transfermoneybyuidrequest"></a>
<a id="tocsinternal_handlers.transfermoneybyuidrequest"></a>

```json
{
  "amount": 100,
  "currency": "USD",
  "description": "Internal transfer",
  "recipient_uid": 100001,
  "transaction_password": "123456"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|amount|number|true|none||none|
|currency|string|false|none||none|
|description|string|false|none||none|
|recipient_uid|integer|true|none||none|
|transaction_password|string|true|none||6位交易密码|

<h2 id="tocS_internal_handlers.TransferMoneyByUIDResponse">internal_handlers.TransferMoneyByUIDResponse</h2>

<a id="schemainternal_handlers.transfermoneybyuidresponse"></a>
<a id="schema_internal_handlers.TransferMoneyByUIDResponse"></a>
<a id="tocSinternal_handlers.transfermoneybyuidresponse"></a>
<a id="tocsinternal_handlers.transfermoneybyuidresponse"></a>

```json
{
  "currency": "USD",
  "message": "Transfer completed successfully",
  "new_balance": 900,
  "recipient_uid": 100001,
  "recipient_wallet_id": "CCP1234567890",
  "status": "success",
  "transaction_id": 1
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|currency|string|false|none||none|
|message|string|false|none||none|
|new_balance|number|false|none||none|
|recipient_uid|integer|false|none||none|
|recipient_wallet_id|string|false|none||none|
|status|string|false|none||none|
|transaction_id|integer|false|none||none|


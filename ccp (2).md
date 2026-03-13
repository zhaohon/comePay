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

# 用户

## GET 获取交易密码设置状态

GET /user/transaction-password/status

查询当前登录用户是否已设置交易密码

> 返回示例

> 200 Response

```json
{
  "is_set": true,
  "message": "Transaction password status retrieved successfully",
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|获取成功|[internal_handlers.GetTransactionPasswordStatusResponse](#schemainternal_handlers.gettransactionpasswordstatusresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|用户不存在|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

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

<h2 id="tocS_internal_handlers.GetTransactionPasswordStatusResponse">internal_handlers.GetTransactionPasswordStatusResponse</h2>

<a id="schemainternal_handlers.gettransactionpasswordstatusresponse"></a>
<a id="schema_internal_handlers.GetTransactionPasswordStatusResponse"></a>
<a id="tocSinternal_handlers.gettransactionpasswordstatusresponse"></a>
<a id="tocsinternal_handlers.gettransactionpasswordstatusresponse"></a>

```json
{
  "is_set": true,
  "message": "Transaction password status retrieved successfully",
  "status": "success"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|is_set|boolean|false|none||IsSet 是否已设置交易密码|
|message|string|false|none||Message 响应消息|
|status|string|false|none||Status 响应状态|


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

- API Key (BearerAuth)
  - Parameter Name: **Authorization**, in: header. Bearer token 认证，格式: Bearer {token}

# 用户

## POST 完成交易密码设置

POST /user/transaction-password/complete

验证邮箱 OTP 并结合第一步返回的 temp_hash 完成交易密码设置

> Body 请求参数

```json
{
  "otp_code": "123456",
  "temp_hash": "$2a$14$abcdefghijklmnopqrstuv"
}
```

### 请求参数

| 名称 | 位置 | 类型                                                                                                                            | 必选 | 说明 |
| ---- | ---- | ------------------------------------------------------------------------------------------------------------------------------- | ---- | ---- |
| body | body | [internal_handlers.CompleteTransactionPasswordChangeRequest](#schemainternal_handlers.completetransactionpasswordchangerequest) | 是   | none |

> 返回示例

> 200 Response

```json
{
  "message": "Transaction password set successfully",
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明                                | 数据模型                                                                                                                          |
| ------ | -------------------------------------------------------------------------- | ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 交易密码设置成功                    | [internal_handlers.CompleteTransactionPasswordChangeResponse](#schemainternal_handlers.completetransactionpasswordchangeresponse) |
| 400    | [Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)           | 验证码无效、已过期或 temp_hash 缺失 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                                                         |
| 401    | [Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)            | 未授权                              | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                                                         |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误                      | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                                                         |

## POST 请求设置/修改交易密码

POST /user/transaction-password/request

请求设置或修改交易密码，系统发送 OTP 验证码到邮箱，并返回第二步所需的 temp_hash

> Body 请求参数

```json
{
  "confirm_transaction_password": "123456",
  "transaction_password": "123456"
}
```

### 请求参数

| 名称 | 位置 | 类型                                                                                                                          | 必选 | 说明 |
| ---- | ---- | ----------------------------------------------------------------------------------------------------------------------------- | ---- | ---- |
| body | body | [internal_handlers.RequestTransactionPasswordChangeRequest](#schemainternal_handlers.requesttransactionpasswordchangerequest) | 是   | none |

> 返回示例

> 200 Response

```json
{
  "email": "user@example.com",
  "message": "OTP sent to your email. Please verify to set your transaction password.",
  "next_step": "verify_transaction_password_otp",
  "otp": "123456",
  "status": "success",
  "temp_hash": "$2a$14$abcdefghijklmnopqrstuv"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明                                   | 数据模型                                                                                                                        |
| ------ | -------------------------------------------------------------------------- | -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | OTP 已发送到邮箱                       | [internal_handlers.RequestTransactionPasswordChangeResponse](#schemainternal_handlers.requesttransactionpasswordchangeresponse) |
| 400    | [Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)           | 请求参数错误或两次输入的交易密码不一致 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                                                       |
| 401    | [Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)            | 未授权                                 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                                                       |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误                         | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                                                       |

# 数据模型

<h2 id="tocS_internal_handlers.CompleteTransactionPasswordChangeRequest">internal_handlers.CompleteTransactionPasswordChangeRequest</h2>

<a id="schemainternal_handlers.completetransactionpasswordchangerequest"></a>
<a id="schema_internal_handlers.CompleteTransactionPasswordChangeRequest"></a>
<a id="tocSinternal_handlers.completetransactionpasswordchangerequest"></a>
<a id="tocsinternal_handlers.completetransactionpasswordchangerequest"></a>

```json
{
  "otp_code": "123456",
  "temp_hash": "$2a$14$abcdefghijklmnopqrstuv"
}
```

### 属性

| 名称      | 类型   | 必选 | 约束 | 中文名 | 说明                          |
| --------- | ------ | ---- | ---- | ------ | ----------------------------- |
| otp_code  | string | true | none |        | OTPCode 邮箱收到的验证码      |
| temp_hash | string | true | none |        | TempHash 第一步返回的临时哈希 |

<h2 id="tocS_internal_handlers.CompleteTransactionPasswordChangeResponse">internal_handlers.CompleteTransactionPasswordChangeResponse</h2>

<a id="schemainternal_handlers.completetransactionpasswordchangeresponse"></a>
<a id="schema_internal_handlers.CompleteTransactionPasswordChangeResponse"></a>
<a id="tocSinternal_handlers.completetransactionpasswordchangeresponse"></a>
<a id="tocsinternal_handlers.completetransactionpasswordchangeresponse"></a>

```json
{
  "message": "Transaction password set successfully",
  "status": "success"
}
```

### 属性

| 名称    | 类型   | 必选  | 约束 | 中文名 | 说明 |
| ------- | ------ | ----- | ---- | ------ | ---- |
| message | string | false | none |        | none |
| status  | string | false | none |        | none |

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

| 名称    | 类型   | 必选  | 约束 | 中文名 | 说明 |
| ------- | ------ | ----- | ---- | ------ | ---- |
| details | string | false | none |        | none |
| error   | string | false | none |        | none |

<h2 id="tocS_internal_handlers.RequestTransactionPasswordChangeRequest">internal_handlers.RequestTransactionPasswordChangeRequest</h2>

<a id="schemainternal_handlers.requesttransactionpasswordchangerequest"></a>
<a id="schema_internal_handlers.RequestTransactionPasswordChangeRequest"></a>
<a id="tocSinternal_handlers.requesttransactionpasswordchangerequest"></a>
<a id="tocsinternal_handlers.requesttransactionpasswordchangerequest"></a>

```json
{
  "confirm_transaction_password": "123456",
  "transaction_password": "123456"
}
```

### 属性

| 名称                         | 类型   | 必选 | 约束 | 中文名 | 说明                                    |
| ---------------------------- | ------ | ---- | ---- | ------ | --------------------------------------- |
| confirm_transaction_password | string | true | none |        | ConfirmTransactionPassword 确认交易密码 |
| transaction_password         | string | true | none |        | TransactionPassword 新的6位交易密码     |

<h2 id="tocS_internal_handlers.RequestTransactionPasswordChangeResponse">internal_handlers.RequestTransactionPasswordChangeResponse</h2>

<a id="schemainternal_handlers.requesttransactionpasswordchangeresponse"></a>
<a id="schema_internal_handlers.RequestTransactionPasswordChangeResponse"></a>
<a id="tocSinternal_handlers.requesttransactionpasswordchangeresponse"></a>
<a id="tocsinternal_handlers.requesttransactionpasswordchangeresponse"></a>

```json
{
  "email": "user@example.com",
  "message": "OTP sent to your email. Please verify to set your transaction password.",
  "next_step": "verify_transaction_password_otp",
  "otp": "123456",
  "status": "success",
  "temp_hash": "$2a$14$abcdefghijklmnopqrstuv"
}
```

### 属性

| 名称      | 类型   | 必选  | 约束 | 中文名 | 说明                                                    |
| --------- | ------ | ----- | ---- | ------ | ------------------------------------------------------- |
| email     | string | false | none |        | Email 接收验证码的邮箱                                  |
| message   | string | false | none |        | Message 响应消息                                        |
| next_step | string | false | none |        | NextStep 下一步操作提示                                 |
| otp       | string | false | none |        | OTP 测试环境返回的验证码                                |
| status    | string | false | none |        | Status 响应状态                                         |
| temp_hash | string | false | none |        | TempHash 第一阶段返回的临时哈希，第二阶段提交时需要携带 |

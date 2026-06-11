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

## PUT 确认或拒绝BIO 3DS挑战

PUT /3ds/messages/{notification_id}/confirm

当前用户对自己的BIO 3DS挑战提交SUCCESS或FAILURE，后端转发给PokePay

> Body 请求参数

```json
{
  "status": "SUCCESS"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|notification_id|path|string| 是 |通知ID|
|body|body|[handlers.ConfirmThreeDSMessageRequest](#schemahandlers.confirmthreedsmessagerequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "message": "3DS challenge confirmed",
  "record": {
    "amount": "string",
    "app_notification_error": "string",
    "app_notification_sent": true,
    "auth_method": "OTP",
    "challenge_expires_at": "string",
    "challenge_status": "OTP_SENT",
    "confirmation_status": "string",
    "confirmed_at": "string",
    "confirmed_by_user_id": 0,
    "created_at": "string",
    "currency": "string",
    "delegate_method": "string",
    "delegate_sca_id": "string",
    "delegate_status": "string",
    "ds_transaction_id": "string",
    "email_notification_error": "string",
    "email_notification_sent": true,
    "expires_after": 0,
    "id": 0,
    "merchant_id": "string",
    "merchant_name": "string",
    "notification_id": "string",
    "passcode": "string",
    "provider_error": "string",
    "provider_request": "string",
    "provider_request_id": "string",
    "provider_response": "string",
    "pubtoken": 0,
    "raw_data": "string",
    "received_at": "string",
    "transaction_token": "string",
    "updated_at": "string",
    "user_id": 0
  },
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|确认成功|[handlers.ConfirmThreeDSMessageResponse](#schemahandlers.confirmthreedsmessageresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器错误|[handlers.ErrorResponse](#schemahandlers.errorresponse)|

## GET 获取我的3DS挑战记录

GET /3ds/my-records

查询当前登录用户的3DS记录，支持分页。OTP记录返回验证码；BIO记录返回认证方式、挑战状态、过期时间和确认结果。

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
        "auth_method": "BIO",
        "challenge_expires_at": "2026-01-20T10:40:00Z",
        "challenge_status": "UNCONFIRMED",
        "confirmation_status": "SUCCESS",
        "confirmed_at": "2026-01-20T10:32:00Z",
        "currency": "USD",
        "expires_after": 600,
        "id": 1,
        "merchant_id": "merchant-123",
        "merchant_name": "Amazon",
        "notification_id": "notif_123",
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

<h2 id="tocS_handlers.ConfirmThreeDSMessageRequest">handlers.ConfirmThreeDSMessageRequest</h2>

<a id="schemahandlers.confirmthreedsmessagerequest"></a>
<a id="schema_handlers.ConfirmThreeDSMessageRequest"></a>
<a id="tocShandlers.confirmthreedsmessagerequest"></a>
<a id="tocshandlers.confirmthreedsmessagerequest"></a>

```json
{
  "status": "SUCCESS"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|status|string|true|none||none|

#### 枚举值

|属性|值|
|---|---|
|status|SUCCESS|
|status|FAILURE|

<h2 id="tocS_handlers.ConfirmThreeDSMessageResponse">handlers.ConfirmThreeDSMessageResponse</h2>

<a id="schemahandlers.confirmthreedsmessageresponse"></a>
<a id="schema_handlers.ConfirmThreeDSMessageResponse"></a>
<a id="tocShandlers.confirmthreedsmessageresponse"></a>
<a id="tocshandlers.confirmthreedsmessageresponse"></a>

```json
{
  "message": "3DS challenge confirmed",
  "record": {
    "amount": "string",
    "app_notification_error": "string",
    "app_notification_sent": true,
    "auth_method": "OTP",
    "challenge_expires_at": "string",
    "challenge_status": "OTP_SENT",
    "confirmation_status": "string",
    "confirmed_at": "string",
    "confirmed_by_user_id": 0,
    "created_at": "string",
    "currency": "string",
    "delegate_method": "string",
    "delegate_sca_id": "string",
    "delegate_status": "string",
    "ds_transaction_id": "string",
    "email_notification_error": "string",
    "email_notification_sent": true,
    "expires_after": 0,
    "id": 0,
    "merchant_id": "string",
    "merchant_name": "string",
    "notification_id": "string",
    "passcode": "string",
    "provider_error": "string",
    "provider_request": "string",
    "provider_request_id": "string",
    "provider_response": "string",
    "pubtoken": 0,
    "raw_data": "string",
    "received_at": "string",
    "transaction_token": "string",
    "updated_at": "string",
    "user_id": 0
  },
  "status": "success"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|message|string|false|none||none|
|record|[models.ThreeDSRecord](#schemamodels.threedsrecord)|false|none||none|
|status|string|false|none||none|

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
        "auth_method": "BIO",
        "challenge_expires_at": "2026-01-20T10:40:00Z",
        "challenge_status": "UNCONFIRMED",
        "confirmation_status": "SUCCESS",
        "confirmed_at": "2026-01-20T10:32:00Z",
        "currency": "USD",
        "expires_after": 600,
        "id": 1,
        "merchant_id": "merchant-123",
        "merchant_name": "Amazon",
        "notification_id": "notif_123",
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
      "auth_method": "BIO",
      "challenge_expires_at": "2026-01-20T10:40:00Z",
      "challenge_status": "UNCONFIRMED",
      "confirmation_status": "SUCCESS",
      "confirmed_at": "2026-01-20T10:32:00Z",
      "currency": "USD",
      "expires_after": 600,
      "id": 1,
      "merchant_id": "merchant-123",
      "merchant_name": "Amazon",
      "notification_id": "notif_123",
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
  "auth_method": "BIO",
  "challenge_expires_at": "2026-01-20T10:40:00Z",
  "challenge_status": "UNCONFIRMED",
  "confirmation_status": "SUCCESS",
  "confirmed_at": "2026-01-20T10:32:00Z",
  "currency": "USD",
  "expires_after": 600,
  "id": 1,
  "merchant_id": "merchant-123",
  "merchant_name": "Amazon",
  "notification_id": "notif_123",
  "passcode": "123456",
  "received_at": "2026-01-20T10:30:00Z"
}

```

用户端3DS挑战记录，OTP记录包含验证码，BIO记录包含待确认/已确认状态和过期时间

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|amount|string|false|none||交易金额|
|auth_method|string|false|none||认证方式|
|challenge_expires_at|string|false|none||挑战过期时间|
|challenge_status|string|false|none||挑战状态|
|confirmation_status|string|false|none||用户确认状态|
|confirmed_at|string|false|none||确认时间|
|currency|string|false|none||货币代码|
|expires_after|integer|false|none||有效期(秒)|
|id|integer|false|none||记录ID|
|merchant_id|string|false|none||商户ID|
|merchant_name|string|false|none||商户名称|
|notification_id|string|false|none||通知ID|
|passcode|string|false|none||OTP验证码，BIO为空|
|received_at|string|false|none||接收时间|

#### 枚举值

|属性|值|
|---|---|
|auth_method|OTP|
|auth_method|BIO|

<h2 id="tocS_models.ThreeDSAuthMethod">models.ThreeDSAuthMethod</h2>

<a id="schemamodels.threedsauthmethod"></a>
<a id="schema_models.ThreeDSAuthMethod"></a>
<a id="tocSmodels.threedsauthmethod"></a>
<a id="tocsmodels.threedsauthmethod"></a>

```json
"OTP"

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|*anonymous*|string|false|none||none|

#### 枚举值

|属性|值|
|---|---|
|*anonymous*|OTP|
|*anonymous*|BIO|

<h2 id="tocS_models.ThreeDSChallengeStatus">models.ThreeDSChallengeStatus</h2>

<a id="schemamodels.threedschallengestatus"></a>
<a id="schema_models.ThreeDSChallengeStatus"></a>
<a id="tocSmodels.threedschallengestatus"></a>
<a id="tocsmodels.threedschallengestatus"></a>

```json
"OTP_SENT"

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|*anonymous*|string|false|none||none|

#### 枚举值

|属性|值|
|---|---|
|*anonymous*|OTP_SENT|
|*anonymous*|UNCONFIRMED|
|*anonymous*|PROCESSING|
|*anonymous*|SUCCESS|
|*anonymous*|FAILURE|
|*anonymous*|EXPIRED|
|*anonymous*|CONFIRM_FAILED|

<h2 id="tocS_models.ThreeDSRecord">models.ThreeDSRecord</h2>

<a id="schemamodels.threedsrecord"></a>
<a id="schema_models.ThreeDSRecord"></a>
<a id="tocSmodels.threedsrecord"></a>
<a id="tocsmodels.threedsrecord"></a>

```json
{
  "amount": "string",
  "app_notification_error": "string",
  "app_notification_sent": true,
  "auth_method": "OTP",
  "challenge_expires_at": "string",
  "challenge_status": "OTP_SENT",
  "confirmation_status": "string",
  "confirmed_at": "string",
  "confirmed_by_user_id": 0,
  "created_at": "string",
  "currency": "string",
  "delegate_method": "string",
  "delegate_sca_id": "string",
  "delegate_status": "string",
  "ds_transaction_id": "string",
  "email_notification_error": "string",
  "email_notification_sent": true,
  "expires_after": 0,
  "id": 0,
  "merchant_id": "string",
  "merchant_name": "string",
  "notification_id": "string",
  "passcode": "string",
  "provider_error": "string",
  "provider_request": "string",
  "provider_request_id": "string",
  "provider_response": "string",
  "pubtoken": 0,
  "raw_data": "string",
  "received_at": "string",
  "transaction_token": "string",
  "updated_at": "string",
  "user_id": 0
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|amount|string|false|none||none|
|app_notification_error|string|false|none||none|
|app_notification_sent|boolean|false|none||通知发送状态|
|auth_method|[models.ThreeDSAuthMethod](#schemamodels.threedsauthmethod)|false|none||none|
|challenge_expires_at|string|false|none||none|
|challenge_status|[models.ThreeDSChallengeStatus](#schemamodels.threedschallengestatus)|false|none||none|
|confirmation_status|string|false|none||none|
|confirmed_at|string|false|none||none|
|confirmed_by_user_id|integer|false|none||none|
|created_at|string|false|none||none|
|currency|string|false|none||none|
|delegate_method|string|false|none||none|
|delegate_sca_id|string|false|none||none|
|delegate_status|string|false|none||none|
|ds_transaction_id|string|false|none||none|
|email_notification_error|string|false|none||none|
|email_notification_sent|boolean|false|none||none|
|expires_after|integer|false|none||有效期(秒)|
|id|integer|false|none||none|
|merchant_id|string|false|none||none|
|merchant_name|string|false|none||none|
|notification_id|string|false|none||none|
|passcode|string|false|none||none|
|provider_error|string|false|none||none|
|provider_request|string|false|none||none|
|provider_request_id|string|false|none||none|
|provider_response|string|false|none||none|
|pubtoken|integer|false|none||none|
|raw_data|string|false|none||原始数据(JSON格式存储)|
|received_at|string|false|none||时间戳|
|transaction_token|string|false|none||none|
|updated_at|string|false|none||none|
|user_id|integer|false|none||none|


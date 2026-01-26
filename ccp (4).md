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

# KYC认证

## GET 检查KYC资格

GET /kyc/eligibility

检查当前用户是否有资格进行KYC认证

> 返回示例

> 200 Response

```json
{
  "eligible": true,
  "payment_status": "completed",
  "payment_type": "kyc",
  "reason": "KYC fee payment required before KYC verification",
  "required_action": "create_kyc_payment",
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|KYC资格检查结果|[handlers.CheckKYCEligibilityResponse](#schemahandlers.checkkyceligibilityresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[handlers.ErrorResponse](#schemahandlers.errorresponse)|

## GET 获取用户KYC状态

GET /didit/status

获取当前用户的KYC认证状态，包括最新的KYC记录和失败原因

> 返回示例

> 200 Response

```json
{
  "can_submit_kyc": true,
  "latest_kyc": {
    "agent_uid": "u1_1704067200_abc12345",
    "created_at": "2024-01-15T10:30:00Z",
    "fail_reason": "证件照片不清晰，请重新上传",
    "id": 1,
    "pokepay_status": 3,
    "status": "rejected",
    "updated_at": "2024-01-15T12:00:00Z"
  },
  "message": "KYC已通过，无需重复提交",
  "user_kyc_status": "pending"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|用户KYC状态|[handlers.GetUserKycStatusResponse](#schemahandlers.getuserkycstatusresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|用户未找到|[handlers.ErrorResponse](#schemahandlers.errorresponse)|

# 数据模型

<h2 id="tocS_handlers.CheckKYCEligibilityResponse">handlers.CheckKYCEligibilityResponse</h2>

<a id="schemahandlers.checkkyceligibilityresponse"></a>
<a id="schema_handlers.CheckKYCEligibilityResponse"></a>
<a id="tocShandlers.checkkyceligibilityresponse"></a>
<a id="tocshandlers.checkkyceligibilityresponse"></a>

```json
{
  "eligible": true,
  "payment_status": "completed",
  "payment_type": "kyc",
  "reason": "KYC fee payment required before KYC verification",
  "required_action": "create_kyc_payment",
  "status": "success"
}

```

KYC资格检查结果，用户需要先支付KYC费用才能进行KYC认证

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|eligible|boolean|false|none||是否有资格进行KYC认证|
|payment_status|string|false|none||支付状态: none=无记录, pending=待支付, processing=处理中, completed=已完成, failed=失败|
|payment_type|string|false|none||支付类型: kyc=KYC费用, virtual=虚拟卡开卡费, physical=实体卡开卡费|
|reason|string|false|none||不符合条件的原因说明|
|required_action|string|false|none||需要执行的操作: create_kyc_payment=创建支付, complete_payment=完成支付|
|status|string|false|none||响应状态|

#### 枚举值

|属性|值|
|---|---|
|payment_status|none|
|payment_status|pending|
|payment_status|processing|
|payment_status|completed|
|payment_status|failed|
|payment_type|kyc|
|payment_type|virtual|
|payment_type|physical|
|required_action|create_kyc_payment|
|required_action|complete_payment|

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

<h2 id="tocS_handlers.GetUserKycStatusResponse">handlers.GetUserKycStatusResponse</h2>

<a id="schemahandlers.getuserkycstatusresponse"></a>
<a id="schema_handlers.GetUserKycStatusResponse"></a>
<a id="tocShandlers.getuserkycstatusresponse"></a>
<a id="tocshandlers.getuserkycstatusresponse"></a>

```json
{
  "can_submit_kyc": true,
  "latest_kyc": {
    "agent_uid": "u1_1704067200_abc12345",
    "created_at": "2024-01-15T10:30:00Z",
    "fail_reason": "证件照片不清晰，请重新上传",
    "id": 1,
    "pokepay_status": 3,
    "status": "rejected",
    "updated_at": "2024-01-15T12:00:00Z"
  },
  "message": "KYC已通过，无需重复提交",
  "user_kyc_status": "pending"
}

```

用户KYC状态查询结果，包含用户整体KYC状态、最新KYC记录及失败原因

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|can_submit_kyc|boolean|false|none||是否可以提交新的KYC认证|
|latest_kyc|[handlers.LatestKycInfo](#schemahandlers.latestkycinfo)|false|none||最新的KYC记录（如果存在）|
|message|string|false|none||提示信息（说明为什么可以/不可以提交KYC）|
|user_kyc_status|string|false|none||用户整体KYC状态: none=未认证, pending=待审核, verified=已认证, rejected=已拒绝|

#### 枚举值

|属性|值|
|---|---|
|user_kyc_status|none|
|user_kyc_status|pending|
|user_kyc_status|verified|
|user_kyc_status|rejected|

<h2 id="tocS_handlers.LatestKycInfo">handlers.LatestKycInfo</h2>

<a id="schemahandlers.latestkycinfo"></a>
<a id="schema_handlers.LatestKycInfo"></a>
<a id="tocShandlers.latestkycinfo"></a>
<a id="tocshandlers.latestkycinfo"></a>

```json
{
  "agent_uid": "u1_1704067200_abc12345",
  "created_at": "2024-01-15T10:30:00Z",
  "fail_reason": "证件照片不清晰，请重新上传",
  "id": 1,
  "pokepay_status": 3,
  "status": "rejected",
  "updated_at": "2024-01-15T12:00:00Z"
}

```

用户最新的KYC认证记录详情

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|agent_uid|string|false|none||唯一标识，用于查询Pokepay KYC状态|
|created_at|string|false|none||创建时间|
|fail_reason|string|false|none||失败原因（来自Pokepay的reason字段）|
|id|integer|false|none||KYC记录ID|
|pokepay_status|integer|false|none||Pokepay KYC状态: 1=未审核/未完成, 2=审核通过, 3=审核失败, 4=信息不匹配, 5=待人工审核, 6=证件号重复|
|status|string|false|none||本地状态: pending_submit=待提交, pending=待审核, processing=审核中, approved=已通过, rejected=已拒绝, failed=失败, not_completed=未完成, cancelled=已取消|
|updated_at|string|false|none||更新时间|

#### 枚举值

|属性|值|
|---|---|
|pokepay_status|1|
|pokepay_status|2|
|pokepay_status|3|
|pokepay_status|4|
|pokepay_status|5|
|pokepay_status|6|
|status|pending_submit|
|status|pending|
|status|processing|
|status|approved|
|status|rejected|
|status|failed|
|status|not_completed|
|status|cancelled|


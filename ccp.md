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

# 实体卡升级

## PUT 提交虚拟卡升级实体卡申请

PUT /card/convertToPhysical

使用 verify_token 和选择的支付币种正式提交升级申请。系统将按顺序执行：幂等校验 → 扣费（从指定币种余额） → 发卡侧提交。升级流程第4步（最终步骤）：获取费用 → 发送验证码 → 校验验证码 → **提交升级**。

> Body 请求参数

```json
{
  "area_code": "+86",
  "name_on_card": "RENWOXIN",
  "payment_currency": "USDT-TRC20",
  "phone": "18588889979",
  "postal_address": "花都区xxx号",
  "postal_city": "广州市",
  "postal_code": "112200",
  "postal_country": "CN",
  "postal_state": "广东",
  "public_token": "123774296",
  "recipient": "任我行",
  "verify_token": "vt_xxxxxxxxxx"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|Idempotency-Key|header|string| 是 |幂等键（8-128位，支持字母数字和 : _ - .），防止重复提交|
|body|body|[internal_handlers.PhysicalUpgradeConvertSwaggerRequest](#schemainternal_handlers.physicalupgradeconvertswaggerrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": {
    "order_no": "UPG20260225120000ABCD",
    "public_token": "123774296",
    "status": "SUBMITTED",
    "status_desc": "处理中",
    "upgrade_amount": 40
  },
  "errstr": "SUCCESS",
  "request_id": "req_xxx"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|提交成功|[internal_handlers.PhysicalUpgradeSubmitSwaggerResponse](#schemainternal_handlers.physicalupgradesubmitswaggerresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误（verify_token无效/币种不支持/余额不足等）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|无权限（卡片不属于该用户）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|409|[Conflict](https://tools.ietf.org/html/rfc7231#section-6.5.8)|幂等键冲突（已有处理中的请求）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|502|[Bad Gateway](https://tools.ietf.org/html/rfc7231#section-6.6.3)|发卡侧调用失败（已自动退款）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|

## POST 发送实体卡升级邮箱验证码

POST /card/physical/upgrade/email-code/send

向用户注册邮箱发送6位验证码（邮箱从账号自动获取）。升级流程第2步：获取费用 → **发送验证码** → 校验验证码 → 提交升级。

> Body 请求参数

```json
{
  "public_token": "123774296",
  "scene": "physical_upgrade"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[internal_handlers.PhysicalUpgradeSendEmailCodeSwaggerRequest](#schemainternal_handlers.physicalupgradesendemailcodeswaggerrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": {
    "public_token": "123774296",
    "scene": "physical_upgrade",
    "sent": true
  },
  "errstr": "SUCCESS",
  "request_id": "req_xxx"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|发送成功|[internal_handlers.PhysicalUpgradeSendEmailCodeSwaggerResponse](#schemainternal_handlers.physicalupgradesendemailcodeswaggerresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|无权限（卡片不属于该用户或不满足升级条件）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|429|[Too Many Requests](https://tools.ietf.org/html/rfc6585#section-4)|发送频率受限（60秒内仅可发送一次）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|

## POST 校验实体卡升级邮箱验证码

POST /card/physical/upgrade/email-code/verify

校验6位邮箱验证码，成功后返回一次性 verify_token（有效期10分钟）。升级流程第3步：获取费用 → 发送验证码 → **校验验证码** → 提交升级。

> Body 请求参数

```json
{
  "code": "123456",
  "public_token": "123774296",
  "scene": "physical_upgrade"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[internal_handlers.PhysicalUpgradeVerifyEmailCodeSwaggerRequest](#schemainternal_handlers.physicalupgradeverifyemailcodeswaggerrequest)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": {
    "expires_in_sec": 600,
    "verify_token": "vt_xxxxxxxxxx"
  },
  "errstr": "SUCCESS",
  "request_id": "req_xxx"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|校验成功，返回 verify_token|[internal_handlers.PhysicalUpgradeVerifyEmailCodeSwaggerResponse](#schemainternal_handlers.physicalupgradeverifyemailcodeswaggerresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|验证码错误或已过期|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|无权限|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|423|[Locked](https://tools.ietf.org/html/rfc2518#section-10.4)|验证码校验锁定（连续错误过多）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|

## GET 获取实体卡升级费用信息

GET /card/physical/upgrade/fee-info

返回实体卡升级所需费用金额及支持的支付币种列表。用户应在发起升级流程前调用此接口确认费用。

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": {
    "currencies": [
      {
        "coin_name": "USDT",
        "logo": "https://...",
        "name": "USDT-TRC20",
        "symbol": "TRCUSDT"
      }
    ],
    "upgrade_amount": 40
  },
  "errstr": "SUCCESS"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|费用信息|[internal_handlers.PhysicalUpgradeFeeInfoSwaggerResponse](#schemainternal_handlers.physicalupgradefeeinfoswaggerresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|

## GET 查询实体卡升级进度

GET /card/physical/upgrade/progress

根据 public_token 查询升级订单状态、时间线、物流单号及失败原因

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|public_token|query|string| 是 |卡 public_token|

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": {
    "fail_reason": "issuer timeout",
    "order_no": "UPG20260225120000ABCD",
    "public_token": "123774296",
    "refund_status": "completed",
    "status": "SHIPPED",
    "status_desc": "已发货",
    "timeline": [
      {
        "at": "2026-02-25T12:00:00Z",
        "external_req_id": "req_issuer_xxx",
        "operator": "system",
        "previous_status": "EMAIL_VERIFIED",
        "remark": "upgrade fee deducted",
        "source": "system",
        "status": "FEE_PAID"
      }
    ],
    "tracking_no": "YT123456789CN"
  },
  "errstr": "SUCCESS",
  "request_id": "req_xxx"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|查询成功|[internal_handlers.PhysicalUpgradeProgressSwaggerResponse](#schemainternal_handlers.physicalupgradeprogressswaggerresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|无权限|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|无升级记录|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|

# 数据模型

<h2 id="tocS_internal_handlers.PhysicalUpgradeConvertSwaggerRequest">internal_handlers.PhysicalUpgradeConvertSwaggerRequest</h2>

<a id="schemainternal_handlers.physicalupgradeconvertswaggerrequest"></a>
<a id="schema_internal_handlers.PhysicalUpgradeConvertSwaggerRequest"></a>
<a id="tocSinternal_handlers.physicalupgradeconvertswaggerrequest"></a>
<a id="tocsinternal_handlers.physicalupgradeconvertswaggerrequest"></a>

```json
{
  "area_code": "+86",
  "name_on_card": "RENWOXIN",
  "payment_currency": "USDT-TRC20",
  "phone": "18588889979",
  "postal_address": "花都区xxx号",
  "postal_city": "广州市",
  "postal_code": "112200",
  "postal_country": "CN",
  "postal_state": "广东",
  "public_token": "123774296",
  "recipient": "任我行",
  "verify_token": "vt_xxxxxxxxxx"
}

```

提交升级申请，需先调用 fee-info 获取费用，再通过邮箱验证获取 verify_token。请求头需携带 Idempotency-Key（8-128位）

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|area_code|string|true|none||收件人电话区号|
|name_on_card|string|false|none||卡面印刷姓名（英文大写）|
|payment_currency|string|true|none||支付币种（如 USDT-TRC20、USDT-ERC20、USDC 等）|
|phone|string|true|none||收件人手机号|
|postal_address|string|true|none||详细地址|
|postal_city|string|true|none||城市|
|postal_code|string|true|none||邮编|
|postal_country|string|true|none||邮寄国家/地区代码|
|postal_state|string|true|none||省/州|
|public_token|string|true|none||卡片 public_token|
|recipient|string|true|none||收件人姓名|
|verify_token|string|true|none||邮箱验证后获取的 verify_token|

<h2 id="tocS_internal_handlers.PhysicalUpgradeErrorSwaggerResponse">internal_handlers.PhysicalUpgradeErrorSwaggerResponse</h2>

<a id="schemainternal_handlers.physicalupgradeerrorswaggerresponse"></a>
<a id="schema_internal_handlers.PhysicalUpgradeErrorSwaggerResponse"></a>
<a id="tocSinternal_handlers.physicalupgradeerrorswaggerresponse"></a>
<a id="tocsinternal_handlers.physicalupgradeerrorswaggerresponse"></a>

```json
{
  "code": 400,
  "errstr": "VERIFY_TOKEN_INVALID",
  "message": "verify_token 无效或已过期",
  "request_id": "req_xxx"
}

```

实体卡升级接口统一错误格式

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||none|
|errstr|string|false|none||none|
|message|string|false|none||none|
|request_id|string|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalUpgradeFeeInfoCurrency">internal_handlers.PhysicalUpgradeFeeInfoCurrency</h2>

<a id="schemainternal_handlers.physicalupgradefeeinfocurrency"></a>
<a id="schema_internal_handlers.PhysicalUpgradeFeeInfoCurrency"></a>
<a id="tocSinternal_handlers.physicalupgradefeeinfocurrency"></a>
<a id="tocsinternal_handlers.physicalupgradefeeinfocurrency"></a>

```json
{
  "coin_name": "USDT",
  "logo": "https://...",
  "name": "USDT-TRC20",
  "symbol": "TRCUSDT"
}

```

实体卡升级支持的支付币种信息

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|coin_name|string|false|none||币种简称|
|logo|string|false|none||币种图标 URL|
|name|string|false|none||币种名称，提交升级时传此值|
|symbol|string|false|none||币种符号|

<h2 id="tocS_internal_handlers.PhysicalUpgradeFeeInfoData">internal_handlers.PhysicalUpgradeFeeInfoData</h2>

<a id="schemainternal_handlers.physicalupgradefeeinfodata"></a>
<a id="schema_internal_handlers.PhysicalUpgradeFeeInfoData"></a>
<a id="tocSinternal_handlers.physicalupgradefeeinfodata"></a>
<a id="tocsinternal_handlers.physicalupgradefeeinfodata"></a>

```json
{
  "currencies": [
    {
      "coin_name": "USDT",
      "logo": "https://...",
      "name": "USDT-TRC20",
      "symbol": "TRCUSDT"
    }
  ],
  "upgrade_amount": 40
}

```

实体卡升级费用金额及支持的支付币种

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|currencies|[[internal_handlers.PhysicalUpgradeFeeInfoCurrency](#schemainternal_handlers.physicalupgradefeeinfocurrency)]|false|none||支持的支付币种列表|
|upgrade_amount|number|false|none||升级费用金额（USD）|

<h2 id="tocS_internal_handlers.PhysicalUpgradeFeeInfoSwaggerResponse">internal_handlers.PhysicalUpgradeFeeInfoSwaggerResponse</h2>

<a id="schemainternal_handlers.physicalupgradefeeinfoswaggerresponse"></a>
<a id="schema_internal_handlers.PhysicalUpgradeFeeInfoSwaggerResponse"></a>
<a id="tocSinternal_handlers.physicalupgradefeeinfoswaggerresponse"></a>
<a id="tocsinternal_handlers.physicalupgradefeeinfoswaggerresponse"></a>

```json
{
  "code": 200,
  "data": {
    "currencies": [
      {
        "coin_name": "USDT",
        "logo": "https://...",
        "name": "USDT-TRC20",
        "symbol": "TRCUSDT"
      }
    ],
    "upgrade_amount": 40
  },
  "errstr": "SUCCESS"
}

```

返回实体卡升级费用金额及可用支付币种

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||none|
|data|[internal_handlers.PhysicalUpgradeFeeInfoData](#schemainternal_handlers.physicalupgradefeeinfodata)|false|none||实体卡升级费用金额及支持的支付币种|
|errstr|string|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalUpgradeProgressData">internal_handlers.PhysicalUpgradeProgressData</h2>

<a id="schemainternal_handlers.physicalupgradeprogressdata"></a>
<a id="schema_internal_handlers.PhysicalUpgradeProgressData"></a>
<a id="tocSinternal_handlers.physicalupgradeprogressdata"></a>
<a id="tocsinternal_handlers.physicalupgradeprogressdata"></a>

```json
{
  "fail_reason": "issuer timeout",
  "order_no": "UPG20260225120000ABCD",
  "public_token": "123774296",
  "refund_status": "completed",
  "status": "SHIPPED",
  "status_desc": "已发货",
  "timeline": [
    {
      "at": "2026-02-25T12:00:00Z",
      "external_req_id": "req_issuer_xxx",
      "operator": "system",
      "previous_status": "EMAIL_VERIFIED",
      "remark": "upgrade fee deducted",
      "source": "system",
      "status": "FEE_PAID"
    }
  ],
  "tracking_no": "YT123456789CN"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|fail_reason|string|false|none||none|
|order_no|string|false|none||none|
|public_token|string|false|none||none|
|refund_status|string|false|none||none|
|status|string|false|none||none|
|status_desc|string|false|none||none|
|timeline|[[internal_handlers.PhysicalUpgradeTimelineItemSwagger](#schemainternal_handlers.physicalupgradetimelineitemswagger)]|false|none||none|
|tracking_no|string|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalUpgradeProgressSwaggerResponse">internal_handlers.PhysicalUpgradeProgressSwaggerResponse</h2>

<a id="schemainternal_handlers.physicalupgradeprogressswaggerresponse"></a>
<a id="schema_internal_handlers.PhysicalUpgradeProgressSwaggerResponse"></a>
<a id="tocSinternal_handlers.physicalupgradeprogressswaggerresponse"></a>
<a id="tocsinternal_handlers.physicalupgradeprogressswaggerresponse"></a>

```json
{
  "code": 200,
  "data": {
    "fail_reason": "issuer timeout",
    "order_no": "UPG20260225120000ABCD",
    "public_token": "123774296",
    "refund_status": "completed",
    "status": "SHIPPED",
    "status_desc": "已发货",
    "timeline": [
      {
        "at": "2026-02-25T12:00:00Z",
        "external_req_id": "req_issuer_xxx",
        "operator": "system",
        "previous_status": "EMAIL_VERIFIED",
        "remark": "upgrade fee deducted",
        "source": "system",
        "status": "FEE_PAID"
      }
    ],
    "tracking_no": "YT123456789CN"
  },
  "errstr": "SUCCESS",
  "request_id": "req_xxx"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||none|
|data|[internal_handlers.PhysicalUpgradeProgressData](#schemainternal_handlers.physicalupgradeprogressdata)|false|none||none|
|errstr|string|false|none||none|
|request_id|string|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalUpgradeSendEmailCodeData">internal_handlers.PhysicalUpgradeSendEmailCodeData</h2>

<a id="schemainternal_handlers.physicalupgradesendemailcodedata"></a>
<a id="schema_internal_handlers.PhysicalUpgradeSendEmailCodeData"></a>
<a id="tocSinternal_handlers.physicalupgradesendemailcodedata"></a>
<a id="tocsinternal_handlers.physicalupgradesendemailcodedata"></a>

```json
{
  "public_token": "123774296",
  "scene": "physical_upgrade",
  "sent": true
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|public_token|string|false|none||none|
|scene|string|false|none||none|
|sent|boolean|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalUpgradeSendEmailCodeSwaggerRequest">internal_handlers.PhysicalUpgradeSendEmailCodeSwaggerRequest</h2>

<a id="schemainternal_handlers.physicalupgradesendemailcodeswaggerrequest"></a>
<a id="schema_internal_handlers.PhysicalUpgradeSendEmailCodeSwaggerRequest"></a>
<a id="tocSinternal_handlers.physicalupgradesendemailcodeswaggerrequest"></a>
<a id="tocsinternal_handlers.physicalupgradesendemailcodeswaggerrequest"></a>

```json
{
  "public_token": "123774296",
  "scene": "physical_upgrade"
}

```

发送邮箱验证码，邮箱从用户账号自动获取，无需手动传入

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|public_token|string|true|none||卡片 public_token|
|scene|string|false|none||场景标识，固定值 physical_upgrade|

<h2 id="tocS_internal_handlers.PhysicalUpgradeSendEmailCodeSwaggerResponse">internal_handlers.PhysicalUpgradeSendEmailCodeSwaggerResponse</h2>

<a id="schemainternal_handlers.physicalupgradesendemailcodeswaggerresponse"></a>
<a id="schema_internal_handlers.PhysicalUpgradeSendEmailCodeSwaggerResponse"></a>
<a id="tocSinternal_handlers.physicalupgradesendemailcodeswaggerresponse"></a>
<a id="tocsinternal_handlers.physicalupgradesendemailcodeswaggerresponse"></a>

```json
{
  "code": 200,
  "data": {
    "public_token": "123774296",
    "scene": "physical_upgrade",
    "sent": true
  },
  "errstr": "SUCCESS",
  "request_id": "req_xxx"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||none|
|data|[internal_handlers.PhysicalUpgradeSendEmailCodeData](#schemainternal_handlers.physicalupgradesendemailcodedata)|false|none||none|
|errstr|string|false|none||none|
|request_id|string|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalUpgradeSubmitData">internal_handlers.PhysicalUpgradeSubmitData</h2>

<a id="schemainternal_handlers.physicalupgradesubmitdata"></a>
<a id="schema_internal_handlers.PhysicalUpgradeSubmitData"></a>
<a id="tocSinternal_handlers.physicalupgradesubmitdata"></a>
<a id="tocsinternal_handlers.physicalupgradesubmitdata"></a>

```json
{
  "order_no": "UPG20260225120000ABCD",
  "public_token": "123774296",
  "status": "SUBMITTED",
  "status_desc": "处理中",
  "upgrade_amount": 40
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|order_no|string|false|none||none|
|public_token|string|false|none||none|
|status|string|false|none||none|
|status_desc|string|false|none||none|
|upgrade_amount|number|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalUpgradeSubmitSwaggerResponse">internal_handlers.PhysicalUpgradeSubmitSwaggerResponse</h2>

<a id="schemainternal_handlers.physicalupgradesubmitswaggerresponse"></a>
<a id="schema_internal_handlers.PhysicalUpgradeSubmitSwaggerResponse"></a>
<a id="tocSinternal_handlers.physicalupgradesubmitswaggerresponse"></a>
<a id="tocsinternal_handlers.physicalupgradesubmitswaggerresponse"></a>

```json
{
  "code": 200,
  "data": {
    "order_no": "UPG20260225120000ABCD",
    "public_token": "123774296",
    "status": "SUBMITTED",
    "status_desc": "处理中",
    "upgrade_amount": 40
  },
  "errstr": "SUCCESS",
  "request_id": "req_xxx"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||none|
|data|[internal_handlers.PhysicalUpgradeSubmitData](#schemainternal_handlers.physicalupgradesubmitdata)|false|none||none|
|errstr|string|false|none||none|
|request_id|string|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalUpgradeTimelineItemSwagger">internal_handlers.PhysicalUpgradeTimelineItemSwagger</h2>

<a id="schemainternal_handlers.physicalupgradetimelineitemswagger"></a>
<a id="schema_internal_handlers.PhysicalUpgradeTimelineItemSwagger"></a>
<a id="tocSinternal_handlers.physicalupgradetimelineitemswagger"></a>
<a id="tocsinternal_handlers.physicalupgradetimelineitemswagger"></a>

```json
{
  "at": "2026-02-25T12:00:00Z",
  "external_req_id": "req_issuer_xxx",
  "operator": "system",
  "previous_status": "EMAIL_VERIFIED",
  "remark": "upgrade fee deducted",
  "source": "system",
  "status": "FEE_PAID"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|at|string|false|none||none|
|external_req_id|string|false|none||none|
|operator|string|false|none||none|
|previous_status|string|false|none||none|
|remark|string|false|none||none|
|source|string|false|none||none|
|status|string|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalUpgradeVerifyEmailCodeData">internal_handlers.PhysicalUpgradeVerifyEmailCodeData</h2>

<a id="schemainternal_handlers.physicalupgradeverifyemailcodedata"></a>
<a id="schema_internal_handlers.PhysicalUpgradeVerifyEmailCodeData"></a>
<a id="tocSinternal_handlers.physicalupgradeverifyemailcodedata"></a>
<a id="tocsinternal_handlers.physicalupgradeverifyemailcodedata"></a>

```json
{
  "expires_in_sec": 600,
  "verify_token": "vt_xxxxxxxxxx"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|expires_in_sec|integer|false|none||none|
|verify_token|string|false|none||none|

<h2 id="tocS_internal_handlers.PhysicalUpgradeVerifyEmailCodeSwaggerRequest">internal_handlers.PhysicalUpgradeVerifyEmailCodeSwaggerRequest</h2>

<a id="schemainternal_handlers.physicalupgradeverifyemailcodeswaggerrequest"></a>
<a id="schema_internal_handlers.PhysicalUpgradeVerifyEmailCodeSwaggerRequest"></a>
<a id="tocSinternal_handlers.physicalupgradeverifyemailcodeswaggerrequest"></a>
<a id="tocsinternal_handlers.physicalupgradeverifyemailcodeswaggerrequest"></a>

```json
{
  "code": "123456",
  "public_token": "123774296",
  "scene": "physical_upgrade"
}

```

校验邮箱验证码，验证通过后返回 verify_token 用于提交升级

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|string|true|none||6位邮箱验证码|
|public_token|string|true|none||卡片 public_token|
|scene|string|false|none||场景标识|

<h2 id="tocS_internal_handlers.PhysicalUpgradeVerifyEmailCodeSwaggerResponse">internal_handlers.PhysicalUpgradeVerifyEmailCodeSwaggerResponse</h2>

<a id="schemainternal_handlers.physicalupgradeverifyemailcodeswaggerresponse"></a>
<a id="schema_internal_handlers.PhysicalUpgradeVerifyEmailCodeSwaggerResponse"></a>
<a id="tocSinternal_handlers.physicalupgradeverifyemailcodeswaggerresponse"></a>
<a id="tocsinternal_handlers.physicalupgradeverifyemailcodeswaggerresponse"></a>

```json
{
  "code": 200,
  "data": {
    "expires_in_sec": 600,
    "verify_token": "vt_xxxxxxxxxx"
  },
  "errstr": "SUCCESS",
  "request_id": "req_xxx"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||none|
|data|[internal_handlers.PhysicalUpgradeVerifyEmailCodeData](#schemainternal_handlers.physicalupgradeverifyemailcodedata)|false|none||none|
|errstr|string|false|none||none|
|request_id|string|false|none||none|


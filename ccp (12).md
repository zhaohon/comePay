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

## GET 查询实体卡升级进度

GET /card/physical/upgrade/progress

根据卡片 public_token 查询最近一笔升级订单的完整进度信息。

返回内容包括：
- 订单基本信息（订单号、当前状态、状态描述）
- 物流信息（物流单号，仅 SHIPPED/DELIVERED 状态下返回）
- 失败信息（失败原因，仅 FAILED 状态下返回）
- 退款状态（仅发生退款时返回，可能值：PENDING / PROCESSING / COMPLETED / FAILED）
- 完整状态时间线（按时间正序排列，记录每次状态变更的详细信息）

订单状态流转：INIT → EMAIL_VERIFIED → FEE_PAID → SUBMITTED → PROCESSING → SHIPPED → DELIVERED
异常分支：任意非终态 → FAILED / CANCELLED

状态说明：
| 状态 | 描述 | 说明 |
|------|------|------|
| INIT | 已创建 | 订单初始化 |
| EMAIL_VERIFIED | 邮箱已验证 | 用户完成邮箱验证码校验 |
| FEE_PAID | 已扣费 | 升级费用已从用户余额扣除 |
| SUBMITTED | 已提交发卡 | 已向发卡侧提交升级请求 |
| PROCESSING | 处理中 | 发卡侧正在处理 |
| SHIPPED | 已发货 | 实体卡已寄出，可查看物流单号 |
| DELIVERED | 已签收 | 用户已签收（终态） |
| FAILED | 失败 | 升级失败，查看 fail_reason（终态） |
| CANCELLED | 已取消 | 订单已取消（终态） |

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|public_token|query|string| 是 |卡片的 public_token，用于标识要查询的卡片|

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": {
    "fail_reason": "issuer timeout",
    "order_no": "UPG20260225120000ABCD",
    "public_token": "123774296",
    "refund_status": "COMPLETED",
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
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|查询成功，返回订单进度详情|[internal_handlers.PhysicalUpgradeProgressSwaggerResponse](#schemainternal_handlers.physicalupgradeprogressswaggerresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误（public_token 为空或格式不合法）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权（Bearer Token 缺失或已过期）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|403|[Forbidden](https://tools.ietf.org/html/rfc7231#section-6.5.3)|无权限（该卡片不属于当前用户）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|无升级记录（该卡片未发起过升级申请）|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.PhysicalUpgradeErrorSwaggerResponse](#schemainternal_handlers.physicalupgradeerrorswaggerresponse)|

# 数据模型

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
  "refund_status": "COMPLETED",
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

实体卡升级订单的完整进度信息，包含订单状态、物流信息、失败原因、退款状态及完整状态变更时间线。

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|fail_reason|string|false|none||失败原因。仅当状态为 FAILED 时返回，描述升级失败的具体原因|
|order_no|string|false|none||升级订单号，格式：UPG + 时间戳 + 随机字符|
|public_token|string|false|none||卡片 public_token|
|refund_status|string|false|none||退款状态。仅在发生退款时返回。可选值：PENDING（退款中）/ PROCESSING（处理中）/ COMPLETED（已退款）/ FAILED（退款失败）|
|status|string|false|none||当前订单状态。可选值：INIT / EMAIL_VERIFIED / FEE_PAID / SUBMITTED / PROCESSING / SHIPPED / DELIVERED / FAILED / CANCELLED|
|status_desc|string|false|none||状态中文描述。对应值：已创建 / 邮箱已验证 / 已扣费 / 已提交发卡 / 处理中 / 已发货 / 已签收 / 失败 / 已取消|
|timeline|[[internal_handlers.PhysicalUpgradeTimelineItemSwagger](#schemainternal_handlers.physicalupgradetimelineitemswagger)]|false|none||状态变更时间线，按时间正序排列，记录订单从创建到当前状态的每一步变更|
|tracking_no|string|false|none||物流单号。仅当状态为 SHIPPED 或 DELIVERED 时返回，其他状态为空字符串|

#### 枚举值

|属性|值|
|---|---|
|refund_status||
|refund_status|PENDING|
|refund_status|PROCESSING|
|refund_status|COMPLETED|
|refund_status|FAILED|
|status|INIT|
|status|EMAIL_VERIFIED|
|status|FEE_PAID|
|status|SUBMITTED|
|status|PROCESSING|
|status|SHIPPED|
|status|DELIVERED|
|status|FAILED|
|status|CANCELLED|

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
    "refund_status": "COMPLETED",
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

GET /card/physical/upgrade/progress 接口的完整响应结构

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||业务状态码，200 表示成功|
|data|[internal_handlers.PhysicalUpgradeProgressData](#schemainternal_handlers.physicalupgradeprogressdata)|false|none||进度详情数据|
|errstr|string|false|none||状态描述，成功时为 SUCCESS|
|request_id|string|false|none||请求追踪ID，用于日志排查|

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

记录订单每次状态变更的详细信息，按时间正序排列。每条记录包含变更前后的状态、触发来源、操作人等信息。

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|at|string|false|none||状态变更时间，RFC3339 格式|
|external_req_id|string|false|none||外部请求ID，关联发卡侧的请求标识（仅发卡侧交互时存在）|
|operator|string|false|none||操作人标识。system 表示系统自动，admin 时为管理员ID|
|previous_status|string|false|none||变更前的状态（首条记录为空）。可选值同 status|
|remark|string|false|none||备注说明，描述本次状态变更的原因或详情|
|source|string|false|none||触发来源。可选值：user（用户操作）/ system（系统自动）/ callback（发卡侧回调）/ polling（轮询同步）/ admin（管理员操作）|
|status|string|false|none||变更后的状态。可选值：INIT / EMAIL_VERIFIED / FEE_PAID / SUBMITTED / PROCESSING / SHIPPED / DELIVERED / FAILED / CANCELLED|


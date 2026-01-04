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

## GET 获取统一交易记录

GET /wallet/unified-transactions

获取用户所有涉及资金变动的交易记录，整合多个数据来源：

**数据来源：**
- **YuDun充值/提现记录** - 链上USDT、TRX等币种的充值和提现
- **Swap兑换记录** - 货币兑换交易（如USDT兑换HKD）
- **开卡费支付记录** - KYC认证费用、开卡费支付
- **推荐佣金记录** - 一级/二级推荐佣金收入
- **转账/手续费记录** - 用户间转账及各类手续费

**交易类型说明：**
- `deposit` - 充值（金额为正数）
- `withdraw` - 提现（金额为负数）
- `swap` - 兑换（显示兑换后金额）
- `card_fee` - 开卡费（金额为负数）
- `commission` - 佣金（金额为正数）
- `transfer` - 转账
- `fee` - 手续费（金额为负数）

**状态说明：**
- `pending` - 处理中/待确认
- `completed` - 已完成
- `failed` - 失败
- `cancelled` - 已取消
- `approved` - 已审核通过（提现）
- `rejected` - 已拒绝（提现）
- `credited` - 已到账（佣金）

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|page|query|integer| 否 |页码，从1开始，默认1|
|page_size|query|integer| 否 |每页数量，1-100，默认20|
|type|query|string| 否 |交易类型筛选|
|status|query|string| 否 |交易状态筛选|
|start_date|query|string| 否 |开始日期，格式YYYY-MM-DD|
|end_date|query|string| 否 |结束日期，格式YYYY-MM-DD（包含当天）|

#### 枚举值

|属性|值|
|---|---|
|type|deposit|
|type|withdraw|
|type|swap|
|type|card_fee|
|type|commission|
|type|transfer|
|type|fee|
|status|pending|
|status|completed|
|status|failed|
|status|cancelled|
|status|approved|
|status|rejected|
|status|credited|

> 返回示例

> 200 Response

```json
{
  "data": {
    "items": [
      {
        "address": "TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "amount": 100.5,
        "completed_at": "2024-01-01T12:05:00Z",
        "created_at": "2024-01-01T12:00:00Z",
        "currency": "USDT",
        "description": "充值 - TRX",
        "exchange_rate": 7.805,
        "fee": 1,
        "from_amount": 100,
        "from_currency": "USDT",
        "id": 1,
        "reference": "quote_xxx-xxx-xxx",
        "source_id": 123,
        "source_table": "yudun_transactions",
        "status": "completed",
        "status_label": "已完成",
        "to_amount": 780.5,
        "to_currency": "HKD",
        "tx_hash": "0x123abc456def...",
        "type": "deposit",
        "type_label": "充值"
      }
    ],
    "page": 1,
    "page_size": 20,
    "total": 100,
    "total_pages": 5
  },
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|获取成功，返回交易记录列表|[internal_handlers.UnifiedTransactionListWrapper](#schemainternal_handlers.unifiedtransactionlistwrapper)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权 - JWT Token无效或已过期|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
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

<h2 id="tocS_internal_handlers.UnifiedTransaction">internal_handlers.UnifiedTransaction</h2>

<a id="schemainternal_handlers.unifiedtransaction"></a>
<a id="schema_internal_handlers.UnifiedTransaction"></a>
<a id="tocSinternal_handlers.unifiedtransaction"></a>
<a id="tocsinternal_handlers.unifiedtransaction"></a>

```json
{
  "address": "TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "amount": 100.5,
  "completed_at": "2024-01-01T12:05:00Z",
  "created_at": "2024-01-01T12:00:00Z",
  "currency": "USDT",
  "description": "充值 - TRX",
  "exchange_rate": 7.805,
  "fee": 1,
  "from_amount": 100,
  "from_currency": "USDT",
  "id": 1,
  "reference": "quote_xxx-xxx-xxx",
  "source_id": 123,
  "source_table": "yudun_transactions",
  "status": "completed",
  "status_label": "已完成",
  "to_amount": 780.5,
  "to_currency": "HKD",
  "tx_hash": "0x123abc456def...",
  "type": "deposit",
  "type_label": "充值"
}

```

统一交易记录结构，整合所有涉及资金变动的交易类型

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|address|string|false|none||链上地址（充值/提现时有值）|
|amount|number|false|none||交易金额（正数为收入，负数为支出）|
|completed_at|string|false|none||完成时间|
|created_at|string|false|none||创建时间|
|currency|string|false|none||币种符号|
|description|string|false|none||交易描述|
|exchange_rate|number|false|none||汇率（兑换交易时有值）|
|fee|number|false|none||手续费|
|from_amount|number|false|none||源金额（兑换交易时有值）|
|from_currency|string|false|none||源币种（兑换交易时有值）|
|id|integer|false|none||交易记录ID|
|reference|string|false|none||交易参考号/订单号|
|source_id|integer|false|none||来源表记录ID|
|source_table|string|false|none||数据来源表名|
|status|string|false|none||交易状态|
|status_label|string|false|none||状态中文标签|
|to_amount|number|false|none||目标金额（兑换交易时有值）|
|to_currency|string|false|none||目标币种（兑换交易时有值）|
|tx_hash|string|false|none||链上交易哈希|
|type|[internal_handlers.UnifiedTransactionType](#schemainternal_handlers.unifiedtransactiontype)|false|none||交易类型|
|type_label|string|false|none||交易类型中文标签|

#### 枚举值

|属性|值|
|---|---|
|type|deposit|
|type|withdraw|
|type|swap|
|type|card_fee|
|type|commission|
|type|transfer|
|type|fee|

<h2 id="tocS_internal_handlers.UnifiedTransactionListResponse">internal_handlers.UnifiedTransactionListResponse</h2>

<a id="schemainternal_handlers.unifiedtransactionlistresponse"></a>
<a id="schema_internal_handlers.UnifiedTransactionListResponse"></a>
<a id="tocSinternal_handlers.unifiedtransactionlistresponse"></a>
<a id="tocsinternal_handlers.unifiedtransactionlistresponse"></a>

```json
{
  "items": [
    {
      "address": "TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "amount": 100.5,
      "completed_at": "2024-01-01T12:05:00Z",
      "created_at": "2024-01-01T12:00:00Z",
      "currency": "USDT",
      "description": "充值 - TRX",
      "exchange_rate": 7.805,
      "fee": 1,
      "from_amount": 100,
      "from_currency": "USDT",
      "id": 1,
      "reference": "quote_xxx-xxx-xxx",
      "source_id": 123,
      "source_table": "yudun_transactions",
      "status": "completed",
      "status_label": "已完成",
      "to_amount": 780.5,
      "to_currency": "HKD",
      "tx_hash": "0x123abc456def...",
      "type": "deposit",
      "type_label": "充值"
    }
  ],
  "page": 1,
  "page_size": 20,
  "total": 100,
  "total_pages": 5
}

```

统一交易记录分页列表响应数据

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|items|[[internal_handlers.UnifiedTransaction](#schemainternal_handlers.unifiedtransaction)]|false|none||交易记录列表|
|page|integer|false|none||当前页码|
|page_size|integer|false|none||每页数量|
|total|integer|false|none||总记录数|
|total_pages|integer|false|none||总页数|

<h2 id="tocS_internal_handlers.UnifiedTransactionListWrapper">internal_handlers.UnifiedTransactionListWrapper</h2>

<a id="schemainternal_handlers.unifiedtransactionlistwrapper"></a>
<a id="schema_internal_handlers.UnifiedTransactionListWrapper"></a>
<a id="tocSinternal_handlers.unifiedtransactionlistwrapper"></a>
<a id="tocsinternal_handlers.unifiedtransactionlistwrapper"></a>

```json
{
  "data": {
    "items": [
      {
        "address": "TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
        "amount": 100.5,
        "completed_at": "2024-01-01T12:05:00Z",
        "created_at": "2024-01-01T12:00:00Z",
        "currency": "USDT",
        "description": "充值 - TRX",
        "exchange_rate": 7.805,
        "fee": 1,
        "from_amount": 100,
        "from_currency": "USDT",
        "id": 1,
        "reference": "quote_xxx-xxx-xxx",
        "source_id": 123,
        "source_table": "yudun_transactions",
        "status": "completed",
        "status_label": "已完成",
        "to_amount": 780.5,
        "to_currency": "HKD",
        "tx_hash": "0x123abc456def...",
        "type": "deposit",
        "type_label": "充值"
      }
    ],
    "page": 1,
    "page_size": 20,
    "total": 100,
    "total_pages": 5
  },
  "status": "success"
}

```

统一交易记录API响应结构

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|data|[internal_handlers.UnifiedTransactionListResponse](#schemainternal_handlers.unifiedtransactionlistresponse)|false|none||响应数据|
|status|string|false|none||响应状态|

<h2 id="tocS_internal_handlers.UnifiedTransactionType">internal_handlers.UnifiedTransactionType</h2>

<a id="schemainternal_handlers.unifiedtransactiontype"></a>
<a id="schema_internal_handlers.UnifiedTransactionType"></a>
<a id="tocSinternal_handlers.unifiedtransactiontype"></a>
<a id="tocsinternal_handlers.unifiedtransactiontype"></a>

```json
"deposit"

```

交易类型枚举值

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|*anonymous*|string|false|none||交易类型枚举值|

#### 枚举值

|属性|值|
|---|---|
|*anonymous*|deposit|
|*anonymous*|withdraw|
|*anonymous*|swap|
|*anonymous*|card_fee|
|*anonymous*|commission|
|*anonymous*|transfer|
|*anonymous*|fee|


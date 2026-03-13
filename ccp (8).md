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

## GET 获取卡片交易记录

GET /card/transaction-history

获取指定卡片的交易记录，支持通过 `public_token` 或 `card_id` 查询
实际交易明细字段由上游 PokePay `/card/{publicToken}/account/trade` 返回决定，文档中列出常见字段

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|public_token|query|string| 否 |卡片 public_token，与 card_id 二选一|
|card_id|query|string| 否 |卡片 ID，与 public_token 二选一|
|page|query|integer| 否 |页码，默认1|
|limit|query|integer| 否 |每页条数，默认20，最大100|
|start_date|query|string| 否 |开始日期，格式 YYYY-MM-DD|
|end_date|query|string| 否 |结束日期，格式 YYYY-MM-DD|

> 返回示例

> 200 Response

```json
{
  "data": {
    "page": 1,
    "page_size": 20,
    "public_token": "123774296",
    "total": 2,
    "transactions": [
      {
        "amount": 12.5,
        "currency": "USD",
        "description": "Card purchase",
        "merchant_name": "Amazon",
        "status": "completed",
        "trade_id": "202603130001",
        "trade_time": "2026-03-13T10:30:00Z",
        "trade_type": "consume",
        "transaction_id": "TXN202603130001"
      }
    ]
  },
  "message": "Transaction history retrieved successfully",
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|获取成功|[internal_handlers.GetCardTransactionHistoryResponse](#schemainternal_handlers.getcardtransactionhistoryresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误或上游返回失败|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
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

<h2 id="tocS_internal_handlers.CardTransactionHistoryData">internal_handlers.CardTransactionHistoryData</h2>

<a id="schemainternal_handlers.cardtransactionhistorydata"></a>
<a id="schema_internal_handlers.CardTransactionHistoryData"></a>
<a id="tocSinternal_handlers.cardtransactionhistorydata"></a>
<a id="tocsinternal_handlers.cardtransactionhistorydata"></a>

```json
{
  "page": 1,
  "page_size": 20,
  "public_token": "123774296",
  "total": 2,
  "transactions": [
    {
      "amount": 12.5,
      "currency": "USD",
      "description": "Card purchase",
      "merchant_name": "Amazon",
      "status": "completed",
      "trade_id": "202603130001",
      "trade_time": "2026-03-13T10:30:00Z",
      "trade_type": "consume",
      "transaction_id": "TXN202603130001"
    }
  ]
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|page|integer|false|none||Page 当前页码|
|page_size|integer|false|none||PageSize 每页条数|
|public_token|string|false|none||PublicToken 卡片 public_token|
|total|integer|false|none||Total 总记录数|
|transactions|[[internal_handlers.CardTransactionHistoryItem](#schemainternal_handlers.cardtransactionhistoryitem)]|false|none||Transactions 交易记录列表|

<h2 id="tocS_internal_handlers.CardTransactionHistoryItem">internal_handlers.CardTransactionHistoryItem</h2>

<a id="schemainternal_handlers.cardtransactionhistoryitem"></a>
<a id="schema_internal_handlers.CardTransactionHistoryItem"></a>
<a id="tocSinternal_handlers.cardtransactionhistoryitem"></a>
<a id="tocsinternal_handlers.cardtransactionhistoryitem"></a>

```json
{
  "amount": 12.5,
  "currency": "USD",
  "description": "Card purchase",
  "merchant_name": "Amazon",
  "status": "completed",
  "trade_id": "202603130001",
  "trade_time": "2026-03-13T10:30:00Z",
  "trade_type": "consume",
  "transaction_id": "TXN202603130001"
}

```

卡片交易记录项，字段基于 PokePay `/card/{publicToken}/account/trade` 常见返回整理

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|amount|number|false|none||Amount 交易金额|
|currency|string|false|none||Currency 交易币种|
|description|string|false|none||Description 交易描述|
|merchant_name|string|false|none||MerchantName 商户名称|
|status|string|false|none||Status 交易状态|
|trade_id|string|false|none||TradeID 上游交易ID|
|trade_time|string|false|none||TradeTime 交易时间|
|trade_type|string|false|none||TradeType 交易类型|
|transaction_id|string|false|none||TransactionID 交易流水号|

<h2 id="tocS_internal_handlers.GetCardTransactionHistoryResponse">internal_handlers.GetCardTransactionHistoryResponse</h2>

<a id="schemainternal_handlers.getcardtransactionhistoryresponse"></a>
<a id="schema_internal_handlers.GetCardTransactionHistoryResponse"></a>
<a id="tocSinternal_handlers.getcardtransactionhistoryresponse"></a>
<a id="tocsinternal_handlers.getcardtransactionhistoryresponse"></a>

```json
{
  "data": {
    "page": 1,
    "page_size": 20,
    "public_token": "123774296",
    "total": 2,
    "transactions": [
      {
        "amount": 12.5,
        "currency": "USD",
        "description": "Card purchase",
        "merchant_name": "Amazon",
        "status": "completed",
        "trade_id": "202603130001",
        "trade_time": "2026-03-13T10:30:00Z",
        "trade_type": "consume",
        "transaction_id": "TXN202603130001"
      }
    ]
  },
  "message": "Transaction history retrieved successfully",
  "status": "success"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|data|[internal_handlers.CardTransactionHistoryData](#schemainternal_handlers.cardtransactionhistorydata)|false|none||Data 响应数据|
|message|string|false|none||Message 响应消息|
|status|string|false|none||Status 响应状态|


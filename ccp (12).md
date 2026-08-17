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

## GET 获取卡片交易详情

GET /card/trade/{id}

校验 public_token 属于当前用户后，调用上游 `/card/trade/{id}`，并原样返回上游 HTTP 状态码和 JSON Body。接口不会返回上游认证 Header 或 Cookie。

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|id|path|integer(int64)| 是 |CardThreddTrade 交易记录 ID，只能从 /card/trades 获取|
|public_token|query|string| 是 |交易所属卡片的 public_token，用于归属校验|

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": {
    "amount": 50,
    "bank_fee": 0,
    "card_id": 62903,
    "card_number": "**** **** **** 1234",
    "clear_amount": 50,
    "clear_time": "2026-08-14 10:30:00",
    "currency_code": "HKD",
    "currency_id": 344,
    "extra_fee": 0,
    "fee_type": 0,
    "id": 3000000522486060,
    "master_id": 0,
    "merchant_amount": 50,
    "merchant_city": "Hong Kong",
    "merchant_country": "HK",
    "merchant_currency": "HKD",
    "merchant_name": "TEST STORE",
    "official_clear_time": "2026-08-14 10:31:00",
    "official_fee": 0,
    "official_trade_time": "2026-08-14 10:29:58",
    "reversal_amount": 0,
    "reversal_time": "",
    "trace_id": "trace_123",
    "trade_clear": 1,
    "trade_exception": 0,
    "trade_fee": 0.5,
    "trade_remark": "Card purchase",
    "trade_reversal": 0,
    "trade_time": "2026-08-14 10:30:00",
    "trade_total": 50.5,
    "trade_type": 17
  },
  "errstr": "SUCCESS",
  "request_id": "req_202608140001"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|上游原始交易详情响应|[internal_handlers.PokePayCardTradeDetailResponse](#schemainternal_handlers.pokepaycardtradedetailresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|参数错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|卡片或交易不存在|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|502|[Bad Gateway](https://tools.ietf.org/html/rfc7231#section-6.6.3)|支付服务不可用或响应无法校验|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

## GET 获取卡片消费记录列表

GET /card/trades

获取 PokePay CardThreddTrade 消费记录。返回记录的 `id` 可用于 `/card/trade/{id}` 查询详情。

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|public_token|query|string| 是 |卡片 public_token|
|page|query|integer| 否 |页码，默认1|
|limit|query|integer| 否 |每页条数，默认20，最大100|
|start_date|query|integer| 否 |交易开始时间戳|
|end_date|query|integer| 否 |交易结束时间戳|
|clear_start_date|query|integer| 否 |结算开始时间戳|
|clear_end_date|query|integer| 否 |结算结束时间戳|
|official_trade_start_date|query|integer| 否 |卡方交易开始时间戳|
|official_trade_end_date|query|integer| 否 |卡方交易结束时间戳|
|trade_clear|query|integer| 否 |结算筛选，按 PokePay 规则传递|
|trade_type|query|integer| 否 |交易类型：17授权，18撤销，19退款|

> 返回示例

> 200 Response

```json
{
  "code": 200,
  "data": {
    "page_num": 1,
    "page_size": 20,
    "total": 13,
    "trades": [
      {
        "amount": 50,
        "bank_fee": 0,
        "card_id": 62903,
        "card_number": "**** **** **** 1234",
        "clear_amount": 50,
        "clear_time": "2026-08-14 10:30:00",
        "currency_code": "HKD",
        "currency_id": 344,
        "extra_fee": 0,
        "fee_type": 0,
        "id": 3000000522486060,
        "master_id": 0,
        "merchant_amount": 50,
        "merchant_city": "Hong Kong",
        "merchant_country": "HK",
        "merchant_currency": "HKD",
        "merchant_name": "TEST STORE",
        "official_clear_time": "2026-08-14 10:31:00",
        "official_fee": 0,
        "official_trade_time": "2026-08-14 10:29:58",
        "reversal_amount": 0,
        "reversal_time": "",
        "trace_id": "trace_123",
        "trade_clear": 1,
        "trade_exception": 0,
        "trade_fee": 0.5,
        "trade_remark": "Card purchase",
        "trade_reversal": 0,
        "trade_time": "2026-08-14 10:30:00",
        "trade_total": 50.5,
        "trade_type": 17
      }
    ]
  },
  "errstr": "SUCCESS",
  "request_id": "req_202608150001"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|上游消费记录列表响应|[internal_handlers.PokePayCardTradeListResponse](#schemainternal_handlers.pokepaycardtradelistresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|参数错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|卡片不存在|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|502|[Bad Gateway](https://tools.ietf.org/html/rfc7231#section-6.6.3)|支付服务不可用或响应无法校验|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

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

<h2 id="tocS_internal_handlers.PokePayCardTradeDetail">internal_handlers.PokePayCardTradeDetail</h2>

<a id="schemainternal_handlers.pokepaycardtradedetail"></a>
<a id="schema_internal_handlers.PokePayCardTradeDetail"></a>
<a id="tocSinternal_handlers.pokepaycardtradedetail"></a>
<a id="tocsinternal_handlers.pokepaycardtradedetail"></a>

```json
{
  "amount": 50,
  "bank_fee": 0,
  "card_id": 62903,
  "card_number": "**** **** **** 1234",
  "clear_amount": 50,
  "clear_time": "2026-08-14 10:30:00",
  "currency_code": "HKD",
  "currency_id": 344,
  "extra_fee": 0,
  "fee_type": 0,
  "id": 3000000522486060,
  "master_id": 0,
  "merchant_amount": 50,
  "merchant_city": "Hong Kong",
  "merchant_country": "HK",
  "merchant_currency": "HKD",
  "merchant_name": "TEST STORE",
  "official_clear_time": "2026-08-14 10:31:00",
  "official_fee": 0,
  "official_trade_time": "2026-08-14 10:29:58",
  "reversal_amount": 0,
  "reversal_time": "",
  "trace_id": "trace_123",
  "trade_clear": 1,
  "trade_exception": 0,
  "trade_fee": 0.5,
  "trade_remark": "Card purchase",
  "trade_reversal": 0,
  "trade_time": "2026-08-14 10:30:00",
  "trade_total": 50.5,
  "trade_type": 17
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|amount|number|false|none||交易金额|
|bank_fee|number|false|none||Visa 费用|
|card_id|integer|false|none||PokePay 内部卡片 ID，不是 public_token|
|card_number|string|false|none||卡号，展示形式由上游决定|
|clear_amount|number|false|none||结算金额|
|clear_time|string|false|none||结算时间|
|currency_code|string|false|none||币种代码|
|currency_id|integer|false|none||币种 ID|
|extra_fee|number|false|none||额外手续费|
|fee_type|integer|false|none||额外手续费类型：1充值，2提现|
|id|integer|false|none||none|
|master_id|integer|false|none||主单 ID|
|merchant_amount|number|false|none||商家金额|
|merchant_city|string|false|none||商家所在城市|
|merchant_country|string|false|none||商家所在国家|
|merchant_currency|string|false|none||商家币种|
|merchant_name|string|false|none||商家名称|
|official_clear_time|string|false|none||卡方结算时间|
|official_fee|number|false|none||卡方交易费用|
|official_trade_time|string|false|none||卡方交易时间|
|reversal_amount|number|false|none||撤销金额|
|reversal_time|string|false|none||撤销时间|
|trace_id|string|false|none||生命周期 Trace ID|
|trade_clear|integer|false|none||结算状态：0结算中，1已结算|
|trade_exception|integer|false|none||异常状态|
|trade_fee|number|false|none||PokePay 交易费用|
|trade_remark|string|false|none||备注|
|trade_reversal|integer|false|none||撤销状态：0无，1部分，2全部|
|trade_time|string|false|none||交易时间|
|trade_total|number|false|none||交易总金额|
|trade_type|integer|false|none||17授权，18撤销，19退款|

<h2 id="tocS_internal_handlers.PokePayCardTradeDetailResponse">internal_handlers.PokePayCardTradeDetailResponse</h2>

<a id="schemainternal_handlers.pokepaycardtradedetailresponse"></a>
<a id="schema_internal_handlers.PokePayCardTradeDetailResponse"></a>
<a id="tocSinternal_handlers.pokepaycardtradedetailresponse"></a>
<a id="tocsinternal_handlers.pokepaycardtradedetailresponse"></a>

```json
{
  "code": 200,
  "data": {
    "amount": 50,
    "bank_fee": 0,
    "card_id": 62903,
    "card_number": "**** **** **** 1234",
    "clear_amount": 50,
    "clear_time": "2026-08-14 10:30:00",
    "currency_code": "HKD",
    "currency_id": 344,
    "extra_fee": 0,
    "fee_type": 0,
    "id": 3000000522486060,
    "master_id": 0,
    "merchant_amount": 50,
    "merchant_city": "Hong Kong",
    "merchant_country": "HK",
    "merchant_currency": "HKD",
    "merchant_name": "TEST STORE",
    "official_clear_time": "2026-08-14 10:31:00",
    "official_fee": 0,
    "official_trade_time": "2026-08-14 10:29:58",
    "reversal_amount": 0,
    "reversal_time": "",
    "trace_id": "trace_123",
    "trade_clear": 1,
    "trade_exception": 0,
    "trade_fee": 0.5,
    "trade_remark": "Card purchase",
    "trade_reversal": 0,
    "trade_time": "2026-08-14 10:30:00",
    "trade_total": 50.5,
    "trade_type": 17
  },
  "errstr": "SUCCESS",
  "request_id": "req_202608140001"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||none|
|data|[internal_handlers.PokePayCardTradeDetail](#schemainternal_handlers.pokepaycardtradedetail)|false|none||none|
|errstr|string|false|none||none|
|request_id|string|false|none||none|

<h2 id="tocS_internal_handlers.PokePayCardTradeListData">internal_handlers.PokePayCardTradeListData</h2>

<a id="schemainternal_handlers.pokepaycardtradelistdata"></a>
<a id="schema_internal_handlers.PokePayCardTradeListData"></a>
<a id="tocSinternal_handlers.pokepaycardtradelistdata"></a>
<a id="tocsinternal_handlers.pokepaycardtradelistdata"></a>

```json
{
  "page_num": 1,
  "page_size": 20,
  "total": 13,
  "trades": [
    {
      "amount": 50,
      "bank_fee": 0,
      "card_id": 62903,
      "card_number": "**** **** **** 1234",
      "clear_amount": 50,
      "clear_time": "2026-08-14 10:30:00",
      "currency_code": "HKD",
      "currency_id": 344,
      "extra_fee": 0,
      "fee_type": 0,
      "id": 3000000522486060,
      "master_id": 0,
      "merchant_amount": 50,
      "merchant_city": "Hong Kong",
      "merchant_country": "HK",
      "merchant_currency": "HKD",
      "merchant_name": "TEST STORE",
      "official_clear_time": "2026-08-14 10:31:00",
      "official_fee": 0,
      "official_trade_time": "2026-08-14 10:29:58",
      "reversal_amount": 0,
      "reversal_time": "",
      "trace_id": "trace_123",
      "trade_clear": 1,
      "trade_exception": 0,
      "trade_fee": 0.5,
      "trade_remark": "Card purchase",
      "trade_reversal": 0,
      "trade_time": "2026-08-14 10:30:00",
      "trade_total": 50.5,
      "trade_type": 17
    }
  ]
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|page_num|integer|false|none||none|
|page_size|integer|false|none||none|
|total|integer|false|none||none|
|trades|[[internal_handlers.PokePayCardTradeDetail](#schemainternal_handlers.pokepaycardtradedetail)]|false|none||none|

<h2 id="tocS_internal_handlers.PokePayCardTradeListResponse">internal_handlers.PokePayCardTradeListResponse</h2>

<a id="schemainternal_handlers.pokepaycardtradelistresponse"></a>
<a id="schema_internal_handlers.PokePayCardTradeListResponse"></a>
<a id="tocSinternal_handlers.pokepaycardtradelistresponse"></a>
<a id="tocsinternal_handlers.pokepaycardtradelistresponse"></a>

```json
{
  "code": 200,
  "data": {
    "page_num": 1,
    "page_size": 20,
    "total": 13,
    "trades": [
      {
        "amount": 50,
        "bank_fee": 0,
        "card_id": 62903,
        "card_number": "**** **** **** 1234",
        "clear_amount": 50,
        "clear_time": "2026-08-14 10:30:00",
        "currency_code": "HKD",
        "currency_id": 344,
        "extra_fee": 0,
        "fee_type": 0,
        "id": 3000000522486060,
        "master_id": 0,
        "merchant_amount": 50,
        "merchant_city": "Hong Kong",
        "merchant_country": "HK",
        "merchant_currency": "HKD",
        "merchant_name": "TEST STORE",
        "official_clear_time": "2026-08-14 10:31:00",
        "official_fee": 0,
        "official_trade_time": "2026-08-14 10:29:58",
        "reversal_amount": 0,
        "reversal_time": "",
        "trace_id": "trace_123",
        "trade_clear": 1,
        "trade_exception": 0,
        "trade_fee": 0.5,
        "trade_remark": "Card purchase",
        "trade_reversal": 0,
        "trade_time": "2026-08-14 10:30:00",
        "trade_total": 50.5,
        "trade_type": 17
      }
    ]
  },
  "errstr": "SUCCESS",
  "request_id": "req_202608150001"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|code|integer|false|none||none|
|data|[internal_handlers.PokePayCardTradeListData](#schemainternal_handlers.pokepaycardtradelistdata)|false|none||none|
|errstr|string|false|none||none|
|request_id|string|false|none||none|


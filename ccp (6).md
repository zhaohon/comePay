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

# 卡片

## PUT 修改卡片状态

PUT /card/status

修改 PokePay 卡片的状态（激活/冻结/注销）

> Body 请求参数

```json
{
  "public_token": "123791920",
  "card_status_code": "G1"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|object| 是 |none|
|» public_token|body|string| 是 |none|
|» card_status_code|body|string| 是 |00激活 G1冻结 99注销|

> 返回示例

> 200 Response

```json
{
  "data": {
    "card_status": "ShortTermDebitBlock",
    "card_status_code": "G1",
    "description": "Card Status Changed From 00 to G1 by card status endpoint - Date: 2025-12-29 06:44:48",
    "public_token": "123791920",
    "status_name": "Frozen",
    "updated": "2025-12-29",
    "updated_by": "Note: Card freezing"
  },
  "message": "Card status modified successfully",
  "status": "success"
}
```

> 400 Response

```json
{}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|修改成功|Inline|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误或无效的状态码|Inline|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|Inline|
|502|[Bad Gateway](https://tools.ietf.org/html/rfc7231#section-6.6.3)|PokePay API 错误|Inline|

### 返回数据结构

状态码 **200**

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|» data|object|true|none||none|
|»» card_status|string|true|none||none|
|»» card_status_code|string|true|none||none|
|»» description|string|true|none||none|
|»» public_token|string|true|none||none|
|»» status_name|string|true|none||none|
|»» updated|string|true|none||none|
|»» updated_by|string|true|none||none|
|» message|string|true|none||none|
|» status|string|true|none||none|

# 数据模型


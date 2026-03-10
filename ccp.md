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

# App版本

## GET 获取App版本信息

GET /app-version

获取指定平台的App最新版本信息，包括版本号、下载链接、更新说明和强制更新标志
此接口无需认证，可公开访问

**语言参数说明:**
- 通过 Header `Accept-Language` 传入语言参数
- 支持 zh(中文)、en(英文)、ar(阿拉伯文)
- 不传则默认返回英文(en)

**返回示例（Header 传入 Accept-Language: zh）:**
```json
{"status":"success","data":{"platform":"ios","version":"1.2.0","download_url":"https://apps.apple.com/app/id123456","release_notes":"新增功能A","force_update":false,"updated_at":"2026-01-05T10:00:00Z"}}
```

**返回示例（不传 Accept-Language，默认en）:**
```json
{"status":"success","data":{"platform":"ios","version":"1.2.0","download_url":"https://apps.apple.com/app/id123456","release_notes":"New feature A","force_update":false,"updated_at":"2026-01-05T10:00:00Z"}}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|platform|query|string| 是 |平台类型|
|Accept-Language|header|string| 否 |语言（zh/en/ar），默认en|

#### 枚举值

|属性|值|
|---|---|
|platform|ios|
|platform|android|
|Accept-Language|zh|
|Accept-Language|en|
|Accept-Language|ar|

> 返回示例

> 200 Response

```json
{
  "data": {
    "download_url": "https://apps.apple.com/app/id123456",
    "force_update": false,
    "platform": "ios",
    "release_notes": "1. 新增功能A\n2. 修复bug B",
    "updated_at": "2026-01-05T10:00:00Z",
    "version": "1.2.0"
  },
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|成功返回版本信息|[handlers.GetAppVersionResponse](#schemahandlers.getappversionresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|请求参数错误（平台参数缺失或无效）|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|该平台版本信息未配置|[handlers.ErrorResponse](#schemahandlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器错误|[handlers.ErrorResponse](#schemahandlers.errorresponse)|

# 数据模型

<h2 id="tocS_handlers.AppVersionPublicInfoSwagger">handlers.AppVersionPublicInfoSwagger</h2>

<a id="schemahandlers.appversionpublicinfoswagger"></a>
<a id="schema_handlers.AppVersionPublicInfoSwagger"></a>
<a id="tocShandlers.appversionpublicinfoswagger"></a>
<a id="tocshandlers.appversionpublicinfoswagger"></a>

```json
{
  "download_url": "https://apps.apple.com/app/id123456",
  "force_update": false,
  "platform": "ios",
  "release_notes": "1. 新增功能A\n2. 修复bug B",
  "updated_at": "2026-01-05T10:00:00Z",
  "version": "1.2.0"
}

```

用户端获取的 App 版本信息（传入 lang 参数时返回）

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|download_url|string|false|none||none|
|force_update|boolean|false|none||none|
|platform|string|false|none||none|
|release_notes|string|false|none||none|
|updated_at|string|false|none||none|
|version|string|false|none||none|

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

<h2 id="tocS_handlers.GetAppVersionResponse">handlers.GetAppVersionResponse</h2>

<a id="schemahandlers.getappversionresponse"></a>
<a id="schema_handlers.GetAppVersionResponse"></a>
<a id="tocShandlers.getappversionresponse"></a>
<a id="tocshandlers.getappversionresponse"></a>

```json
{
  "data": {
    "download_url": "https://apps.apple.com/app/id123456",
    "force_update": false,
    "platform": "ios",
    "release_notes": "1. 新增功能A\n2. 修复bug B",
    "updated_at": "2026-01-05T10:00:00Z",
    "version": "1.2.0"
  },
  "status": "success"
}

```

用户端获取 App 版本信息的响应（传入 lang 参数时返回）

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|data|[handlers.AppVersionPublicInfoSwagger](#schemahandlers.appversionpublicinfoswagger)|false|none||用户端获取的 App 版本信息（传入 lang 参数时返回）|
|status|string|false|none||none|


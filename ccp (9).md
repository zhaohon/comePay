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

# 通知

## POST 注册或刷新 FCM 设备

POST /push/devices

将 FCM Token 幂等绑定到当前登录用户；同一 Token 再次注册时刷新平台、设备和版本信息。服务端从 Bearer Token 读取用户身份，不接受请求中的 user_id。

> Body 请求参数

```json
{
  "app_version": "2.6.0",
  "device_id": "android-device-001",
  "fcm_token": "fcm-token-placeholder",
  "platform": "android"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[internal_handlers.PushDeviceRegisterRequestSwagger](#schemainternal_handlers.pushdeviceregisterrequestswagger)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "device": {
    "app_version": "2.3.0",
    "device_id": "iphone-15-pro",
    "enabled": true,
    "id": 12,
    "last_seen_at": "2026-08-07T12:00:00Z",
    "platform": "ios"
  },
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[internal_handlers.PushDeviceRegisterResponse](#schemainternal_handlers.pushdeviceregisterresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Bad Request|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|Internal Server Error|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

## DELETE 注销 FCM 设备

DELETE /push/devices

仅停用属于当前登录用户的 FCM Token，无法操作其他用户设备。注销后保留设备投递日志，但后续任务不会再向该设备发送。

> Body 请求参数

```json
{
  "fcm_token": "fcm-token-placeholder"
}
```

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|body|body|[internal_handlers.PushDeviceUnregisterRequestSwagger](#schemainternal_handlers.pushdeviceunregisterrequestswagger)| 是 |none|

> 返回示例

> 200 Response

```json
{
  "message": "推送设备已注销",
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|OK|[internal_handlers.PushDeviceUnregisterResponseSwagger](#schemainternal_handlers.pushdeviceunregisterresponseswagger)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|Bad Request|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|Unauthorized|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|Not Found|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|Internal Server Error|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

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

<h2 id="tocS_internal_handlers.PushDeviceData">internal_handlers.PushDeviceData</h2>

<a id="schemainternal_handlers.pushdevicedata"></a>
<a id="schema_internal_handlers.PushDeviceData"></a>
<a id="tocSinternal_handlers.pushdevicedata"></a>
<a id="tocsinternal_handlers.pushdevicedata"></a>

```json
{
  "app_version": "2.3.0",
  "device_id": "iphone-15-pro",
  "enabled": true,
  "id": 12,
  "last_seen_at": "2026-08-07T12:00:00Z",
  "platform": "ios"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|app_version|string|false|none||none|
|device_id|string|false|none||none|
|enabled|boolean|false|none||none|
|id|integer|false|none||none|
|last_seen_at|string|false|none||none|
|platform|string|false|none||none|

<h2 id="tocS_internal_handlers.PushDeviceRegisterRequestSwagger">internal_handlers.PushDeviceRegisterRequestSwagger</h2>

<a id="schemainternal_handlers.pushdeviceregisterrequestswagger"></a>
<a id="schema_internal_handlers.PushDeviceRegisterRequestSwagger"></a>
<a id="tocSinternal_handlers.pushdeviceregisterrequestswagger"></a>
<a id="tocsinternal_handlers.pushdeviceregisterrequestswagger"></a>

```json
{
  "app_version": "2.6.0",
  "device_id": "android-device-001",
  "fcm_token": "fcm-token-placeholder",
  "platform": "android"
}

```

将 FCM Token 绑定到当前登录用户。同一 Token 重复提交时幂等更新设备信息，不接受请求中的 user_id。

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|app_version|string|false|none||App 版本|
|device_id|string|true|none||客户端稳定设备标识|
|fcm_token|string|true|none||FCM 设备 Token；服务端不会在响应中返回|
|platform|string|true|none||客户端平台|

#### 枚举值

|属性|值|
|---|---|
|platform|android|
|platform|ios|
|platform|web|

<h2 id="tocS_internal_handlers.PushDeviceRegisterResponse">internal_handlers.PushDeviceRegisterResponse</h2>

<a id="schemainternal_handlers.pushdeviceregisterresponse"></a>
<a id="schema_internal_handlers.PushDeviceRegisterResponse"></a>
<a id="tocSinternal_handlers.pushdeviceregisterresponse"></a>
<a id="tocsinternal_handlers.pushdeviceregisterresponse"></a>

```json
{
  "device": {
    "app_version": "2.3.0",
    "device_id": "iphone-15-pro",
    "enabled": true,
    "id": 12,
    "last_seen_at": "2026-08-07T12:00:00Z",
    "platform": "ios"
  },
  "status": "success"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|device|[internal_handlers.PushDeviceData](#schemainternal_handlers.pushdevicedata)|false|none||none|
|status|string|false|none||none|

<h2 id="tocS_internal_handlers.PushDeviceUnregisterRequestSwagger">internal_handlers.PushDeviceUnregisterRequestSwagger</h2>

<a id="schemainternal_handlers.pushdeviceunregisterrequestswagger"></a>
<a id="schema_internal_handlers.PushDeviceUnregisterRequestSwagger"></a>
<a id="tocSinternal_handlers.pushdeviceunregisterrequestswagger"></a>
<a id="tocsinternal_handlers.pushdeviceunregisterrequestswagger"></a>

```json
{
  "fcm_token": "fcm-token-placeholder"
}

```

仅停用当前登录用户拥有的 Token；提交其他用户的 Token 不会修改其他用户设备。

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|fcm_token|string|true|none||要停用的 FCM Token|

<h2 id="tocS_internal_handlers.PushDeviceUnregisterResponseSwagger">internal_handlers.PushDeviceUnregisterResponseSwagger</h2>

<a id="schemainternal_handlers.pushdeviceunregisterresponseswagger"></a>
<a id="schema_internal_handlers.PushDeviceUnregisterResponseSwagger"></a>
<a id="tocSinternal_handlers.pushdeviceunregisterresponseswagger"></a>
<a id="tocsinternal_handlers.pushdeviceunregisterresponseswagger"></a>

```json
{
  "message": "推送设备已注销",
  "status": "success"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|message|string|false|none||none|
|status|string|false|none||none|


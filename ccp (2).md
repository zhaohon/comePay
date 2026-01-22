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

## GET 获取通知列表

GET /notifications

获取当前用户的通知列表，支持按状态过滤。返回的每条通知包含 status 字段表示已读(read)或未读(unread)状态。

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|limit|query|integer| 否 |每页数量，默认20|
|offset|query|integer| 否 |偏移量，默认0|
|status|query|string| 否 |状态过滤: unread(仅未读), read(仅已读), 不传则返回全部|

#### 枚举值

|属性|值|
|---|---|
|status|unread|
|status|read|

> 返回示例

> 200 Response

```json
{
  "count": 10,
  "notifications": [
    {
      "body": "您有一条新消息",
      "created_at": "2024-01-15T10:00:00Z",
      "data": "{\"type\":\"system\"}",
      "id": 1,
      "read_at": "2024-01-15T10:30:00Z",
      "status": "unread",
      "title": "系统通知",
      "updated_at": "2024-01-15T10:00:00Z",
      "user_id": 123
    }
  ],
  "status": "success",
  "total": 50
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|通知列表，包含 status 字段表示已读/未读状态|[internal_handlers.GetNotificationsResponse](#schemainternal_handlers.getnotificationsresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

## GET 获取未读通知数量

GET /notifications/unread-count

获取当前用户的未读通知数量。返回 status 为 unread 的通知总数，可用于显示未读角标。

> 返回示例

> 200 Response

```json
{
  "count": 5,
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|未读通知数量|[internal_handlers.GetUnreadNotificationCountResponse](#schemainternal_handlers.getunreadnotificationcountresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

## GET 获取通知详情

GET /notifications/{id}

获取指定通知的详情。调用此接口后，如果通知为未读状态，将自动标记为已读，并更新 read_at 时间戳。

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|id|path|integer| 是 |通知ID|

> 返回示例

> 200 Response

```json
{
  "notification": {
    "body": "您有一条新消息",
    "created_at": "2024-01-15T10:00:00Z",
    "data": "{\"type\":\"system\"}",
    "id": 1,
    "read_at": "2024-01-15T10:30:00Z",
    "status": "unread",
    "title": "系统通知",
    "updated_at": "2024-01-15T10:00:00Z",
    "user_id": 123
  },
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|通知详情，status 字段会更新为 read|[internal_handlers.GetNotificationDetailResponse](#schemainternal_handlers.getnotificationdetailresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|无效的通知ID|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|通知不存在|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

# 公告

## GET 获取已发布的公告列表

GET /announcements

获取已发布的公告列表（App端），支持多语言和分页，返回每条公告的已读状态

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|page|query|integer| 否 |页码|
|limit|query|integer| 否 |每页数量|
|lang|query|string| 否 |语言|

#### 枚举值

|属性|值|
|---|---|
|lang|zh|
|lang|en|
|lang|ar|

> 返回示例

> 200 Response

```json
{
  "items": [
    {
      "content": "System will undergo maintenance tonight...",
      "created_at": "2024-01-01T00:00:00Z",
      "id": 1,
      "is_read": false,
      "title": "System Maintenance"
    }
  ],
  "limit": 20,
  "page": 1,
  "status": "success",
  "total": 10,
  "total_pages": 1
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|获取成功|[internal_handlers.GetPublishedAnnouncementsResponse](#schemainternal_handlers.getpublishedannouncementsresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

## GET 获取公告详情

GET /announcements/{id}

根据ID获取已发布的公告详情（App端），支持多语言，自动标记公告为已读

### 请求参数

|名称|位置|类型|必选|说明|
|---|---|---|---|---|
|id|path|integer| 是 |公告ID|
|lang|query|string| 否 |语言|

#### 枚举值

|属性|值|
|---|---|
|lang|zh|
|lang|en|
|lang|ar|

> 返回示例

> 200 Response

```json
{
  "data": {
    "content": "System will undergo maintenance tonight...",
    "created_at": "2024-01-01T00:00:00Z",
    "id": 1,
    "status": "published",
    "title": "System Maintenance"
  },
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|获取成功|[internal_handlers.GetPublishedAnnouncementByIDResponse](#schemainternal_handlers.getpublishedannouncementbyidresponse)|
|400|[Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)|无效的公告ID|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|401|[Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)|未授权|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|404|[Not Found](https://tools.ietf.org/html/rfc7231#section-6.5.4)|公告不存在|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|
|500|[Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1)|服务器内部错误|[internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)|

## GET 获取未读公告数量

GET /announcements/unread-count

获取当前用户的未读公告数量

> 返回示例

> 200 Response

```json
{
  "count": 5,
  "status": "success"
}
```

### 返回结果

|状态码|状态码含义|说明|数据模型|
|---|---|---|---|
|200|[OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)|获取成功|[internal_handlers.UnreadCountResponse](#schemainternal_handlers.unreadcountresponse)|
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

<h2 id="tocS_internal_handlers.AnnouncementItemResponse">internal_handlers.AnnouncementItemResponse</h2>

<a id="schemainternal_handlers.announcementitemresponse"></a>
<a id="schema_internal_handlers.AnnouncementItemResponse"></a>
<a id="tocSinternal_handlers.announcementitemresponse"></a>
<a id="tocsinternal_handlers.announcementitemresponse"></a>

```json
{
  "content": "System will undergo maintenance tonight...",
  "created_at": "2024-01-01T00:00:00Z",
  "id": 1,
  "status": "published",
  "title": "System Maintenance"
}

```

公告列表中的单个项目（根据语言返回对应内容）

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|content|string|false|none||内容（根据语言参数返回）|
|created_at|string|false|none||创建时间|
|id|integer|false|none||公告ID|
|status|string|false|none||状态|
|title|string|false|none||标题（根据语言参数返回）|

#### 枚举值

|属性|值|
|---|---|
|status|draft|
|status|published|
|status|deleted|

<h2 id="tocS_internal_handlers.AnnouncementWithReadStatusResponse">internal_handlers.AnnouncementWithReadStatusResponse</h2>

<a id="schemainternal_handlers.announcementwithreadstatusresponse"></a>
<a id="schema_internal_handlers.AnnouncementWithReadStatusResponse"></a>
<a id="tocSinternal_handlers.announcementwithreadstatusresponse"></a>
<a id="tocsinternal_handlers.announcementwithreadstatusresponse"></a>

```json
{
  "content": "System will undergo maintenance tonight...",
  "created_at": "2024-01-01T00:00:00Z",
  "id": 1,
  "is_read": false,
  "title": "System Maintenance"
}

```

App端公告列表中的单个项目（包含已读状态）

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|content|string|false|none||内容（根据语言参数返回）|
|created_at|string|false|none||创建时间|
|id|integer|false|none||公告ID|
|is_read|boolean|false|none||是否已读|
|title|string|false|none||标题（根据语言参数返回）|

<h2 id="tocS_internal_handlers.GetNotificationsResponse">internal_handlers.GetNotificationsResponse</h2>

<a id="schemainternal_handlers.getnotificationsresponse"></a>
<a id="schema_internal_handlers.GetNotificationsResponse"></a>
<a id="tocSinternal_handlers.getnotificationsresponse"></a>
<a id="tocsinternal_handlers.getnotificationsresponse"></a>

```json
{
  "count": 10,
  "notifications": [
    {
      "body": "您有一条新消息",
      "created_at": "2024-01-15T10:00:00Z",
      "data": "{\"type\":\"system\"}",
      "id": 1,
      "read_at": "2024-01-15T10:30:00Z",
      "status": "unread",
      "title": "系统通知",
      "updated_at": "2024-01-15T10:00:00Z",
      "user_id": 123
    }
  ],
  "status": "success",
  "total": 50
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|count|integer|false|none||none|
|notifications|[[internal_handlers.NotificationItem](#schemainternal_handlers.notificationitem)]|false|none||none|
|status|string|false|none||none|
|total|integer|false|none||none|

<h2 id="tocS_internal_handlers.GetUnreadNotificationCountResponse">internal_handlers.GetUnreadNotificationCountResponse</h2>

<a id="schemainternal_handlers.getunreadnotificationcountresponse"></a>
<a id="schema_internal_handlers.GetUnreadNotificationCountResponse"></a>
<a id="tocSinternal_handlers.getunreadnotificationcountresponse"></a>
<a id="tocsinternal_handlers.getunreadnotificationcountresponse"></a>

```json
{
  "count": 5,
  "status": "success"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|count|integer|false|none||none|
|status|string|false|none||none|

<h2 id="tocS_internal_handlers.GetNotificationDetailResponse">internal_handlers.GetNotificationDetailResponse</h2>

<a id="schemainternal_handlers.getnotificationdetailresponse"></a>
<a id="schema_internal_handlers.GetNotificationDetailResponse"></a>
<a id="tocSinternal_handlers.getnotificationdetailresponse"></a>
<a id="tocsinternal_handlers.getnotificationdetailresponse"></a>

```json
{
  "notification": {
    "body": "您有一条新消息",
    "created_at": "2024-01-15T10:00:00Z",
    "data": "{\"type\":\"system\"}",
    "id": 1,
    "read_at": "2024-01-15T10:30:00Z",
    "status": "unread",
    "title": "系统通知",
    "updated_at": "2024-01-15T10:00:00Z",
    "user_id": 123
  },
  "status": "success"
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|notification|[internal_handlers.NotificationItem](#schemainternal_handlers.notificationitem)|false|none||none|
|status|string|false|none||none|

<h2 id="tocS_internal_handlers.GetPublishedAnnouncementByIDResponse">internal_handlers.GetPublishedAnnouncementByIDResponse</h2>

<a id="schemainternal_handlers.getpublishedannouncementbyidresponse"></a>
<a id="schema_internal_handlers.GetPublishedAnnouncementByIDResponse"></a>
<a id="tocSinternal_handlers.getpublishedannouncementbyidresponse"></a>
<a id="tocsinternal_handlers.getpublishedannouncementbyidresponse"></a>

```json
{
  "data": {
    "content": "System will undergo maintenance tonight...",
    "created_at": "2024-01-01T00:00:00Z",
    "id": 1,
    "status": "published",
    "title": "System Maintenance"
  },
  "status": "success"
}

```

用户端公告详情响应

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|data|[internal_handlers.AnnouncementItemResponse](#schemainternal_handlers.announcementitemresponse)|false|none||公告详情|
|status|string|false|none||响应状态|

<h2 id="tocS_internal_handlers.GetPublishedAnnouncementsResponse">internal_handlers.GetPublishedAnnouncementsResponse</h2>

<a id="schemainternal_handlers.getpublishedannouncementsresponse"></a>
<a id="schema_internal_handlers.GetPublishedAnnouncementsResponse"></a>
<a id="tocSinternal_handlers.getpublishedannouncementsresponse"></a>
<a id="tocsinternal_handlers.getpublishedannouncementsresponse"></a>

```json
{
  "items": [
    {
      "content": "System will undergo maintenance tonight...",
      "created_at": "2024-01-01T00:00:00Z",
      "id": 1,
      "is_read": false,
      "title": "System Maintenance"
    }
  ],
  "limit": 20,
  "page": 1,
  "status": "success",
  "total": 10,
  "total_pages": 1
}

```

用户端已发布公告列表响应（分页），包含每条公告的已读状态

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|items|[[internal_handlers.AnnouncementWithReadStatusResponse](#schemainternal_handlers.announcementwithreadstatusresponse)]|false|none||公告列表（包含已读状态）|
|limit|integer|false|none||每页数量|
|page|integer|false|none||当前页码|
|status|string|false|none||响应状态|
|total|integer|false|none||总记录数|
|total_pages|integer|false|none||总页数|

<h2 id="tocS_internal_handlers.NotificationItem">internal_handlers.NotificationItem</h2>

<a id="schemainternal_handlers.notificationitem"></a>
<a id="schema_internal_handlers.NotificationItem"></a>
<a id="tocSinternal_handlers.notificationitem"></a>
<a id="tocsinternal_handlers.notificationitem"></a>

```json
{
  "body": "您有一条新消息",
  "created_at": "2024-01-15T10:00:00Z",
  "data": "{\"type\":\"system\"}",
  "id": 1,
  "read_at": "2024-01-15T10:30:00Z",
  "status": "unread",
  "title": "系统通知",
  "updated_at": "2024-01-15T10:00:00Z",
  "user_id": 123
}

```

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|body|string|false|none||none|
|created_at|string|false|none||none|
|data|string|false|none||none|
|id|integer|false|none||none|
|read_at|string|false|none||none|
|status|string|false|none||none|
|title|string|false|none||none|
|updated_at|string|false|none||none|
|user_id|integer|false|none||none|

#### 枚举值

|属性|值|
|---|---|
|status|unread|
|status|read|

<h2 id="tocS_internal_handlers.UnreadCountResponse">internal_handlers.UnreadCountResponse</h2>

<a id="schemainternal_handlers.unreadcountresponse"></a>
<a id="schema_internal_handlers.UnreadCountResponse"></a>
<a id="tocSinternal_handlers.unreadcountresponse"></a>
<a id="tocsinternal_handlers.unreadcountresponse"></a>

```json
{
  "count": 5,
  "status": "success"
}

```

用户未读公告数量响应

### 属性

|名称|类型|必选|约束|中文名|说明|
|---|---|---|---|---|---|
|count|integer|false|none||未读公告数量|
|status|string|false|none||响应状态|


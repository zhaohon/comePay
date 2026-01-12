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

ComeComePay 后端 API 服务 - 提供用户认证、钱包管理、卡片管理、KYC 验证等功能

Base URLs:

# Authentication

- API Key (BearerAuth)
  - Parameter Name: **Authorization**, in: header. Bearer token 认证，格式: Bearer {token}

# 推荐系统

## GET 获取提成配置

GET /admin/commission-config

获取系统提成配置（管理员接口）

> 返回示例

> 200 Response

```json
{
  "config": null,
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明           | 数据模型                                                                                              |
| ------ | -------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 提成配置       | [internal_handlers.GetCommissionConfigResponse](#schemainternal_handlers.getcommissionconfigresponse) |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                             |

## PUT 更新提成配置

PUT /admin/commission-config

更新系统提成配置（管理员接口）

> Body 请求参数

```json
{
  "card_transaction_fee_rate": 0.02,
  "level1_card_opening_rate": 0.1,
  "level1_transaction_rate": 0.01,
  "level2_card_opening_rate": 0.05,
  "level2_transaction_rate": 0.005
}
```

### 请求参数

| 名称 | 位置 | 类型                                                                                                      | 必选 | 说明 |
| ---- | ---- | --------------------------------------------------------------------------------------------------------- | ---- | ---- |
| body | body | [internal_handlers.UpdateCommissionConfigRequest](#schemainternal_handlers.updatecommissionconfigrequest) | 是   | none |

> 返回示例

> 200 Response

```json
{
  "config": null,
  "message": "Commission config updated successfully",
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明           | 数据模型                                                                                                    |
| ------ | -------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 更新成功       | [internal_handlers.UpdateCommissionConfigResponse](#schemainternal_handlers.updatecommissionconfigresponse) |
| 400    | [Bad Request](https://tools.ietf.org/html/rfc7231#section-6.5.1)           | 请求参数错误   | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                                   |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                                   |

## GET 获取提成历史

GET /user/commissions

获取当前用户的提成记录历史

### 请求参数

| 名称      | 位置  | 类型    | 必选 | 说明     |
| --------- | ----- | ------- | ---- | -------- |
| page      | query | integer | 否   | 页码     |
| page_size | query | integer | 否   | 每页数量 |

> 返回示例

> 200 Response

```json
{
  "commissions": [null],
  "pagination": null,
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明           | 数据模型                                                                                    |
| ------ | -------------------------------------------------------------------------- | -------------- | ------------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 提成历史       | [internal_handlers.GetCommissionsResponse](#schemainternal_handlers.getcommissionsresponse) |
| 401    | [Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)            | 未授权         | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                   |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                   |

## GET 获取我的上级邀请人

GET /user/my-referrer

获取当前用户的上级邀请人信息（一级和二级）

> 返回示例

> 200 Response

```json
{
  "has_referrer": true,
  "level1_referrer": null,
  "level2_referrer": null,
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明           | 数据模型                                                                                  |
| ------ | -------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 邀请人信息     | [internal_handlers.GetMyReferrerResponse](#schemainternal_handlers.getmyreferrerresponse) |
| 401    | [Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)            | 未授权         | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                 |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                 |

## GET 获取邀请码

GET /user/referral-code

获取当前用户的邀请码，如果没有则自动生成

> 返回示例

> 200 Response

```json
{
  "referral_code": "ABC123",
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明           | 数据模型                                                                                      |
| ------ | -------------------------------------------------------------------------- | -------------- | --------------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 邀请码         | [internal_handlers.GetReferralCodeResponse](#schemainternal_handlers.getreferralcoderesponse) |
| 401    | [Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)            | 未授权         | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                     |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                     |

## GET 获取推荐统计

GET /user/referral-stats

获取当前用户的推荐统计数据

> 返回示例

> 200 Response

```json
{
  "stats": null,
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明           | 数据模型                                                                                        |
| ------ | -------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 推荐统计       | [internal_handlers.GetReferralStatsResponse](#schemainternal_handlers.getreferralstatsresponse) |
| 401    | [Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)            | 未授权         | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                       |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                       |

## GET 获取推荐用户列表

GET /user/referrals

获取当前用户推荐的用户列表

### 请求参数

| 名称      | 位置  | 类型    | 必选 | 说明                               |
| --------- | ----- | ------- | ---- | ---------------------------------- |
| level     | query | integer | 否   | 推荐层级（0=全部，1=一级，2=二级） |
| page      | query | integer | 否   | 页码                               |
| page_size | query | integer | 否   | 每页数量                           |

> 返回示例

> 200 Response

```json
{
  "pagination": null,
  "referrals": [null],
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明           | 数据模型                                                                                |
| ------ | -------------------------------------------------------------------------- | -------------- | --------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 推荐用户列表   | [internal_handlers.GetReferralsResponse](#schemainternal_handlers.getreferralsresponse) |
| 401    | [Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)            | 未授权         | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)               |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)               |

## GET 获取等级配置列表（公开）

GET /tier-configs

获取所有等级配置信息，包括等级名称、人数范围、各项返佣比例

> 返回示例

> 200 Response

```json
{
  "data": {
    "configs": [
      {
        "description": "中级等级",
        "level1_card_opening_rate": 0.25,
        "level1_transaction_rate": 0.001,
        "level2_card_opening_rate": 0.1,
        "level2_transaction_rate": 0.1,
        "max_referral_count": 30,
        "min_referral_count": 11,
        "tier_level": 2,
        "tier_name": "V2"
      }
    ],
    "total": 4
  },
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明           | 数据模型                                                                                                |
| ------ | -------------------------------------------------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 等级配置列表   | [internal_handlers.GetPublicTierConfigsResponse](#schemainternal_handlers.getpublictierconfigsresponse) |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                               |

## GET 获取用户等级信息

GET /user/tier

获取当前用户的等级信息，包括等级名称、直推人数、各项返佣比例

> 返回示例

> 200 Response

```json
{
  "data": {
    "direct_referrals": 15,
    "level1_card_rate": 0.25,
    "level1_tx_rate": 0.001,
    "level2_card_rate": 0.1,
    "level2_tx_rate": 0.1,
    "tier_level": 2,
    "tier_name": "V2",
    "user_id": 1
  },
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明           | 数据模型                                                                              |
| ------ | -------------------------------------------------------------------------- | -------------- | ------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 用户等级信息   | [internal_handlers.GetUserTierResponse](#schemainternal_handlers.getusertierresponse) |
| 401    | [Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)            | 未授权         | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)             |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)             |

## GET 获取用户升级进度

GET /user/tier/progress

获取当前用户的升级进度，包括当前等级、下一等级、所需人数等

> 返回示例

> 200 Response

```json
{
  "data": {
    "current_referrals": 15,
    "current_tier": "V2",
    "is_max_tier": false,
    "next_tier": "V3",
    "remaining_count": 16,
    "required_referrals": 31
  },
  "status": "success"
}
```

### 返回结果

| 状态码 | 状态码含义                                                                 | 说明           | 数据模型                                                                                              |
| ------ | -------------------------------------------------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------- |
| 200    | [OK](https://tools.ietf.org/html/rfc7231#section-6.3.1)                    | 升级进度       | [internal_handlers.GetUserTierProgressResponse](#schemainternal_handlers.getusertierprogressresponse) |
| 401    | [Unauthorized](https://tools.ietf.org/html/rfc7235#section-3.1)            | 未授权         | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                             |
| 500    | [Internal Server Error](https://tools.ietf.org/html/rfc7231#section-6.6.1) | 服务器内部错误 | [internal_handlers.ErrorResponse](#schemainternal_handlers.errorresponse)                             |

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

| 名称    | 类型   | 必选  | 约束 | 中文名 | 说明 |
| ------- | ------ | ----- | ---- | ------ | ---- |
| details | string | false | none |        | none |
| error   | string | false | none |        | none |

<h2 id="tocS_internal_handlers.GetCommissionConfigResponse">internal_handlers.GetCommissionConfigResponse</h2>

<a id="schemainternal_handlers.getcommissionconfigresponse"></a>
<a id="schema_internal_handlers.GetCommissionConfigResponse"></a>
<a id="tocSinternal_handlers.getcommissionconfigresponse"></a>
<a id="tocsinternal_handlers.getcommissionconfigresponse"></a>

```json
{
  "config": null,
  "status": "success"
}
```

### 属性

| 名称   | 类型   | 必选  | 约束 | 中文名 | 说明 |
| ------ | ------ | ----- | ---- | ------ | ---- |
| config | any    | false | none |        | none |
| status | string | false | none |        | none |

<h2 id="tocS_internal_handlers.GetCommissionsResponse">internal_handlers.GetCommissionsResponse</h2>

<a id="schemainternal_handlers.getcommissionsresponse"></a>
<a id="schema_internal_handlers.GetCommissionsResponse"></a>
<a id="tocSinternal_handlers.getcommissionsresponse"></a>
<a id="tocsinternal_handlers.getcommissionsresponse"></a>

```json
{
  "commissions": [null],
  "pagination": null,
  "status": "success"
}
```

### 属性

| 名称        | 类型   | 必选  | 约束 | 中文名 | 说明 |
| ----------- | ------ | ----- | ---- | ------ | ---- |
| commissions | [any]  | false | none |        | none |
| pagination  | any    | false | none |        | none |
| status      | string | false | none |        | none |

<h2 id="tocS_internal_handlers.GetMyReferrerResponse">internal_handlers.GetMyReferrerResponse</h2>

<a id="schemainternal_handlers.getmyreferrerresponse"></a>
<a id="schema_internal_handlers.GetMyReferrerResponse"></a>
<a id="tocSinternal_handlers.getmyreferrerresponse"></a>
<a id="tocsinternal_handlers.getmyreferrerresponse"></a>

```json
{
  "has_referrer": true,
  "level1_referrer": null,
  "level2_referrer": null,
  "status": "success"
}
```

### 属性

| 名称            | 类型    | 必选  | 约束 | 中文名 | 说明 |
| --------------- | ------- | ----- | ---- | ------ | ---- |
| has_referrer    | boolean | false | none |        | none |
| level1_referrer | any     | false | none |        | none |
| level2_referrer | any     | false | none |        | none |
| status          | string  | false | none |        | none |

<h2 id="tocS_internal_handlers.GetReferralCodeResponse">internal_handlers.GetReferralCodeResponse</h2>

<a id="schemainternal_handlers.getreferralcoderesponse"></a>
<a id="schema_internal_handlers.GetReferralCodeResponse"></a>
<a id="tocSinternal_handlers.getreferralcoderesponse"></a>
<a id="tocsinternal_handlers.getreferralcoderesponse"></a>

```json
{
  "referral_code": "ABC123",
  "status": "success"
}
```

### 属性

| 名称          | 类型   | 必选  | 约束 | 中文名 | 说明 |
| ------------- | ------ | ----- | ---- | ------ | ---- |
| referral_code | string | false | none |        | none |
| status        | string | false | none |        | none |

<h2 id="tocS_internal_handlers.GetReferralStatsResponse">internal_handlers.GetReferralStatsResponse</h2>

<a id="schemainternal_handlers.getreferralstatsresponse"></a>
<a id="schema_internal_handlers.GetReferralStatsResponse"></a>
<a id="tocSinternal_handlers.getreferralstatsresponse"></a>
<a id="tocsinternal_handlers.getreferralstatsresponse"></a>

```json
{
  "stats": null,
  "status": "success"
}
```

### 属性

| 名称   | 类型   | 必选  | 约束 | 中文名 | 说明 |
| ------ | ------ | ----- | ---- | ------ | ---- |
| stats  | any    | false | none |        | none |
| status | string | false | none |        | none |

<h2 id="tocS_internal_handlers.GetReferralsResponse">internal_handlers.GetReferralsResponse</h2>

<a id="schemainternal_handlers.getreferralsresponse"></a>
<a id="schema_internal_handlers.GetReferralsResponse"></a>
<a id="tocSinternal_handlers.getreferralsresponse"></a>
<a id="tocsinternal_handlers.getreferralsresponse"></a>

```json
{
  "pagination": null,
  "referrals": [null],
  "status": "success"
}
```

### 属性

| 名称       | 类型   | 必选  | 约束 | 中文名 | 说明 |
| ---------- | ------ | ----- | ---- | ------ | ---- |
| pagination | any    | false | none |        | none |
| referrals  | [any]  | false | none |        | none |
| status     | string | false | none |        | none |

<h2 id="tocS_internal_handlers.GetPublicTierConfigsResponse">internal_handlers.GetPublicTierConfigsResponse</h2>

<a id="schemainternal_handlers.getpublictierconfigsresponse"></a>
<a id="schema_internal_handlers.GetPublicTierConfigsResponse"></a>
<a id="tocSinternal_handlers.getpublictierconfigsresponse"></a>
<a id="tocsinternal_handlers.getpublictierconfigsresponse"></a>

```json
{
  "data": {
    "configs": [
      {
        "description": "中级等级",
        "level1_card_opening_rate": 0.25,
        "level1_transaction_rate": 0.001,
        "level2_card_opening_rate": 0.1,
        "level2_transaction_rate": 0.1,
        "max_referral_count": 30,
        "min_referral_count": 11,
        "tier_level": 2,
        "tier_name": "V2"
      }
    ],
    "total": 4
  },
  "status": "success"
}
```

### 属性

| 名称   | 类型                                                                                      | 必选  | 约束 | 中文名 | 说明 |
| ------ | ----------------------------------------------------------------------------------------- | ----- | ---- | ------ | ---- |
| data   | [internal_handlers.PublicTierConfigsData](#schemainternal_handlers.publictierconfigsdata) | false | none |        | none |
| status | string                                                                                    | false | none |        | none |

<h2 id="tocS_internal_handlers.GetUserTierProgressResponse">internal_handlers.GetUserTierProgressResponse</h2>

<a id="schemainternal_handlers.getusertierprogressresponse"></a>
<a id="schema_internal_handlers.GetUserTierProgressResponse"></a>
<a id="tocSinternal_handlers.getusertierprogressresponse"></a>
<a id="tocsinternal_handlers.getusertierprogressresponse"></a>

```json
{
  "data": {
    "current_referrals": 15,
    "current_tier": "V2",
    "is_max_tier": false,
    "next_tier": "V3",
    "remaining_count": 16,
    "required_referrals": 31
  },
  "status": "success"
}
```

### 属性

| 名称   | 类型                                                                                    | 必选  | 约束 | 中文名 | 说明 |
| ------ | --------------------------------------------------------------------------------------- | ----- | ---- | ------ | ---- |
| data   | [internal_handlers.UserTierProgressData](#schemainternal_handlers.usertierprogressdata) | false | none |        | none |
| status | string                                                                                  | false | none |        | none |

<h2 id="tocS_internal_handlers.GetUserTierResponse">internal_handlers.GetUserTierResponse</h2>

<a id="schemainternal_handlers.getusertierresponse"></a>
<a id="schema_internal_handlers.GetUserTierResponse"></a>
<a id="tocSinternal_handlers.getusertierresponse"></a>
<a id="tocsinternal_handlers.getusertierresponse"></a>

```json
{
  "data": {
    "direct_referrals": 15,
    "level1_card_rate": 0.25,
    "level1_tx_rate": 0.001,
    "level2_card_rate": 0.1,
    "level2_tx_rate": 0.1,
    "tier_level": 2,
    "tier_name": "V2",
    "user_id": 1
  },
  "status": "success"
}
```

### 属性

| 名称   | 类型                                                                            | 必选  | 约束 | 中文名 | 说明 |
| ------ | ------------------------------------------------------------------------------- | ----- | ---- | ------ | ---- |
| data   | [internal_handlers.UserTierInfoData](#schemainternal_handlers.usertierinfodata) | false | none |        | none |
| status | string                                                                          | false | none |        | none |

<h2 id="tocS_internal_handlers.PublicTierConfigItem">internal_handlers.PublicTierConfigItem</h2>

<a id="schemainternal_handlers.publictierconfigitem"></a>
<a id="schema_internal_handlers.PublicTierConfigItem"></a>
<a id="tocSinternal_handlers.publictierconfigitem"></a>
<a id="tocsinternal_handlers.publictierconfigitem"></a>

```json
{
  "description": "中级等级",
  "level1_card_opening_rate": 0.25,
  "level1_transaction_rate": 0.001,
  "level2_card_opening_rate": 0.1,
  "level2_transaction_rate": 0.1,
  "max_referral_count": 30,
  "min_referral_count": 11,
  "tier_level": 2,
  "tier_name": "V2"
}
```

### 属性

| 名称                     | 类型    | 必选  | 约束 | 中文名 | 说明 |
| ------------------------ | ------- | ----- | ---- | ------ | ---- |
| description              | string  | false | none |        | none |
| level1_card_opening_rate | number  | false | none |        | none |
| level1_transaction_rate  | number  | false | none |        | none |
| level2_card_opening_rate | number  | false | none |        | none |
| level2_transaction_rate  | number  | false | none |        | none |
| max_referral_count       | integer | false | none |        | none |
| min_referral_count       | integer | false | none |        | none |
| tier_level               | integer | false | none |        | none |
| tier_name                | string  | false | none |        | none |

<h2 id="tocS_internal_handlers.UpdateCommissionConfigRequest">internal_handlers.UpdateCommissionConfigRequest</h2>

<a id="schemainternal_handlers.updatecommissionconfigrequest"></a>
<a id="schema_internal_handlers.UpdateCommissionConfigRequest"></a>
<a id="tocSinternal_handlers.updatecommissionconfigrequest"></a>
<a id="tocsinternal_handlers.updatecommissionconfigrequest"></a>

```json
{
  "card_transaction_fee_rate": 0.02,
  "level1_card_opening_rate": 0.1,
  "level1_transaction_rate": 0.01,
  "level2_card_opening_rate": 0.05,
  "level2_transaction_rate": 0.005
}
```

### 属性

| 名称                      | 类型   | 必选 | 约束 | 中文名 | 说明 |
| ------------------------- | ------ | ---- | ---- | ------ | ---- |
| card_transaction_fee_rate | number | true | none |        | none |
| level1_card_opening_rate  | number | true | none |        | none |
| level1_transaction_rate   | number | true | none |        | none |
| level2_card_opening_rate  | number | true | none |        | none |
| level2_transaction_rate   | number | true | none |        | none |

<h2 id="tocS_internal_handlers.PublicTierConfigsData">internal_handlers.PublicTierConfigsData</h2>

<a id="schemainternal_handlers.publictierconfigsdata"></a>
<a id="schema_internal_handlers.PublicTierConfigsData"></a>
<a id="tocSinternal_handlers.publictierconfigsdata"></a>
<a id="tocsinternal_handlers.publictierconfigsdata"></a>

```json
{
  "configs": [
    {
      "description": "中级等级",
      "level1_card_opening_rate": 0.25,
      "level1_transaction_rate": 0.001,
      "level2_card_opening_rate": 0.1,
      "level2_transaction_rate": 0.1,
      "max_referral_count": 30,
      "min_referral_count": 11,
      "tier_level": 2,
      "tier_name": "V2"
    }
  ],
  "total": 4
}
```

### 属性

| 名称    | 类型                                                                                      | 必选  | 约束 | 中文名 | 说明 |
| ------- | ----------------------------------------------------------------------------------------- | ----- | ---- | ------ | ---- |
| configs | [[internal_handlers.PublicTierConfigItem](#schemainternal_handlers.publictierconfigitem)] | false | none |        | none |
| total   | integer                                                                                   | false | none |        | none |

<h2 id="tocS_internal_handlers.UpdateCommissionConfigResponse">internal_handlers.UpdateCommissionConfigResponse</h2>

<a id="schemainternal_handlers.updatecommissionconfigresponse"></a>
<a id="schema_internal_handlers.UpdateCommissionConfigResponse"></a>
<a id="tocSinternal_handlers.updatecommissionconfigresponse"></a>
<a id="tocsinternal_handlers.updatecommissionconfigresponse"></a>

```json
{
  "config": null,
  "message": "Commission config updated successfully",
  "status": "success"
}
```

### 属性

| 名称    | 类型   | 必选  | 约束 | 中文名 | 说明 |
| ------- | ------ | ----- | ---- | ------ | ---- |
| config  | any    | false | none |        | none |
| message | string | false | none |        | none |
| status  | string | false | none |        | none |

<h2 id="tocS_internal_handlers.UserTierInfoData">internal_handlers.UserTierInfoData</h2>

<a id="schemainternal_handlers.usertierinfodata"></a>
<a id="schema_internal_handlers.UserTierInfoData"></a>
<a id="tocSinternal_handlers.usertierinfodata"></a>
<a id="tocsinternal_handlers.usertierinfodata"></a>

```json
{
  "direct_referrals": 15,
  "level1_card_rate": 0.25,
  "level1_tx_rate": 0.001,
  "level2_card_rate": 0.1,
  "level2_tx_rate": 0.1,
  "tier_level": 2,
  "tier_name": "V2",
  "user_id": 1
}
```

### 属性

| 名称             | 类型    | 必选  | 约束 | 中文名 | 说明 |
| ---------------- | ------- | ----- | ---- | ------ | ---- |
| direct_referrals | integer | false | none |        | none |
| level1_card_rate | number  | false | none |        | none |
| level1_tx_rate   | number  | false | none |        | none |
| level2_card_rate | number  | false | none |        | none |
| level2_tx_rate   | number  | false | none |        | none |
| tier_level       | integer | false | none |        | none |
| tier_name        | string  | false | none |        | none |
| user_id          | integer | false | none |        | none |

<h2 id="tocS_internal_handlers.UserTierProgressData">internal_handlers.UserTierProgressData</h2>

<a id="schemainternal_handlers.usertierprogressdata"></a>
<a id="schema_internal_handlers.UserTierProgressData"></a>
<a id="tocSinternal_handlers.usertierprogressdata"></a>
<a id="tocsinternal_handlers.usertierprogressdata"></a>

```json
{
  "current_referrals": 15,
  "current_tier": "V2",
  "is_max_tier": false,
  "next_tier": "V3",
  "remaining_count": 16,
  "required_referrals": 31
}
```

### 属性

| 名称               | 类型    | 必选  | 约束 | 中文名 | 说明 |
| ------------------ | ------- | ----- | ---- | ------ | ---- |
| current_referrals  | integer | false | none |        | none |
| current_tier       | string  | false | none |        | none |
| is_max_tier        | boolean | false | none |        | none |
| next_tier          | string  | false | none |        | none |
| remaining_count    | integer | false | none |        | none |
| required_referrals | integer | false | none |        | none |

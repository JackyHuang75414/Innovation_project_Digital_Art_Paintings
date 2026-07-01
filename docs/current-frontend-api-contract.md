# 当前前端接口文档

本文档基于当前 `frontend` 代码整理，用于后端按现有 Spring Boot 分层结构实现接口：

```text
controller -> service -> service/impl -> mapper -> database
```

后端包结构按当前项目截图保持：

```text
com.ren.yinghui.backend
├── config
├── controller
├── dto
├── entity
├── interceptors
├── mapper
├── service
├── utils
└── vo
```

## 1. 前端请求基础配置

前端接口封装位置：

```text
frontend/src/api/artworks.js
frontend/src/api/orders.js
frontend/src/api/payments.js
```

Axios 基础地址：

```js
baseURL: import.meta.env.VITE_API_BASE_URL || '/api'
```

Vite 代理：

```text
/api -> http://localhost:8000
```

建议后端本地运行端口统一为：

```yaml
server:
  port: 8000
```

建议后端接口统一加 `/api` 前缀。也就是说前端请求 `/api/artworks` 时，后端实际 Controller 可以通过全局 context path 或 Controller 路径匹配到 `/api/artworks`。

## 2. 通用响应格式

当前后端已有 `Result<T>`：

```json
{
  "code": 0,
  "message": "Operation successful",
  "data": {}
}
```

建议所有后端接口统一返回这个格式：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| code | Integer | `0` 成功，`1` 失败 |
| message | String | 提示信息 |
| data | Any | 业务数据 |

注意：当前前端部分 API 代码直接读取 `response.data` 当业务数据使用。如果后端继续返回 `Result<T>`，前端需要统一改成读取 `response.data.data`，或者在 axios 响应拦截器里自动 unwrap。

## 3. 认证规则

需要登录的接口请求头：

```http
Authorization: <jwt-token>
```

后端由 `LoginInterceptor` 解析 token，并将用户信息写入 `ThreadLocalUtil`。

建议公开接口：

```text
POST /api/user/login
POST /api/user/register
GET  /api/artworks
GET  /api/artworks/{id}
GET  /api/artworks/{id}/recommendations
GET  /api/artworks/search
```

建议需要登录接口：

```text
GET    /api/user/me
POST   /api/orders
GET    /api/orders/{id}
GET    /api/orders/me
POST   /api/wishlist
DELETE /api/wishlist
GET    /api/wishlist/me
```

## 4. 作品接口

前端调用来源：

```text
frontend/src/api/artworks.js
frontend/src/stores/artworks.js
frontend/src/views/ArtworkDetailView.vue
frontend/src/views/BrowseView.vue
```

### 4.1 获取作品列表

```http
GET /api/artworks
```

用于：首页、浏览页、筛选、搜索、排序。

请求参数：

| 参数 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| q | String | 否 | abstract | 搜索关键词 |
| category | String | 否 | Digital | 分类 |
| medium | String | 否 | Acrylic | 媒介 |
| orientation | String | 否 | Portrait | 方向 |
| color | String | 否 | Red | 主色 |
| priceMin | BigDecimal | 否 | 50 | 最低价格 |
| priceMax | BigDecimal | 否 | 200 | 最高价格 |
| sort | String | 否 | recommended | 排序 |
| offset | Integer | 否 | 0 | 偏移量 |
| limit | Integer | 否 | 12 | 数量 |
| page | Integer | 否 | 1 | 页码 |
| pageSize | Integer | 否 | 12 | 每页数量 |

`sort` 建议值：

```text
recommended
newest
price_asc
price_desc
trending
```

响应 `data`：

```json
[
  {
    "id": 1,
    "imageUrl": "https://example.com/artwork.jpg",
    "title": "Abstract Harmony",
    "artistName": "Sophie Laurent",
    "price": 89.00,
    "medium": "Acrylic on Canvas",
    "badge": "Trending"
  }
]
```

对应后端类型建议：

```text
ArtworkQueryDTO
ArtworkListVO
```

当前后端已有接口差异：

```text
当前后端：GET /artworks/list
前端期望：GET /api/artworks
```

建议后端新增 REST 风格接口，或前端改 `artworks.js`。

### 4.2 获取作品详情

```http
GET /api/artworks/{id}
```

路径参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | Long | 是 | 作品 ID |

响应 `data`：

```json
{
  "id": 1,
  "imageUrl": "https://example.com/artwork.jpg",
  "title": "Abstract Harmony",
  "artistName": "Sophie Laurent",
  "artistCountry": "France",
  "price": 89.00,
  "medium": "Acrylic on Canvas",
  "dimensions": "60 x 80 cm",
  "year": 2024,
  "description": "A vivid exploration of colour and emotion.",
  "tags": ["abstract", "colourful"],
  "availableSizes": ["A4 Print", "A3 Print", "A2 Print"]
}
```

对应后端类型建议：

```text
ArtworkDetailVO
```

当前后端已有接口差异：

```text
当前后端：GET /artworks/detail?id=1
前端期望：GET /api/artworks/1
```

### 4.3 获取作品相关推荐

```http
GET /api/artworks/{id}/recommendations
```

路径参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | Long | 是 | 当前作品 ID |

请求参数：

| 参数 | 类型 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- | --- |
| limit | Integer | 否 | 4 | 返回数量 |

响应 `data`：

```json
[
  {
    "id": 2,
    "imageUrl": "https://example.com/rec.jpg",
    "title": "Urban Geometry",
    "artistName": "Marco Chen",
    "price": 120.00
  }
]
```

对应后端类型建议：

```text
ArtworkRecommendationVO
```

当前后端已有接口差异：

```text
当前后端：GET /artworks/recommendations?id=1&limit=4
前端期望：GET /api/artworks/1/recommendations
```

### 4.4 搜索作品

```http
GET /api/artworks/search?q=abstract
```

说明：前端已有 `searchArtworks(query)` 封装，但当前页面主要通过列表接口筛选。后端可以不单独实现搜索接口，直接让 `/api/artworks?q=xxx` 支持搜索即可。

如果保留单独接口，响应同作品列表。

## 5. 订单接口

前端调用来源：

```text
frontend/src/api/orders.js
frontend/src/views/CheckoutView.vue
frontend/src/stores/cart.js
```

当前 `CheckoutView.vue` 还没有真正调用 `createOrder`，只是本地模拟支付成功。后端接口需要提前准备，后续接入支付成功后创建订单。

### 5.1 创建订单

```http
POST /api/orders
```

需要登录：建议需要。

请求体：

```json
{
  "customerName": "Sophie Laurent",
  "customerEmail": "sophie@example.com",
  "customerPhone": "123456789",
  "shippingCountry": "France",
  "shippingCity": "Paris",
  "shippingAddressLine1": "1 Rue de Rivoli",
  "shippingAddressLine2": "Apt 2",
  "shippingPostalCode": "75001",
  "paymentMethod": "card",
  "items": [
    {
      "artworkId": 1,
      "size": "A3 Print",
      "quantity": 1
    }
  ]
}
```

字段类型必须与 DTO 保持一致：

| 字段 | 类型 | 必填 |
| --- | --- | --- |
| customerName | String | 是 |
| customerEmail | String | 是 |
| customerPhone | String | 否 |
| shippingCountry | String | 是 |
| shippingCity | String | 是 |
| shippingAddressLine1 | String | 是 |
| shippingAddressLine2 | String | 否 |
| shippingPostalCode | String | 是 |
| paymentMethod | String | 否 |
| items | List<CreateOrderItemDTO> | 是 |
| items[].artworkId | Long | 是 |
| items[].size | String | 是 |
| items[].quantity | Integer | 是 |

响应 `data`：

```json
{
  "id": 10001,
  "orderNo": "AC202606150001",
  "status": "pending",
  "subtotal": 89.00,
  "shippingFee": 0.00,
  "total": 89.00,
  "createdAt": "2026-06-15T20:30:00"
}
```

对应后端类型建议：

```text
CreateOrderDTO
CreateOrderItemDTO
OrderCreateVO
```

当前后端已有接口差异：

```text
当前后端：POST /orders/create
前端期望：POST /api/orders
```

### 5.2 获取订单详情

```http
GET /api/orders/{id}
```

需要登录：是。

路径参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | Long | 是 | 订单 ID |

响应 `data`：

```json
{
  "id": 10001,
  "orderNo": "AC202606150001",
  "status": "paid",
  "items": [
    {
      "artworkId": 1,
      "title": "Abstract Harmony",
      "imageUrl": "https://example.com/artwork.jpg",
      "artistName": "Sophie Laurent",
      "size": "A3 Print",
      "quantity": 1,
      "unitPrice": 89.00,
      "subtotal": 89.00
    }
  ],
  "subtotal": 89.00,
  "shippingFee": 0.00,
  "total": 89.00,
  "createdAt": "2026-06-15T20:30:00"
}
```

对应后端类型建议：

```text
OrderDetailVO
OrderDetailItemVO
```

当前后端已有接口差异：

```text
当前后端：GET /orders/detail?id=10001
前端期望：GET /api/orders/10001
```

### 5.3 获取我的订单

```http
GET /api/orders/me
```

需要登录：是。

响应 `data`：

```json
[
  {
    "id": 10001,
    "orderNo": "AC202606150001",
    "status": "paid",
    "total": 89.00,
    "createdAt": "2026-06-15T20:30:00"
  }
]
```

对应后端类型建议：

```text
OrderListVO
```

当前后端接口路径基本一致：

```text
当前后端：GET /orders/me
前端期望：GET /api/orders/me
```

主要差异是 `/api` 前缀和 token 处理。

## 6. 用户接口

前端当前登录是本地模拟：

```text
frontend/src/stores/auth.js
frontend/src/components/ui/LoginModal.vue
```

前端现有 demo 账号：

```text
demo / demo123
whale / whale888
algo / algo2025
```

如果要接后端，需要新增 `frontend/src/api/user.js` 并让 `auth.js` 调用真实接口。

### 6.1 用户注册

```http
POST /api/user/register
```

当前后端接收表单/query 参数，不是 JSON：

| 参数 | 类型 | 必填 | 校验 |
| --- | --- | --- | --- |
| name | String | 是 | 3 到 16 位，不能有空白 |
| email | String | 是 | 邮箱格式 |
| password | String | 是 | 5 到 16 位，不能有空白 |

建议请求方式：

```http
POST /api/user/register?name=demo&email=demo@example.com&password=demo123
```

响应：

```json
{
  "code": 0,
  "message": "Operation successful",
  "data": null
}
```

### 6.2 用户登录

```http
POST /api/user/login
```

当前后端接收表单/query 参数：

| 参数 | 类型 | 必填 |
| --- | --- | --- |
| name | String | 是 |
| password | String | 是 |

响应 `data`：

```json
"jwt-token-string"
```

建议前端登录成功后保存：

```text
localStorage token key: artex_token
```

之后 axios 请求加：

```http
Authorization: jwt-token-string
```

### 6.3 获取当前用户

```http
GET /api/user/me
```

需要登录：是。

响应 `data`：

```json
{
  "id": 1,
  "name": "demo",
  "email": "demo@example.com"
}
```

对应后端类型建议：

```text
UserInfoVO
```

## 7. 收藏接口

当前后端已经有收藏接口，但前端还没有对应 API 文件。建议新增：

```text
frontend/src/api/wishlist.js
```

### 7.1 添加收藏

```http
POST /api/wishlist?artworkId=1
```

需要登录：是。

请求参数：

| 参数 | 类型 | 必填 |
| --- | --- | --- |
| artworkId | Long | 是 |

响应 `data`：

```json
{
  "artworkId": 1,
  "wishlisted": true
}
```

对应后端类型建议：

```text
WishlistStatusVO
```

### 7.2 取消收藏

```http
DELETE /api/wishlist?artworkId=1
```

需要登录：是。

响应 `data`：

```json
{
  "artworkId": 1,
  "wishlisted": false
}
```

### 7.3 获取我的收藏

```http
GET /api/wishlist/me
```

需要登录：是。

响应 `data`：

```json
[
  {
    "id": 1,
    "imageUrl": "https://example.com/artwork.jpg",
    "title": "Abstract Harmony",
    "artistName": "Sophie Laurent",
    "price": 89.00,
    "medium": "Acrylic on Canvas",
    "badge": "Trending"
  }
]
```

对应后端类型建议：

```text
ArtworkListVO
```

## 8. 支付接口

前端当前支付逻辑主要是本地模拟：

```text
frontend/src/views/CheckoutView.vue
frontend/src/api/payments.js
```

当前情况：

| 支付方式 | 当前实现 | 是否经过后端 |
| --- | --- | --- |
| Demo card | 前端 Luhn 校验后模拟成功 | 否 |
| Stripe | 前端创建 paymentMethod，注释中计划发给后端 | 否 |
| Bitcoin testnet | 通过 Vite 代理请求 BlockCypher | 否 |

后续如果要真实落库，建议增加：

```http
POST /api/payments/charge
POST /api/payments/bitcoin/address
GET  /api/payments/bitcoin/status?address=xxx
```

这些接口当前不是前端必须接口，可以后续再做。

## 9. 交易市场模块

前端新增的市场和交易页主要是本地模拟：

```text
frontend/src/views/MarketView.vue
frontend/src/views/TradingView.vue
frontend/src/views/AccountView.vue
frontend/src/stores/trading.js
frontend/src/stores/wallet.js
frontend/src/stores/prices.js
```

当前这些数据没有走后端：

| 功能 | 当前来源 |
| --- | --- |
| 数字艺术品交易列表 | `stores/trading.js` 静态 `ARTWORKS` |
| 实时价格 | 前端随机模拟 + CoinGecko BTC 价格 |
| 买入/卖出份额 | 前端 Pinia 内存状态 |
| 永续合约 | 前端 Pinia 内存状态 |
| TP/SL | 前端 Pinia 内存状态 |
| AI agent 配置 | 前端 Pinia/localStorage |
| 钱包连接 | 前端模拟 |

这部分如果要后端实现，建议单独设计交易域接口，不要混在普通艺术品商城订单接口里。

建议后续接口：

```text
GET  /api/market/artworks
GET  /api/market/artworks/{id}
GET  /api/market/artworks/{id}/order-book
GET  /api/market/artworks/{id}/trades
GET  /api/market/artworks/{id}/price-history
POST /api/trades/spot
POST /api/trades/perp/open
POST /api/trades/perp/close
GET  /api/account/portfolio
POST /api/account/tpsl
DELETE /api/account/tpsl/{id}
```

当前阶段建议先不做交易后端，优先完成商城闭环：

```text
作品列表 -> 作品详情 -> 加购物车 -> 创建订单 -> 我的订单
```

## 10. 当前最需要对齐的问题

### 10.1 路径风格不一致

前端期望：

```text
GET  /api/artworks
GET  /api/artworks/{id}
POST /api/orders
GET  /api/orders/{id}
```

当前后端：

```text
GET  /artworks/list
GET  /artworks/detail?id=1
POST /orders/create
GET  /orders/detail?id=1
```

建议：后端新增 REST 风格接口，保留旧接口也可以。

### 10.2 `/api` 前缀不一致

建议后端统一加：

```text
/api
```

可选做法：

```yaml
server:
  servlet:
    context-path: /api
```

这样 Controller 仍然写：

```java
@RequestMapping("/artworks")
```

最终访问路径就是：

```text
/api/artworks
```

### 10.3 公开接口被登录拦截

当前 `WebConfig` 只排除了：

```text
/user/login
/user/register
```

建议同时排除：

```text
/api/user/login
/api/user/register
/api/artworks
/api/artworks/**
```

否则前端未登录时无法浏览作品。

### 10.4 返回值包装不一致

后端返回：

```json
{
  "code": 0,
  "message": "Operation successful",
  "data": []
}
```

前端当前部分代码期望：

```json
[]
```

建议前端增加 axios 响应拦截器，统一把 `Result<T>` unwrap 成 `data`。

## 11. 后端开发顺序建议

按你要求的结构，建议顺序：

1. 完成 `ArtworkQueryDTO`、`CreateOrderDTO` 等 DTO。
2. 补齐 `ArtworkListVO`、`ArtworkDetailVO`、`OrderCreateVO` 等 VO。
3. 在 `mapper` 层实现作品查询、详情、推荐、订单查询。
4. 在 `service` 定义接口。
5. 在 `service/impl` 写业务实现。
6. 在 `controller` 暴露 REST 风格接口。
7. 调整 `WebConfig` 登录拦截放行规则。
8. 前端统一处理 `Result<T>` 和 token。

优先实现接口：

```text
GET  /api/artworks
GET  /api/artworks/{id}
GET  /api/artworks/{id}/recommendations
POST /api/user/login
GET  /api/user/me
POST /api/orders
GET  /api/orders/me
```

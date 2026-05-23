# ArtCanvas Frontend API Documentation

本文档根据当前 Vue 前端页面和 `src/api` 目录整理，供后端开发接口时使用。

## 1. 基础说明

### 1.1 基础地址

前端通过环境变量配置接口地址：

```env
VITE_API_BASE_URL=http://localhost:8000
```

如果没有配置，前端默认请求：

```text
/
```

### 1.2 数据格式

请求和响应均使用 JSON。

```http
Content-Type: application/json
```

### 1.3 通用错误响应

```json
{
  "code": 400,
  "message": "Invalid request",
  "detail": "priceMin must be a number"
}
```

常用状态码：

| 状态码 | 含义 |
| --- | --- |
| 200 | 请求成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未登录或 token 无效 |
| 403 | 无权限 |
| 404 | 数据不存在 |
| 500 | 服务器错误 |

## 2. 数据模型

### 2.1 Artwork 作品

前端页面使用到的作品字段如下：

```json
{
  "id": 1,
  "title": "Abstract Harmony",
  "artistName": "Sophie Laurent",
  "artistCountry": "France",
  "imageUrl": "https://example.com/artwork.jpg",
  "price": 89,
  "medium": "Acrylic on Canvas",
  "category": "Paintings",
  "orientation": "Portrait",
  "dominantColor": "Red",
  "dimensions": "60 x 80 cm",
  "year": 2024,
  "description": "A vivid exploration of colour and emotion.",
  "tags": ["abstract", "colourful", "expressive"],
  "badge": "Trending"
}
```

字段说明：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | number | 是 | 作品 ID |
| title | string | 是 | 作品标题 |
| artistName | string | 是 | 艺术家名称 |
| artistCountry | string | 否 | 艺术家国家，详情页使用 |
| imageUrl | string | 是 | 作品图片地址 |
| price | number | 是 | 价格，单位欧元 |
| medium | string | 是 | 作品媒介，如 Oil、Digital |
| category | string | 否 | 分类 |
| orientation | string | 否 | Landscape、Portrait、Square |
| dominantColor | string | 否 | 主色调 |
| dimensions | string | 否 | 尺寸 |
| year | number | 否 | 创作年份 |
| description | string | 否 | 作品描述 |
| tags | string[] | 否 | 标签 |
| badge | string | 否 | 角标，如 New、Trending、Limited |

### 2.2 Order 订单

```json
{
  "id": 10001,
  "orderNo": "AC202605170001",
  "status": "pending",
  "items": [
    {
      "artworkId": 1,
      "title": "Abstract Harmony",
      "imageUrl": "https://example.com/artwork.jpg",
      "artistName": "Sophie Laurent",
      "size": "A3 Print",
      "quantity": 1,
      "unitPrice": 89,
      "subtotal": 89
    }
  ],
  "subtotal": 89,
  "shippingFee": 0,
  "total": 89,
  "createdAt": "2026-05-17T12:00:00Z"
}
```

订单状态建议：

| 状态 | 说明 |
| --- | --- |
| pending | 待支付 |
| paid | 已支付 |
| shipped | 已发货 |
| completed | 已完成 |
| cancelled | 已取消 |

## 3. 作品接口

### 3.1 获取作品列表

用于浏览页、首页推荐位、分类入口、筛选、排序和关键词搜索。

```http
GET /artworks
```

请求参数：

| 参数 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| q | string | 否 | abstract | 搜索关键词，匹配作品标题和媒介 |
| category | string | 否 | Paintings | 分类 |
| medium | string | 否 | Oil | 媒介 |
| priceMin | number | 否 | 50 | 最低价格 |
| priceMax | number | 否 | 150 | 最高价格 |
| orientation | string | 否 | Portrait | 方向 |
| color | string | 否 | Red | 主色 |
| sort | string | 否 | recommended | 排序 |
| offset | number | 否 | 0 | 从第几条开始查询，用于 Load more |
| limit | number | 否 | 12 | 每次查询数量 |

`sort` 可选值：

| 值 | 说明 |
| --- | --- |
| recommended | 推荐排序 |
| newest | 最新 |
| price_asc | 价格从低到高 |
| price_desc | 价格从高到低 |
| trending | 热门 |

Load more 示例：

```http
GET /artworks?offset=0&limit=12
GET /artworks?offset=12&limit=12
GET /artworks?offset=24&limit=12
```

当前前端 `useArtworksStore` 直接接收数组，所以后端最简单可以返回数组：

```json
[
  {
    "id": 1,
    "imageUrl": "https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=500",
    "title": "Abstract Harmony",
    "artistName": "Sophie Laurent",
    "price": 89,
    "medium": "Acrylic",
    "badge": "Trending"
  }
]
```

如果后端需要分页，建议返回：

```json
{
  "items": [
    {
      "id": 1,
      "imageUrl": "https://example.com/artwork.jpg",
      "title": "Abstract Harmony",
      "artistName": "Sophie Laurent",
      "price": 89,
      "medium": "Acrylic",
      "badge": "Trending"
    }
  ],
  "offset": 0,
  "limit": 12,
  "total": 120
}
```

注意：如果采用分页对象格式，前端 `src/stores/artworks.js` 需要把 `items.value = data` 改为 `items.value = data.items`。

### 3.2 获取作品详情

用于作品详情页 `/artwork/:id`。

```http
GET /artworks/{id}
```

路径参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | number | 是 | 作品 ID |

响应示例：

```json
{
  "id": 1,
  "imageUrl": "https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=800",
  "title": "Abstract Harmony",
  "artistName": "Sophie Laurent",
  "artistCountry": "France",
  "price": 89,
  "medium": "Acrylic on Canvas",
  "dimensions": "60 x 80 cm",
  "year": 2024,
  "description": "A vivid exploration of colour and emotion.",
  "tags": ["abstract", "colourful", "expressive"],
  "availableSizes": ["A4 Print", "A3 Print", "A2 Print", "50x70 cm", "60x80 cm"]
}
```

### 3.3 获取相关推荐作品

用于详情页底部 “You might also like”。

```http
GET /artworks/{id}/recommendations
```

路径参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | number | 是 | 当前作品 ID |

请求参数：

| 参数 | 类型 | 必填 | 示例 | 说明 |
| --- | --- | --- | --- | --- |
| limit | number | 否 | 4 | 推荐数量 |

响应示例：

```json
[
  {
    "id": 2,
    "imageUrl": "https://example.com/artwork-2.jpg",
    "title": "Urban Geometry",
    "artistName": "Marco Chen",
    "price": 120
  }
]
```

## 4. 订单接口

### 4.1 创建订单

购物车目前保存在前端本地状态，点击结算时应调用该接口。

```http
POST /orders/create
```

请求体：

```json
{
  "items": [
    {
      "artworkId": 1,
      "size": "A3 Print",
      "quantity": 1
    }
  ],
  "customerName": "Yinghui",
  "customerEmail": "yinghui@example.com",
  "customerPhone": "123456789",
  "shippingCountry": "France",
  "shippingCity": "Paris",
  "shippingAddressLine1": "1 Rue Example",
  "shippingAddressLine2": "",
  "shippingPostalCode": "75001",
  "paymentMethod": "card"
}
```

请求字段说明：

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| items | array | 是 | 订单商品 |
| items[].artworkId | number | 是 | 作品 ID |
| items[].size | string | 是 | 用户选择的尺寸 |
| items[].quantity | number | 是 | 数量 |
| customerName | string | 是 | 顾客姓名 |
| customerEmail | string | 是 | 顾客邮箱 |
| customerPhone | string | 否 | 顾客电话 |
| shippingCountry | string | 是 | 收货国家 |
| shippingCity | string | 是 | 收货城市 |
| shippingAddressLine1 | string | 是 | 收货地址第一行 |
| shippingAddressLine2 | string | 否 | 收货地址第二行 |
| shippingPostalCode | string | 是 | 邮政编码 |
| paymentMethod | string | 否 | 支付方式 |

响应示例：

```json
{
  "id": 10001,
  "orderNo": "AC202605170001",
  "status": "pending",
  "subtotal": 89,
  "shippingFee": 0,
  "total": 89,
  "createdAt": "2026-05-17T12:00:00Z"
}
```

运费规则与前端保持一致：

| 条件 | 运费 |
| --- | --- |
| 商品小计 >= 80 | 0 |
| 商品小计 < 80 | 9.9 |

### 4.2 获取订单详情

```http
GET /orders/{id}
```

路径参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| id | number | 是 | 订单 ID |

响应示例：

```json
{
  "id": 10001,
  "orderNo": "AC202605170001",
  "status": "pending",
  "items": [
    {
      "artworkId": 1,
      "title": "Abstract Harmony",
      "imageUrl": "https://example.com/artwork.jpg",
      "artistName": "Sophie Laurent",
      "size": "A3 Print",
      "quantity": 1,
      "unitPrice": 89,
      "subtotal": 89
    }
  ],
  "subtotal": 89,
  "shippingFee": 0,
  "total": 89,
  "createdAt": "2026-05-17T12:00:00Z"
}
```

### 4.3 获取我的订单

用于账户页后续展示订单历史。

```http
GET /orders/me
```

请求头：

```http
Authorization: <token>
```

响应示例：

```json
[
  {
    "id": 10001,
    "orderNo": "AC202605170001",
    "status": "pending",
    "total": 89,
    "createdAt": "2026-05-17T12:00:00Z"
  }
]
```

## 5. 用户与收藏接口

当前账户页和收藏按钮只有前端入口，还没有 `src/api` 对应代码。以下接口是建议后续扩展。

### 5.1 用户注册

```http
POST /user/register
```

请求参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| name | string | 是 | 用户名，3-16 位非空字符 |
| email | string | 是 | 邮箱 |
| password | string | 是 | 密码，5-16 位非空字符 |

响应示例：

```json
{
  "code": 0,
  "message": "Operation successful",
  "data": null
}
```

### 5.2 用户登录

```http
POST /auth/login
```

请求体：

```json
{
  "email": "yinghui@example.com",
  "password": "123456"
}
```

响应示例：

```json
{
  "token": "jwt-token",
  "user": {
    "id": 1,
    "name": "Yinghui",
    "email": "yinghui@example.com"
  }
}
```

### 5.3 获取当前用户信息

```http
GET /user/me
```

请求头：

```http
Authorization: <token>
```

响应示例：

```json
{
  "id": 1,
  "name": "Yinghui",
  "email": "yinghui@example.com"
}
```

### 5.4 添加收藏

```http
POST /wishlist?artworkId=1
```

请求头：

```http
Authorization: <token>
```

请求参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| artworkId | number | 是 | 作品 ID |

响应示例：

```json
{
  "artworkId": 1,
  "wishlisted": true
}
```

### 5.5 取消收藏

```http
DELETE /wishlist?artworkId=1
```

请求参数：

| 参数 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| artworkId | number | 是 | 作品 ID |

响应示例：

```json
{
  "artworkId": 1,
  "wishlisted": false
}
```

### 5.6 获取我的收藏

```http
GET /wishlist/me
```

响应示例：

```json
[
  {
    "id": 1,
    "imageUrl": "https://example.com/artwork.jpg",
    "title": "Abstract Harmony",
    "artistName": "Sophie Laurent",
    "price": 89,
    "medium": "Acrylic"
  }
]
```

## 6. 前端页面与接口对应关系

| 页面 | 路由 | 需要接口 |
| --- | --- | --- |
| 首页 | `/` | 暂用静态数据；后续可调用 `GET /artworks?sort=trending` |
| 浏览页 | `/browse` | `GET /artworks` |
| 搜索结果 | `/browse?q=xxx` | `GET /artworks?q=xxx` |
| 作品详情 | `/artwork/:id` | `GET /artworks/{id}` |
| 相关推荐 | `/artwork/:id` | `GET /artworks/{id}/recommendations` |
| 购物车 | `/cart` | 本地状态；结算时调用 `POST /orders/create` |
| 账户页 | `/account` | 后续调用 `GET /user/me`、`GET /orders/me` |

## 7. 后端最少需要先实现的接口

为了让当前前端从静态数据切换到真实数据，建议先实现下面 4 个接口：

```text
GET  /artworks
GET  /artworks/{id}
GET  /artworks/{id}/recommendations
POST /orders/create
```

之后再补：

```text
GET /orders/{id}
GET /orders/me
POST /auth/login
GET /user/me
POST /wishlist?artworkId=1
DELETE /wishlist?artworkId=1
GET /wishlist/me
```

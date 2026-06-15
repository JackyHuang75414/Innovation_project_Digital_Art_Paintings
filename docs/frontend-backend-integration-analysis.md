# 前后端对接分析文档

本文档基于当前仓库代码状态整理，仅用于前后端对接前的问题梳理与接口统一参考。

分析时间：2026-05-23

## 一、当前项目结构

项目分为前后端两个独立目录：

```text
frontend/   Vue 3 + Vite 前端项目
backend/    Spring Boot + MyBatis 后端项目
docs/       项目文档
```

前端主要接口封装位置：

```text
frontend/src/api/artworks.js
frontend/src/api/orders.js
```

后端主要接口位置：

```text
backend/src/main/java/com/ren/yinghui/backend/controller/ArtworksController.java
backend/src/main/java/com/ren/yinghui/backend/controller/OrdersController.java
backend/src/main/java/com/ren/yinghui/backend/controller/UserController.java
backend/src/main/java/com/ren/yinghui/backend/controller/WishListController.java
```

## 二、启动与代理配置问题

### 1. 前端代理端口与后端默认端口不一致

前端 Vite 配置中，`/api` 被代理到：

```text
http://localhost:8000
```

位置：

```text
frontend/vite.config.js
```

但后端 `application.yaml` 当前没有配置 `server.port`，Spring Boot 默认端口是：

```text
8080
```

因此如果后端按默认方式启动，前端请求 `/api/**` 会转发到 `8000`，导致无法访问后端。

### 2. `/api` 前缀不一致

前端 axios 默认配置：

```js
baseURL: import.meta.env.VITE_API_BASE_URL || '/api'
```

因此前端实际请求路径会变成：

```text
/api/artworks
/api/orders
```

但后端 Controller 当前路径没有 `/api` 前缀：

```text
/artworks
/orders
/user
/wishlist
```

如果不统一，前端请求会出现 404 或代理转发后找不到接口。

## 三、接口路径不一致问题

### 1. 作品接口

前端当前定义：

```text
GET /artworks
GET /artworks/{id}
GET /artworks/{id}/recommendations
GET /artworks/search?q=xxx
```

后端当前实际提供：

```text
GET /artworks/list
GET /artworks/detail?id=xxx
GET /artworks/recommendations?id=xxx&limit=4
```

主要差异：

| 功能 | 前端期望 | 后端实际 |
| --- | --- | --- |
| 作品列表 | `GET /artworks` | `GET /artworks/list` |
| 作品详情 | `GET /artworks/{id}` | `GET /artworks/detail?id=xxx` |
| 相关推荐 | `GET /artworks/{id}/recommendations` | `GET /artworks/recommendations?id=xxx` |
| 搜索作品 | `GET /artworks/search?q=xxx` | 当前无单独搜索接口，列表接口支持 `q` 参数 |

建议优先统一为 REST 风格：

```text
GET /artworks
GET /artworks/{id}
GET /artworks/{id}/recommendations
```

或者前端改为完全适配后端现有路径。两种方式需要二选一。

### 2. 订单接口

前端当前定义：

```text
POST /orders
GET /orders/{id}
GET /orders/me
```

后端当前实际提供：

```text
POST /orders/create
GET /orders/detail?id=xxx
GET /orders/me
```

主要差异：

| 功能 | 前端期望 | 后端实际 |
| --- | --- | --- |
| 创建订单 | `POST /orders` | `POST /orders/create` |
| 订单详情 | `GET /orders/{id}` | `GET /orders/detail?id=xxx` |
| 我的订单 | `GET /orders/me` | `GET /orders/me` |

其中只有 `GET /orders/me` 当前路径一致。

建议统一为：

```text
POST /orders
GET /orders/{id}
GET /orders/me
```

或前端改为调用：

```text
POST /orders/create
GET /orders/detail?id=xxx
```

### 3. 用户登录接口

后端当前实际接口：

```text
POST /user/register
POST /user/login
GET /user/me
```

当前文档中曾出现过 `/auth/login` 的描述，但后端实际没有 `/auth/login`。

另外，后端登录接口参数当前是普通请求参数：

```text
name
password
```

不是 JSON 请求体。

如果前端后续实现登录页，需要明确采用哪种格式：

```http
POST /user/login
Content-Type: application/x-www-form-urlencoded

name=xxx&password=xxx
```

或改造成 JSON：

```http
POST /user/login
Content-Type: application/json

{
  "name": "xxx",
  "password": "xxx"
}
```

## 四、响应结构不一致问题

后端当前统一响应格式为：

```json
{
  "code": 0,
  "message": "Operation successful",
  "data": {}
}
```

其中：

```text
code = 0 表示成功
code = 1 表示失败
data 为实际业务数据
```

但前端当前 store 中直接使用 axios 返回的 `data`：

```js
const { data } = await getArtworks(...)
items.value = data
```

这意味着前端期望接口直接返回数组：

```json
[
  {
    "id": 1,
    "title": "Abstract Harmony"
  }
]
```

但后端实际返回：

```json
{
  "code": 0,
  "message": "Operation successful",
  "data": [
    {
      "id": 1,
      "title": "Abstract Harmony"
    }
  ]
}
```

因此前端真实接入时需要读取：

```js
response.data.data
```

或者在 axios 响应拦截器中统一解包。

建议保留后端统一响应格式，前端增加统一响应处理，避免每个页面重复判断。

## 五、认证与 Token 问题

### 1. 当前后端拦截范围过大

后端 `WebConfig` 当前只放行：

```text
/user/login
/user/register
```

其他接口都会进入 `LoginInterceptor`。

这意味着以下接口当前也需要登录：

```text
/artworks/list
/artworks/detail
/artworks/recommendations
```

但作品列表、作品详情通常应为公开接口，否则未登录用户无法浏览商品。

建议至少放行：

```text
/artworks/**
```

如果使用 `/api` 前缀，则对应放行路径也要同步调整。

### 2. 前端当前没有 Token 处理

当前前端没有完整登录页，也没有统一保存 token 或自动添加请求头。

后端拦截器读取请求头：

```text
Authorization
```

因此前端后续需要：

1. 登录成功后保存 token
2. axios 请求拦截器中添加：

```http
Authorization: <token>
```

或约定为：

```http
Authorization: Bearer <token>
```

当前后端 `JwtUtil.parseToken(token)` 是直接解析整个 header 值，如果前端发送 `Bearer xxx`，后端需要先去掉 `Bearer ` 前缀。

因此这里也需要统一约定。

## 六、前端页面尚未真正接入接口

当前前端虽然有部分 API 封装，但页面层大多仍使用静态占位数据。

### 1. 首页

`HomeView.vue` 中作品数据为本地静态数组：

```text
newArrivals
galleryWorks
```

当前未调用后端接口。

### 2. 浏览页

`BrowseView.vue` 当前使用静态 `artworks` 数组，并有 TODO：

```js
// TODO: call useArtworksStore().fetchAll(newFilters)
```

当前筛选器变化后不会真实请求后端。

### 3. 作品详情页

`ArtworkDetailView.vue` 当前使用静态 `artwork` 和 `recommendations` 数据。

当前未根据路由参数 `/artwork/:id` 请求后端作品详情。

### 4. 结账页

`CheckoutView.vue` 当前支付成功后只在前端本地生成订单号：

```js
orderNumber.value = 'AC-' + Math.random().toString(36).slice(2, 8).toUpperCase()
```

当前未调用后端创建订单接口。

### 5. 账户页

`AccountView.vue` 当前是 Coming Soon 页面。

当前未调用：

```text
GET /user/me
GET /orders/me
GET /wishlist/me
```

## 七、订单创建数据结构问题

后端创建订单 DTO 要求：

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

但当前前端购物车中保存的是：

```js
{
  key,
  artwork,
  size,
  quantity,
  price
}
```

提交订单前需要转换为后端 DTO：

```js
{
  artworkId: item.artwork.id,
  size: item.size,
  quantity: item.quantity
}
```

同时，当前结账页只有姓名和邮箱，缺少后端必填的收货信息字段：

```text
shippingCountry
shippingCity
shippingAddressLine1
shippingPostalCode
```

如果直接调用后端创建订单，会触发参数校验失败。

## 八、数据库与接口字段匹配情况

当前后端 MyBatis Mapper 使用的表名为：

```text
artists
artworks
categories
tags
artwork_tags
sizes
artwork_sizes
artwork_recommendations
users
orders
order_items
wishlist_items
```

这些表结构与 `docs/database-schema.sql` 匹配。

仓库根目录下的 `schema.sql` 是另一套偏法语命名的表结构，例如：

```text
utilisateurs
oeuvres
artistes
commandes
```

该文件与当前后端代码不匹配。

后端对接数据库时应优先使用：

```text
docs/database-schema.sql
```

而不是根目录的：

```text
schema.sql
```

## 九、建议统一后的最小对接方案

为了尽快完成前后端真实数据闭环，建议先统一并实现以下最小接口：

```text
GET  /artworks
GET  /artworks/{id}
GET  /artworks/{id}/recommendations
POST /orders
```

如果保留后端现有路径，则前端应改为：

```text
GET  /artworks/list
GET  /artworks/detail?id={id}
GET  /artworks/recommendations?id={id}&limit=4
POST /orders/create
```

二者选择其一即可。

## 十、推荐的对接顺序

### 第一步：统一基础路径

需要明确：

```text
后端端口使用 8000 还是 8080
接口是否统一带 /api 前缀
```

推荐方案：

```text
后端端口：8000
接口前缀：/api
```

这样前端现有 Vite 代理配置可以继续使用。

### 第二步：统一响应格式

推荐保留后端：

```json
{
  "code": 0,
  "message": "Operation successful",
  "data": {}
}
```

前端通过 axios 拦截器统一解包 `data`。

### 第三步：先接作品浏览闭环

优先接入：

```text
BrowseView.vue
ArtworkDetailView.vue
```

对应接口：

```text
GET /artworks
GET /artworks/{id}
GET /artworks/{id}/recommendations
```

### 第四步：再接订单闭环

补齐结账页收货信息字段，然后调用：

```text
POST /orders
```

或后端现有：

```text
POST /orders/create
```

### 第五步：最后接登录、账户、收藏

后续再统一：

```text
POST /user/login
POST /user/register
GET /user/me
GET /orders/me
POST /wishlist?artworkId=1
DELETE /wishlist?artworkId=1
GET /wishlist/me
```

## 十一、当前主要阻塞点汇总

| 优先级 | 问题 | 影响 |
| --- | --- | --- |
| 高 | 前端代理 `8000` 与后端默认 `8080` 不一致 | 请求无法到达后端 |
| 高 | 前端 `/api` 与后端无 `/api` 前缀不一致 | 接口 404 |
| 高 | 作品和订单接口路径不一致 | 即使代理成功也无法调用 |
| 高 | 后端统一响应未被前端解包 | 页面拿不到真实数组/对象 |
| 高 | 公开作品接口被登录拦截 | 未登录用户无法浏览作品 |
| 中 | 前端页面仍是静态数据 | API 封装存在但未被页面使用 |
| 中 | 结账页缺少后端必填收货字段 | 创建订单会参数校验失败 |
| 中 | Token 格式未约定 | 登录态接口无法稳定调用 |
| 低 | 文档、前端、后端三者接口命名不完全一致 | 后续协作容易混乱 |

## 十二、结论

当前项目并不是单个接口字段的小问题，而是前端、后端、文档三者的接口契约还没有完全统一。

建议先确定一套最终接口规范，再决定是：

```text
前端适配后端现有接口
```

还是：

```text
后端调整为前端和文档中描述的 REST 风格接口
```

从长期维护角度看，建议统一为 REST 风格，并保留后端统一响应结构，前端通过 axios 统一处理响应与 token。

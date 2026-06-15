# 前后端对接问题与接口缺口报告

本文档基于当前代码重新分析生成，重点覆盖前后端对接时的阻塞点，以及前端缺后端接口、后端缺前端调用这两类问题。

生成日期：2026-05-23

## 1. 当前结论

当前项目已经具备一部分前后端能力，但还没有形成完整对接闭环。

主要问题不是单个字段错误，而是以下几类问题叠加：

1. 前端代理地址与后端默认端口不一致。
2. 前端默认带 `/api` 前缀，后端接口没有 `/api` 前缀。
3. 前端 API 封装采用 REST 风格，后端 Controller 多数采用 `/list`、`/detail?id=` 风格。
4. 后端统一返回 `Result<T>`，前端当前按原始数组/对象读取。
5. 后端登录拦截器会拦截公开作品接口，前端又没有 token 处理。
6. 前端页面大量仍是静态数据，API 封装没有真正接到页面。
7. 前端存在收藏、搜索、账户、支付等 UI 或注释需求，但缺少对应后端接口或前端封装。
8. 后端已经有用户、订单、收藏接口，但前端没有完整调用链。

## 2. 基础配置问题

### 2.1 前端代理端口与后端端口不一致

前端 Vite 代理：

```text
frontend/vite.config.js
```

当前配置：

```text
/api -> http://localhost:8000
```

后端配置：

```text
backend/src/main/resources/application.yaml
```

当前没有设置 `server.port`，Spring Boot 默认端口是：

```text
8080
```

影响：

```text
前端请求 /api/** 会转发到 8000。
如果后端默认运行在 8080，则前端无法访问后端。
```

### 2.2 `/api` 前缀不一致

前端 axios 默认：

```js
baseURL: import.meta.env.VITE_API_BASE_URL || '/api'
```

后端 Controller 当前路径：

```text
/artworks
/orders
/user
/wishlist
```

影响：

```text
前端实际请求 /api/artworks。
后端实际监听 /artworks。
路径无法匹配。
```

建议二选一：

| 方案 | 调整方向 |
| --- | --- |
| 推荐 | 后端统一加 `/api` 前缀，端口统一为 8000 |
| 可行 | 前端去掉 `/api` 代理前缀，并改代理到 8080 |

## 3. 前端期望接口与后端实际接口对照

### 3.1 作品接口

前端文件：

```text
frontend/src/api/artworks.js
```

前端当前封装：

```text
GET /artworks
GET /artworks/{id}
GET /artworks/{id}/recommendations
GET /artworks/search?q=xxx
```

后端 Controller：

```text
backend/src/main/java/com/ren/yinghui/backend/controller/ArtworksController.java
```

后端当前实际提供：

```text
GET /artworks/list
GET /artworks/detail?id=xxx
GET /artworks/recommendations?id=xxx&limit=4
```

差异表：

| 功能 | 前端期望 | 后端实际 | 问题 |
| --- | --- | --- | --- |
| 作品列表 | `GET /artworks` | `GET /artworks/list` | 路径不一致 |
| 作品详情 | `GET /artworks/{id}` | `GET /artworks/detail?id=xxx` | 路径参数和 query 参数不一致 |
| 相关推荐 | `GET /artworks/{id}/recommendations` | `GET /artworks/recommendations?id=xxx` | 路径不一致 |
| 搜索 | `GET /artworks/search?q=xxx` | 无单独接口，`/artworks/list` 支持 `q` | 前端封装了不存在的接口 |

### 3.2 订单接口

前端文件：

```text
frontend/src/api/orders.js
```

前端当前封装：

```text
POST /orders
GET /orders/{id}
GET /orders/me
```

后端 Controller：

```text
backend/src/main/java/com/ren/yinghui/backend/controller/OrdersController.java
```

后端当前实际提供：

```text
POST /orders/create
GET /orders/detail?id=xxx
GET /orders/me
```

差异表：

| 功能 | 前端期望 | 后端实际 | 问题 |
| --- | --- | --- | --- |
| 创建订单 | `POST /orders` | `POST /orders/create` | 路径不一致 |
| 订单详情 | `GET /orders/{id}` | `GET /orders/detail?id=xxx` | 路径参数和 query 参数不一致 |
| 我的订单 | `GET /orders/me` | `GET /orders/me` | 路径一致，但需要 token |

### 3.3 用户接口

后端当前实际提供：

```text
POST /user/register
POST /user/login
GET /user/me
```

前端当前状态：

```text
没有 user/auth API 封装。
没有登录页。
没有注册页。
没有 token 存储。
没有 axios 请求拦截器添加 Authorization。
```

缺口：

| 功能 | 后端是否有 | 前端是否有 | 问题 |
| --- | --- | --- | --- |
| 注册 | 有 | 无 | 前端缺页面和 API |
| 登录 | 有 | 无 | 前端缺页面、API、token 保存 |
| 当前用户 | 有 | 无 | Account 页没有调用 |
| 退出登录 | 无 | 无 | 若需要账户体系，前端本地清 token 即可，但需设计 |

额外注意：

后端登录、注册接口当前接收普通请求参数：

```text
name
email
password
```

不是 JSON body。前端实现时需要明确使用表单参数，或后端改成 `@RequestBody`。

### 3.4 收藏接口

后端当前实际提供：

```text
POST /wishlist?artworkId=1
DELETE /wishlist?artworkId=1
GET /wishlist/me
```

前端当前状态：

```text
ArtworkCard.vue 有收藏按钮，但只切换本地 wishlisted 状态。
AppHeader.vue 有 Wishlist 图标按钮，但没有跳转、没有页面、没有 API。
AccountView.vue 文案提到 wishlists，但没有实现。
```

缺口：

| 功能 | 后端是否有 | 前端是否有 | 问题 |
| --- | --- | --- | --- |
| 添加收藏 | 有 | 无 API 调用 | 只改本地状态，刷新丢失 |
| 取消收藏 | 有 | 无 API 调用 | 只改本地状态 |
| 我的收藏列表 | 有 | 无页面/无 API 封装 | Header 收藏入口不可用 |
| 查询单个作品是否已收藏 | 无 | 前端需要 | 详情页/卡片初始化状态无法从后端获得 |

建议后端补充：

```text
GET /wishlist/status?artworkId=1
```

响应：

```json
{
  "artworkId": 1,
  "wishlisted": true
}
```

或在作品列表/详情 VO 中增加：

```text
wishlisted
```

但这会引入登录态和公开接口的处理复杂度。

## 4. 前端需要但后端缺失的接口

以下是从当前前端页面、组件、API 封装和注释中推断出的后端缺口。

### 4.1 REST 风格作品接口缺失

前端已封装但后端没有同路径接口：

```text
GET /artworks
GET /artworks/{id}
GET /artworks/{id}/recommendations
GET /artworks/search
```

后端目前有等价能力，但路径不同。

### 4.2 REST 风格订单接口缺失

前端已封装但后端没有同路径接口：

```text
POST /orders
GET /orders/{id}
```

后端目前有等价能力，但路径不同。

### 4.3 支付接口缺失

前端 `CheckoutView.vue` 中注释提到：

```text
POST /api/payments/charge
```

当前后端没有 `PaymentsController`，没有支付相关接口。

当前前端支付逻辑：

1. Stripe 只在浏览器创建 `paymentMethod.id`，没有提交到后端扣款。
2. Demo 卡支付只做前端校验和模拟成功。
3. Bitcoin 使用 Vite 代理直连 BlockCypher testnet。
4. 支付成功后没有创建后端订单。

如果要实现真实支付闭环，后端至少需要：

```text
POST /payments/stripe/intent
POST /payments/stripe/confirm
POST /payments/bitcoin/address
GET  /payments/bitcoin/status?address=xxx
```

或采用更简单的课程项目方案：

```text
POST /orders
```

创建订单时只记录 `paymentMethod`，不做真实支付扣款。

### 4.4 分类/筛选元数据接口缺失

前端 Header 和 ArtworkFilters 中分类、媒介、方向、颜色都是静态写死。

当前后端没有：

```text
GET /categories
GET /artworks/filters
```

如果希望分类、媒介、颜色来自数据库，需要后端补充元数据接口。

建议接口：

```text
GET /artworks/filter-options
```

响应示例：

```json
{
  "categories": [
    { "name": "Paintings", "slug": "paintings" }
  ],
  "mediums": ["Oil", "Acrylic", "Digital"],
  "orientations": ["Landscape", "Portrait", "Square"],
  "colors": ["Red", "Blue", "Green"],
  "sorts": ["recommended", "newest", "price_asc", "price_desc", "trending"]
}
```

### 4.5 账户页所需聚合接口缺失

`AccountView.vue` 当前是 Coming Soon，文案提到：

```text
Account management, order history, and wishlists
```

后端有：

```text
GET /user/me
GET /orders/me
GET /wishlist/me
```

但没有账户聚合接口。

这不是必须缺口，前端可以分别调用三个接口。如果希望减少请求，可补：

```text
GET /account/summary
```

### 4.6 购物车持久化接口缺失

前端购物车完全使用 Pinia 本地状态。

后端没有购物车接口：

```text
GET /cart
POST /cart/items
PUT /cart/items/{id}
DELETE /cart/items/{id}
```

如果项目目标是本地购物车，则不需要补；如果要求登录用户跨设备同步购物车，则后端缺失。

### 4.7 库存/尺寸价格实时校验接口缺失

后端创建订单时会校验：

```text
作品是否 active
库存是否足够
尺寸是否可用
尺寸价格
```

但前端加入购物车和结账页没有实时校验接口。

可选补充：

```text
POST /orders/preview
```

用于根据购物车 items 返回后端计算后的价格、运费、库存状态。

这可以避免前端显示价格与后端实际订单金额不一致。

## 5. 后端已有但前端缺失的调用

以下接口后端已经存在，但前端目前没有完整使用。

### 5.1 用户注册

后端：

```text
POST /user/register
```

前端缺失：

```text
注册页面
注册 API 封装
表单校验
成功后跳转或自动登录流程
```

### 5.2 用户登录

后端：

```text
POST /user/login
```

前端缺失：

```text
登录页面
登录 API 封装
token 保存
Authorization 请求头注入
登录失败提示
登录状态恢复
```

### 5.3 当前用户信息

后端：

```text
GET /user/me
```

前端缺失：

```text
AccountView 没有调用
没有 user store
没有未登录跳转逻辑
```

### 5.4 我的订单

后端：

```text
GET /orders/me
```

前端缺失：

```text
账户页订单列表
orders API 虽然有 getMyOrders，但没有页面调用
```

### 5.5 订单详情

后端：

```text
GET /orders/detail?id=xxx
```

前端缺失：

```text
订单详情页面
后端路径对应的 API 调用
```

前端已有 `getOrder(id)`，但路径是：

```text
GET /orders/{id}
```

与后端不匹配。

### 5.6 收藏

后端：

```text
POST /wishlist
DELETE /wishlist
GET /wishlist/me
```

前端缺失：

```text
wishlist API 文件
收藏按钮真实请求
收藏列表页面
收藏状态初始化
未登录处理
```

## 6. 请求与响应结构问题

### 6.1 后端统一响应未被前端解包

后端统一格式：

```json
{
  "code": 0,
  "message": "Operation successful",
  "data": {}
}
```

前端当前 store 中：

```js
const { data } = await getArtworks(...)
items.value = data
```

这会把整个 Result 对象赋值给 `items`，而不是作品数组。

正确读取应为：

```js
items.value = response.data.data
```

更推荐增加 axios 响应拦截器，统一返回业务 `data`。

### 6.2 错误响应不统一

后端业务失败通常返回：

```json
{
  "code": 1,
  "message": "xxx",
  "data": null
}
```

但参数校验异常、运行时异常目前没有看到统一全局异常处理。

风险：

```text
前端可能同时收到 Result 格式错误、Spring 默认错误 JSON、空 401 响应。
错误提示难以统一。
```

建议后端补充全局异常处理：

```text
GlobalExceptionHandler
```

统一处理：

```text
参数校验失败
RuntimeException
未登录 401
未知异常 500
```

## 7. 认证与登录态问题

### 7.1 公开作品接口被拦截

后端拦截器当前只排除：

```text
/user/login
/user/register
```

所以作品列表、详情、推荐都会被拦截。

影响：

```text
未登录用户无法浏览作品。
前端当前没有 token，所以接入真实作品接口会直接 401。
```

建议公开放行：

```text
/artworks/**
```

如果加 `/api` 前缀，则应放行：

```text
/api/artworks/**
```

### 7.2 Authorization 格式未约定

后端当前直接读取：

```text
Authorization
```

并直接作为 JWT 解析。

也就是说后端当前期望：

```http
Authorization: <token>
```

但更常见的前端写法是：

```http
Authorization: Bearer <token>
```

如果使用 `Bearer`，后端当前会解析失败。

需要统一约定：

| 方案 | 前端 | 后端 |
| --- | --- | --- |
| 简单方案 | `Authorization: token` | 保持当前 |
| 推荐方案 | `Authorization: Bearer token` | 拦截器去掉 `Bearer ` 前缀 |

### 7.3 订单创建强依赖登录态

后端 `OrdersServiceImpl.createOrder` 中会调用：

```text
getCurrentUserId()
```

如果未登录或 ThreadLocal 为空，会出错。

这意味着：

```text
POST /orders/create 必须登录。
```

但当前前端结账流程没有登录要求，也没有 token。

需要明确业务规则：

| 规则 | 影响 |
| --- | --- |
| 必须登录后下单 | 前端 checkout 前要检查登录 |
| 允许游客下单 | 后端 createOrder 不能强制读取 userId，userId 应允许为空 |

当前数据库 `orders.user_id` 允许为空，因此技术上可以支持游客订单，但后端服务实现目前不支持。

## 8. 前端页面接入问题

### 8.1 HomeView

当前状态：

```text
首页新作品、精选作品都是静态数组。
```

需要接口：

```text
GET /artworks?sort=newest&limit=3
GET /artworks?sort=trending&limit=6
```

后端当前可以通过 `/artworks/list` 部分支持，但路径不同。

### 8.2 BrowseView

当前状态：

```text
浏览页使用静态 artworks 数组。
筛选函数中只有 TODO。
```

需要接入：

```text
GET /artworks
```

或后端当前：

```text
GET /artworks/list
```

额外问题：

```text
Header 搜索会跳转 /browse?q=xxx。
BrowseView 当前没有读取 route.query。
```

### 8.3 ArtworkDetailView

当前状态：

```text
详情页 artwork 和 recommendations 都是静态数据。
没有读取 useRoute().params.id 请求后端。
尺寸 options 也是静态数组。
```

需要接入：

```text
GET /artworks/{id}
GET /artworks/{id}/recommendations
```

后端详情 VO 已有：

```text
availableSizes
```

前端应使用后端返回的 `availableSizes`，否则可能出现用户选择了后端不可用尺寸。

### 8.4 CartView

当前状态：

```text
购物车完全本地状态。
```

这可以接受，但下单时必须把本地 cart 转成后端 DTO。

### 8.5 CheckoutView

当前状态：

```text
只收集 name 和 email。
没有收货地址字段。
支付成功后本地生成 orderNumber。
没有调用 createOrder。
```

后端创建订单必填：

```text
items
customerName
customerEmail
shippingCountry
shippingCity
shippingAddressLine1
shippingPostalCode
```

因此当前 CheckoutView 即使调用后端，也会因为缺少收货字段失败。

### 8.6 AccountView

当前状态：

```text
Coming Soon。
```

后端已有：

```text
GET /user/me
GET /orders/me
GET /wishlist/me
```

但前端没有使用。

## 9. 字段与参数问题

### 9.1 分类 slug 不一致

Header 中分类：

```text
Digital Art -> digital
Collections -> collections
```

数据库示例中分类 slug：

```text
digital-art
```

后端查询条件支持：

```sql
c.name = #{category} OR c.slug = #{category}
```

因此前端传 `digital` 时查不到 `digital-art`。

另外 `collections` 在当前数据库分类中不存在。

### 9.2 medium 筛选类型可能不匹配

`ArtworkFilters.vue` 中：

```js
filters.medium = ''
```

但 medium 使用 checkbox：

```html
<input type="checkbox" v-model="filters.medium" />
```

Vue checkbox 多选通常应绑定数组，而后端 DTO 当前是：

```java
private String medium;
```

如果前端未来改成多选数组，后端当前不支持 `medium[]` 或多个 medium。

需要明确：

| 方案 | 前端 | 后端 |
| --- | --- | --- |
| 单选 medium | radio 或 select | `String medium` |
| 多选 medium | array | `List<String> mediums` |

### 9.3 color 命名不一致风险

前端颜色 label：

```text
Black & White
Red
Orange
Yellow
...
```

后端字段：

```text
dominant_color
```

DTO 参数名：

```text
color
```

当前可以传 `color=Red`，但 `Black & White` 是否存在于数据库需要确认。

### 9.4 尺寸文本不一致风险

前端静态尺寸：

```text
50×70 cm
60×80 cm
```

数据库示例尺寸：

```text
50x70 cm
60x80 cm
```

一个是乘号 `×`，一个是字母 `x`。

后端创建订单按尺寸名称精确匹配：

```text
findArtworkSizeByArtworkIdAndSizeName
```

如果前端提交 `50×70 cm`，后端数据库是 `50x70 cm`，会返回：

```text
Artwork size not available
```

详情页应使用后端返回的 `availableSizes`，不要使用本地静态尺寸。

## 10. 数据库脚本问题

当前后端 Mapper 使用表：

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

匹配：

```text
docs/database-schema.sql
```

根目录：

```text
schema.sql
```

使用的是另一套法语命名表，如：

```text
utilisateurs
oeuvres
artistes
commandes
```

该脚本与当前后端 Mapper 不匹配。

对接和初始化数据库时，应使用：

```text
docs/database-schema.sql
```

## 11. 推荐统一接口规范

建议统一为以下接口。这样更接近当前前端 API 封装和已有文档风格。

### 11.1 基础约定

```text
后端端口：8000
接口前缀：/api
响应格式：统一 Result<T>
认证头：Authorization: Bearer <token>
```

响应格式：

```json
{
  "code": 0,
  "message": "Operation successful",
  "data": {}
}
```

### 11.2 作品接口

```text
GET /api/artworks
GET /api/artworks/{id}
GET /api/artworks/{id}/recommendations
GET /api/artworks/filter-options
```

列表参数：

```text
q
category
medium
orientation
color
priceMin
priceMax
sort
offset
limit
page
pageSize
```

### 11.3 订单接口

```text
POST /api/orders
GET /api/orders/{id}
GET /api/orders/me
POST /api/orders/preview
```

`POST /api/orders/preview` 可选，但建议用于结账前价格和库存校验。

### 11.4 用户接口

```text
POST /api/user/register
POST /api/user/login
GET /api/user/me
```

### 11.5 收藏接口

```text
POST /api/wishlist?artworkId=1
DELETE /api/wishlist?artworkId=1
GET /api/wishlist/me
GET /api/wishlist/status?artworkId=1
```

### 11.6 支付接口

如果只做项目演示，可以暂不接真实支付，只在订单中记录 `paymentMethod`。

如果要真实支付，需要新增：

```text
POST /api/payments/stripe/intent
POST /api/payments/stripe/confirm
POST /api/payments/bitcoin/address
GET /api/payments/bitcoin/status
```

## 12. 最小可落地对接顺序

### 第 1 步：统一端口和 `/api` 前缀

先解决请求能否到达后端的问题。

必须明确：

```text
前端代理到哪个端口
后端是否加 /api
```

### 第 2 步：统一作品接口路径

优先打通：

```text
GET /api/artworks
GET /api/artworks/{id}
GET /api/artworks/{id}/recommendations
```

然后接入：

```text
BrowseView.vue
ArtworkDetailView.vue
```

### 第 3 步：前端统一解包后端 Result

否则页面拿不到真实数据。

建议 axios 返回业务 `data`，并统一处理：

```text
code !== 0
401 未登录
网络错误
```

### 第 4 步：放行公开作品接口

否则未登录用户无法浏览。

建议放行：

```text
/api/artworks/**
```

### 第 5 步：确定下单是否必须登录

如果必须登录：

```text
Checkout 前必须登录。
```

如果允许游客下单：

```text
后端 createOrder 不能强制 getCurrentUserId。
```

### 第 6 步：补齐 Checkout 表单并调用创建订单

前端必须提供：

```text
shippingCountry
shippingCity
shippingAddressLine1
shippingPostalCode
```

并将 cart items 转换为：

```json
{
  "artworkId": 1,
  "size": "A3 Print",
  "quantity": 1
}
```

### 第 7 步：接登录、账户、收藏

依次接：

```text
POST /api/user/login
GET /api/user/me
GET /api/orders/me
POST /api/wishlist
DELETE /api/wishlist
GET /api/wishlist/me
```

## 13. 问题汇总表

| 优先级 | 类型 | 问题 | 影响 |
| --- | --- | --- | --- |
| 高 | 基础配置 | 前端代理 8000，后端默认 8080 | 请求无法到达后端 |
| 高 | 基础路径 | 前端带 `/api`，后端无 `/api` | 404 |
| 高 | 接口路径 | 作品接口 REST 风格和 `/list/detail` 风格不一致 | 列表/详情/推荐无法调用 |
| 高 | 接口路径 | 订单接口路径不一致 | 创建订单和详情无法调用 |
| 高 | 响应结构 | 后端返回 Result，前端未解包 | 页面拿不到数组/对象 |
| 高 | 认证 | 作品接口被登录拦截 | 未登录无法浏览 |
| 高 | 认证 | 前端没有 token 体系 | 所有登录态接口无法用 |
| 高 | 下单 | 后端创建订单强依赖登录，前端 checkout 无登录 | 下单失败 |
| 高 | 下单 | 前端缺收货地址字段 | 参数校验失败 |
| 中 | 前端缺口 | 页面大多还是静态数据 | API 即使可用也未展示 |
| 中 | 后端缺口 | 无支付接口 | Stripe/Bitcoin 无后端闭环 |
| 中 | 后端缺口 | 无收藏状态接口 | 卡片/详情无法初始化收藏状态 |
| 中 | 后端缺口 | 无筛选元数据接口 | 分类/筛选只能静态维护 |
| 中 | 字段 | 分类 slug `digital` vs `digital-art` | 分类筛选查不到 |
| 中 | 字段 | 尺寸 `×` vs `x` | 下单尺寸匹配失败 |
| 低 | 数据库 | 根目录 schema.sql 与后端 Mapper 不匹配 | 初始化错库会导致接口不可用 |

## 14. 本轮分析范围

本轮只分析以下文件，不修改业务代码：

```text
frontend/src/api/*
frontend/src/views/*
frontend/src/components/*
frontend/src/stores/*
frontend/vite.config.js
backend/src/main/java/com/ren/yinghui/backend/controller/*
backend/src/main/java/com/ren/yinghui/backend/service/impl/*
backend/src/main/java/com/ren/yinghui/backend/dto/*
backend/src/main/java/com/ren/yinghui/backend/vo/*
backend/src/main/java/com/ren/yinghui/backend/config/*
backend/src/main/java/com/ren/yinghui/backend/interceptors/*
backend/src/main/resources/application.yaml
backend/src/main/resources/mapper/*
docs/database-schema.sql
```

## 15. 最终建议

建议不要在前端和后端分别修补路径，而是先确定一份最终接口契约。

推荐契约：

```text
端口：8000
统一前缀：/api
接口风格：REST
响应格式：Result<T>
认证格式：Authorization: Bearer <token>
公开接口：/api/artworks/**
```

然后按“作品浏览 -> 作品详情 -> 下单 -> 登录账户 -> 收藏 -> 支付增强”的顺序接入。

这样可以最快得到一个可演示、可继续扩展的前后端闭环。

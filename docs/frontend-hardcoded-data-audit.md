# 前端写死数据与本地模拟状态审计

本文档整理 `frontend/src` 中曾经写死或本地模拟的数据，以及当前替换状态。

## 1. 总结

当前第一阶段商城接口和第二阶段市场/交易核心接口已经接入后端。主要 API 封装文件包括：

```text
frontend/src/api/http.js
frontend/src/api/artworks.js
frontend/src/api/orders.js
frontend/src/api/user.js
frontend/src/api/trading.js
frontend/src/api/payments.js
```

仍然保留本地状态的部分主要是 UI 偏好、语言通知设置、AI 聊天消息、外部支付演示状态和 DeepSeek 请求过程。

已修复的问题：

```text
数据库 artworks 表中的画作 = 前端首页 / Browse / Market / Trade 页面显示的画作
```

当前数据库 `artworks` / `artwork_markets` 表对应前端市场作品：

```text
Everydays: The First 5000 Days
Right-click and Save As guy
A Coin for the Ferryman
The Pixel
Machine Hallucinations: NYC
Unsupervised
```

## 2. 画作与市场数据

### 2.1 `frontend/src/stores/trading.js`

原写死内容：

```text
ARTWORKS
TOTAL_SHARES = 1_000_000
MAINTENANCE_RATE = 0.005
FAKE_TRADERS
```

`ARTWORKS` 中原写死 6 个交易市场画作，现已迁移到数据库：

```text
1. Everydays: The First 5000 Days - Beeple
2. Right-click and Save As guy - Xcopy
3. A Coin for the Ferryman - Xcopy
4. The Pixel - Pak
5. Machine Hallucinations: NYC - Refik Anadol
6. Unsupervised - Refik Anadol
```

每个画作写死字段包括：

```text
id
initPrice
title
artist
imageUrl
imageLarge
artistBio
description
tags
year
medium
edition
```

已替换为后端接口的内容：

```text
prices
books
feeds
history
wallet
```

仍在前端保留或后续可继续替换的内容：

```text
btcPrice
aiAgents
aiMonitor
FAKE_TRADERS 文案来源
```

已不再本地随机生成的内容：

```text
价格走势
K 线历史
订单簿 bids / asks
recent trades
永续仓位 id
TP/SL order id
```

使用页面：

```text
frontend/src/views/HomeView.vue
frontend/src/views/BrowseView.vue
frontend/src/views/MarketView.vue
frontend/src/views/TradingView.vue
frontend/src/views/AccountView.vue
frontend/src/components/ui/AiRecommendChat.vue
frontend/src/App.vue
```

当前后端接口：

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

## 3. 作品详情页静态数据

### 3.1 `frontend/src/views/ArtworkDetailView.vue`

原写死主画作：

```text
Abstract Harmony
Sophie Laurent
France
price = 89
medium = Acrylic on Canvas
dimensions = 60 × 80 cm
year = 2024
tags = abstract / colourful / expressive
```

原写死尺寸：

```text
A4 Print
A3 Print
A2 Print
50×70 cm
60×80 cm
```

原写死推荐作品：

```text
Urban Geometry
Blue Silence
Golden Hour
Forest Dream
```

当前注释也说明了这是 placeholder：

```text
Placeholder — replace with API fetch using useRoute().params.id
```

当前已替换为：

```text
GET /api/artworks/{id}
GET /api/artworks/{id}/recommendations
```

## 4. AI 推荐聊天中的静态画作池

### 4.1 `frontend/src/components/ui/AiRecommendChat.vue`

写死 `artworkPool`：

```text
Everydays: The First 5000 Days
Right-click and Save As guy
A Coin for the Ferryman
The Pixel
Machine Hallucinations: NYC
Unsupervised
```

其他本地模拟：

```text
messages
price alert watcher
随机推荐 picks
DeepSeek 请求体中的推荐上下文
```

外部接口：

```text
POST /llm-api/v1/chat/completions
```

替换建议：

```text
GET /api/artworks
GET /api/account/portfolio
GET /api/account/ai-monitor
POST /api/account/ai-monitor
```

## 5. 登录与用户数据

### 5.1 `frontend/src/stores/auth.js`

写死 demo 账号：

```text
demo / demo123
whale / whale888
algo / algo2025
```

每个账号写死字段：

```text
id
username
password
displayName
initials
color
startUsd
startBtc
bio
isPaid
```

本地持久化：

```text
localStorage key: artex_user
```

当前没有真正调用后端登录接口。

替换建议：

```text
POST /api/user/login
GET  /api/user/me
```

如果保留 demo 登录按钮，建议点击后也调用后端登录接口。

## 6. 钱包连接数据

### 6.1 `frontend/src/stores/wallet.js`

写死钱包列表：

```text
Test Wallet
MetaMask
Coinbase Wallet
WalletConnect
Phantom
```

写死 Test Wallet：

```text
address = 0xTest4rtEx00DemoAcc0unt
balanceEth = 10.0000
chainId = test-1337
```

浏览器插件检测：

```text
window.ethereum
window.coinbaseWalletExtension
window.solana
```

替换建议：

```text
POST /api/wallet/connect
POST /api/wallet/disconnect
GET  /api/wallet/me
```

当前接口文档中暂未正式定义钱包接口，可作为第二阶段新增。

## 7. 账户页设置

### 7.1 `frontend/src/views/AccountView.vue`

写死语言列表：

```text
English
中文
日本語
Français
Español
Deutsch
```

本地存储：

```text
artex_lang
artex_notifs
artex_user
```

写死通知设置默认值：

```text
priceAlerts
tradeConfirm
aiActions
marketMoves
tpslTriggers
liquidation
```

用户资料编辑只改本地：

```text
displayName
bio
```

替换建议：

```text
GET  /api/user/me
PUT  /api/user/me
GET  /api/account/settings
PUT  /api/account/settings
```

这些接口当前后端尚未实现。

## 8. 支付与结账

### 8.1 `frontend/src/views/CheckoutView.vue`

本地模拟内容：

```text
orderNumber = 'AC-' + random string
paymentSuccess
Demo card form
simulateBtcPayment()
```

Demo card 逻辑：

```text
前端 Luhn 校验
setTimeout 模拟处理
成功后直接 cart.clear()
```

Stripe 逻辑：

```text
读取 VITE_STRIPE_PUBLIC_KEY
加载 https://js.stripe.com/v3/
创建 paymentMethod
没有真正 POST 到后端
```

Bitcoin 逻辑：

```text
BlockCypher testnet 通过 /blockcypher 代理请求
前端轮询余额
提供模拟付款按钮
```

固定汇率来源：

```text
frontend/src/api/payments.js
EUR_TO_BTC = 0.0000145
```

替换建议：

```text
POST /api/orders
POST /api/payments/charge
POST /api/payments/bitcoin/address
GET  /api/payments/bitcoin/status?address=xxx
```

当前 `CheckoutView.vue` 还没有真正调用 `createOrder()`。

## 9. 价格与币种

### 9.1 `frontend/src/stores/prices.js`

写死币种：

```text
BTC
ETH
BNB
SOL
XRP
```

写死法币：

```text
USD
EUR
GBP
JPY
CAD
AUD
```

写死初始价格：

```text
BTC = 64800
ETH = 3240
BNB = 582
SOL = 178
XRP = 0.618
```

写死初始 24h 涨跌：

```text
BTC = 1.2
ETH = -0.8
BNB = 2.1
SOL = -3.4
XRP = 0.5
```

外部请求：

```text
GET /coingecko/api/v3/simple/price
```

本地存储：

```text
artex_crypto
artex_fiat
```

## 10. 购物车

### 10.1 `frontend/src/stores/cart.js`

购物车完全存在前端：

```text
items
count
total
```

本地持久化：

```text
Pinia persist
```

购物车 item 包含：

```text
key
artwork
size
quantity
price
```

当前没有后端购物车表或接口。

替换建议：

```text
POST   /api/cart/items
GET    /api/cart
PATCH  /api/cart/items/{key}
DELETE /api/cart/items/{key}
```

如果项目只需要轻量结账，也可以继续保留前端购物车，只在 checkout 时调用 `POST /api/orders`。

## 11. 用户偏好画像

### 11.1 `frontend/src/stores/userProfile.js`

本地记录：

```text
viewedArtworkIds
tagScores
artistScores
mediumScores
lastViewedAt
```

本地存储：

```text
artex_user_profile
```

使用场景：

```text
AI recommend chat
个性化推荐提示
浏览行为统计
```

替换建议：

```text
POST /api/profile/artwork-view
GET  /api/profile/preferences
```

当前后端没有实现。

## 12. 通知

### 12.1 `frontend/src/stores/notifications.js`

本地状态：

```text
pendingMessages
```

通知 ID：

```text
Math.random().toString(36).slice(2)
```

当前没有后端通知接口。

替换建议：

```text
GET  /api/notifications
POST /api/notifications/read
```

## 13. 筛选组件

### 13.1 `frontend/src/components/artwork/ArtworkFilters.vue`

筛选项本地初始化：

```text
category
priceMin
priceMax
medium
```

这部分不是业务数据表，但如果需要动态筛选项，可以从后端获取：

```text
GET /api/artwork-filters
```

## 14. 当前替换优先级

建议按以下顺序替换写死数据：

1. `ArtworkDetailView.vue`：改为调用 `GET /api/artworks/{id}` 和推荐接口。
2. `CheckoutView.vue`：支付成功后调用 `POST /api/orders`。
3. `auth.js` / `LoginModal.vue`：改为调用 `POST /api/user/login`。
4. `BrowseView.vue` / `HomeView.vue`：决定使用商城画作接口还是交易市场接口。
5. `MarketView.vue` / `TradingView.vue`：使用 `/api/market/**` 接口替换 `trading.js`。
6. `AccountView.vue`：持仓、订单、TP/SL、AI 配置改为后端接口。

## 15. 后端已具备和缺失能力

已具备第一阶段后端接口：

```text
GET  /api/artworks
GET  /api/artworks/{id}
GET  /api/artworks/{id}/recommendations
GET  /api/artworks/search
POST /api/user/login
GET  /api/user/me
POST /api/orders
GET  /api/orders/{id}
GET  /api/orders/me
POST /api/wishlist
DELETE /api/wishlist
GET  /api/wishlist/me
```

尚未完整实现：

```text
真实注册页面
真实前端登录接入
支付落库
交易市场接口
钱包接口
用户设置接口
通知接口
用户偏好画像接口
后端购物车接口
```

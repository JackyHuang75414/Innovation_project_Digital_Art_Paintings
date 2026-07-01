# Project Improvement Roadmap

本文档记录当前项目从 demo 闭环升级到更完整产品形态的后续完善建议。

## 当前状态

第一阶段商城主链路已经基本打通：

```text
作品列表 -> 作品详情 -> 推荐作品 -> 登录 -> 收藏/购物车 -> 创建订单 -> 我的订单
```

但项目里仍有一些功能停留在前端模拟或半后端化状态，例如注册入口、支付、钱包连接、AI 推荐、后台管理等。后续目标是把涉及用户数据、订单、支付、钱包、交易、AI 配置和审计日志的功能逐步后端化。

## 完善优先级

### 1. 补齐用户闭环

当前后端已有注册接口：

```text
POST /api/user/register
```

但前端只有登录和退出登录，没有注册入口。

建议补充：

- `frontend/src/api/user.js` 增加 `registerUser(name, email, password)`。
- `LoginModal.vue` 增加登录/注册切换表单。
- 注册成功后自动登录，或提示用户返回登录。
- 注册新用户时，后端同步初始化用户钱包数据，例如为 `user_wallets` 创建默认记录。

### 2. 收藏按钮全量接后端

后端已有收藏接口：

```text
POST   /api/wishlist?artworkId=1
DELETE /api/wishlist?artworkId=1
GET    /api/wishlist/me
```

建议补充：

- 新增 `frontend/src/api/wishlist.js`。
- 作品卡片和详情页增加收藏按钮。
- 登录后加载用户收藏状态。
- 未登录点击收藏时弹登录框。
- 收藏状态以后端为准，不只保存在前端状态中。

### 3. 支付接口后端化

当前 `frontend/src/api/payments.js` 直接访问 BlockCypher 测试网，不适合正式产品。

当前已改为由 Spring Boot 生成 Bitcoin testnet 收款地址并查询 BlockCypher 到账状态，但真实 testnet 转账链路暂未完成验证，标记为待验证。

建议新增后端接口：

```text
POST /api/payments/bitcoin/address
GET  /api/payments/{paymentId}
POST /api/payments/card/confirm
```

目标：

- 前端只调用 Spring Boot。
- Spring Boot 负责调用 BlockCypher、Stripe 或 demo payment provider。
- 支付状态由后端控制。
- 支付成功后更新订单状态和支付交易记录。

相关数据库表：

```text
payment_transactions
bitcoin_payment_addresses
orders
```

### 4. 钱包连接后端化

当前 `Connect Wallet` 弹窗只修改前端 Pinia 状态，没有写入后端。

当前已完成最小闭环：登录用户连接钱包后写入 `wallet_connections`，断开钱包会将 active 连接置为非 active，页面刷新后可从后端恢复 active 钱包。真实钱包的 nonce 和签名验证仍待增强。

建议新增接口：

```text
GET    /api/account/wallet-connections
POST   /api/account/wallet-connections/nonce
POST   /api/account/wallet-connections
DELETE /api/account/wallet-connections/{id}
```

推荐流程：

```text
前端连接钱包 -> 获取 address/chainId -> 请求 nonce -> 钱包签名 -> 后端验证签名 -> 写入 wallet_connections
```

实现策略：

- `Test Wallet` 可以先允许无签名绑定，方便演示。
- `MetaMask` / `Coinbase Wallet` 应使用 Ethereum 签名验证。
- `Phantom` 后续补 Solana 签名验证。
- `WalletConnect` 等接入 SDK 后再后端化。

相关数据库表：

```text
wallet_connections
user_wallets
```

### 5. 订单状态和支付状态联动

当前订单能创建，但订单状态流转仍较基础。

建议完善状态：

```text
pending -> paid -> shipped -> completed -> cancelled
```

建议新增接口：

```text
GET  /api/orders/{id}
POST /api/orders/{id}/cancel
POST /api/payments/{paymentId}/confirm
```

目标：

- 支付成功后将 `orders.status` 更新为 `paid`。
- 支付交易表记录真实支付状态。
- 用户可以查看订单详情和状态。
- 后续管理员可以更新发货和完成状态。

### 6. 市场交易模块完善

当前市场、交易、portfolio、TP/SL 已有雏形。后续应保证交易行为和数据库状态一致。

建议完善：

- 买入/卖出后更新 `portfolio_share_holdings`。
- 写入 `trade_executions`。
- 更新 `user_wallets` 余额。
- 更新或返回最新市场价格。
- 前端交易完成后刷新 portfolio、order book、trades。

注意：

- 市场交易模块应独立于商城订单模块。
- 普通订单逻辑不要混入 spot/perp 交易逻辑。

### 7. AI chat 最小后端代理

当前 AI 推荐聊天已从 Vite `/llm-api` 代理改为调用 Spring Boot `/api/ai/chat`。该步骤只做最小后端代理，不保存聊天记录，不实现 `ai_agent_configs` / `ai_monitor_configs`，也不做自动交易或自动监控。

已新增接口：

```text
POST /api/ai/chat
```

后端应负责：

- 管理 LLM API key。
- 接收前端 messages。
- 调用 DeepSeek chat completions。
- 返回统一 `Result<AiChatVO>`。
- 后续如有需要，再扩展配置持久化、调用频率限制和审计日志。

### 8. 增加作品数据和后台管理

当前 seed 数据只有 6 个作品，展示内容偏少。

建议补充：

- 至少 20 到 50 个作品。
- 多个 artist、category、tag、size。
- 完整 recommendations 数据。
- 管理员作品管理接口。
- 管理员订单管理接口。

建议后台接口：

```text
POST   /api/admin/artworks
PUT    /api/admin/artworks/{id}
DELETE /api/admin/artworks/{id}
GET    /api/admin/orders
PUT    /api/admin/orders/{id}/status
```

### 9. 测试、文档和启动说明

建议补充：

- Spring Boot 集成测试。
- 前端关键流程手动验证清单。
- Postman 或 Bruno 接口集合。
- README 写清楚启动方式。
- `.env.example` 写清楚前端和后端环境变量。
- 接口文档和实际代码保持同步。

## 推荐开发顺序

建议按以下顺序推进：

```text
1. 注册前端接入
2. 登录后退出登录
3. 注册后初始化 user_wallets
4. 收藏按钮全量接后端
5. 支付改成 Spring Boot 接口（Bitcoin testnet 真实到账待验证）
6. 钱包连接写入 wallet_connections（最小闭环已完成，签名验证待增强）
7. AI chat 走 Spring Boot 代理（最小实现，不落库）
8. 增加测试和 README
9. 增加作品 seed 数据
10. 管理员订单/作品管理
```

## 企业级后端化原则

以下功能应由后端控制：

- 用户数据
- 订单数据
- 支付状态
- 钱包绑定
- 交易记录
- 资产余额
- API key
- AI 配置和调用日志
- 权限和审计记录

以下内容可以保留在前端：

- 弹窗开关状态
- 当前输入框内容
- 临时筛选条件
- UI 展示状态
- 无敏感信息的本地偏好设置

总体原则：

```text
涉及钱、用户、权限、交易、API key、审计的功能必须后端化；
纯展示和短生命周期 UI 状态可以留在前端。
```

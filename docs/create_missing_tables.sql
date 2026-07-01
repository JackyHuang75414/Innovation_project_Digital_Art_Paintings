-- Create all tables that DeepSeek's setup_db.sql omitted, and add missing columns.
-- Safe to run multiple times (IF NOT EXISTS / IF NOT EXISTS column checks use ADD COLUMN IF NOT EXISTS).
-- Run this FIRST, then run seed_orderbook_trades.sql.

USE digital_art_paintings;

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- ── Add missing columns to artworks ──────────────────────────────────────────
ALTER TABLE artworks
    ADD COLUMN IF NOT EXISTS image_large_url TEXT NULL AFTER image_url,
    ADD COLUMN IF NOT EXISTS edition VARCHAR(100) NULL;

-- ── user_wallets ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_wallets (
    user_id     BIGINT PRIMARY KEY,
    usd_balance DECIMAL(20, 8) NOT NULL DEFAULT 0,
    btc_balance DECIMAL(20, 8) NOT NULL DEFAULT 0
);

-- ── portfolio_share_holdings ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS portfolio_share_holdings (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT        NOT NULL,
    artwork_id BIGINT        NOT NULL,
    quantity   DECIMAL(20,8) NOT NULL DEFAULT 0,
    avg_cost   DECIMAL(20,8) NOT NULL DEFAULT 0,
    UNIQUE KEY uq_user_artwork (user_id, artwork_id)
);

-- ── perp_positions ────────────────────────────────────────────────────────────
-- Column names match MarketMapper.xml: opened_at, closed_at
CREATE TABLE IF NOT EXISTS perp_positions (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT        NOT NULL,
    artwork_id  BIGINT        NOT NULL,
    side        VARCHAR(10)   NOT NULL,
    notional    DECIMAL(20,8) NOT NULL,
    leverage    INT           NOT NULL DEFAULT 1,
    entry_price DECIMAL(20,8) NOT NULL,
    margin_btc  DECIMAL(20,8) NOT NULL DEFAULT 0,
    status      VARCHAR(20)   NOT NULL DEFAULT 'open',
    opened_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at   DATETIME      NULL
);

-- ── tpsl_orders ──────────────────────────────────────────────────────────────
-- Column names match MarketMapper.xml: perp_position_id, quantity
CREATE TABLE IF NOT EXISTS tpsl_orders (
    id                BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id           BIGINT        NOT NULL,
    artwork_id        BIGINT        NOT NULL,
    type              VARCHAR(20)   NOT NULL DEFAULT 'spot',
    perp_position_id  BIGINT        NULL,
    tp_price          DECIMAL(20,8) NULL,
    sl_price          DECIMAL(20,8) NULL,
    quantity          DECIMAL(20,8) NULL,
    status            VARCHAR(20)   NOT NULL DEFAULT 'active',
    created_at        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ── order_book_orders ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS order_book_orders (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    artwork_id     BIGINT        NOT NULL,
    user_id        BIGINT        NULL,
    side           VARCHAR(10)   NOT NULL,
    price          DECIMAL(20,8) NOT NULL,
    size           DECIMAL(20,8) NOT NULL,
    remaining_size DECIMAL(20,8) NOT NULL,
    status         VARCHAR(30)   NOT NULL DEFAULT 'open',
    is_vmm         TINYINT(1)    NOT NULL DEFAULT 0,
    created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_ob_artwork_side (artwork_id, side, price)
);

-- ── trade_executions ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS trade_executions (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    artwork_id      BIGINT        NOT NULL,
    buyer_user_id   BIGINT        NULL,
    seller_user_id  BIGINT        NULL,
    side            VARCHAR(10)   NOT NULL,
    price           DECIMAL(20,8) NOT NULL,
    size            DECIMAL(20,8) NOT NULL,
    notional        DECIMAL(20,8) NOT NULL,
    source          VARCHAR(30)   NOT NULL DEFAULT 'user',
    executed_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_te_artwork_time (artwork_id, executed_at)
);

-- ── wallet_connections ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS wallet_connections (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT        NOT NULL,
    wallet_type     VARCHAR(50)   NOT NULL,
    address         VARCHAR(255)  NOT NULL,
    chain_id        VARCHAR(50)   NULL,
    balance_native  DECIMAL(30,10) NOT NULL DEFAULT 0,
    is_active       TINYINT(1)    NOT NULL DEFAULT 1,
    connected_at    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_address (user_id, address)
);

SET FOREIGN_KEY_CHECKS = 1;

-- ── Seed demo users & wallets ─────────────────────────────────────────────────
-- password_hash is NOT NULL in DeepSeek's schema, so use a placeholder
INSERT IGNORE INTO users (id, name, email, password_hash, role)
VALUES
    (1, 'demo',  'demo@artex.io',  'DEMO_ACCOUNT', 'customer'),
    (2, 'whale', 'whale@artex.io', 'DEMO_ACCOUNT', 'customer'),
    (3, 'algo',  'algo@artex.io',  'DEMO_ACCOUNT', 'customer');

INSERT IGNORE INTO user_wallets (user_id, usd_balance, btc_balance)
VALUES
    (1,  10000.00, 0.50),
    (2, 200000.00, 3.00),
    (3,  50000.00, 1.20);

-- ── Verify ────────────────────────────────────────────────────────────────────
-- Expected: all 6 tables appear, artworks has image_large_url column
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'digital_art_paintings'
  AND table_name IN (
      'order_book_orders','trade_executions','user_wallets',
      'portfolio_share_holdings','perp_positions','tpsl_orders'
  )
ORDER BY table_name;

SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'digital_art_paintings'
  AND table_name = 'artworks'
  AND column_name IN ('image_large_url','edition');

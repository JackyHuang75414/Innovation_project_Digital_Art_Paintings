-- Create all tables that DeepSeek's setup_db.sql omitted, and add missing columns.
-- Uses DROP + CREATE for trading tables (safe — no real data yet).
-- Uses dynamic SQL for ALTER TABLE to support MySQL 5.7+.
-- Run this FIRST, then run seed_orderbook_trades.sql.

USE digital_art_paintings;

SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- ── Add image_large_url to artworks (MySQL 5.7 compatible) ───────────────────
SET @exists_large = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'artworks'
      AND column_name  = 'image_large_url'
);
SET @sql_large = IF(@exists_large = 0,
    'ALTER TABLE artworks ADD COLUMN image_large_url TEXT NULL AFTER image_url',
    'SELECT 1'
);
PREPARE stmt FROM @sql_large;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ── Add edition to artworks (MySQL 5.7 compatible) ───────────────────────────
SET @exists_edition = (
    SELECT COUNT(*) FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name   = 'artworks'
      AND column_name  = 'edition'
);
SET @sql_edition = IF(@exists_edition = 0,
    'ALTER TABLE artworks ADD COLUMN edition VARCHAR(100) NULL',
    'SELECT 1'
);
PREPARE stmt FROM @sql_edition;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ── Drop trading tables to guarantee correct schema ───────────────────────────
-- These are safe to drop — VmmService repopulates them on every 2s tick.
DROP TABLE IF EXISTS tpsl_orders;
DROP TABLE IF EXISTS portfolio_share_holdings;
DROP TABLE IF EXISTS trade_executions;
DROP TABLE IF EXISTS order_book_orders;
DROP TABLE IF EXISTS perp_positions;
DROP TABLE IF EXISTS wallet_connections;
DROP TABLE IF EXISTS user_wallets;

-- ── user_wallets ──────────────────────────────────────────────────────────────
CREATE TABLE user_wallets (
    user_id     BIGINT PRIMARY KEY,
    usd_balance DECIMAL(20, 8) NOT NULL DEFAULT 0,
    btc_balance DECIMAL(20, 8) NOT NULL DEFAULT 0
);

-- ── portfolio_share_holdings ──────────────────────────────────────────────────
CREATE TABLE portfolio_share_holdings (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT        NOT NULL,
    artwork_id BIGINT        NOT NULL,
    quantity   DECIMAL(20,8) NOT NULL DEFAULT 0,
    avg_cost   DECIMAL(20,8) NOT NULL DEFAULT 0,
    UNIQUE KEY uq_user_artwork (user_id, artwork_id)
);

-- ── perp_positions ────────────────────────────────────────────────────────────
-- Columns opened_at / closed_at match MarketMapper.xml queries
CREATE TABLE perp_positions (
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
-- Columns perp_position_id / quantity match MarketMapper.xml queries
CREATE TABLE tpsl_orders (
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
CREATE TABLE order_book_orders (
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
CREATE TABLE trade_executions (
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
CREATE TABLE wallet_connections (
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

-- ── Seed demo users (password_hash is NOT NULL in DeepSeek schema) ────────────
INSERT IGNORE INTO users (id, name, email, password_hash)
VALUES
    (1, 'demo',  'demo@artex.io',  'DEMO_ACCOUNT'),
    (2, 'whale', 'whale@artex.io', 'DEMO_ACCOUNT'),
    (3, 'algo',  'algo@artex.io',  'DEMO_ACCOUNT');

INSERT INTO user_wallets (user_id, usd_balance, btc_balance)
VALUES
    (1,  10000.00, 0.50),
    (2, 200000.00, 3.00),
    (3,  50000.00, 1.20)
ON DUPLICATE KEY UPDATE usd_balance = VALUES(usd_balance), btc_balance = VALUES(btc_balance);

SET SQL_SAFE_UPDATES = 1;

-- ── Verify ────────────────────────────────────────────────────────────────────
-- Should show 6 table names
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'digital_art_paintings'
  AND table_name IN (
      'order_book_orders','trade_executions','user_wallets',
      'portfolio_share_holdings','perp_positions','tpsl_orders'
  )
ORDER BY table_name;

-- Should show edition, image_large_url
SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'digital_art_paintings'
  AND table_name   = 'artworks'
  AND column_name  IN ('image_large_url', 'edition')
ORDER BY column_name;

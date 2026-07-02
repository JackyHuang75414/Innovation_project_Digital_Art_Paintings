-- ArtCanvas database schema
-- Target database: MySQL 8.0+
-- This script creates the tables needed by docs/current-frontend-api-contract.md.

CREATE DATABASE IF NOT EXISTS digital_art_paintings
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE digital_art_paintings;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS wishlist_items;
DROP TABLE IF EXISTS ai_action_logs;
DROP TABLE IF EXISTS ai_monitor_configs;
DROP TABLE IF EXISTS ai_agent_configs;
DROP TABLE IF EXISTS tpsl_orders;
DROP TABLE IF EXISTS perp_positions;
DROP TABLE IF EXISTS portfolio_share_holdings;
DROP TABLE IF EXISTS trade_executions;
DROP TABLE IF EXISTS order_book_orders;
DROP TABLE IF EXISTS artwork_price_history;
DROP TABLE IF EXISTS artwork_markets;
DROP TABLE IF EXISTS wallet_connections;
DROP TABLE IF EXISTS user_wallets;
DROP TABLE IF EXISTS payment_transactions;
DROP TABLE IF EXISTS bitcoin_payment_addresses;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS artwork_recommendations;
DROP TABLE IF EXISTS artwork_sizes;
DROP TABLE IF EXISTS artwork_tags;
DROP TABLE IF EXISTS artwork_images;
DROP TABLE IF EXISTS artworks;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS sizes;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS artists;
DROP TABLE IF EXISTS categories;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE categories (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL,
  slug VARCHAR(100) NOT NULL,
  description VARCHAR(500) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_categories_name (name),
  UNIQUE KEY uk_categories_slug (slug)
) ENGINE=InnoDB;

CREATE TABLE artists (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  country VARCHAR(80) NULL,
  bio TEXT NULL,
  avatar_url VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_artists_name (name),
  KEY idx_artists_country (country)
) ENGINE=InnoDB;

CREATE TABLE artworks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  artist_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NULL,
  title VARCHAR(160) NOT NULL,
  image_url VARCHAR(500) NOT NULL,
  image_large_url VARCHAR(500) NULL,
  price DECIMAL(10,2) NOT NULL,
  medium VARCHAR(120) NOT NULL,
  edition VARCHAR(60) NULL,
  orientation ENUM('Landscape', 'Portrait', 'Square') NULL,
  dominant_color VARCHAR(60) NULL,
  dimensions VARCHAR(80) NULL,
  year SMALLINT UNSIGNED NULL,
  description TEXT NULL,
  badge ENUM('New', 'Trending', 'Limited') NULL,
  stock_quantity INT UNSIGNED NOT NULL DEFAULT 0,
  view_count INT UNSIGNED NOT NULL DEFAULT 0,
  sold_count INT UNSIGNED NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_artworks_artist_id (artist_id),
  KEY idx_artworks_category_id (category_id),
  KEY idx_artworks_price (price),
  KEY idx_artworks_medium (medium),
  KEY idx_artworks_orientation (orientation),
  KEY idx_artworks_dominant_color (dominant_color),
  KEY idx_artworks_badge (badge),
  KEY idx_artworks_created_at (created_at),
  KEY idx_artworks_recommended (is_active, sold_count, view_count),
  FULLTEXT KEY ft_artworks_search (title, medium, description),
  CONSTRAINT fk_artworks_artist
    FOREIGN KEY (artist_id) REFERENCES artists (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_artworks_category
    FOREIGN KEY (category_id) REFERENCES categories (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_artworks_price_non_negative CHECK (price >= 0),
  CONSTRAINT chk_artworks_stock_non_negative CHECK (stock_quantity >= 0)
) ENGINE=InnoDB;

CREATE TABLE artwork_images (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  artwork_id BIGINT UNSIGNED NOT NULL,
  image_url VARCHAR(500) NOT NULL,
  alt_text VARCHAR(200) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_artwork_images_artwork_id (artwork_id),
  CONSTRAINT fk_artwork_images_artwork
    FOREIGN KEY (artwork_id) REFERENCES artworks (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tags (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(60) NOT NULL,
  slug VARCHAR(80) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_tags_name (name),
  UNIQUE KEY uk_tags_slug (slug)
) ENGINE=InnoDB;

CREATE TABLE artwork_tags (
  artwork_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (artwork_id, tag_id),
  KEY idx_artwork_tags_tag_id (tag_id),
  CONSTRAINT fk_artwork_tags_artwork
    FOREIGN KEY (artwork_id) REFERENCES artworks (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_artwork_tags_tag
    FOREIGN KEY (tag_id) REFERENCES tags (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE sizes (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL,
  price_delta DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_sizes_name (name)
) ENGINE=InnoDB;

CREATE TABLE artwork_sizes (
  artwork_id BIGINT UNSIGNED NOT NULL,
  size_id BIGINT UNSIGNED NOT NULL,
  price_override DECIMAL(10,2) NULL,
  is_available TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (artwork_id, size_id),
  KEY idx_artwork_sizes_size_id (size_id),
  CONSTRAINT fk_artwork_sizes_artwork
    FOREIGN KEY (artwork_id) REFERENCES artworks (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_artwork_sizes_size
    FOREIGN KEY (size_id) REFERENCES sizes (id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_artwork_sizes_price_override CHECK (price_override IS NULL OR price_override >= 0)
) ENGINE=InnoDB;

CREATE TABLE artwork_recommendations (
  artwork_id BIGINT UNSIGNED NOT NULL,
  recommended_artwork_id BIGINT UNSIGNED NOT NULL,
  score DECIMAL(6,4) NOT NULL DEFAULT 0.0000,
  reason VARCHAR(200) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (artwork_id, recommended_artwork_id),
  KEY idx_artwork_recommendations_score (artwork_id, score),
  KEY idx_artwork_recommendations_recommended (recommended_artwork_id),
  CONSTRAINT fk_artwork_recommendations_artwork
    FOREIGN KEY (artwork_id) REFERENCES artworks (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_artwork_recommendations_recommended
    FOREIGN KEY (recommended_artwork_id) REFERENCES artworks (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_artwork_recommendations_score CHECK (score >= 0 AND score <= 1)
) ENGINE=InnoDB;

CREATE TABLE users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL,
  password_hash VARCHAR(255) NULL,
  display_name VARCHAR(120) NULL,
  initials VARCHAR(12) NULL,
  avatar_color VARCHAR(20) NULL,
  bio VARCHAR(500) NULL,
  is_paid TINYINT(1) NOT NULL DEFAULT 0,
  start_usd DECIMAL(18,2) NOT NULL DEFAULT 10000.00,
  start_btc DECIMAL(18,8) NOT NULL DEFAULT 0.50000000,
  phone VARCHAR(40) NULL,
  role ENUM('customer', 'admin') NOT NULL DEFAULT 'customer',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_users_name (name),
  UNIQUE KEY uk_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_no VARCHAR(40) NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  status ENUM('pending', 'paid', 'shipped', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
  customer_name VARCHAR(120) NOT NULL,
  customer_email VARCHAR(190) NOT NULL,
  customer_phone VARCHAR(40) NULL,
  shipping_country VARCHAR(80) NOT NULL,
  shipping_city VARCHAR(80) NOT NULL,
  shipping_address_line1 VARCHAR(200) NOT NULL,
  shipping_address_line2 VARCHAR(200) NULL,
  shipping_postal_code VARCHAR(30) NOT NULL,
  payment_method VARCHAR(40) NULL,
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  shipping_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_orders_order_no (order_no),
  KEY idx_orders_user_id (user_id),
  KEY idx_orders_status (status),
  KEY idx_orders_customer_email (customer_email),
  KEY idx_orders_created_at (created_at),
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_orders_subtotal CHECK (subtotal >= 0),
  CONSTRAINT chk_orders_shipping_fee CHECK (shipping_fee >= 0),
  CONSTRAINT chk_orders_total CHECK (total >= 0)
) ENGINE=InnoDB;

CREATE TABLE order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  artwork_id BIGINT UNSIGNED NULL,
  artwork_title VARCHAR(160) NOT NULL,
  artwork_image_url VARCHAR(500) NOT NULL,
  artist_name VARCHAR(120) NOT NULL,
  size_name VARCHAR(80) NOT NULL,
  quantity INT UNSIGNED NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_items_order_id (order_id),
  KEY idx_order_items_artwork_id (artwork_id),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_order_items_artwork
    FOREIGN KEY (artwork_id) REFERENCES artworks (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
  CONSTRAINT chk_order_items_unit_price CHECK (unit_price >= 0),
  CONSTRAINT chk_order_items_subtotal CHECK (subtotal >= 0)
) ENGINE=InnoDB;

CREATE TABLE wishlist_items (
  user_id BIGINT UNSIGNED NOT NULL,
  artwork_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, artwork_id),
  KEY idx_wishlist_items_artwork_id (artwork_id),
  CONSTRAINT fk_wishlist_items_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_wishlist_items_artwork
    FOREIGN KEY (artwork_id) REFERENCES artworks (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE payment_transactions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NULL,
  provider ENUM('demo_card', 'stripe', 'bitcoin_testnet') NOT NULL,
  provider_payment_id VARCHAR(120) NULL,
  status ENUM('pending', 'processing', 'succeeded', 'failed', 'cancelled') NOT NULL DEFAULT 'pending',
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(10) NOT NULL DEFAULT 'EUR',
  raw_response JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_payment_transactions_order_id (order_id),
  KEY idx_payment_transactions_user_id (user_id),
  KEY idx_payment_transactions_status (status),
  CONSTRAINT fk_payment_transactions_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_payment_transactions_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_payment_transactions_amount CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE bitcoin_payment_addresses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  payment_transaction_id BIGINT UNSIGNED NULL,
  order_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NULL,
  address VARCHAR(120) NOT NULL,
  expected_btc DECIMAL(18,8) NOT NULL,
  received_satoshi BIGINT UNSIGNED NOT NULL DEFAULT 0,
  status ENUM('pending', 'paid', 'expired') NOT NULL DEFAULT 'pending',
  expires_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_bitcoin_payment_addresses_address (address),
  KEY idx_bitcoin_payment_addresses_order_id (order_id),
  KEY idx_bitcoin_payment_addresses_user_id (user_id),
  CONSTRAINT fk_bitcoin_payment_addresses_payment
    FOREIGN KEY (payment_transaction_id) REFERENCES payment_transactions (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_bitcoin_payment_addresses_order
    FOREIGN KEY (order_id) REFERENCES orders (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_bitcoin_payment_addresses_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_bitcoin_payment_addresses_expected_btc CHECK (expected_btc >= 0)
) ENGINE=InnoDB;

CREATE TABLE user_wallets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  usd_balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  btc_balance DECIMAL(18,8) NOT NULL DEFAULT 0.00000000,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_wallets_user_id (user_id),
  CONSTRAINT fk_user_wallets_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_user_wallets_usd_balance CHECK (usd_balance >= 0),
  CONSTRAINT chk_user_wallets_btc_balance CHECK (btc_balance >= 0)
) ENGINE=InnoDB;

CREATE TABLE wallet_connections (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  wallet_type ENUM('testwallet', 'metamask', 'coinbase', 'walletconnect', 'phantom') NOT NULL,
  address VARCHAR(160) NOT NULL,
  chain_id VARCHAR(60) NULL,
  balance_native DECIMAL(28,10) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  connected_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  disconnected_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_wallet_connections_user_id (user_id),
  KEY idx_wallet_connections_address (address),
  CONSTRAINT fk_wallet_connections_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE artwork_markets (
  artwork_id BIGINT UNSIGNED NOT NULL,
  total_shares BIGINT UNSIGNED NOT NULL DEFAULT 1000000,
  initial_share_price DECIMAL(18,8) NOT NULL,
  current_share_price DECIMAL(18,8) NOT NULL,
  market_cap DECIMAL(20,2) GENERATED ALWAYS AS (current_share_price * total_shares) STORED,
  volume_24h DECIMAL(20,2) NOT NULL DEFAULT 0.00,
  change_24h_pct DECIMAL(10,4) NOT NULL DEFAULT 0.0000,
  is_tradable TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (artwork_id),
  KEY idx_artwork_markets_tradable (is_tradable, market_cap),
  CONSTRAINT fk_artwork_markets_artwork
    FOREIGN KEY (artwork_id) REFERENCES artworks (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_artwork_markets_total_shares CHECK (total_shares > 0),
  CONSTRAINT chk_artwork_markets_initial_price CHECK (initial_share_price >= 0),
  CONSTRAINT chk_artwork_markets_current_price CHECK (current_share_price >= 0)
) ENGINE=InnoDB;

CREATE TABLE artwork_price_history (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  artwork_id BIGINT UNSIGNED NOT NULL,
  price DECIMAL(18,8) NOT NULL,
  recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_artwork_price_history_artwork_time (artwork_id, recorded_at),
  CONSTRAINT fk_artwork_price_history_artwork
    FOREIGN KEY (artwork_id) REFERENCES artwork_markets (artwork_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_artwork_price_history_price CHECK (price >= 0)
) ENGINE=InnoDB;

CREATE TABLE order_book_orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  artwork_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  side ENUM('bid', 'ask') NOT NULL,
  order_type ENUM('limit', 'market', 'vmm') NOT NULL DEFAULT 'limit',
  price DECIMAL(18,8) NOT NULL,
  size DECIMAL(18,6) NOT NULL,
  remaining_size DECIMAL(18,6) NOT NULL,
  status ENUM('open', 'partially_filled', 'filled', 'cancelled') NOT NULL DEFAULT 'open',
  is_vmm TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_book_orders_artwork_side_price (artwork_id, side, price),
  KEY idx_order_book_orders_user_id (user_id),
  CONSTRAINT fk_order_book_orders_artwork
    FOREIGN KEY (artwork_id) REFERENCES artwork_markets (artwork_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_order_book_orders_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_order_book_orders_price CHECK (price >= 0),
  CONSTRAINT chk_order_book_orders_size CHECK (size > 0),
  CONSTRAINT chk_order_book_orders_remaining_size CHECK (remaining_size >= 0)
) ENGINE=InnoDB;

CREATE TABLE trade_executions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  artwork_id BIGINT UNSIGNED NOT NULL,
  buyer_user_id BIGINT UNSIGNED NULL,
  seller_user_id BIGINT UNSIGNED NULL,
  side ENUM('buy', 'sell') NOT NULL,
  price DECIMAL(18,8) NOT NULL,
  size DECIMAL(18,6) NOT NULL,
  notional DECIMAL(20,2) NOT NULL,
  source ENUM('spot', 'perp', 'vmm', 'ai_agent') NOT NULL DEFAULT 'spot',
  executed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_trade_executions_artwork_time (artwork_id, executed_at),
  KEY idx_trade_executions_buyer (buyer_user_id),
  KEY idx_trade_executions_seller (seller_user_id),
  CONSTRAINT fk_trade_executions_artwork
    FOREIGN KEY (artwork_id) REFERENCES artwork_markets (artwork_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_trade_executions_buyer
    FOREIGN KEY (buyer_user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_trade_executions_seller
    FOREIGN KEY (seller_user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_trade_executions_price CHECK (price >= 0),
  CONSTRAINT chk_trade_executions_size CHECK (size > 0),
  CONSTRAINT chk_trade_executions_notional CHECK (notional >= 0)
) ENGINE=InnoDB;

CREATE TABLE portfolio_share_holdings (
  user_id BIGINT UNSIGNED NOT NULL,
  artwork_id BIGINT UNSIGNED NOT NULL,
  quantity DECIMAL(18,6) NOT NULL DEFAULT 0.000000,
  avg_cost DECIMAL(18,8) NOT NULL DEFAULT 0.00000000,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, artwork_id),
  KEY idx_portfolio_share_holdings_artwork_id (artwork_id),
  CONSTRAINT fk_portfolio_share_holdings_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_portfolio_share_holdings_artwork
    FOREIGN KEY (artwork_id) REFERENCES artwork_markets (artwork_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_portfolio_share_holdings_quantity CHECK (quantity >= 0),
  CONSTRAINT chk_portfolio_share_holdings_avg_cost CHECK (avg_cost >= 0)
) ENGINE=InnoDB;

CREATE TABLE perp_positions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  artwork_id BIGINT UNSIGNED NOT NULL,
  side ENUM('long', 'short') NOT NULL,
  notional DECIMAL(20,2) NOT NULL,
  leverage INT UNSIGNED NOT NULL,
  entry_price DECIMAL(18,8) NOT NULL,
  margin_btc DECIMAL(18,8) NOT NULL,
  status ENUM('open', 'closed', 'liquidated') NOT NULL DEFAULT 'open',
  opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_perp_positions_user_status (user_id, status),
  KEY idx_perp_positions_artwork_id (artwork_id),
  CONSTRAINT fk_perp_positions_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_perp_positions_artwork
    FOREIGN KEY (artwork_id) REFERENCES artwork_markets (artwork_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_perp_positions_notional CHECK (notional >= 0),
  CONSTRAINT chk_perp_positions_leverage CHECK (leverage > 0),
  CONSTRAINT chk_perp_positions_entry_price CHECK (entry_price >= 0),
  CONSTRAINT chk_perp_positions_margin_btc CHECK (margin_btc >= 0)
) ENGINE=InnoDB;

CREATE TABLE tpsl_orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  artwork_id BIGINT UNSIGNED NOT NULL,
  type ENUM('spot', 'perp') NOT NULL DEFAULT 'spot',
  perp_position_id BIGINT UNSIGNED NULL,
  tp_price DECIMAL(18,8) NULL,
  sl_price DECIMAL(18,8) NULL,
  quantity DECIMAL(18,6) NULL,
  status ENUM('active', 'triggered', 'cancelled', 'expired') NOT NULL DEFAULT 'active',
  trigger_type ENUM('take_profit', 'stop_loss', 'expired') NULL,
  trigger_price DECIMAL(18,8) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  triggered_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_tpsl_orders_user_status (user_id, status),
  KEY idx_tpsl_orders_artwork_id (artwork_id),
  KEY idx_tpsl_orders_perp_position_id (perp_position_id),
  CONSTRAINT fk_tpsl_orders_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_tpsl_orders_artwork
    FOREIGN KEY (artwork_id) REFERENCES artwork_markets (artwork_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_tpsl_orders_perp_position
    FOREIGN KEY (perp_position_id) REFERENCES perp_positions (id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_tpsl_orders_tp_price CHECK (tp_price IS NULL OR tp_price >= 0),
  CONSTRAINT chk_tpsl_orders_sl_price CHECK (sl_price IS NULL OR sl_price >= 0),
  CONSTRAINT chk_tpsl_orders_quantity CHECK (quantity IS NULL OR quantity > 0)
) ENGINE=InnoDB;

CREATE TABLE ai_agent_configs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  artwork_id BIGINT UNSIGNED NOT NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 0,
  strategy ENUM('momentum', 'mean_reversion', 'grid', 'custom') NOT NULL DEFAULT 'momentum',
  max_usd DECIMAL(18,2) NOT NULL DEFAULT 500.00,
  interval_sec INT UNSIGNED NOT NULL DEFAULT 30,
  custom_endpoint VARCHAR(500) NULL,
  custom_key_encrypted VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_ai_agent_configs_user_artwork (user_id, artwork_id),
  CONSTRAINT fk_ai_agent_configs_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ai_agent_configs_artwork
    FOREIGN KEY (artwork_id) REFERENCES artwork_markets (artwork_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_ai_agent_configs_max_usd CHECK (max_usd >= 0),
  CONSTRAINT chk_ai_agent_configs_interval CHECK (interval_sec > 0)
) ENGINE=InnoDB;

CREATE TABLE ai_monitor_configs (
  user_id BIGINT UNSIGNED NOT NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 0,
  endpoint VARCHAR(500) NULL,
  api_key_encrypted VARCHAR(500) NULL,
  interval_sec INT UNSIGNED NOT NULL DEFAULT 60,
  last_run DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_ai_monitor_configs_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_ai_monitor_configs_interval CHECK (interval_sec > 0)
) ENGINE=InnoDB;

CREATE TABLE ai_action_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  actions JSON NULL,
  error_message VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_ai_action_logs_user_time (user_id, created_at),
  CONSTRAINT fk_ai_action_logs_user
    FOREIGN KEY (user_id) REFERENCES users (id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO categories (id, name, slug, sort_order) VALUES
  (1, 'Paintings', 'paintings', 10),
  (2, 'Digital Art', 'digital-art', 20),
  (3, 'Photography', 'photography', 30),
  (4, 'Prints', 'prints', 40);

INSERT INTO artists (id, name, country, bio) VALUES
  (
    1, 'Beeple (Mike Winkelmann)', 'United States',
    'Mike Winkelmann, known as Beeple, is a graphic designer from Charleston, SC. His Everydays project culminated in a Christie''s auction that shattered records.'
  ),
  (
    2, 'Xcopy', 'United Kingdom',
    'Xcopy is an anonymous London-based digital artist and a founding figure of the NFT glitch-art movement.'
  ),
  (
    3, 'Pak', 'Unknown',
    'Pak is an anonymous digital artist or collective known for conceptual minimalism and algorithmic scarcity.'
  ),
  (
    4, 'Refik Anadol', 'Turkey',
    'Refik Anadol is a media artist whose practice sits at the intersection of AI research and architecture.'
  ),
  (
    5, 'Lina Ortega', 'Spain',
    'Lina Ortega creates luminous generative compositions inspired by memory systems, maps and archival interfaces.'
  ),
  (
    6, 'Theo Nakamura', 'Japan',
    'Theo Nakamura works with simulated machines, orbital diagrams and minimalist computational forms.'
  ),
  (
    7, 'Mira Kova', 'Serbia',
    'Mira Kova builds synthetic landscapes from noise fields, weather data and imagined network topologies.'
  ),
  (
    8, 'Amara Singh', 'India',
    'Amara Singh explores digital architecture, signal flow and ritual geometry through bold vector systems.'
  ),
  (
    9, 'Jules Moreau', 'France',
    'Jules Moreau makes quiet conceptual works about ledgers, receipts, timestamps and machine memory.'
  ),
  (
    10, 'Nia Okafor', 'Nigeria',
    'Nia Okafor combines saturated colour, abstract city scans and data-driven visual rhythm.'
  );

INSERT INTO tags (id, name, slug) VALUES
  (1, 'Historic NFT', 'historic-nft'),
  (2, 'Digital Collage', 'digital-collage'),
  (3, 'Generative', 'generative'),
  (4, '5000 Days', '5000-days'),
  (5, 'Glitch Art', 'glitch-art'),
  (6, 'Animated GIF', 'animated-gif'),
  (7, 'Dark Punk', 'dark-punk'),
  (8, 'CC0', 'cc0'),
  (9, 'Mythology', 'mythology'),
  (10, 'Death', 'death'),
  (11, 'Conceptual', 'conceptual'),
  (12, 'Minimalist', 'minimalist'),
  (13, 'Single Pixel', 'single-pixel'),
  (14, 'Sotheby''s', 'sothebys'),
  (15, 'AI Art', 'ai-art'),
  (16, 'Data Sculpture', 'data-sculpture'),
  (17, 'Immersive', 'immersive'),
  (18, 'Machine Learning', 'machine-learning'),
  (19, 'MoMA', 'moma'),
  (20, 'Living Archive', 'living-archive'),
  (21, 'Neural Color', 'neural-color'),
  (22, 'Synthetic Landscape', 'synthetic-landscape'),
  (23, 'Chain Geometry', 'chain-geometry'),
  (24, 'Light Field', 'light-field'),
  (25, 'Cyber Minimal', 'cyber-minimal'),
  (26, 'Signal Mapping', 'signal-mapping'),
  (27, 'Abstract Print', 'abstract-print'),
  (28, 'Token Study', 'token-study'),
  (29, 'Gradient System', 'gradient-system'),
  (30, 'Digital Architecture', 'digital-architecture'),
  (31, 'Algorithmic Bloom', 'algorithmic-bloom'),
  (32, 'Data Weather', 'data-weather');

INSERT INTO sizes (id, name, price_delta, sort_order) VALUES
  (1, 'A4 Print', 0.00, 10),
  (2, 'A3 Print', 10.00, 20),
  (3, 'A2 Print', 25.00, 30),
  (4, '50x70 cm', 40.00, 40),
  (5, '60x80 cm', 55.00, 50);

INSERT INTO artworks (
  id, artist_id, category_id, title, image_url, image_large_url, price, medium, edition,
  orientation, dominant_color, dimensions, year, description, badge,
  stock_quantity, view_count, sold_count
) VALUES
  (
    1, 1, 2, 'Everydays: The First 5000 Days',
    'https://static.wixstatic.com/media/a64726_8b0e3cb2371c4d58ab569c6a5d521719~mv2.jpg/v1/fill/w_940,h_940,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/BEEPLE-EVERYDAYS_THE_FIRST_5000_DAYS_3k_.jpg',
    'https://static.wixstatic.com/media/a64726_8b0e3cb2371c4d58ab569c6a5d521719~mv2.jpg/v1/fill/w_3000,h_3000,al_c,q_90,enc_avif,quality_auto/BEEPLE-EVERYDAYS_THE_FIRST_5000_DAYS_3k_.jpg',
    6.90, 'Digital', '1 / 1', 'Square', 'Mixed', '60 x 80 cm', 2021,
    'A 21,069 x 21,069 pixel collage of 5,000 individual digital works created daily from May 2007 to January 2021.',
    'Trending', 20, 130, 18
  ),
  (
    2, 2, 2, 'Right-click and Save As guy',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Right-Click_and_Save_as_Guy.gif/500px-Right-Click_and_Save_as_Guy.gif',
    'https://raw2.seadn.io/ethereum/0x41a322b28d0ff354040e2cbc676f0320d8c8850d/92579d4e11c5125592c530d21d721e/fb92579d4e11c5125592c530d21d721e.gif',
    2.80, 'Animated GIF', '1 / 1', 'Square', 'Purple', '50 x 50 cm', 2018,
    'Released in 2018, this animated GIF became one of the defining images of the NFT ownership debate.',
    'New', 15, 95, 9
  ),
  (
    3, 2, 2, 'A Coin for the Ferryman',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/A_Coin_for_the_Ferryman.gif/500px-A_Coin_for_the_Ferryman.gif',
    'https://raw2.seadn.io/ethereum/0x41a322b28d0ff354040e2cbc676f0320d8c8850d/c66ed71e3786537324770103976fa5/99c66ed71e3786537324770103976fa5.gif',
    1.92, 'Animated GIF', '1 / 1', 'Square', 'Blue', '70 x 50 cm', 2018,
    'A haunting meditation on mortality drawn from Greek mythology, rendered in fluorescent-on-void glitch loops.',
    NULL, 18, 78, 6
  ),
  (
    4, 3, 2, 'The Pixel',
    '/artworks/the-pixel.jpg',
    '/artworks/the-pixel.jpg',
    3.20, 'Digital (1 x 1 px)', '1 / 1', 'Square', 'White', '1 x 1 px', 2021,
    'A single pixel sold at Sotheby''s in 2021, reducing art to its indivisible atomic unit.',
    NULL, 12, 81, 7
  ),
  (
    5, 4, 2, 'Machine Hallucinations: NYC',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Machine_Hallucinations-Artechouse_NYC_by_Refik_Anadol.jpg/500px-Machine_Hallucinations-Artechouse_NYC_by_Refik_Anadol.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/d/d9/Machine_Hallucinations-Artechouse_NYC_by_Refik_Anadol.jpg',
    1.40, 'AI Data Sculpture', '1 / 1', 'Landscape', 'Blue', '70 x 50 cm', 2019,
    'An immersive data sculpture trained on public photographs of New York City.',
    'Trending', 25, 150, 21
  ),
  (
    6, 4, 2, 'Unsupervised',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Unsupervised_by_Refik_Anadol.jpg/500px-Unsupervised_by_Refik_Anadol.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/7/7f/Unsupervised_by_Refik_Anadol.jpg',
    0.88, 'AI Living Archive', '1 / 1', 'Landscape', 'Blue', '70 x 50 cm', 2022,
    'Unsupervised fed MoMA''s public collection into a machine learning model that dreamed its own interpretation of the canon.',
    'Limited', 8, 68, 4
  ),
  (
    7, 5, 2, 'Neon Memory Grid',
    '/artworks/neon-memory-grid.jpg', '/artworks/neon-memory-grid.jpg',
    1.15, 'Generative Vector', 'Edition of 12', 'Square', 'Mixed', '60 x 60 cm', 2026,
    'A luminous grid of remembered signals, built from layered geometry and archival colour fields.',
    'New', 24, 54, 5
  ),
  (
    8, 8, 2, 'Liquid Data Cathedral',
    '/artworks/liquid-data-cathedral.jpg', '/artworks/liquid-data-cathedral.jpg',
    1.72, 'AI Data Sculpture', '1 / 1', 'Square', 'Blue', '80 x 80 cm', 2026,
    'A vaulted structure of synthetic data, suspended between sacred geometry and machine vision.',
    'Trending', 15, 88, 12
  ),
  (
    9, 7, 2, 'Blue Noise Archive',
    '/artworks/blue-noise-archive.jpg', '/artworks/blue-noise-archive.jpg',
    0.94, 'Digital Abstract', 'Edition of 25', 'Square', 'Blue', '50 x 50 cm', 2025,
    'An atmospheric study of noisy memory, soft signals and drifting archival light.',
    NULL, 30, 43, 3
  ),
  (
    10, 5, 2, 'Chrome Bloom Protocol',
    '/artworks/chrome-bloom-protocol.jpg', '/artworks/chrome-bloom-protocol.jpg',
    2.35, 'Algorithmic Bloom', '1 / 1', 'Square', 'Red', '70 x 70 cm', 2026,
    'A polished synthetic flower generated from mirrored petals and protocol-like symmetry.',
    'Limited', 10, 76, 9
  ),
  (
    11, 10, 2, 'Solar Fragment Study',
    '/artworks/solar-fragment-study.jpg', '/artworks/solar-fragment-study.jpg',
    1.48, 'Digital Painting', 'Edition of 15', 'Square', 'Orange', '60 x 60 cm', 2025,
    'A concentrated solar form fractured into layered heat, ritual marks and dark core geometry.',
    'Trending', 18, 70, 8
  ),
  (
    12, 7, 2, 'Velvet Signal Map',
    '/artworks/velvet-signal-map.jpg', '/artworks/velvet-signal-map.jpg',
    0.82, 'Signal Mapping', 'Edition of 30', 'Landscape', 'Purple', '70 x 50 cm', 2026,
    'A soft map of competing signals, shaped like weather patterns over an invisible network.',
    NULL, 32, 39, 2
  ),
  (
    13, 9, 2, 'Monolith Rain Index',
    '/artworks/monolith-rain-index.jpg', '/artworks/monolith-rain-index.jpg',
    1.26, 'Conceptual Digital', 'Edition of 20', 'Portrait', 'Black', '50 x 70 cm', 2025,
    'A severe monolith of falling data, indexed by cold lines and machine-readable traces.',
    NULL, 20, 51, 4
  ),
  (
    14, 8, 2, 'Opal Circuit Garden',
    '/artworks/opal-circuit-garden.jpg', '/artworks/opal-circuit-garden.jpg',
    1.05, 'Vector System', 'Edition of 24', 'Square', 'Green', '60 x 60 cm', 2026,
    'A garden of circuit paths where nodes bloom like synthetic opals in clean morning light.',
    'New', 26, 57, 5
  ),
  (
    15, 6, 2, 'Pixel Tide Window',
    '/artworks/pixel-tide-window.jpg', '/artworks/pixel-tide-window.jpg',
    0.68, 'Pixel Study', 'Edition of 40', 'Square', 'Blue', '45 x 45 cm', 2025,
    'A crisp pixel window where tide, colour and modular memory collapse into a small square.',
    NULL, 40, 34, 2
  ),
  (
    16, 10, 2, 'Ember Dream Ledger',
    '/artworks/ember-dream-ledger.jpg', '/artworks/ember-dream-ledger.jpg',
    1.98, 'Digital Painting', 'Edition of 10', 'Portrait', 'Orange', '50 x 70 cm', 2026,
    'A ledger of heat and ritual, recording a flame-like form against a dark computational ground.',
    'Limited', 12, 82, 10
  ),
  (
    17, 6, 2, 'Glass Orbit Machine',
    '/artworks/glass-orbit-machine.jpg', '/artworks/glass-orbit-machine.jpg',
    1.64, 'Orbital Diagram', 'Edition of 16', 'Square', 'White', '60 x 60 cm', 2025,
    'An elegant orbital machine drawn with translucent loops, glass logic and precise motion.',
    'Trending', 16, 74, 7
  ),
  (
    18, 7, 2, 'Spectral Harbor',
    '/artworks/spectral-harbor.jpg', '/artworks/spectral-harbor.jpg',
    1.22, 'Synthetic Landscape', 'Edition of 18', 'Landscape', 'Blue', '80 x 50 cm', 2026,
    'A spectral harbor with sail-like data structures floating between sea, code and horizon.',
    NULL, 22, 49, 3
  ),
  (
    19, 5, 2, 'Lattice of Soft Machines',
    '/artworks/lattice-of-soft-machines.jpg', '/artworks/lattice-of-soft-machines.jpg',
    0.96, 'Abstract Print', 'Edition of 35', 'Square', 'Mixed', '60 x 60 cm', 2025,
    'A warm lattice where machine parts become soft, decorative and almost botanical.',
    NULL, 35, 45, 3
  ),
  (
    20, 9, 2, 'Cosmic Receipt',
    '/artworks/cosmic-receipt.jpg', '/artworks/cosmic-receipt.jpg',
    1.34, 'Token Study', 'Edition of 20', 'Portrait', 'White', '50 x 70 cm', 2026,
    'A receipt-like token drifting through a small cosmos of transaction marks and distant dots.',
    'New', 20, 58, 6
  ),
  (
    21, 7, 2, 'Magenta Weather System',
    '/artworks/magenta-weather-system.jpg', '/artworks/magenta-weather-system.jpg',
    1.18, 'Data Weather', 'Edition of 22', 'Landscape', 'Purple', '80 x 50 cm', 2025,
    'A volatile weather system of magenta bands, cyan pressure lines and warm synthetic sun.',
    NULL, 24, 52, 4
  ),
  (
    22, 8, 2, 'Green Room for Algorithms',
    '/artworks/green-room-for-algorithms.jpg', '/artworks/green-room-for-algorithms.jpg',
    1.44, 'Digital Architecture', 'Edition of 14', 'Square', 'Green', '70 x 70 cm', 2026,
    'A green architectural room where algorithms gather around a dark computational core.',
    'Trending', 14, 69, 8
  ),
  (
    23, 10, 2, 'Amber Vector Field',
    '/artworks/amber-vector-field.jpg', '/artworks/amber-vector-field.jpg',
    0.74, 'Vector Field', 'Edition of 32', 'Landscape', 'Orange', '70 x 50 cm', 2025,
    'A clean amber field of directional vectors, warm intervals and measured digital force.',
    NULL, 32, 41, 2
  ),
  (
    24, 5, 2, 'Blackbox Orchid',
    '/artworks/blackbox-orchid.jpg', '/artworks/blackbox-orchid.jpg',
    2.10, 'Algorithmic Bloom', '1 / 1', 'Square', 'Purple', '70 x 70 cm', 2026,
    'A radiant orchid grown inside a blackbox system, luminous and mathematically restrained.',
    'Limited', 8, 86, 11
  ),
  (
    25, 6, 2, 'Ice Bound Token',
    '/artworks/ice-bound-token.jpg', '/artworks/ice-bound-token.jpg',
    1.08, 'Token Study', 'Edition of 28', 'Square', 'Blue', '60 x 60 cm', 2026,
    'A frozen token crystal, cut by clean axes and suspended in a pale protocol field.',
    'New', 28, 47, 4
  ),
  (
    26, 10, 2, 'Redshift City Scan',
    '/artworks/redshift-city-scan.jpg', '/artworks/redshift-city-scan.jpg',
    1.56, 'City Data Scan', 'Edition of 12', 'Landscape', 'Red', '80 x 50 cm', 2025,
    'A redshifted city profile scanned by heat, movement and horizontal streams of urban data.',
    'Trending', 12, 73, 9
  );

INSERT INTO artwork_tags (artwork_id, tag_id) VALUES
  (1, 1), (1, 2), (1, 3), (1, 4),
  (2, 5), (2, 6), (2, 7), (2, 8),
  (3, 5), (3, 6), (3, 9), (3, 10),
  (4, 11), (4, 12), (4, 13), (4, 14),
  (5, 15), (5, 16), (5, 17), (5, 3),
  (6, 15), (6, 18), (6, 19), (6, 20),
  (7, 21), (7, 23), (7, 24), (7, 29),
  (8, 15), (8, 16), (8, 30), (8, 24),
  (9, 22), (9, 26), (9, 29), (9, 27),
  (10, 31), (10, 23), (10, 25), (10, 29),
  (11, 24), (11, 27), (11, 29), (11, 28),
  (12, 26), (12, 32), (12, 22), (12, 29),
  (13, 11), (13, 25), (13, 26), (13, 28),
  (14, 23), (14, 30), (14, 31), (14, 24),
  (15, 13), (15, 25), (15, 28), (15, 27),
  (16, 24), (16, 28), (16, 27), (16, 29),
  (17, 23), (17, 25), (17, 30), (17, 24),
  (18, 22), (18, 24), (18, 26), (18, 32),
  (19, 27), (19, 31), (19, 23), (19, 29),
  (20, 28), (20, 11), (20, 25), (20, 26),
  (21, 32), (21, 26), (21, 22), (21, 29),
  (22, 30), (22, 23), (22, 25), (22, 31),
  (23, 27), (23, 26), (23, 29), (23, 24),
  (24, 31), (24, 25), (24, 21), (24, 29),
  (25, 28), (25, 23), (25, 25), (25, 24),
  (26, 32), (26, 22), (26, 26), (26, 30);

INSERT INTO artwork_sizes (artwork_id, size_id, price_override, is_available)
SELECT a.id, s.id, NULL, 1
FROM artworks a
CROSS JOIN sizes s;

INSERT INTO artwork_recommendations (artwork_id, recommended_artwork_id, score, reason) VALUES
  (1, 2, 0.9200, 'Historic crypto-art collectors also watch Xcopy'),
  (1, 5, 0.8600, 'Generative and AI art overlap'),
  (1, 6, 0.8300, 'Museum-scale digital work'),
  (1, 4, 0.7200, 'Blue-chip conceptual digital art'),
  (2, 3, 0.9000, 'Same artist and glitch-art market'),
  (2, 1, 0.7800, 'Historic NFT ownership debate'),
  (3, 2, 0.8400, 'Same Xcopy collector base'),
  (3, 4, 0.7600, 'Scarce conceptual market'),
  (5, 6, 0.8800, 'Refik Anadol AI installations'),
  (6, 5, 0.7400, 'AI data sculpture collector match'),
  (7, 10, 0.8200, 'Shared generative colour systems'),
  (7, 19, 0.7800, 'Grid-based abstract collector match'),
  (8, 22, 0.8500, 'Digital architecture and AI data sculpture overlap'),
  (8, 17, 0.7900, 'Precise machine geometry'),
  (9, 12, 0.8000, 'Synthetic landscape and signal mapping'),
  (9, 18, 0.7600, 'Atmospheric blue landscape pairing'),
  (10, 24, 0.8800, 'Algorithmic bloom collector path'),
  (10, 7, 0.7400, 'Neural colour and mirrored systems'),
  (11, 16, 0.8400, 'Warm digital painting collector match'),
  (11, 23, 0.7300, 'Amber vector and solar palette'),
  (12, 21, 0.8600, 'Weather system and signal field pairing'),
  (12, 9, 0.7200, 'Soft signal archive overlap'),
  (13, 20, 0.7900, 'Conceptual ledger and index works'),
  (13, 25, 0.7000, 'Token-oriented minimal systems'),
  (14, 22, 0.8300, 'Architectural circuit logic'),
  (14, 19, 0.7200, 'Soft machine lattice pairing'),
  (15, 25, 0.8000, 'Pixel and token minimalism'),
  (15, 4, 0.6900, 'Minimal digital art lineage'),
  (16, 11, 0.8400, 'Warm heat-field works'),
  (16, 20, 0.7400, 'Ledger and token narrative'),
  (17, 8, 0.7900, 'Machine diagram and data cathedral'),
  (17, 25, 0.7600, 'Precise blue-white token geometry'),
  (18, 9, 0.8100, 'Blue atmospheric landscape'),
  (18, 21, 0.7500, 'Weather and harbor systems'),
  (19, 14, 0.7700, 'Soft machine and circuit garden'),
  (19, 7, 0.7200, 'Grid and lattice language'),
  (20, 13, 0.8300, 'Conceptual index and receipt works'),
  (20, 25, 0.7400, 'Token study collector route'),
  (21, 12, 0.8600, 'Magenta weather and velvet signal'),
  (21, 18, 0.7300, 'Landscape weather pairing'),
  (22, 8, 0.8200, 'Digital architecture and cathedral structure'),
  (22, 14, 0.7900, 'Green computational spaces'),
  (23, 11, 0.7500, 'Amber palette continuity'),
  (23, 26, 0.7100, 'Vector field and city scan'),
  (24, 10, 0.8800, 'Algorithmic bloom pairing'),
  (24, 7, 0.7400, 'Neural color collector path'),
  (25, 15, 0.8100, 'Minimal token and pixel study'),
  (25, 17, 0.7600, 'Geometric machine clarity'),
  (26, 21, 0.8200, 'Redshift weather and data scans'),
  (26, 23, 0.7300, 'Urban vector rhythm');

INSERT INTO users (
  id, name, email, password_hash, display_name, initials, avatar_color, bio,
  is_paid, start_usd, start_btc, phone, role
) VALUES
  (
    1, 'demo', 'demo@example.com', NULL, 'Demo Trader', 'DT', '#E8552A',
    'New to crypto art trading. Starting with a balanced portfolio.',
    0, 10000.00, 0.50000000, '123456789', 'customer'
  ),
  (
    2, 'whale', 'whale@example.com', NULL, 'Whale Investor', 'WI', '#9945ff',
    'High-conviction NFT collector. Focus on blue-chip digital works.',
    1, 200000.00, 3.00000000, NULL, 'customer'
  ),
  (
    3, 'algo', 'algo@example.com', NULL, 'Algo Trader', 'AT', '#22c55e',
    'Fully automated. All positions managed by AI agents.',
    1, 50000.00, 1.20000000, NULL, 'customer'
  );

INSERT INTO orders (
  id, order_no, user_id, status, customer_name, customer_email, customer_phone,
  shipping_country, shipping_city, shipping_address_line1, shipping_address_line2,
  shipping_postal_code, payment_method, subtotal, shipping_fee, total, created_at
) VALUES
  (
    10001, 'AC202605170001', 1, 'pending', 'Demo Trader', 'demo@example.com', '123456789',
    'France', 'Paris', '1 Rue Example', NULL, '75001', 'card',
    16.90, 9.90, 26.80, '2026-05-17 12:00:00'
  );

INSERT INTO order_items (
  order_id, artwork_id, artwork_title, artwork_image_url, artist_name,
  size_name, quantity, unit_price, subtotal
) VALUES
  (
    10001, 1, 'Everydays: The First 5000 Days',
    'https://static.wixstatic.com/media/a64726_8b0e3cb2371c4d58ab569c6a5d521719~mv2.jpg/v1/fill/w_940,h_940,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/BEEPLE-EVERYDAYS_THE_FIRST_5000_DAYS_3k_.jpg',
    'Beeple (Mike Winkelmann)', 'A3 Print', 1, 16.90, 16.90
  );

INSERT INTO wishlist_items (user_id, artwork_id) VALUES
  (1, 1),
  (1, 5);

INSERT INTO user_wallets (user_id, usd_balance, btc_balance) VALUES
  (1, 10000.00, 0.50000000),
  (2, 200000.00, 3.00000000),
  (3, 50000.00, 1.20000000);

INSERT INTO wallet_connections (
  user_id, wallet_type, address, chain_id, balance_native, is_active
) VALUES
  (1, 'testwallet', '0xTest4rtEx00DemoAcc0unt', 'test-1337', 10.0000000000, 1);

INSERT INTO artwork_markets (
  artwork_id, total_shares, initial_share_price, current_share_price,
  volume_24h, change_24h_pct, is_tradable
) VALUES
  (1, 1000000, 6.90000000, 7.12000000, 128000.00, 3.1884, 1),
  (2, 1000000, 2.80000000, 2.73000000, 84200.00, -2.5000, 1),
  (3, 1000000, 1.92000000, 1.98000000, 39100.00, 3.1250, 1),
  (4, 1000000, 3.20000000, 3.11000000, 55200.00, -2.8125, 1),
  (5, 1000000, 1.40000000, 1.46000000, 47600.00, 4.2857, 1),
  (6, 1000000, 0.88000000, 0.91000000, 22000.00, 3.4091, 1),
  (7, 1000000, 1.15000000, 1.18000000, 18400.00, 2.6087, 1),
  (8, 1000000, 1.72000000, 1.76000000, 22600.00, 2.3256, 1),
  (9, 1000000, 0.94000000, 0.92000000, 9800.00, -2.1277, 1),
  (10, 1000000, 2.35000000, 2.43000000, 34200.00, 3.4043, 1),
  (11, 1000000, 1.48000000, 1.52000000, 20500.00, 2.7027, 1),
  (12, 1000000, 0.82000000, 0.80000000, 7600.00, -2.4390, 1),
  (13, 1000000, 1.26000000, 1.24000000, 11200.00, -1.5873, 1),
  (14, 1000000, 1.05000000, 1.09000000, 15100.00, 3.8095, 1),
  (15, 1000000, 0.68000000, 0.70000000, 6400.00, 2.9412, 1),
  (16, 1000000, 1.98000000, 2.04000000, 28900.00, 3.0303, 1),
  (17, 1000000, 1.64000000, 1.61000000, 19400.00, -1.8293, 1),
  (18, 1000000, 1.22000000, 1.25000000, 13700.00, 2.4590, 1),
  (19, 1000000, 0.96000000, 0.99000000, 8900.00, 3.1250, 1),
  (20, 1000000, 1.34000000, 1.31000000, 12100.00, -2.2388, 1),
  (21, 1000000, 1.18000000, 1.22000000, 15900.00, 3.3898, 1),
  (22, 1000000, 1.44000000, 1.50000000, 24800.00, 4.1667, 1),
  (23, 1000000, 0.74000000, 0.72000000, 7100.00, -2.7027, 1),
  (24, 1000000, 2.10000000, 2.19000000, 36500.00, 4.2857, 1),
  (25, 1000000, 1.08000000, 1.11000000, 11800.00, 2.7778, 1),
  (26, 1000000, 1.56000000, 1.62000000, 27300.00, 3.8462, 1);

INSERT INTO artwork_price_history (artwork_id, price, recorded_at) VALUES
  (1, 6.90000000, DATE_SUB(NOW(), INTERVAL 24 HOUR)),
  (1, 7.02000000, DATE_SUB(NOW(), INTERVAL 12 HOUR)),
  (1, 7.12000000, NOW()),
  (2, 2.80000000, DATE_SUB(NOW(), INTERVAL 24 HOUR)),
  (2, 2.76000000, DATE_SUB(NOW(), INTERVAL 12 HOUR)),
  (2, 2.73000000, NOW()),
  (3, 1.92000000, DATE_SUB(NOW(), INTERVAL 24 HOUR)),
  (3, 1.95000000, DATE_SUB(NOW(), INTERVAL 12 HOUR)),
  (3, 1.98000000, NOW());

INSERT INTO artwork_price_history (artwork_id, price, recorded_at)
SELECT artwork_id, initial_share_price, DATE_SUB(NOW(), INTERVAL 24 HOUR)
FROM artwork_markets
WHERE artwork_id BETWEEN 7 AND 26
UNION ALL
SELECT artwork_id, (initial_share_price + current_share_price) / 2, DATE_SUB(NOW(), INTERVAL 12 HOUR)
FROM artwork_markets
WHERE artwork_id BETWEEN 7 AND 26
UNION ALL
SELECT artwork_id, current_share_price, NOW()
FROM artwork_markets
WHERE artwork_id BETWEEN 7 AND 26;

INSERT INTO order_book_orders (
  artwork_id, user_id, side, order_type, price, size, remaining_size, status, is_vmm
) VALUES
  (1, NULL, 'bid', 'vmm', 7.09000000, 1200.000000, 1200.000000, 'open', 1),
  (1, NULL, 'bid', 'vmm', 7.07000000, 1800.000000, 1800.000000, 'open', 1),
  (1, NULL, 'ask', 'vmm', 7.15000000, 1300.000000, 1300.000000, 'open', 1),
  (1, NULL, 'ask', 'vmm', 7.18000000, 1900.000000, 1900.000000, 'open', 1),
  (2, NULL, 'bid', 'vmm', 2.71000000, 2100.000000, 2100.000000, 'open', 1),
  (2, NULL, 'ask', 'vmm', 2.75000000, 1800.000000, 1800.000000, 'open', 1);

INSERT INTO trade_executions (
  artwork_id, buyer_user_id, seller_user_id, side, price, size, notional, source, executed_at
) VALUES
  (1, 1, NULL, 'buy', 7.10000000, 70.000000, 497.00, 'spot', DATE_SUB(NOW(), INTERVAL 2 HOUR)),
  (1, NULL, 1, 'sell', 7.12000000, 20.000000, 142.40, 'spot', DATE_SUB(NOW(), INTERVAL 1 HOUR)),
  (2, 2, NULL, 'buy', 2.73000000, 1000.000000, 2730.00, 'spot', DATE_SUB(NOW(), INTERVAL 30 MINUTE));

INSERT INTO portfolio_share_holdings (user_id, artwork_id, quantity, avg_cost) VALUES
  (1, 1, 50.000000, 7.00000000),
  (1, 3, 120.000000, 1.93000000),
  (2, 1, 5000.000000, 6.80000000),
  (3, 5, 1500.000000, 1.42000000);

INSERT INTO perp_positions (
  id, user_id, artwork_id, side, notional, leverage, entry_price, margin_btc, status, opened_at
) VALUES
  (1, 1, 1, 'long', 1000.00, 10, 6.95000000, 0.00155000, 'open', DATE_SUB(NOW(), INTERVAL 3 HOUR));

INSERT INTO tpsl_orders (
  user_id, artwork_id, type, perp_position_id, tp_price, sl_price, quantity, status
) VALUES
  (1, 1, 'spot', NULL, 8.00000000, 6.50000000, 25.000000, 'active'),
  (1, 1, 'perp', 1, 7.80000000, 6.60000000, NULL, 'active');

INSERT INTO ai_agent_configs (
  user_id, artwork_id, enabled, strategy, max_usd, interval_sec
) VALUES
  (3, 1, 1, 'momentum', 500.00, 30),
  (3, 5, 1, 'mean_reversion', 300.00, 45);

INSERT INTO ai_monitor_configs (
  user_id, enabled, endpoint, interval_sec
) VALUES
  (3, 0, NULL, 60);

-- Query examples for backend implementation:
--
-- Artwork list:
-- SELECT a.id, a.title, ar.name AS artistName, a.image_url AS imageUrl,
--        a.price, a.medium, a.badge
-- FROM artworks a
-- JOIN artists ar ON ar.id = a.artist_id
-- LEFT JOIN categories c ON c.id = a.category_id
-- WHERE a.is_active = 1
-- ORDER BY a.sold_count DESC, a.view_count DESC;
--
-- Artwork detail with tags:
-- SELECT a.*, ar.name AS artistName, ar.country AS artistCountry,
--        c.name AS category
-- FROM artworks a
-- JOIN artists ar ON ar.id = a.artist_id
-- LEFT JOIN categories c ON c.id = a.category_id
-- WHERE a.id = ? AND a.is_active = 1;
--
-- Order number format suggestion:
-- AC + yyyyMMdd + 4 digit sequence, for example AC202605170001.

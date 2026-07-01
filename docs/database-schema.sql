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
  (20, 'Living Archive', 'living-archive');

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
    'https://upload.wikimedia.org/wikipedia/en/thumb/a/a7/Everydays--The_First_5000_Days.jpg/500px-Everydays--The_First_5000_Days.jpg',
    'https://upload.wikimedia.org/wikipedia/en/a/a7/Everydays--The_First_5000_Days.jpg',
    6.90, 'Digital', '1 / 1', 'Square', 'Mixed', '60 x 80 cm', 2021,
    'A 21,069 x 21,069 pixel collage of 5,000 individual digital works created daily from May 2007 to January 2021.',
    'Trending', 20, 130, 18
  ),
  (
    2, 2, 2, 'Right-click and Save As guy',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Right-Click_and_Save_as_Guy.gif/500px-Right-Click_and_Save_as_Guy.gif',
    'https://upload.wikimedia.org/wikipedia/commons/d/d6/Right-Click_and_Save_as_Guy.gif',
    2.80, 'Animated GIF', '1 / 1', 'Square', 'Purple', '50 x 50 cm', 2018,
    'Released in 2018, this animated GIF became one of the defining images of the NFT ownership debate.',
    'New', 15, 95, 9
  ),
  (
    3, 2, 2, 'A Coin for the Ferryman',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/A_Coin_for_the_Ferryman.gif/500px-A_Coin_for_the_Ferryman.gif',
    'https://upload.wikimedia.org/wikipedia/commons/a/a8/A_Coin_for_the_Ferryman.gif',
    1.92, 'Animated GIF', '1 / 1', 'Square', 'Blue', '70 x 50 cm', 2018,
    'A haunting meditation on mortality drawn from Greek mythology, rendered in fluorescent-on-void glitch loops.',
    NULL, 18, 78, 6
  ),
  (
    4, 3, 2, 'The Pixel',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Pakpixel.jpg/500px-Pakpixel.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/7/7e/Pakpixel.jpg',
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
  );

INSERT INTO artwork_tags (artwork_id, tag_id) VALUES
  (1, 1), (1, 2), (1, 3), (1, 4),
  (2, 5), (2, 6), (2, 7), (2, 8),
  (3, 5), (3, 6), (3, 9), (3, 10),
  (4, 11), (4, 12), (4, 13), (4, 14),
  (5, 15), (5, 16), (5, 17), (5, 3),
  (6, 15), (6, 18), (6, 19), (6, 20);

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
  (6, 5, 0.7400, 'AI data sculpture collector match');

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
  (6, 1000000, 0.88000000, 0.91000000, 22000.00, 3.4091, 1);

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

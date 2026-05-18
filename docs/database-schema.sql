-- ArtCanvas database schema
-- Target database: MySQL 8.0+
-- This script creates the tables needed by docs/interface-documentation.md.

CREATE DATABASE IF NOT EXISTS digital_art_paintings
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE digital_art_paintings;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS wishlist_items;
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
  price DECIMAL(10,2) NOT NULL,
  medium VARCHAR(120) NOT NULL,
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
  phone VARCHAR(40) NULL,
  role ENUM('customer', 'admin') NOT NULL DEFAULT 'customer',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
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

INSERT INTO categories (id, name, slug, sort_order) VALUES
  (1, 'Paintings', 'paintings', 10),
  (2, 'Digital Art', 'digital-art', 20),
  (3, 'Photography', 'photography', 30),
  (4, 'Prints', 'prints', 40);

INSERT INTO artists (id, name, country) VALUES
  (1, 'Sophie Laurent', 'France'),
  (2, 'Marco Chen', 'China'),
  (3, 'Amara Diallo', 'Senegal'),
  (4, 'Lena Kuznetsov', 'Russia'),
  (5, 'Jules Moreau', 'France'),
  (6, 'Yuki Tanaka', 'Japan');

INSERT INTO tags (id, name, slug) VALUES
  (1, 'abstract', 'abstract'),
  (2, 'colourful', 'colourful'),
  (3, 'expressive', 'expressive'),
  (4, 'geometric', 'geometric'),
  (5, 'blue', 'blue'),
  (6, 'nature', 'nature'),
  (7, 'limited', 'limited'),
  (8, 'minimal', 'minimal');

INSERT INTO sizes (id, name, price_delta, sort_order) VALUES
  (1, 'A4 Print', 0.00, 10),
  (2, 'A3 Print', 10.00, 20),
  (3, 'A2 Print', 25.00, 30),
  (4, '50x70 cm', 40.00, 40),
  (5, '60x80 cm', 55.00, 50);

INSERT INTO artworks (
  id, artist_id, category_id, title, image_url, price, medium,
  orientation, dominant_color, dimensions, year, description, badge,
  stock_quantity, view_count, sold_count
) VALUES
  (
    1, 1, 1, 'Abstract Harmony',
    'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=800',
    89.00, 'Acrylic on Canvas', 'Portrait', 'Red', '60 x 80 cm', 2024,
    'A vivid exploration of colour and emotion through layered brushwork.',
    'Trending', 20, 130, 18
  ),
  (
    2, 2, 2, 'Urban Geometry',
    'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=800',
    120.00, 'Digital', 'Square', 'Orange', '50 x 50 cm', 2024,
    'Sharp city forms arranged into a balanced digital composition.',
    'New', 15, 95, 9
  ),
  (
    3, 3, 1, 'Blue Silence',
    'https://images.unsplash.com/photo-1620503374956-c942862f0372?w=800',
    75.00, 'Oil', 'Landscape', 'Blue', '70 x 50 cm', 2023,
    'A quiet oil painting built around depth, shadow, and blue tones.',
    NULL, 18, 78, 6
  ),
  (
    4, 4, 3, 'Golden Hour',
    'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=800',
    99.00, 'Photograph', 'Landscape', 'Yellow', '50 x 70 cm', 2023,
    'Warm photographic study of light, surface, and atmosphere.',
    NULL, 12, 81, 7
  ),
  (
    5, 5, 1, 'Forest Dream',
    'https://images.unsplash.com/photo-1605721911519-3dfeb3be25e7?w=800',
    65.00, 'Watercolour', 'Portrait', 'Green', '40 x 60 cm', 2022,
    'Soft watercolour layers inspired by forests and memory.',
    'Trending', 25, 150, 21
  ),
  (
    6, 6, 1, 'Desert Wind',
    'https://images.unsplash.com/photo-1559762717-99c81ac85059?w=800',
    110.00, 'Ink', 'Landscape', 'Brown', '70 x 50 cm', 2024,
    'Ink movement study with dry texture and open desert space.',
    'Limited', 8, 68, 4
  );

INSERT INTO artwork_tags (artwork_id, tag_id) VALUES
  (1, 1), (1, 2), (1, 3),
  (2, 2), (2, 4),
  (3, 5), (3, 8),
  (4, 2), (4, 8),
  (5, 3), (5, 6),
  (6, 7), (6, 8);

INSERT INTO artwork_sizes (artwork_id, size_id, price_override, is_available)
SELECT a.id, s.id, NULL, 1
FROM artworks a
CROSS JOIN sizes s;

INSERT INTO artwork_recommendations (artwork_id, recommended_artwork_id, score, reason) VALUES
  (1, 2, 0.9200, 'Similar colour intensity'),
  (1, 3, 0.8600, 'Abstract painting interest'),
  (1, 5, 0.8300, 'Expressive brushwork'),
  (1, 4, 0.7200, 'Popular with similar buyers'),
  (2, 1, 0.9000, 'Strong visual composition'),
  (2, 4, 0.7800, 'Urban and geometric mood'),
  (3, 1, 0.8400, 'Painting collector match'),
  (3, 5, 0.7600, 'Soft colour palette'),
  (5, 1, 0.8800, 'Expressive painting match'),
  (5, 3, 0.7400, 'Quiet natural palette');

INSERT INTO users (id, name, email, phone, role) VALUES
  (1, 'Yinghui', 'yinghui@example.com', '123456789', 'customer');

INSERT INTO orders (
  id, order_no, user_id, status, customer_name, customer_email, customer_phone,
  shipping_country, shipping_city, shipping_address_line1, shipping_address_line2,
  shipping_postal_code, payment_method, subtotal, shipping_fee, total, created_at
) VALUES
  (
    10001, 'AC202605170001', 1, 'pending', 'Yinghui', 'yinghui@example.com', '123456789',
    'France', 'Paris', '1 Rue Example', NULL, '75001', 'card',
    89.00, 0.00, 89.00, '2026-05-17 12:00:00'
  );

INSERT INTO order_items (
  order_id, artwork_id, artwork_title, artwork_image_url, artist_name,
  size_name, quantity, unit_price, subtotal
) VALUES
  (
    10001, 1, 'Abstract Harmony',
    'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=800',
    'Sophie Laurent', 'A3 Print', 1, 89.00, 89.00
  );

INSERT INTO wishlist_items (user_id, artwork_id) VALUES
  (1, 1),
  (1, 5);

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

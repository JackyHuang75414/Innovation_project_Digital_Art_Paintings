-- ArtEx MySQL Setup Script
-- Run as: mysql -u root -p < setup_db.sql

CREATE DATABASE IF NOT EXISTS digital_art_paintings CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE digital_art_paintings;

-- ── Core tables ───────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS artists (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    country     VARCHAR(100),
    bio         TEXT,
    avatar_url  TEXT,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categories (
    id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    slug  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS sizes (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    price_delta DECIMAL(10,2) DEFAULT 0,
    sort_order  INT DEFAULT 0,
    created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tags (
    id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS artworks (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    artist_id       BIGINT NOT NULL,
    category_id     BIGINT,
    title           VARCHAR(255) NOT NULL,
    image_url       TEXT,
    price           DECIMAL(10,2) NOT NULL,
    medium          VARCHAR(100),
    orientation     VARCHAR(50),
    dominant_color  VARCHAR(50),
    dimensions      VARCHAR(100),
    year            INT,
    description     TEXT,
    badge           VARCHAR(50),
    stock_quantity  INT DEFAULT 1,
    view_count      INT DEFAULT 0,
    sold_count      INT DEFAULT 0,
    is_active       TINYINT(1) DEFAULT 1,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (artist_id)   REFERENCES artists(id),
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE IF NOT EXISTS artwork_tags (
    artwork_id BIGINT NOT NULL,
    tag_id     BIGINT NOT NULL,
    PRIMARY KEY (artwork_id, tag_id),
    FOREIGN KEY (artwork_id) REFERENCES artworks(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id)     REFERENCES tags(id)
);

CREATE TABLE IF NOT EXISTS artwork_sizes (
    artwork_id     BIGINT NOT NULL,
    size_id        BIGINT NOT NULL,
    price_override DECIMAL(10,2),
    is_available   TINYINT(1) DEFAULT 1,
    PRIMARY KEY (artwork_id, size_id),
    FOREIGN KEY (artwork_id) REFERENCES artworks(id) ON DELETE CASCADE,
    FOREIGN KEY (size_id)    REFERENCES sizes(id)
);

CREATE TABLE IF NOT EXISTS artwork_recommendations (
    artwork_id             BIGINT NOT NULL,
    recommended_artwork_id BIGINT NOT NULL,
    score                  DECIMAL(5,2) DEFAULT 1.0,
    PRIMARY KEY (artwork_id, recommended_artwork_id),
    FOREIGN KEY (artwork_id)             REFERENCES artworks(id) ON DELETE CASCADE,
    FOREIGN KEY (recommended_artwork_id) REFERENCES artworks(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS users (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL UNIQUE,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id                    BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_no              VARCHAR(50) NOT NULL UNIQUE,
    user_id               BIGINT,
    status                VARCHAR(50) DEFAULT 'pending',
    customer_name         VARCHAR(100),
    customer_email        VARCHAR(255),
    customer_phone        VARCHAR(50),
    shipping_country      VARCHAR(100),
    shipping_city         VARCHAR(100),
    shipping_address_line1 VARCHAR(255),
    shipping_address_line2 VARCHAR(255),
    shipping_postal_code  VARCHAR(20),
    payment_method        VARCHAR(50),
    subtotal              DECIMAL(10,2) DEFAULT 0,
    shipping_fee          DECIMAL(10,2) DEFAULT 0,
    total                 DECIMAL(10,2) DEFAULT 0,
    created_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id    BIGINT NOT NULL,
    artwork_id  BIGINT,
    title       VARCHAR(255),
    image_url   TEXT,
    artist_name VARCHAR(100),
    size        VARCHAR(100),
    quantity    INT DEFAULT 1,
    unit_price  DECIMAL(10,2),
    subtotal    DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS wishlists (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT NOT NULL,
    artwork_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_artwork (user_id, artwork_id),
    FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (artwork_id) REFERENCES artworks(id) ON DELETE CASCADE
);

-- ── Seed Data ─────────────────────────────────────────────────────────────────

INSERT IGNORE INTO categories (name, slug) VALUES
    ('Digital Art', 'digital-art'),
    ('Photography', 'photography'),
    ('Paintings', 'paintings'),
    ('NFT', 'nft'),
    ('Generative', 'generative');

INSERT IGNORE INTO sizes (name, price_delta, sort_order) VALUES
    ('A4 Print',   0,    1),
    ('A3 Print',   15,   2),
    ('A2 Print',   35,   3),
    ('50x70 cm',   55,   4),
    ('60x80 cm',   80,   5),
    ('Original',   500,  6);

INSERT IGNORE INTO tags (name) VALUES
    ('abstract'), ('generative'), ('NFT'), ('dark'), ('colorful'),
    ('minimalist'), ('digital'), ('3D'), ('pixel'), ('glitch'),
    ('landscape'), ('portrait'), ('crypto'), ('AI'), ('surreal');

INSERT IGNORE INTO artists (id, name, country, bio) VALUES
    (1, 'Beeple',         'USA',           'Mike Winkelmann, known as Beeple, is a digital artist who sold "Everydays: The First 5000 Days" for $69M at Christie''s in 2021.'),
    (2, 'Xcopy',          'UK',            'Anonymous crypto-native artist known for glitchy, dystopian digital works. One of the most collected NFT artists.'),
    (3, 'Pak',            'Anonymous',     'Anonymous digital artist and NFT pioneer, creator of "The Merge" which sold for $91.8M — the highest-grossing NFT ever.'),
    (4, 'Refik Anadol',   'Turkey/USA',    'Media artist and director working at the intersection of AI and architecture. Known for large-scale data sculptures.'),
    (5, 'Sofia Crespo',   'Argentina',     'Artist working with AI and natural sciences, exploring the relationship between technology and organic life.'),
    (6, 'Tyler Hobbs',    'USA',           'Generative artist known for Fidenza, one of the most celebrated Art Blocks projects.');

INSERT IGNORE INTO artworks (id, artist_id, category_id, title, image_url, price, medium, orientation, dominant_color, dimensions, year, description, badge, is_active) VALUES
    (1, 1, 4, 'Everydays: The First 5000 Days',
     'https://upload.wikimedia.org/wikipedia/en/4/4a/Everydays%2C_The_First_5000_Days.jpg',
     69000000, 'Digital', 'Square', 'Multi', '21069x21069 px', 2021,
     'A digital collage of 5,000 images created daily from May 1, 2007 to January 7, 2021. Sold at Christie''s for $69.3M.', 'Iconic', 1),
    (2, 2, 4, 'Right-click and Save As guy',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Xcopy_right_click_save_as_guy.gif/300px-Xcopy_right_click_save_as_guy.gif',
     1600, 'Digital Animation', 'Square', 'Dark', '1:1', 2018,
     'One of Xcopy''s most recognised works — a looping animation critiquing NFT skeptics who "right-click save" digital art.', 'Trending', 1),
    (3, 3, 4, 'The Merge',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Pak_-_The_Merge_%28mass_1%29.jpg/300px-Pak_-_The_Merge_%28mass_1%29.jpg',
     91800000, 'Digital', 'Square', 'Black', 'Variable', 2021,
     'A fractionalized NFT sold to 28,983 collectors for a total of $91.8M — the highest-grossing NFT and living artist sale ever recorded.', 'Record', 1),
    (4, 4, 5, 'Machine Hallucinations — Space',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Refik_Anadol_Machine_Hallucination_%E2%80%93_Space.jpg/300px-Refik_Anadol_Machine_Hallucination_%E2%80%93_Space.jpg',
     520000, 'AI Data Sculpture', 'Landscape', 'Blue', 'Variable', 2020,
     'A data sculpture generated from 62TB of public NASA imagery, processed by custom AI algorithms to create a living painting of space.', 'New', 1),
    (5, 5, 5, 'Neural Zoo',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/7/76/Sofia_Crespo_Neural_Zoo.jpg/300px-Sofia_Crespo_Neural_Zoo.jpg',
     8500, 'AI Generative', 'Portrait', 'Green', '4096x4096 px', 2019,
     'Exploring the intersection of AI and natural life — creatures that could exist if neural networks dreamed of evolution.', 'Trending', 1),
    (6, 6, 5, 'Fidenza #313',
     'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Fidenza_313_by_Tyler_Hobbs.jpg/300px-Fidenza_313_by_Tyler_Hobbs.jpg',
     235000, 'Generative Algorithm', 'Portrait', 'Multi', '3000x4500 px', 2021,
     'From the landmark Art Blocks Fidenza collection. Uses a flow-field algorithm to produce organic, painterly compositions.', 'Limited', 1);

-- Artwork tags
INSERT IGNORE INTO artwork_tags (artwork_id, tag_id) VALUES
    (1, 3),(1, 7),(1, 1),
    (2, 3),(2, 10),(2, 4),
    (3, 3),(3, 6),(3, 4),
    (4, 14),(4, 2),(4, 7),
    (5, 14),(5, 2),(5, 5),
    (6, 2),(6, 7),(6, 6);

-- Artwork sizes
INSERT IGNORE INTO artwork_sizes (artwork_id, size_id, is_available) VALUES
    (1,1,1),(1,2,1),(1,3,1),(1,4,1),(1,5,1),
    (2,1,1),(2,2,1),(2,3,1),
    (3,1,1),(3,2,1),(3,3,1),(3,4,1),(3,5,1),
    (4,1,1),(4,2,1),(4,3,1),(4,4,1),
    (5,1,1),(5,2,1),(5,3,1),
    (6,1,1),(6,2,1),(6,3,1),(6,4,1);

-- Cross recommendations
INSERT IGNORE INTO artwork_recommendations (artwork_id, recommended_artwork_id, score) VALUES
    (1,2,0.9),(1,3,0.85),(1,4,0.7),
    (2,1,0.9),(2,3,0.8),(2,6,0.75),
    (3,1,0.85),(3,2,0.8),(3,4,0.7),
    (4,5,0.95),(4,6,0.8),(4,1,0.65),
    (5,4,0.95),(5,6,0.85),(5,2,0.7),
    (6,5,0.85),(6,4,0.8),(6,1,0.6);

SELECT 'Database setup complete.' AS status;
SELECT COUNT(*) AS artwork_count FROM artworks;
SELECT COUNT(*) AS artist_count FROM artists;

-- Replace placeholder artworks with the 10 most expensive NFTs of 2021
-- Images served from /artworks/ (frontend/public/artworks/)
-- Run AFTER create_missing_tables.sql

USE digital_art_paintings;
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- ── 1. Add missing artists ────────────────────────────────────────────────────
-- Beeple (id=1), XCOPY (id=2) already exist from setup_db.sql
INSERT IGNORE INTO artists (id, name, country, bio) VALUES
  (3, 'freeross',       'USA',     'Ross Ulbricht, the founder of Silk Road, who is serving two life sentences. His NFT collection raised funds for his legal defense.'),
  (4, 'Edward Snowden', 'USA',     'NSA whistleblower and privacy activist. His NFT "Stay Free" sold for $5.4M with proceeds donated to the Freedom of the Press Foundation.'),
  (5, 'Mad Dog Jones',  'Canada',  'Michah Dowbak, a Canadian digital artist and musician known for sci-fi landscapes and generative NFT projects.'),
  (6, 'XCOPY',          'UK',      'Anonymous crypto-native artist known for glitchy, dystopian digital works. One of the most collected NFT artists.');

-- ── 2. Update existing artworks 1–6 ──────────────────────────────────────────
UPDATE artworks SET
  artist_id       = 1,
  category_id     = 4,
  title           = 'Everydays: The First 5000 Days',
  image_url       = '/artworks/artwork1.jpg',
  image_large_url = '/artworks/artwork1.jpg',
  price           = 69000000,
  medium          = 'Digital Collage',
  orientation     = 'Square',
  dominant_color  = 'Multi',
  dimensions      = '21069×21069 px',
  year            = 2021,
  description     = 'A digital collage of 5,000 images created daily over 13 years. Sold at Christie''s for $69.3M — the highest price ever achieved for a digital artwork at auction.',
  badge           = 'Record',
  is_active       = 1
WHERE id = 1;

UPDATE artworks SET
  artist_id       = 1,
  category_id     = 4,
  title           = 'HUMAN ONE',
  image_url       = '/artworks/artwork2.png',
  image_large_url = '/artworks/artwork2.png',
  price           = 29800000,
  medium          = 'Kinetic Video Sculpture',
  orientation     = 'Portrait',
  dominant_color  = 'Blue',
  dimensions      = '4 screens, 7ft tall',
  year            = 2021,
  description     = 'A 7-foot kinetic video sculpture with a continuously evolving digital human walking through landscapes. Sold at Christie''s for $29.8M alongside a unique NFT.',
  badge           = 'Iconic',
  is_active       = 1
WHERE id = 2;

UPDATE artworks SET
  artist_id       = 2,
  category_id     = 4,
  title           = 'Right-click and Save As guy',
  image_url       = '/artworks/artwork3.gif',
  image_large_url = '/artworks/artwork3.gif',
  price           = 7000000,
  medium          = 'Digital Animation',
  orientation     = 'Square',
  dominant_color  = 'Dark',
  dimensions      = '1:1',
  year            = 2018,
  description     = 'One of XCOPY''s most recognised works — a looping GIF critiquing NFT skeptics who "right-click save" digital art. Sold for $7M on SuperRare in December 2021.',
  badge           = 'Trending',
  is_active       = 1
WHERE id = 3;

UPDATE artworks SET
  artist_id       = 1,
  category_id     = 4,
  title           = 'Crossroads',
  image_url       = '/artworks/artwork4.png',
  image_large_url = '/artworks/artwork4.png',
  price           = 6600000,
  medium          = 'Digital',
  orientation     = 'Landscape',
  dominant_color  = 'Dark',
  dimensions      = 'Variable',
  year            = 2021,
  description     = 'A 10-second looping video that changes based on the result of the 2020 U.S. presidential election. Originally sold for $66,666 and resold on Nifty Gateway for $6.6M.',
  badge           = 'Limited',
  is_active       = 1
WHERE id = 4;

UPDATE artworks SET
  artist_id       = 1,
  category_id     = 4,
  title           = 'Ocean Front',
  image_url       = '/artworks/artwork5.jpg',
  image_large_url = '/artworks/artwork5.jpg',
  price           = 6000000,
  medium          = 'Digital',
  orientation     = 'Landscape',
  dominant_color  = 'Blue',
  dimensions      = 'Variable',
  year            = 2021,
  description     = 'A climate-change-focused digital artwork depicting an ocean-front structure. Sold for $6M on Nifty Gateway in March 2021, with proceeds going to Open Earth Foundation.',
  badge           = 'New',
  is_active       = 1
WHERE id = 5;

UPDATE artworks SET
  artist_id       = 2,
  category_id     = 4,
  title           = 'A Coin for the Ferryman',
  image_url       = '/artworks/artwork6.gif',
  image_large_url = '/artworks/artwork6.gif',
  price           = 6000000,
  medium          = 'Digital Animation',
  orientation     = 'Square',
  dominant_color  = 'Dark',
  dimensions      = '1:1',
  year            = 2021,
  description     = 'A glitchy animated GIF referencing the mythological ferryman Charon. Sold for $6M on SuperRare in November 2021, making XCOPY the highest-selling NFT artist at the time.',
  badge           = 'Trending',
  is_active       = 1
WHERE id = 6;

-- ── 3. Insert artworks 7–10 (new rows) ───────────────────────────────────────
INSERT IGNORE INTO artworks
  (id, artist_id, category_id, title, image_url, image_large_url, price, medium, orientation, dominant_color, dimensions, year, description, badge, is_active)
VALUES
  (7, 3, 4, 'Ross Ulbricht Genesis Collection',
   '/artworks/artwork7.png', '/artworks/artwork7.png',
   5930000, 'Digital', 'Landscape', 'Multi', 'Variable', 2021,
   'A collection of artworks made by Ross Ulbricht while incarcerated. Sold on SuperRare in December 2021 for $5.93M, with 100% of proceeds going to his legal defense fund.',
   'Limited', 1),
  (8, 4, 4, 'Stay Free (Edward Snowden)',
   '/artworks/artwork8.png', '/artworks/artwork8.png',
   5400000, 'Digital Collage', 'Portrait', 'Dark', 'Variable', 2021,
   'A portrait of Edward Snowden composed of pages from the court decision that found NSA surveillance unconstitutional. Sold for $5.4M on Foundation; proceeds to Freedom of the Press Foundation.',
   'New', 1),
  (9, 5, 4, 'Replicator',
   '/artworks/artwork9.jpg', '/artworks/artwork9.jpg',
   4100000, 'Generative Digital', 'Landscape', 'Teal', 'Variable', 2021,
   'A generative NFT that replicates itself over 28 months, producing seven "generations" of derivative tokens. Sold at Phillips in April 2021 for $4.1M — the first NFT sale at a major auction house.',
   'Trending', 1),
  (10, 2, 4, 'Some Asshole',
   '/artworks/artwork10.gif', '/artworks/artwork10.gif',
   3800000, 'Digital Animation', 'Square', 'Dark', '1:1', 2021,
   'An animated GIF portrait by XCOPY depicting a skull-like figure. Sold on SuperRare for $3.8M in September 2021.',
   'New', 1);

-- ── 4. Add artwork_markets entries for artworks 7–10 ─────────────────────────
-- Share prices are scaled for demo trading (not actual sale prices)
INSERT IGNORE INTO artwork_markets (artwork_id, current_share_price, initial_share_price, is_tradable) VALUES
  (7, 5.93, 5.93, 1),
  (8, 5.40, 5.40, 1),
  (9, 4.10, 4.10, 1),
  (10, 3.80, 3.80, 1);

-- ── 5. Add artwork_tags for new artworks ─────────────────────────────────────
-- tag IDs: 3=NFT, 4=dark, 7=digital, 10=glitch, 14=AI, 2=generative
INSERT IGNORE INTO artwork_tags (artwork_id, tag_id) VALUES
  (7, 3),(7, 7),(7, 1),
  (8, 3),(8, 7),(8, 4),
  (9, 2),(9, 3),(9, 7),
  (10, 3),(10, 10),(10, 4);

-- ── 6. Add artwork_recommendations for new artworks ──────────────────────────
INSERT IGNORE INTO artwork_recommendations (artwork_id, recommended_artwork_id, score) VALUES
  (7, 8, 0.85),(7, 9, 0.75),(7, 10, 0.70),
  (8, 7, 0.85),(8, 3, 0.80),(8, 10, 0.70),
  (9, 5, 0.80),(9, 8, 0.75),(9, 1, 0.65),
  (10, 3, 0.95),(10, 6, 0.90),(10, 2, 0.75);

SET SQL_SAFE_UPDATES = 1;
SET FOREIGN_KEY_CHECKS = 1;

-- Verify
SELECT id, title, SUBSTRING(image_url, 1, 30) AS img, price FROM artworks WHERE id <= 10 ORDER BY id;
SELECT COUNT(*) AS market_rows FROM artwork_markets;

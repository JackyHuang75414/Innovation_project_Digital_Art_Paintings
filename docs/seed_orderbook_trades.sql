-- Seed VMM order book + recent trade history for demo
-- Run ONCE in MySQL before/after starting the backend.
-- After this, VmmService will keep the order book live on every 2s tick.

USE digital_art_paintings;

-- Disable safe-update mode so DELETE without PK in WHERE works
SET SQL_SAFE_UPDATES = 0;

-- ────────────────────────────────────────────────────────────
-- 1. CLEAR existing VMM orders (if any)
-- ────────────────────────────────────────────────────────────
DELETE FROM order_book_orders WHERE is_vmm = 1;
-- Remove any stale VMM trades for a clean demo
DELETE FROM trade_executions WHERE source = 'vmm';

-- ────────────────────────────────────────────────────────────
-- 2. VMM ORDER BOOK  (6 bid + 6 ask levels per artwork)
--    Prices taken from current artwork_markets.current_share_price
-- ────────────────────────────────────────────────────────────
INSERT INTO order_book_orders
  (artwork_id, user_id, side, price, size, remaining_size, status, is_vmm)
SELECT
  m.artwork_id,
  NULL,
  lv.side,
  ROUND(m.current_share_price * lv.factor, 8),
  lv.sz,
  lv.sz,
  'open',
  1
FROM artwork_markets m
JOIN (
  -- ask levels (above mid)
  SELECT 'ask' AS side, 1.0015 AS factor, 1200 AS sz UNION ALL
  SELECT 'ask', 1.0035, 900  UNION ALL
  SELECT 'ask', 1.0060, 650  UNION ALL
  SELECT 'ask', 1.0095, 480  UNION ALL
  SELECT 'ask', 1.0140, 320  UNION ALL
  SELECT 'ask', 1.0200, 200  UNION ALL
  -- bid levels (below mid)
  SELECT 'bid', 0.9985, 1100 UNION ALL
  SELECT 'bid', 0.9965, 850  UNION ALL
  SELECT 'bid', 0.9940, 600  UNION ALL
  SELECT 'bid', 0.9905, 430  UNION ALL
  SELECT 'bid', 0.9860, 280  UNION ALL
  SELECT 'bid', 0.9800, 180
) lv ON 1=1
WHERE m.is_tradable = 1;

-- ────────────────────────────────────────────────────────────
-- 3. RECENT TRADES  (~15 trades per artwork over last 2 hours)
-- ────────────────────────────────────────────────────────────
INSERT INTO trade_executions
  (artwork_id, buyer_user_id, seller_user_id, side, price, size, notional, source, executed_at)
SELECT
  m.artwork_id,
  NULL, NULL,
  tr.side,
  ROUND(m.current_share_price * tr.pct, 8),
  tr.sz,
  ROUND(m.current_share_price * tr.pct * tr.sz, 4),
  'vmm',
  DATE_SUB(NOW(), INTERVAL tr.mins MINUTE)
FROM artwork_markets m
JOIN (
  SELECT 'buy'  AS side, 0.9988 AS pct, 320  AS sz, 118 AS mins UNION ALL
  SELECT 'sell', 1.0012, 185,  107 UNION ALL
  SELECT 'buy',  0.9995, 560,   95 UNION ALL
  SELECT 'sell', 1.0008, 240,   83 UNION ALL
  SELECT 'buy',  1.0002, 410,   74 UNION ALL
  SELECT 'sell', 0.9991, 300,   66 UNION ALL
  SELECT 'buy',  1.0015, 220,   57 UNION ALL
  SELECT 'sell', 0.9978, 480,   48 UNION ALL
  SELECT 'buy',  0.9993, 155,   39 UNION ALL
  SELECT 'sell', 1.0021, 390,   31 UNION ALL
  SELECT 'buy',  1.0005, 270,   22 UNION ALL
  SELECT 'sell', 0.9983, 340,   14 UNION ALL
  SELECT 'buy',  0.9997, 190,    7 UNION ALL
  SELECT 'sell', 1.0009, 420,    3 UNION ALL
  SELECT 'buy',  1.0001, 250,    1
) tr ON 1=1
WHERE m.is_tradable = 1;

-- ────────────────────────────────────────────────────────────
-- 4. FIX IMAGE URLS — use reliable picsum.photos for all artworks
--    (Wikipedia CDN blocks hotlinks from localhost in some browsers)
-- ────────────────────────────────────────────────────────────
UPDATE artworks SET
  image_url       = 'https://picsum.photos/seed/beeple/600/600',
  image_large_url = 'https://picsum.photos/seed/beeple/1200/1200'
WHERE id = 1;

UPDATE artworks SET
  image_url       = 'https://picsum.photos/seed/xcopy/600/600',
  image_large_url = 'https://picsum.photos/seed/xcopy/1200/1200'
WHERE id = 2;

UPDATE artworks SET
  image_url       = 'https://picsum.photos/seed/pak/600/600',
  image_large_url = 'https://picsum.photos/seed/pak/1200/1200'
WHERE id = 3;

UPDATE artworks SET
  image_url       = 'https://picsum.photos/seed/anadol/600/600',
  image_large_url = 'https://picsum.photos/seed/anadol/1200/1200'
WHERE id = 4;

UPDATE artworks SET
  image_url       = 'https://picsum.photos/seed/crespo/600/600',
  image_large_url = 'https://picsum.photos/seed/crespo/1200/1200'
WHERE id = 5;

UPDATE artworks SET
  image_url       = 'https://picsum.photos/seed/hobbs/600/600',
  image_large_url = 'https://picsum.photos/seed/hobbs/1200/1200'
WHERE id = 6;

-- Restore safe-update mode
SET SQL_SAFE_UPDATES = 1;

-- Verify — expected: order_book_orders=72, trade_executions=90, artwork_markets=6
SELECT 'order_book_orders' AS tbl, COUNT(*) AS cnt FROM order_book_orders
UNION ALL
SELECT 'trade_executions', COUNT(*) FROM trade_executions
UNION ALL
SELECT 'artwork_markets',  COUNT(*) FROM artwork_markets;

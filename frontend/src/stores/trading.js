import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const TOTAL_SHARES = 1_000_000
export const MAINTENANCE_RATE = 0.005  // 0.5% maintenance margin

// ─── All images from Wikimedia Commons — free for educational use ─────────────
export const ARTWORKS = [
  {
    id: 1, initPrice: 6.90,
    title: 'Everydays: The First 5000 Days',
    artist: 'Beeple (Mike Winkelmann)',
    imageUrl: 'https://static.wixstatic.com/media/a64726_8b0e3cb2371c4d58ab569c6a5d521719~mv2.jpg/v1/fill/w_940,h_940,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/BEEPLE-EVERYDAYS_THE_FIRST_5000_DAYS_3k_.jpg',
    imageLarge: 'https://static.wixstatic.com/media/a64726_8b0e3cb2371c4d58ab569c6a5d521719~mv2.jpg/v1/fill/w_3000,h_3000,al_c,q_90,enc_avif,quality_auto/BEEPLE-EVERYDAYS_THE_FIRST_5000_DAYS_3k_.jpg',
    artistBio: 'Mike Winkelmann, known as Beeple, is a graphic designer from Charleston, SC. His Everydays project — one artwork created daily without exception since May 2007 — culminated in a Christie\'s auction that shattered records. He is now among the three most valuable living artists.',
    description: 'A 21,069 × 21,069 pixel collage of 5,000 individual digital works created daily from May 2007 to January 2021. The mosaic catalogs 13 years of artistic evolution — from twisted pop-culture caricatures to breathtaking sci-fi landscapes. Sold at Christie\'s for $69.3 million in March 2021, the highest price ever achieved by a purely digital work and the first NFT offered by a major auction house.',
    tags: ['Digital Collage', 'Generative', 'Historic NFT', '5000 Days'],
    year: 2021, medium: 'Digital', edition: '1 / 1',
  },
  {
    id: 2, initPrice: 2.80,
    title: 'Right-click and Save As guy',
    artist: 'Xcopy',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Right-Click_and_Save_as_Guy.gif/500px-Right-Click_and_Save_as_Guy.gif',
    imageLarge: 'https://raw2.seadn.io/ethereum/0x41a322b28d0ff354040e2cbc676f0320d8c8850d/92579d4e11c5125592c530d21d721e/fb92579d4e11c5125592c530d21d721e.gif',
    artistBio: 'Xcopy is an anonymous London-based digital artist (born 1981) and a founding figure of the NFT glitch-art movement. An early SuperRare adopter from 2018, their macabre looping animations explore death, apathy and the existential fragility of digital existence. All works dedicated to the public domain (CC0) since 2022.',
    description: 'Released December 2018, this sardonic animated GIF became one of the defining images of the NFT ownership debate. A glitched, flickering skull-face embodies the sceptic who dismisses digital ownership by simply right-clicking to save. The 1/1 edition sold for 1,600 ETH (≈ $7 million) in December 2021, validating through market force the very concept it mockingly portrays.',
    tags: ['Glitch Art', 'Animated GIF', 'Dark Punk', 'CC0'],
    year: 2018, medium: 'Animated GIF', edition: '1 / 1',
  },
  {
    id: 3, initPrice: 1.92,
    title: 'A Coin for the Ferryman',
    artist: 'Xcopy',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/A_Coin_for_the_Ferryman.gif/500px-A_Coin_for_the_Ferryman.gif',
    imageLarge: 'https://raw2.seadn.io/ethereum/0x41a322b28d0ff354040e2cbc676f0320d8c8850d/c66ed71e3786537324770103976fa5/99c66ed71e3786537324770103976fa5.gif',
    artistBio: 'Xcopy is an anonymous London-based digital artist who pioneered glitch aesthetics in the crypto-art space. Their work, rooted in early internet visual culture, strips human experience to its most primal anxieties. Consistently ranked among the highest-selling NFT artists, with cumulative sales exceeding $70 million.',
    description: 'A haunting meditation on mortality drawn from Greek mythology: an obol placed on the eyes of the deceased to pay Charon\'s toll across the river Styx. Xcopy renders this ancient rite in their signature fluorescent-on-void palette — a coin perpetually spinning in rhythmic, glitch-distorted loops. Minted in 2018, the work predates the NFT boom and carries the full weight of early crypto-art history.',
    tags: ['Glitch Art', 'Mythology', 'Death', 'Animated GIF'],
    year: 2018, medium: 'Animated GIF', edition: '1 / 1',
  },
  {
    id: 4, initPrice: 3.20,
    title: 'The Pixel',
    artist: 'Pak',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Pakpixel.jpg/500px-Pakpixel.jpg',
    imageLarge: 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Pakpixel.jpg',
    artistBio: 'Pak is a mysterious, anonymous digital artist or collective with over 20 years of practise. True identity undisclosed. Creator of AI curation system Archillect (2014) and architect of the $91.8M "Merge" sale on Nifty Gateway. Pak\'s work champions conceptual minimalism, algorithmic scarcity and the metaphysics of digital ownership.',
    description: 'A single pixel sold at Sotheby\'s in 2021 for $1.36 million — the ultimate reduction of art to its indivisible atomic unit. "The Pixel" is Pak\'s definitive assertion that value is entirely conceptual: if the market believes, even one pixel holds immeasurable worth. The work dissolves every assumption about what constitutes art, ownership and collectability in the digital age.',
    tags: ['Minimalist', 'Conceptual', 'Single Pixel', 'Sotheby\'s'],
    year: 2021, medium: 'Digital (1 × 1 px)', edition: '1 / 1',
  },
  {
    id: 5, initPrice: 1.40,
    title: 'Machine Hallucinations: NYC',
    artist: 'Refik Anadol',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Machine_Hallucinations-Artechouse_NYC_by_Refik_Anadol.jpg/500px-Machine_Hallucinations-Artechouse_NYC_by_Refik_Anadol.jpg',
    imageLarge: 'https://upload.wikimedia.org/wikipedia/commons/d/d9/Machine_Hallucinations-Artechouse_NYC_by_Refik_Anadol.jpg',
    artistBio: 'Refik Anadol (born 1985, Istanbul) is a media artist and director whose practice exists at the intersection of AI research and architecture. His data sculptures have been permanently acquired by MoMA, exhibited at the Serpentine Gallery and the Venice Biennale, and projected on landmarks from the Sydney Opera House to the Walt Disney Concert Hall.',
    description: 'An immersive data sculpture trained on over 113 million publicly accessible photographs of New York City. Neural networks process decades of urban visual memory and recombine them into liquid, ceaselessly shifting dream-states of colour and form. Exhibited at Artechouse NYC in 2019, the work poses the question: what does a city look like when machine intelligence hallucinates it back into existence?',
    tags: ['AI Art', 'Data Sculpture', 'Generative', 'Immersive'],
    year: 2019, medium: 'AI Data Sculpture', edition: '1 / 1',
  },
  {
    id: 6, initPrice: 0.88,
    title: 'Unsupervised',
    artist: 'Refik Anadol',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Unsupervised_by_Refik_Anadol.jpg/500px-Unsupervised_by_Refik_Anadol.jpg',
    imageLarge: 'https://upload.wikimedia.org/wikipedia/commons/7/7f/Unsupervised_by_Refik_Anadol.jpg',
    artistBio: 'Refik Anadol is a Turkish-American media artist whose studio processes massive public datasets — urban infrastructure, natural systems, astronomical archives — to produce living data installations. In 2023, MoMA acquired Unsupervised into its permanent collection, marking the first AI artwork to enter the museum\'s holdings.',
    description: 'Installed in MoMA\'s ground-floor lobby from November 2022 to March 2023, Unsupervised fed the museum\'s entire public collection — over 200 years of art history — into a machine learning model that dreamed its own interpretation of the canon in real-time. Visitors watched the AI invent, dissolve and reinvent art history moment by moment. First AI artwork to enter MoMA\'s permanent collection.',
    tags: ['AI Art', 'MoMA', 'Machine Learning', 'Living Archive'],
    year: 2022, medium: 'AI Living Archive', edition: '1 / 1',
  },
]

const FAKE_TRADERS = [
  '0x7f3a…d2e1', '0xb41c…8fa9', '0x3d77…cc12', '0xa29b…0fe5',
  'ArtBull_42', 'Collector_88', 'DeepVal_9', 'NFT_Ghost', 'WhaleTrade', 'QuietBid',
]

// ── Math helpers ──────────────────────────────────────────────────────────────

function boxMuller() {
  let u, v
  do { u = Math.random() } while (!u)
  do { v = Math.random() } while (!v)
  return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * v)
}

function randUser() {
  return FAKE_TRADERS[Math.floor(Math.random() * FAKE_TRADERS.length)]
}

// ── Simulation helpers ────────────────────────────────────────────────────────

function genHistory(p0, n = 120) {
  const pts = []
  let p = p0 * (0.65 + Math.random() * 0.25)
  const now = Date.now()
  for (let i = n; i >= 0; i--) {
    p = Math.max(1e-4, p * Math.exp((6e-5 - 0.5 * 8e-3 ** 2) + 8e-3 * boxMuller()))
    pts.push({ t: now - i * 30_000, p })
  }
  return pts
}

function buildBook(price) {
  const S = 0.003
  const bids = []
  const asks = []
  for (let i = 1; i <= 10; i++) {
    bids.push({ price: price * (1 - S * i - Math.random() * 4e-4), size: Math.floor(500 + Math.random() * 3000), user: 'VMM', isVmm: true })
    asks.push({ price: price * (1 + S * i + Math.random() * 4e-4), size: Math.floor(500 + Math.random() * 3000), user: 'VMM', isVmm: true })
  }
  const n = 3 + Math.floor(Math.random() * 3)
  for (let i = 0; i < n; i++) {
    const lvl = Math.floor(Math.random() * 10)
    const u = randUser()
    const sz = Math.floor(100 + Math.random() * 600)
    if (Math.random() < 0.5) bids.push({ price: price * (1 - S * (lvl + 0.6)), size: sz, user: u, isVmm: false })
    else asks.push({ price: price * (1 + S * (lvl + 0.6)), size: sz, user: u, isVmm: false })
  }
  return {
    bids: bids.sort((a, b) => b.price - a.price).slice(0, 12),
    asks: asks.sort((a, b) => a.price - b.price).slice(0, 12),
  }
}

// ── Store ─────────────────────────────────────────────────────────────────────

export const useTradingStore = defineStore('trading', () => {
  const prices   = ref({})   // artworkId -> USD per share
  const books    = ref({})   // artworkId -> { bids, asks }
  const feeds    = ref({})   // artworkId -> recent trades[]
  const history  = ref({})   // artworkId -> { t, p }[]
  const btcPrice = ref(64_800)

  const wallet = ref({
    usd:  10_000,
    btc:  0.5,
    shares: {},           // artworkId -> qty (float)
    perpPositions: [],    // see openPerp for shape
    tpslOrders: [],       // take-profit / stop-loss orders
    orderHistory: [],     // executed TP/SL log
  })

  const aiAgents = ref({}) // artworkId -> AI trading agent config

  // ── AI Account Monitor (小龍蝦接口) ───────────────────────────────────────────
  const aiMonitor = ref({
    enabled:     false,
    endpoint:    '',
    apiKey:      '',
    intervalSec: 60,
    lastRun:     null,
    actionLog:   [],     // [{ time, actions, error }]
  })

  let _vmm = null
  let _btc = null
  let _monitor = null
  const _ai = {}

  // ── Init / destroy ──────────────────────────────────────────────────────────

  function init() {
    if (_vmm) return  // already running
    ARTWORKS.forEach(art => {
      const p = art.initPrice * (0.88 + Math.random() * 0.24)
      prices.value[art.id]  = p
      books.value[art.id]   = buildBook(p)
      history.value[art.id] = genHistory(art.initPrice)
      feeds.value[art.id]   = []
    })
    _vmm = setInterval(_vmmTick, 2000)
    _btc = setInterval(_btcTick, 3000)
  }

  function destroy() {
    clearInterval(_vmm); _vmm = null
    clearInterval(_btc); _btc = null
    clearInterval(_monitor); _monitor = null
    Object.values(_ai).forEach(clearInterval)
  }

  // ── VMM tick (Geometric Brownian Motion) ────────────────────────────────────

  function _vmmTick() {
    ARTWORKS.forEach(art => {
      const p = prices.value[art.id]
      // GBM: dS = μS dt + σS dW  (discrete)
      const newP = Math.max(1e-4, p * Math.exp((6e-5 - 0.5 * 8e-3 ** 2) + 8e-3 * boxMuller()))
      prices.value[art.id] = newP

      const h = history.value[art.id]
      h.push({ t: Date.now(), p: newP })
      if (h.length > 200) h.shift()

      books.value[art.id] = buildBook(newP)

      if (Math.random() < 0.65) {
        const side = Math.random() < 0.52 ? 'buy' : 'sell'
        const feed = feeds.value[art.id]
        feed.unshift({
          id: Math.random().toString(36).slice(2),
          price: newP * (1 + (Math.random() - 0.5) * 0.001),
          size:  Math.floor(50 + Math.random() * 400),
          side,
          user:  Math.random() < 0.55 ? 'VMM' : randUser(),
          time:  Date.now(),
        })
        if (feed.length > 60) feed.pop()
      }
    })
    _checkLiquidations()
    _checkTpSl()
  }

  function _btcTick() {
    btcPrice.value = Math.max(100, btcPrice.value * Math.exp((1e-4 - 0.5 * 0.015 ** 2) + 0.015 * boxMuller()))
  }

  // ── Spot trading ─────────────────────────────────────────────────────────────

  function buyShares(artworkId, usdAmount) {
    const p = prices.value[artworkId]
    if (!p) return { ok: false, msg: 'Market not initialised' }
    if (wallet.value.usd < usdAmount) return { ok: false, msg: 'Insufficient USD balance' }
    const shares = usdAmount / p
    wallet.value.usd -= usdAmount
    wallet.value.shares[artworkId] = (wallet.value.shares[artworkId] || 0) + shares
    return { ok: true, shares, price: p }
  }

  function sellShares(artworkId, shares) {
    const held = wallet.value.shares[artworkId] || 0
    if (shares > held + 1e-9) return { ok: false, msg: 'Insufficient shares' }
    const p = prices.value[artworkId]
    const proceeds = shares * p
    wallet.value.shares[artworkId] = Math.max(0, held - shares)
    wallet.value.usd += proceeds
    return { ok: true, proceeds, price: p }
  }

  // ── Perpetual futures ─────────────────────────────────────────────────────────

  function openPerp(artworkId, side, leverage, marginBtc) {
    if (wallet.value.btc < marginBtc) return { ok: false, msg: 'Insufficient BTC collateral' }
    const notional = marginBtc * btcPrice.value * leverage
    const entryPrice = prices.value[artworkId]
    wallet.value.btc -= marginBtc
    const pos = {
      id: Math.random().toString(36).slice(2),
      artworkId, side, notional, leverage, entryPrice, marginBtc,
      openTime: Date.now(),
    }
    wallet.value.perpPositions.push(pos)
    return { ok: true, pos }
  }

  function closePerp(posId) {
    const idx = wallet.value.perpPositions.findIndex(p => p.id === posId)
    if (idx === -1) return { ok: false, msg: 'Position not found' }
    const pos = wallet.value.perpPositions[idx]
    const pnlUsd = calcPnl(pos, prices.value[pos.artworkId])
    // Return margin ± PnL converted back to BTC at current BTC price
    const returnBtc = pos.marginBtc + pnlUsd / btcPrice.value
    wallet.value.btc += Math.max(0, returnBtc)
    wallet.value.perpPositions.splice(idx, 1)
    return { ok: true, pnlUsd }
  }

  function calcPnl(pos, currentPrice) {
    const dir = pos.side === 'long' ? 1 : -1
    return dir * ((currentPrice - pos.entryPrice) / pos.entryPrice) * pos.notional
  }

  function liqPrice(pos) {
    // For long:  liq = entry × (1 - (1/leverage - MAINTENANCE_RATE))
    // For short: liq = entry × (1 + (1/leverage - MAINTENANCE_RATE))
    const dir = pos.side === 'long' ? -1 : 1
    return pos.entryPrice * (1 + dir * (1 / pos.leverage - MAINTENANCE_RATE))
  }

  function _checkLiquidations() {
    const toRemove = []
    wallet.value.perpPositions.forEach(pos => {
      const cp = prices.value[pos.artworkId]
      const pnlUsd = calcPnl(pos, cp)
      // Collateral value changes with BTC price
      const equityUsd = pos.marginBtc * btcPrice.value + pnlUsd
      if (equityUsd / pos.notional <= MAINTENANCE_RATE) toRemove.push(pos.id)
    })
    toRemove.forEach(id => {
      const idx = wallet.value.perpPositions.findIndex(p => p.id === id)
      if (idx !== -1) wallet.value.perpPositions.splice(idx, 1)
    })
  }

  // ── TP/SL orders ─────────────────────────────────────────────────────────────

  function setTpSl({ artworkId, type = 'spot', posId = null, tpPrice = null, slPrice = null, qty = null }) {
    // Remove any existing order for this artwork/position
    wallet.value.tpslOrders = wallet.value.tpslOrders.filter(o =>
      type === 'perp' ? o.posId !== posId : o.artworkId !== artworkId || o.type !== 'spot'
    )
    if (!tpPrice && !slPrice) return  // removing only
    wallet.value.tpslOrders.push({
      id: Math.random().toString(36).slice(2),
      artworkId, type, posId,
      tpPrice, slPrice,
      qty,   // for spot: shares to sell; null = sell all
      status: 'active',
      createdAt: Date.now(),
    })
  }

  function cancelTpSl(orderId) {
    wallet.value.tpslOrders = wallet.value.tpslOrders.filter(o => o.id !== orderId)
  }

  function _checkTpSl() {
    const triggered = []
    wallet.value.tpslOrders.forEach(order => {
      if (order.status !== 'active') return
      const cp = prices.value[order.artworkId]
      if (!cp) return

      if (order.type === 'spot') {
        const held = wallet.value.shares[order.artworkId] || 0
        if (!held) return
        const sellQty = order.qty ?? held

        if (order.tpPrice && cp >= order.tpPrice) {
          sellShares(order.artworkId, Math.min(sellQty, held))
          triggered.push({ ...order, triggeredAt: Date.now(), triggerType: 'take_profit', triggerPrice: cp })
        } else if (order.slPrice && cp <= order.slPrice) {
          sellShares(order.artworkId, Math.min(sellQty, held))
          triggered.push({ ...order, triggeredAt: Date.now(), triggerType: 'stop_loss', triggerPrice: cp })
        }
      } else if (order.type === 'perp') {
        const pos = wallet.value.perpPositions.find(p => p.id === order.posId)
        if (!pos) { triggered.push({ ...order, triggeredAt: Date.now(), triggerType: 'expired' }); return }
        const isLong = pos.side === 'long'
        if (order.tpPrice && (isLong ? cp >= order.tpPrice : cp <= order.tpPrice)) {
          closePerp(order.posId)
          triggered.push({ ...order, triggeredAt: Date.now(), triggerType: 'take_profit', triggerPrice: cp })
        } else if (order.slPrice && (isLong ? cp <= order.slPrice : cp >= order.slPrice)) {
          closePerp(order.posId)
          triggered.push({ ...order, triggeredAt: Date.now(), triggerType: 'stop_loss', triggerPrice: cp })
        }
      }
    })

    if (triggered.length) {
      const ids = new Set(triggered.map(o => o.id))
      wallet.value.tpslOrders = wallet.value.tpslOrders.filter(o => !ids.has(o.id))
      wallet.value.orderHistory.unshift(...triggered)
      if (wallet.value.orderHistory.length > 100) wallet.value.orderHistory.length = 100
    }
  }

  // ── AI Account Monitor (小龍蝦接口) ───────────────────────────────────────────

  function setAiMonitor(config) {
    aiMonitor.value = { ...aiMonitor.value, ...config }
    clearInterval(_monitor); _monitor = null
    if (aiMonitor.value.enabled && aiMonitor.value.endpoint) {
      _monitor = setInterval(_runMonitor, aiMonitor.value.intervalSec * 1000)
    }
  }

  async function _runMonitor() {
    const cfg = aiMonitor.value
    if (!cfg.enabled || !cfg.endpoint) return

    const payload = {
      timestamp: Date.now(),
      wallet: {
        usd: wallet.value.usd,
        btc: wallet.value.btc,
        shares: { ...wallet.value.shares },
      },
      positions: wallet.value.perpPositions.map(p => ({
        ...p,
        currentPrice: prices.value[p.artworkId],
        pnlUsd: calcPnl(p, prices.value[p.artworkId]),
      })),
      tpslOrders: wallet.value.tpslOrders,
      market: Object.fromEntries(
        ARTWORKS.map(a => [a.id, {
          price: prices.value[a.id],
          change24h: priceChange(a.id),
          mcap: (prices.value[a.id] ?? 0) * TOTAL_SHARES,
          title: a.title, artist: a.artist,
        }])
      ),
    }

    const logEntry = { time: Date.now(), actions: [], error: null }

    try {
      const res = await fetch(cfg.endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(cfg.apiKey ? { Authorization: `Bearer ${cfg.apiKey}` } : {}),
        },
        body: JSON.stringify(payload),
        signal: AbortSignal.timeout(15_000),
      })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const { actions = [] } = await res.json()

      for (const act of actions) {
        if (act.type === 'buy_shares')    buyShares(act.artworkId, act.usdAmount)
        if (act.type === 'sell_shares')   sellShares(act.artworkId, act.shares)
        if (act.type === 'open_perp')     openPerp(act.artworkId, act.side, act.leverage, act.marginBtc)
        if (act.type === 'close_perp')    closePerp(act.posId)
        if (act.type === 'set_tpsl')      setTpSl(act)
        if (act.type === 'cancel_tpsl')   cancelTpSl(act.orderId)
      }
      logEntry.actions = actions
    } catch (e) {
      logEntry.error = e.message
    }

    aiMonitor.value.lastRun = Date.now()
    aiMonitor.value.actionLog.unshift(logEntry)
    if (aiMonitor.value.actionLog.length > 20) aiMonitor.value.actionLog.length = 20
  }

  // ── AI agent management ───────────────────────────────────────────────────────

  function setAiAgent(artworkId, config) {
    aiAgents.value[artworkId] = { ...config }
    if (_ai[artworkId]) { clearInterval(_ai[artworkId]); delete _ai[artworkId] }
    if (config.enabled && config.intervalSec > 0) {
      _ai[artworkId] = setInterval(() => _runAgent(artworkId), config.intervalSec * 1000)
    }
  }

  async function _runAgent(artworkId) {
    const cfg = aiAgents.value[artworkId]
    if (!cfg?.enabled) return
    const p  = prices.value[artworkId]
    const h  = history.value[artworkId]

    if (cfg.strategy === 'custom' && cfg.customEndpoint) {
      // POST order book + history to user's AI endpoint
      try {
        const res = await fetch(cfg.customEndpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', ...(cfg.customKey ? { Authorization: `Bearer ${cfg.customKey}` } : {}) },
          body: JSON.stringify({ artworkId, price: p, book: books.value[artworkId], history: h.slice(-20) }),
        })
        const { action, amount } = await res.json()  // expects { action: 'buy'|'sell'|'hold', amount: USD }
        if (action === 'buy')  buyShares(artworkId, Math.min(amount, cfg.maxUsd, wallet.value.usd))
        if (action === 'sell') sellShares(artworkId, Math.min(amount / p, wallet.value.shares[artworkId] || 0))
      } catch { /* silent */ }
      return
    }

    if (cfg.strategy === 'momentum') {
      const past = h[Math.max(0, h.length - 10)]?.p ?? p
      const chg  = (p - past) / past
      if (chg >  0.005 && wallet.value.usd >= 100) buyShares(artworkId, Math.min(cfg.maxUsd * 0.1, wallet.value.usd))
      if (chg < -0.005 && (wallet.value.shares[artworkId] || 0) > 0) {
        sellShares(artworkId, (wallet.value.shares[artworkId] || 0) * 0.15)
      }
    } else if (cfg.strategy === 'mean_reversion') {
      const recent = h.slice(-20)
      const avg = recent.reduce((s, pt) => s + pt.p, 0) / (recent.length || 1)
      const dev = (p - avg) / avg
      if (dev < -0.012 && wallet.value.usd >= 100) buyShares(artworkId, Math.min(cfg.maxUsd * 0.1, wallet.value.usd))
      if (dev >  0.012 && (wallet.value.shares[artworkId] || 0) > 0) {
        sellShares(artworkId, (wallet.value.shares[artworkId] || 0) * 0.15)
      }
    } else if (cfg.strategy === 'grid') {
      // Buy every 0.5% below current, sell every 0.5% above
      const gridStep = 0.005
      const lastBuy  = (wallet.value.shares[artworkId] || 0) > 0
        ? h.slice().reverse().find(pt => pt.p <= p * (1 - gridStep))
        : null
      if (!lastBuy && wallet.value.usd >= 100) buyShares(artworkId, Math.min(cfg.maxUsd * 0.05, wallet.value.usd))
    }
  }

  // ── Computed helpers ──────────────────────────────────────────────────────────

  const totalMcap = computed(() =>
    ARTWORKS.reduce((s, art) => s + (prices.value[art.id] || 0) * TOTAL_SHARES, 0)
  )

  const portfolioValue = computed(() => {
    let total = wallet.value.usd + wallet.value.btc * btcPrice.value
    Object.entries(wallet.value.shares).forEach(([id, qty]) => { total += qty * (prices.value[id] || 0) })
    wallet.value.perpPositions.forEach(pos => {
      const pnl = calcPnl(pos, prices.value[pos.artworkId])
      total += Math.max(0, pos.marginBtc * btcPrice.value + pnl)
    })
    return total
  })

  function priceChange(artworkId, bars = 72) {
    const h = history.value[artworkId]
    if (!h || h.length < 2) return 0
    const past = h[Math.max(0, h.length - bars)].p
    return ((prices.value[artworkId] || past) - past) / past * 100
  }

  function volume24h(artworkId) {
    return (feeds.value[artworkId] || []).reduce((s, t) => s + t.price * t.size, 0)
  }

  return {
    prices, books, feeds, history, btcPrice, wallet, aiAgents, aiMonitor,
    totalMcap, portfolioValue,
    ARTWORKS, TOTAL_SHARES,
    init, destroy,
    buyShares, sellShares, openPerp, closePerp, calcPnl, liqPrice,
    priceChange, volume24h,
    setAiAgent, setTpSl, cancelTpSl, setAiMonitor,
  }
})

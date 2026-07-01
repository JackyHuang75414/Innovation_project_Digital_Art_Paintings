import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import {
  getMarketArtworks,
  getOrderBook,
  getTrades,
  getPriceHistory,
  getPortfolio,
  executeSpot,
  openPerp as openPerpApi,
  closePerp as closePerpApi,
  setTpSl as setTpSlApi,
  cancelTpSl as cancelTpSlApi,
} from '@/api/trading'

export const TOTAL_SHARES = 1_000_000
export const MAINTENANCE_RATE = 0.005

// Compatibility export for places that import ARTWORKS directly.
// The store mutates this array in-place after loading from the backend.
export const ARTWORKS = []

function asNumberMap(input = {}) {
  return Object.fromEntries(Object.entries(input).map(([k, v]) => [Number(k), Number(v)]))
}

export const useTradingStore = defineStore('trading', () => {
  const artworks = ref([])
  const prices = ref({})
  const books = ref({})
  const feeds = ref({})
  const history = ref({})
  const btcPrice = ref(64_800)

  const wallet = ref({
    usd: 0,
    btc: 0,
    shares: {},
    perpPositions: [],
    tpslOrders: [],
    orderHistory: [],
  })

  const aiAgents = ref({})
  const aiMonitor = ref({
    enabled: false,
    endpoint: '',
    apiKey: '',
    intervalSec: 60,
    lastRun: null,
    actionLog: [],
  })

  const loaded = ref(false)
  let marketTimer = null
  let marketRefreshing = false

  async function init() {
    if (loaded.value) {
      await loadWallet()
      startMarketPolling()
      return
    }
    await loadMarket()
    await loadWallet()
    startMarketPolling()
  }

  function destroy() {
    stopMarketPolling()
  }

  async function loadMarket() {
    const { data } = await getMarketArtworks()
    artworks.value = data.map(normalizeArtwork)
    ARTWORKS.splice(0, ARTWORKS.length, ...artworks.value)

    prices.value = Object.fromEntries(artworks.value.map(a => [a.id, a.price ?? a.initPrice]))
    await Promise.all(artworks.value.map(async art => {
      const [bookRes, tradesRes, historyRes] = await Promise.all([
        getOrderBook(art.id),
        getTrades(art.id),
        getPriceHistory(art.id),
      ])
      books.value[art.id] = {
        bids: (bookRes.data.bids ?? []).map(normalizeBookLevel),
        asks: (bookRes.data.asks ?? []).map(normalizeBookLevel),
      }
      feeds.value[art.id] = (tradesRes.data ?? []).map(normalizeTrade)
      history.value[art.id] = (historyRes.data ?? []).map(pt => ({
        t: new Date(pt.t).getTime(),
        p: Number(pt.p),
      }))
    }))
    loaded.value = true
  }

  function startMarketPolling() {
    if (marketTimer) return
    marketTimer = setInterval(refreshMarketFromBackend, 2000)
  }

  function stopMarketPolling() {
    clearInterval(marketTimer)
    marketTimer = null
  }

  async function refreshMarketFromBackend() {
    if (marketRefreshing || !loaded.value) return
    marketRefreshing = true
    try {
      await loadMarket()
    } catch {
      // Keep the last market snapshot if a polling request fails.
    } finally {
      marketRefreshing = false
    }
  }

  async function loadWallet() {
    try {
      const { data } = await getPortfolio()
      applyWallet(data)
    } catch {
      // Public pages can load before login; keep an empty wallet.
    }
  }

  function applyWallet(data) {
    wallet.value = {
      usd: Number(data?.usd ?? 0),
      btc: Number(data?.btc ?? 0),
      shares: asNumberMap(data?.shares ?? {}),
      perpPositions: (data?.perpPositions ?? []).map(p => ({
        ...p,
        artworkId: Number(p.artworkId),
        notional: Number(p.notional),
        leverage: Number(p.leverage),
        entryPrice: Number(p.entryPrice),
        marginBtc: Number(p.marginBtc),
        openTime: p.openTime ? new Date(p.openTime).getTime() : Date.now(),
      })),
      tpslOrders: (data?.tpslOrders ?? []).map(o => ({
        ...o,
        artworkId: Number(o.artworkId),
        posId: o.posId == null ? null : Number(o.posId),
        tpPrice: o.tpPrice == null ? null : Number(o.tpPrice),
        slPrice: o.slPrice == null ? null : Number(o.slPrice),
        qty: o.qty == null ? null : Number(o.qty),
        createdAt: o.createdAt ? new Date(o.createdAt).getTime() : Date.now(),
      })),
      orderHistory: wallet.value.orderHistory ?? [],
    }
  }

  async function buyShares(artworkId, usdAmount) {
    const { data } = await executeSpot({ artworkId, side: 'buy', amount: usdAmount })
    if (data.wallet) applyWallet(data.wallet)
    await refreshArtwork(artworkId)
    return { ok: data.ok, msg: data.msg, shares: Number(data.shares ?? 0), price: Number(data.price ?? prices.value[artworkId] ?? 0) }
  }

  async function sellShares(artworkId, shares) {
    const { data } = await executeSpot({ artworkId, side: 'sell', amount: shares })
    if (data.wallet) applyWallet(data.wallet)
    await refreshArtwork(artworkId)
    return { ok: data.ok, msg: data.msg, proceeds: Number(data.proceeds ?? 0), price: Number(data.price ?? prices.value[artworkId] ?? 0) }
  }

  async function openPerp(artworkId, side, leverage, marginBtc) {
    const { data } = await openPerpApi({ artworkId, side, leverage, marginBtc })
    if (data.wallet) applyWallet(data.wallet)
    await refreshArtwork(artworkId)
    return { ok: data.ok, msg: data.msg, pos: data.pos }
  }

  async function closePerp(posId) {
    const { data } = await closePerpApi(posId)
    if (data.wallet) applyWallet(data.wallet)
    return { ok: data.ok, msg: data.msg, pnlUsd: Number(data.pnlUsd ?? 0) }
  }

  async function setTpSl(payload) {
    await setTpSlApi({
      artworkId: payload.artworkId,
      type: payload.type,
      posId: payload.posId,
      tpPrice: payload.tpPrice,
      slPrice: payload.slPrice,
      qty: payload.qty,
    })
    await loadWallet()
  }

  async function cancelTpSl(orderId) {
    await cancelTpSlApi(orderId)
    await loadWallet()
  }

  async function refreshArtwork(artworkId) {
    const [bookRes, tradesRes, historyRes] = await Promise.all([
      getOrderBook(artworkId),
      getTrades(artworkId),
      getPriceHistory(artworkId),
    ])
    books.value[artworkId] = {
      bids: (bookRes.data.bids ?? []).map(normalizeBookLevel),
      asks: (bookRes.data.asks ?? []).map(normalizeBookLevel),
    }
    feeds.value[artworkId] = (tradesRes.data ?? []).map(normalizeTrade)
    history.value[artworkId] = (historyRes.data ?? []).map(pt => ({ t: new Date(pt.t).getTime(), p: Number(pt.p) }))
  }

  function calcPnl(pos, currentPrice) {
    const dir = pos.side === 'long' ? 1 : -1
    return dir * ((currentPrice - pos.entryPrice) / pos.entryPrice) * pos.notional
  }

  function liqPrice(pos) {
    const dir = pos.side === 'long' ? -1 : 1
    return pos.entryPrice * (1 + dir * (1 / pos.leverage - MAINTENANCE_RATE))
  }

  function priceChange(artworkId) {
    const art = artworks.value.find(a => a.id === Number(artworkId))
    return Number(art?.change24h ?? 0)
  }

  function volume24h(artworkId) {
    const art = artworks.value.find(a => a.id === Number(artworkId))
    return Number(art?.volume24h ?? 0)
  }

  function setAiMonitor(config) {
    aiMonitor.value = { ...aiMonitor.value, ...config }
  }

  function setAiAgent(artworkId, config) {
    aiAgents.value[artworkId] = { ...config }
  }

  const totalMcap = computed(() =>
    artworks.value.reduce((s, art) => s + Number(art.mcapUsd ?? 0), 0)
  )

  const portfolioValue = computed(() => {
    let total = wallet.value.usd + wallet.value.btc * btcPrice.value
    Object.entries(wallet.value.shares).forEach(([id, qty]) => { total += Number(qty) * (prices.value[id] || 0) })
    wallet.value.perpPositions.forEach(pos => {
      total += Math.max(0, pos.marginBtc * btcPrice.value + calcPnl(pos, prices.value[pos.artworkId] || pos.entryPrice))
    })
    return total
  })

  return {
    prices, books, feeds, history, btcPrice, wallet, aiAgents, aiMonitor,
    totalMcap, portfolioValue,
    ARTWORKS: artworks,
    TOTAL_SHARES,
    loaded,
    init, destroy, loadMarket, loadWallet,
    buyShares, sellShares, openPerp, closePerp, calcPnl, liqPrice,
    priceChange, volume24h,
    setAiAgent, setTpSl, cancelTpSl, setAiMonitor,
  }
})

function normalizeArtwork(art) {
  return {
    ...art,
    id: Number(art.id),
    initPrice: Number(art.initPrice ?? art.price ?? 0),
    price: Number(art.price ?? art.initPrice ?? 0),
    mcapUsd: Number(art.mcapUsd ?? 0),
    volume24h: Number(art.volume24h ?? 0),
    change24h: Number(art.change24h ?? 0),
    totalShares: Number(art.totalShares ?? TOTAL_SHARES),
    tags: art.tags ?? [],
  }
}

function normalizeBookLevel(level) {
  return {
    price: Number(level.price),
    size: Number(level.size),
    user: level.user,
    isVmm: !!level.isVmm,
  }
}

function normalizeTrade(trade) {
  return {
    id: trade.id,
    artworkId: Number(trade.artworkId),
    price: Number(trade.price),
    size: Number(trade.size),
    side: trade.side,
    user: trade.user,
    time: trade.time ? new Date(trade.time).getTime() : Date.now(),
  }
}

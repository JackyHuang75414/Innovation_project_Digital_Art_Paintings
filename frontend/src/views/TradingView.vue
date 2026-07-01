<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useTradingStore, TOTAL_SHARES, MAINTENANCE_RATE } from '@/stores/trading'
import { usePricesStore } from '@/stores/prices'
import { useWalletStore } from '@/stores/wallet'
import { useAuthStore } from '@/stores/auth'
import WalletConnectModal from '@/components/ui/WalletConnectModal.vue'
import LoginModal from '@/components/ui/LoginModal.vue'
import CryptoPriceBadge from '@/components/ui/CryptoPriceBadge.vue'

const route  = useRoute()
const router = useRouter()
const store  = useTradingStore()
const prices = usePricesStore()
const wallet = useWalletStore()
const auth   = useAuthStore()

onMounted(store.init)
onUnmounted(store.destroy)

const artworkId = computed(() => Number(route.params.id))
const artwork   = computed(() => store.ARTWORKS.find(a => a.id === artworkId.value))
const price     = computed(() => store.prices[artworkId.value] ?? 0)
const book      = computed(() => store.books[artworkId.value]  ?? { bids: [], asks: [] })
const feed      = computed(() => (store.feeds[artworkId.value] ?? []).slice(0, 30))
const history   = computed(() => store.history[artworkId.value] ?? [])
const change24h = computed(() => store.priceChange(artworkId.value))
const mcapUsd   = computed(() => price.value * TOTAL_SHARES)

// ── Trade form ────────────────────────────────────────────────────────────────
const tradeTab  = ref('spot')
const tradeSide = ref('buy')
const perpSide  = ref('long')
const spotAmount  = ref('')
const leverage    = ref(10)
const marginBtc   = ref('')
const tradeMsg    = ref(null)
const showWalletModal = ref(false)
const showLoginModal = ref(false)

const sharesHeld  = computed(() => store.wallet.shares[artworkId.value] || 0)
const usdBalance  = computed(() => store.wallet.usd)
const btcBalance  = computed(() => store.wallet.btc)
const btcPrice    = computed(() => store.btcPrice)

const spotPreview = computed(() => {
  const amt = parseFloat(spotAmount.value) || 0
  if (tradeSide.value === 'buy')  return (amt / price.value).toFixed(2) + ' shares'
  return '$' + (amt * price.value).toFixed(2)
})
const perpNotional = computed(() => {
  const btc = parseFloat(marginBtc.value) || 0
  return (btc * btcPrice.value * leverage.value).toFixed(2)
})
const perpLiqPrice = computed(() => {
  const btc = parseFloat(marginBtc.value) || 0
  if (!btc || !price.value) return '—'
  const fakePos = { side: perpSide.value, notional: btc * btcPrice.value * leverage.value, leverage: leverage.value, entryPrice: price.value, marginBtc: btc }
  return '$' + store.liqPrice(fakePos).toFixed(4)
})

function requireWallet() {
  if (!wallet.isConnected) {
    openWallet()
    return false
  }
  return true
}

function openWallet() {
  if (!auth.isLoggedIn) {
    showLoginModal.value = true
    return
  }
  showWalletModal.value = true
}

async function executeSpot() {
  if (!requireWallet()) return
  const amt = parseFloat(spotAmount.value)
  if (!amt || amt <= 0) return
  try {
    let result = tradeSide.value === 'buy'
      ? await store.buyShares(artworkId.value, amt)
      : await store.sellShares(artworkId.value, amt)
    tradeMsg.value = { ok: result.ok, text: result.ok ? `Filled @ $${(result.price ?? price.value).toFixed(4)}` : result.msg }
    if (result.ok) spotAmount.value = ''
  } catch (err) {
    tradeMsg.value = { ok: false, text: err.message || 'Trade failed' }
  }
  setTimeout(() => { tradeMsg.value = null }, 3000)
}

async function executePerp() {
  if (!requireWallet()) return
  const btc = parseFloat(marginBtc.value)
  if (!btc || btc <= 0) return
  try {
    const result = await store.openPerp(artworkId.value, perpSide.value, leverage.value, btc)
    tradeMsg.value = { ok: result.ok, text: result.ok ? `${perpSide.value.toUpperCase()} opened @ $${price.value.toFixed(4)}` : result.msg }
    if (result.ok) marginBtc.value = ''
  } catch (err) {
    tradeMsg.value = { ok: false, text: err.message || 'Position open failed' }
  }
  setTimeout(() => { tradeMsg.value = null }, 3000)
}

async function closePosition(posId) {
  try {
    const result = await store.closePerp(posId)
    tradeMsg.value = { ok: result.ok, text: result.ok ? `Closed. PnL: $${(result.pnlUsd ?? 0).toFixed(2)}` : result.msg }
  } catch (err) {
    tradeMsg.value = { ok: false, text: err.message || 'Close failed' }
  }
  setTimeout(() => { tradeMsg.value = null }, 4000)
}

const openPositions = computed(() =>
  store.wallet.perpPositions.filter(p => p.artworkId === artworkId.value).map(pos => ({
    ...pos,
    pnlUsd:  store.calcPnl(pos, price.value),
    liq:     store.liqPrice(pos),
    pnlPct:  (store.calcPnl(pos, price.value) / pos.notional) * pos.leverage * 100,
  }))
)

// ── AI agent ──────────────────────────────────────────────────────────────────
const agent = computed(() => store.aiAgents[artworkId.value] ?? { enabled: false, strategy: 'momentum', maxUsd: 500, intervalSec: 30, customEndpoint: '', customKey: '' })
const agentDraft = ref({ ...agent.value })
watch(() => store.aiAgents[artworkId.value], v => { if (v) agentDraft.value = { ...v } }, { deep: true })

function saveAgent() {
  store.setAiAgent(artworkId.value, { ...agentDraft.value })
  tradeMsg.value = { ok: true, text: agentDraft.value.enabled ? 'AI agent activated' : 'AI agent paused' }
  setTimeout(() => { tradeMsg.value = null }, 2500)
}

// ── Chart ─────────────────────────────────────────────────────────────────────
const CHART_W = 520
const CHART_H = 80

const chartPath = computed(() => {
  const pts = history.value.slice(-80)
  if (pts.length < 2) return ''
  const ps  = pts.map(pt => pt.p)
  const min = Math.min(...ps), max = Math.max(...ps)
  const range = max - min || min * 0.01
  const coords = pts.map((pt, i) => {
    const x = (i / (pts.length - 1)) * CHART_W
    const y = CHART_H - ((pt.p - min) / range) * CHART_H
    return `${x.toFixed(1)},${y.toFixed(1)}`
  })
  return 'M ' + coords.join(' L ')
})
const chartColor = computed(() => change24h.value >= 0 ? '#22c55e' : '#ef4444')
const chartFill  = computed(() => change24h.value >= 0 ? 'rgba(34,197,94,0.07)' : 'rgba(239,68,68,0.07)')

const bookMaxSize = computed(() => {
  const all = [...book.value.bids, ...book.value.asks]
  return all.length ? Math.max(...all.map(o => o.size)) : 1
})

function fmt(n) { return (!n || n === 0) ? '—' : n < 1 ? n.toFixed(4) : n.toFixed(2) }
function fmtK(n) {
  if (n >= 1e6) return '$' + (n / 1e6).toFixed(2) + 'M'
  if (n >= 1e3) return '$' + (n / 1e3).toFixed(1)  + 'K'
  return '$' + n.toFixed(0)
}
function timeAgo(ts) {
  const s = Math.floor((Date.now() - ts) / 1000)
  return s < 60 ? s + 's' : Math.floor(s / 60) + 'm'
}
</script>

<template>
  <div v-if="!artwork" class="py-20 text-center text-gray-500">Artwork not found.</div>
  <div v-else class="bg-[#09090b] min-h-screen">

    <!-- ════════════════════════════════════════════════════════════
         ARTWORK SHOWCASE (top section)
         ════════════════════════════════════════════════════════════ -->
    <section class="border-b border-white/[0.07]">
      <div class="max-w-screen-xl mx-auto px-6 lg:px-10 py-8">
        <div class="grid grid-cols-1 lg:grid-cols-[1fr_420px] gap-8 items-start">

          <!-- Large artwork image -->
          <div class="relative bg-[#0d0d10] overflow-hidden aspect-[4/3] lg:aspect-auto lg:min-h-[480px]">
            <img
              :src="artwork.imageLarge ?? artwork.imageUrl"
              :alt="artwork.title"
              class="w-full h-full object-contain"
              loading="eager"
            />
            <!-- Subtle dark vignette -->
            <div class="absolute inset-0 shadow-[inset_0_0_60px_rgba(0,0,0,0.4)] pointer-events-none" />
          </div>

          <!-- Artwork info panel -->
          <div class="flex flex-col gap-5">

            <!-- Title + artist -->
            <div>
              <p class="text-[10px] tracking-[0.3em] uppercase text-[#E8552A] font-light mb-2">
                {{ artwork.medium }} · {{ artwork.year }} · {{ artwork.edition }}
              </p>
              <h1 class="font-display italic text-white text-3xl lg:text-4xl leading-tight mb-1">
                {{ artwork.title }}
              </h1>
              <p class="text-gray-400 font-light text-sm">{{ artwork.artist }}</p>
            </div>

            <!-- Tags -->
            <div class="flex flex-wrap gap-1.5">
              <span
                v-for="tag in artwork.tags" :key="tag"
                class="text-[9px] tracking-[0.2em] uppercase px-2.5 py-1 border border-white/[0.1] text-gray-500"
              >{{ tag }}</span>
            </div>

            <!-- Description -->
            <p class="text-sm text-gray-500 font-light leading-relaxed">{{ artwork.description }}</p>

            <!-- Artist bio -->
            <div class="border-t border-white/[0.06] pt-4">
              <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-1.5">About the Artist</p>
              <p class="text-xs text-gray-500 font-light leading-relaxed">{{ artwork.artistBio }}</p>
            </div>

            <!-- Live price highlight -->
            <div class="bg-[#111116] border border-white/[0.07] p-4">
              <div class="flex items-start justify-between mb-3">
                <div>
                  <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-1">Market Cap</p>
                  <CryptoPriceBadge :usd-value="mcapUsd" size="lg" :show-change="true" :change24h="change24h" />
                </div>
                <div class="text-right">
                  <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-1">Per Share</p>
                  <span class="font-mono text-base text-white">${{ fmt(price) }}</span>
                </div>
              </div>
              <div class="grid grid-cols-3 gap-3 pt-3 border-t border-white/[0.06] text-center">
                <div>
                  <p class="text-[9px] uppercase text-gray-700 mb-0.5">MCap</p>
                  <p class="font-mono text-xs text-gray-400">{{ fmtK(mcapUsd) }}</p>
                </div>
                <div>
                  <p class="text-[9px] uppercase text-gray-700 mb-0.5">Volume</p>
                  <p class="font-mono text-xs text-gray-400">{{ fmtK(store.volume24h(artworkId)) }}</p>
                </div>
                <div>
                  <p class="text-[9px] uppercase text-gray-700 mb-0.5">Shares</p>
                  <p class="font-mono text-xs text-gray-400">1M</p>
                </div>
              </div>
            </div>

            <!-- CTA row -->
            <div class="flex gap-2">
              <button
                class="flex-1 py-3 bg-[#E8552A] hover:bg-[#d4461c] text-white text-[11px] tracking-[0.2em] uppercase font-medium transition-colors"
                @click="tradeTab = 'spot'; tradeSide = 'buy'; $el.closest('html').querySelector('#trading-panel')?.scrollIntoView({ behavior: 'smooth' })"
              >
                Buy Shares
              </button>
              <button
                class="flex-1 py-3 bg-white/[0.05] hover:bg-white/10 text-gray-300 text-[11px] tracking-[0.2em] uppercase font-medium border border-white/[0.1] transition-colors"
                @click="tradeTab = 'perp'; $el.closest('html').querySelector('#trading-panel')?.scrollIntoView({ behavior: 'smooth' })"
              >
                Trade Perp
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ════════════════════════════════════════════════════════════
         TRADING TERMINAL (below artwork)
         ════════════════════════════════════════════════════════════ -->
    <div id="trading-panel" class="grid grid-cols-1 xl:grid-cols-[1fr_340px] max-w-screen-2xl mx-auto">

      <!-- Left: chart + order book + feed -->
      <div class="border-r border-white/[0.06]">

        <!-- Stats bar -->
        <div class="px-5 py-2.5 border-b border-white/[0.06] flex items-center gap-6 flex-wrap text-[11px] text-gray-500 overflow-x-auto">
          <span>Price <span class="font-mono text-white ml-1">${{ fmt(price) }}</span></span>
          <span>
            24h
            <span class="font-mono ml-1" :class="change24h >= 0 ? 'text-green-400' : 'text-red-400'">
              {{ change24h >= 0 ? '+' : '' }}{{ change24h.toFixed(2) }}%
            </span>
          </span>
          <span>BTC <span class="font-mono text-amber-400 ml-1">${{ btcPrice.toFixed(0) }}</span></span>
        </div>

        <!-- Chart -->
        <div class="px-4 pt-4 pb-2">
          <svg :width="CHART_W" :height="CHART_H + 10" viewBox="-2 -4 526 100" class="w-full overflow-visible" preserveAspectRatio="none">
            <path v-if="chartPath" :d="chartPath + ` L ${CHART_W},${CHART_H + 20} L 0,${CHART_H + 20} Z`" :fill="chartFill" />
            <path v-if="chartPath" :d="chartPath" fill="none" :stroke="chartColor" stroke-width="1.5" stroke-linejoin="round" stroke-linecap="round" />
          </svg>
        </div>

        <!-- Order book -->
        <div class="grid grid-cols-2 border-t border-white/[0.06]">
          <div class="border-r border-white/[0.06]">
            <div class="px-4 py-2 text-[10px] tracking-[0.2em] uppercase text-gray-600 flex justify-between border-b border-white/[0.06]">
              <span>Ask</span><span>Size</span>
            </div>
            <div v-for="(ask, i) in book.asks.slice(0, 8)" :key="i"
              class="relative px-4 py-1 flex justify-between text-xs font-mono hover:bg-white/[0.03] transition-colors">
              <div class="absolute inset-0 right-auto bg-red-900/15" :style="{ width: (ask.size / bookMaxSize * 100) + '%' }" />
              <span class="text-red-400 relative">${{ fmt(ask.price) }}</span>
              <span class="text-gray-600 relative" :class="ask.isVmm ? 'opacity-50' : ''">{{ ask.size.toLocaleString() }}</span>
            </div>
          </div>
          <div>
            <div class="px-4 py-2 text-[10px] tracking-[0.2em] uppercase text-gray-600 flex justify-between border-b border-white/[0.06]">
              <span>Bid</span><span>Size</span>
            </div>
            <div v-for="(bid, i) in book.bids.slice(0, 8)" :key="i"
              class="relative px-4 py-1 flex justify-between text-xs font-mono hover:bg-white/[0.03] transition-colors">
              <div class="absolute inset-0 right-auto bg-green-900/15" :style="{ width: (bid.size / bookMaxSize * 100) + '%' }" />
              <span class="text-green-400 relative">${{ fmt(bid.price) }}</span>
              <span class="text-gray-600 relative" :class="bid.isVmm ? 'opacity-50' : ''">{{ bid.size.toLocaleString() }}</span>
            </div>
          </div>
        </div>

        <!-- Activity feed -->
        <div class="border-t border-white/[0.06] px-4 py-3">
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-2">Recent Trades</p>
          <div class="space-y-0.5 max-h-40 overflow-y-auto">
            <div v-for="trade in feed" :key="trade.id" class="flex items-center justify-between text-xs font-mono py-0.5">
              <span :class="trade.side === 'buy' ? 'text-green-400' : 'text-red-400'">
                {{ trade.side === 'buy' ? '▲' : '▼' }} ${{ fmt(trade.price) }}
              </span>
              <span class="text-gray-600">{{ trade.size.toLocaleString() }}</span>
              <span class="text-gray-700 text-[10px]">{{ trade.user === 'VMM' ? 'VMM' : trade.user }}</span>
              <span class="text-gray-800 text-[10px]">{{ timeAgo(trade.time) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Right: trade panel -->
      <div class="flex flex-col">

        <!-- Notification -->
        <Transition name="fade">
          <div v-if="tradeMsg"
            class="px-4 py-2.5 text-xs font-light border-b text-center"
            :class="tradeMsg.ok ? 'bg-green-900/40 text-green-300 border-green-800' : 'bg-red-900/40 text-red-300 border-red-800'">
            {{ tradeMsg.text }}
          </div>
        </Transition>

        <!-- Wallet required banner -->
        <div v-if="!wallet.isConnected" class="mx-4 mt-4 flex items-center justify-between bg-amber-500/10 border border-amber-500/20 px-3 py-2.5">
          <p class="text-[11px] text-amber-400 font-light">Connect a wallet to trade</p>
          <button class="text-[10px] tracking-[0.1em] uppercase text-amber-400 hover:text-white transition-colors" @click="openWallet">
            Connect →
          </button>
        </div>

        <!-- Tab selector -->
        <div class="flex border-b border-white/[0.06]">
          <button v-for="tab in ['spot', 'perp']" :key="tab"
            class="flex-1 py-3 text-[11px] tracking-[0.2em] uppercase font-light transition-colors"
            :class="tradeTab === tab ? 'text-white border-b-2 border-[#E8552A]' : 'text-gray-600 hover:text-gray-400'"
            @click="tradeTab = tab">
            {{ tab === 'spot' ? 'Spot' : 'Perp / Futures' }}
          </button>
        </div>

        <!-- Wallet summary -->
        <div class="px-4 py-2.5 border-b border-white/[0.06] flex gap-4 text-[11px] text-gray-500">
          <span>USD <span class="text-white font-medium">${{ usdBalance.toFixed(2) }}</span></span>
          <span>BTC <span class="text-amber-400 font-medium">{{ btcBalance.toFixed(4) }}</span></span>
          <span>Shares <span class="text-white font-medium">{{ sharesHeld.toFixed(2) }}</span></span>
        </div>

        <!-- Spot panel -->
        <div v-if="tradeTab === 'spot'" class="p-4 flex flex-col gap-4">
          <div class="flex">
            <button class="flex-1 py-2 text-[11px] tracking-[0.15em] uppercase font-medium transition-colors"
              :class="tradeSide === 'buy' ? 'bg-green-600 text-white' : 'bg-white/[0.05] text-gray-500 hover:text-gray-300'"
              @click="tradeSide = 'buy'">Buy</button>
            <button class="flex-1 py-2 text-[11px] tracking-[0.15em] uppercase font-medium transition-colors"
              :class="tradeSide === 'sell' ? 'bg-red-600 text-white' : 'bg-white/[0.05] text-gray-500 hover:text-gray-300'"
              @click="tradeSide = 'sell'">Sell</button>
          </div>

          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-600 block mb-1.5">
              {{ tradeSide === 'buy' ? 'Amount (USD)' : 'Shares to sell' }}
            </label>
            <input v-model="spotAmount" type="number" :placeholder="tradeSide === 'buy' ? '100.00' : '0.00'" min="0"
              class="w-full bg-[#111116] border border-white/[0.1] text-white px-3 py-2.5 text-sm font-mono outline-none focus:border-white/20" />
            <p class="text-[11px] text-gray-600 mt-1.5">≈ {{ spotPreview }}</p>
          </div>

          <button
            class="w-full py-3 text-[11px] tracking-[0.15em] uppercase font-medium transition-colors"
            :class="tradeSide === 'buy' ? 'bg-green-600 hover:bg-green-500 text-white' : 'bg-red-600 hover:bg-red-500 text-white'"
            @click="executeSpot">
            {{ tradeSide === 'buy' ? 'Buy' : 'Sell' }} @ ${{ fmt(price) }}
          </button>
        </div>

        <!-- Perp panel -->
        <div v-else class="p-4 flex flex-col gap-4">
          <div class="flex">
            <button class="flex-1 py-2 text-[11px] tracking-[0.15em] uppercase font-medium transition-colors"
              :class="perpSide === 'long' ? 'bg-green-600 text-white' : 'bg-white/[0.05] text-gray-500 hover:text-gray-300'"
              @click="perpSide = 'long'">Long</button>
            <button class="flex-1 py-2 text-[11px] tracking-[0.15em] uppercase font-medium transition-colors"
              :class="perpSide === 'short' ? 'bg-red-600 text-white' : 'bg-white/[0.05] text-gray-500 hover:text-gray-300'"
              @click="perpSide = 'short'">Short</button>
          </div>

          <div>
            <div class="flex justify-between text-[10px] uppercase text-gray-600 mb-1.5">
              <span>Leverage</span><span class="text-white font-mono">{{ leverage }}×</span>
            </div>
            <input v-model="leverage" type="range" min="1" max="50" step="1" class="w-full accent-[#E8552A]" />
            <div class="flex justify-between text-[10px] text-gray-700 mt-0.5"><span>1×</span><span>25×</span><span>50×</span></div>
          </div>

          <div>
            <label class="text-[10px] uppercase text-gray-600 block mb-1.5 tracking-[0.15em]">Margin (BTC)</label>
            <input v-model="marginBtc" type="number" placeholder="0.010" min="0" step="0.001"
              class="w-full bg-[#111116] border border-white/[0.1] text-white px-3 py-2.5 text-sm font-mono outline-none focus:border-white/20" />
          </div>

          <div class="bg-[#111116] border border-white/[0.07] px-3 py-2.5 text-xs space-y-1.5 font-mono">
            <div class="flex justify-between"><span class="text-gray-600">Notional</span><span>${{ perpNotional }}</span></div>
            <div class="flex justify-between"><span class="text-gray-600">Init. margin</span><span>{{ (100 / leverage).toFixed(1) }}%</span></div>
            <div class="flex justify-between"><span class="text-gray-600">Liq. price</span><span class="text-amber-400">{{ perpLiqPrice }}</span></div>
            <div class="flex justify-between"><span class="text-gray-600">Maint.</span><span class="text-gray-500">{{ (MAINTENANCE_RATE * 100).toFixed(1) }}%</span></div>
          </div>

          <button
            class="w-full py-3 text-[11px] tracking-[0.15em] uppercase font-medium transition-colors"
            :class="perpSide === 'long' ? 'bg-green-600 hover:bg-green-500 text-white' : 'bg-red-600 hover:bg-red-500 text-white'"
            @click="executePerp">
            Open {{ perpSide }} {{ leverage }}× @ ${{ fmt(price) }}
          </button>
        </div>

        <!-- Open positions -->
        <div v-if="openPositions.length" class="border-t border-white/[0.06] px-4 py-3">
          <p class="text-[10px] uppercase text-gray-600 mb-2 tracking-[0.2em]">Open Positions</p>
          <div class="space-y-2">
            <div v-for="pos in openPositions" :key="pos.id" class="bg-[#111116] border border-white/[0.07] px-3 py-2.5 text-xs">
              <div class="flex items-center justify-between mb-1.5">
                <span class="text-[10px] tracking-[0.15em] uppercase font-medium px-1.5 py-0.5"
                  :class="pos.side === 'long' ? 'bg-green-800/40 text-green-300' : 'bg-red-800/40 text-red-300'">
                  {{ pos.side }} {{ pos.leverage }}×
                </span>
                <button class="text-[10px] uppercase text-gray-600 hover:text-red-400 transition-colors" @click="closePosition(pos.id)">Close</button>
              </div>
              <div class="grid grid-cols-2 gap-x-4 gap-y-0.5 font-mono text-[11px]">
                <span class="text-gray-600">Entry</span><span>${{ fmt(pos.entryPrice) }}</span>
                <span class="text-gray-600">Current</span><span>${{ fmt(price) }}</span>
                <span class="text-gray-600">Liq.</span><span class="text-amber-400">${{ fmt(pos.liq) }}</span>
                <span class="text-gray-600">PnL</span>
                <span :class="pos.pnlUsd >= 0 ? 'text-green-400' : 'text-red-400'">
                  {{ pos.pnlUsd >= 0 ? '+' : '' }}${{ pos.pnlUsd.toFixed(2) }} ({{ pos.pnlPct.toFixed(1) }}%)
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- AI agent -->
        <div class="border-t border-white/[0.06] px-4 py-3 mt-auto">
          <div class="flex items-center justify-between mb-3">
            <p class="text-[10px] uppercase text-gray-600 tracking-[0.2em]">AI Trading Agent</p>
            <template v-if="auth.isPaid">
              <button
                class="relative w-10 h-5 rounded-full transition-colors"
                :class="agentDraft.enabled ? 'bg-[#E8552A]' : 'bg-white/10'"
                @click="agentDraft.enabled = !agentDraft.enabled">
                <span class="absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-white transition-transform"
                  :class="agentDraft.enabled ? 'translate-x-5' : 'translate-x-0'" />
              </button>
            </template>
            <span v-else class="text-[9px] tracking-[0.15em] uppercase text-[#E8552A] border border-[#E8552A]/40 px-2 py-0.5 rounded-sm">Pro</span>
          </div>

          <!-- Paid: full agent config -->
          <template v-if="auth.isPaid">
            <div class="space-y-2" :class="!agentDraft.enabled ? 'opacity-40 pointer-events-none' : ''">
              <select v-model="agentDraft.strategy"
                class="w-full bg-[#111116] border border-white/[0.1] text-gray-300 px-2 py-1.5 text-xs outline-none">
                <option value="momentum">Momentum (ArtEx AI)</option>
                <option value="mean_reversion">Mean Reversion (ArtEx AI)</option>
                <option value="grid">Grid (ArtEx AI)</option>
                <option value="custom">Custom Endpoint</option>
              </select>
              <template v-if="agentDraft.strategy === 'custom'">
                <input v-model="agentDraft.customEndpoint" type="url" placeholder="https://your-ai-endpoint.com/trade"
                  class="w-full bg-[#111116] border border-white/[0.1] text-gray-300 px-2 py-1.5 text-xs outline-none placeholder:text-gray-700" />
                <input v-model="agentDraft.customKey" type="password" placeholder="API key (optional)"
                  class="w-full bg-[#111116] border border-white/[0.1] text-gray-300 px-2 py-1.5 text-xs outline-none placeholder:text-gray-700" />
              </template>
              <div class="grid grid-cols-2 gap-2">
                <div>
                  <label class="text-[10px] uppercase text-gray-700 block mb-1">Max USD</label>
                  <input v-model="agentDraft.maxUsd" type="number" min="10" placeholder="500"
                    class="w-full bg-[#111116] border border-white/[0.1] text-gray-300 px-2 py-1.5 text-xs font-mono outline-none" />
                </div>
                <div>
                  <label class="text-[10px] uppercase text-gray-700 block mb-1">Interval (s)</label>
                  <input v-model="agentDraft.intervalSec" type="number" min="5" placeholder="30"
                    class="w-full bg-[#111116] border border-white/[0.1] text-gray-300 px-2 py-1.5 text-xs font-mono outline-none" />
                </div>
              </div>
              <button class="w-full py-2 bg-[#E8552A] hover:bg-[#d4461c] text-white text-[10px] uppercase tracking-[0.2em] transition-colors" @click="saveAgent">
                {{ agentDraft.enabled ? 'Activate Agent' : 'Save' }}
              </button>
            </div>
          </template>

          <!-- Free: locked paywall -->
          <template v-else>
            <div class="relative">
              <!-- Blurred preview -->
              <div class="space-y-2 opacity-30 pointer-events-none select-none blur-[1px]">
                <div class="w-full bg-[#111116] border border-white/[0.1] text-gray-500 px-2 py-1.5 text-xs">Momentum (ArtEx AI)</div>
                <div class="grid grid-cols-2 gap-2">
                  <div class="bg-[#111116] border border-white/[0.1] px-2 py-1.5 text-[10px] text-gray-600 font-mono">$500</div>
                  <div class="bg-[#111116] border border-white/[0.1] px-2 py-1.5 text-[10px] text-gray-600 font-mono">30s</div>
                </div>
                <div class="w-full py-2 bg-white/10 text-gray-600 text-[10px] uppercase text-center">Activate Agent</div>
              </div>
              <!-- Paywall overlay -->
              <div class="absolute inset-0 flex flex-col items-center justify-center bg-[#09090c]/70 rounded-sm">
                <svg class="w-5 h-5 text-gray-500 mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z"/>
                </svg>
                <p class="text-[10px] text-gray-400 mb-2.5 text-center leading-snug">AI Trading Agent<br>requires Pro</p>
                <button
                  class="px-3 py-1.5 bg-[#E8552A] hover:bg-[#d4461c] text-white text-[10px] uppercase tracking-[0.2em] transition-colors rounded-sm"
                  @click="router.push('/subscription')"
                >Upgrade to Pro</button>
              </div>
            </div>
          </template>
        </div>
      </div>
    </div>

    <!-- Wallet modal -->
    <Teleport to="body">
      <WalletConnectModal v-if="showWalletModal" @close="showWalletModal = false" />
      <LoginModal v-if="showLoginModal" @close="showLoginModal = false" />
    </Teleport>
  </div>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>

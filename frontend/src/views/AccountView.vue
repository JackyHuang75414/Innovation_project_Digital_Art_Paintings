<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { usePricesStore, CRYPTOS, FIATS } from '@/stores/prices'
import { useTradingStore, TOTAL_SHARES } from '@/stores/trading'
import { useAuthStore } from '@/stores/auth'
import { useWishlistStore } from '@/stores/wishlist'
import CryptoPriceBadge from '@/components/ui/CryptoPriceBadge.vue'

const prices = usePricesStore()
const store  = useTradingStore()
const auth   = useAuthStore()
const wishlist = useWishlistStore()
const router = useRouter()

const activeTab = ref('holdings')  // holdings | wishlist | positions | orders | monitor | settings

onMounted(() => wishlist.loadMine())

// ── Settings state ────────────────────────────────────────────────────────────
const LANGUAGES = [
  { code: 'EN', label: 'English'  },
  { code: 'ZH', label: '中文'     },
  { code: 'JA', label: '日本語'   },
  { code: 'FR', label: 'Français' },
  { code: 'ES', label: 'Español'  },
  { code: 'DE', label: 'Deutsch'  },
]
const lang = ref(localStorage.getItem('artex_lang') || 'EN')
function setLang(code) { lang.value = code; localStorage.setItem('artex_lang', code) }

const notifs = ref(
  JSON.parse(localStorage.getItem('artex_notifs') ?? 'null') ?? {
    priceAlerts:   true,
    tradeConfirm:  true,
    aiActions:     false,
    marketMoves:   true,
    tpslTriggers:  true,
    liquidation:   true,
  }
)
function saveNotifs() { localStorage.setItem('artex_notifs', JSON.stringify(notifs.value)) }

// Edit personal info (display name + bio)
const editingProfile = ref(false)
const profileDraft   = ref({ displayName: auth.user?.displayName ?? '', bio: auth.user?.bio ?? '' })
function saveProfile() {
  if (auth.user) {
    auth.user.displayName = profileDraft.value.displayName
    auth.user.bio         = profileDraft.value.bio
    localStorage.setItem('artex_user', JSON.stringify(auth.user))
  }
  editingProfile.value = false
}

function logout() {
  auth.logout()
  wishlist.reset()
  router.push('/')
}

async function toggleWishlist(artwork) {
  await wishlist.toggle(artwork)
}

// ── Holdings ──────────────────────────────────────────────────────────────────
const holdings = computed(() =>
  Object.entries(store.wallet.shares)
    .filter(([, qty]) => qty > 0.0001)
    .map(([id, qty]) => {
      const art     = store.ARTWORKS.find(a => a.id === Number(id))
      const price   = store.prices[id] ?? art?.initPrice ?? 0
      const value   = qty * price
      const chg     = store.priceChange(Number(id))
      const tpsl    = store.wallet.tpslOrders.find(o => o.artworkId === Number(id) && o.type === 'spot')
      return { ...art, qty, price, value, chg, tpsl }
    })
)

// ── Perp positions ────────────────────────────────────────────────────────────
const positions = computed(() =>
  store.wallet.perpPositions.map(pos => {
    const art = store.ARTWORKS.find(a => a.id === pos.artworkId)
    const cp  = store.prices[pos.artworkId] ?? pos.entryPrice
    const pnl = store.calcPnl(pos, cp)
    const liq = store.liqPrice(pos)
    const tpsl = store.wallet.tpslOrders.find(o => o.posId === pos.id)
    return { ...pos, art, cp, pnlUsd: pnl, pnlPct: (pnl / pos.notional) * pos.leverage * 100, liq, tpsl }
  })
)

// ── Summary ───────────────────────────────────────────────────────────────────
const totalValue = computed(() => store.portfolioValue)
const cashUsd    = computed(() => store.wallet.usd)
const cashBtc    = computed(() => store.wallet.btc)

// ── Quick sell ────────────────────────────────────────────────────────────────
const sellModal = ref(null)  // { art, maxQty }
const sellQty   = ref('')
const sellMsg   = ref(null)

function openSell(art, maxQty) {
  sellModal.value = { art, maxQty }
  sellQty.value   = maxQty.toFixed(2)
}
async function executeSell() {
  const qty = parseFloat(sellQty.value)
  if (!qty || qty <= 0) return
  let r
  try {
    r = await store.sellShares(sellModal.value.art.id, qty)
    sellMsg.value = r.ok ? `Sold ${qty.toFixed(2)} shares @ $${r.price.toFixed(4)}` : r.msg
  } catch (err) {
    r = { ok: false }
    sellMsg.value = err.message || 'Sell failed'
  }
  setTimeout(() => {
    sellMsg.value   = null
    if (r.ok) sellModal.value = null
  }, 2000)
}

// ── Quick close perp ──────────────────────────────────────────────────────────
const closeMsg = ref(null)
async function closePos(posId) {
  try {
    const r = await store.closePerp(posId)
    closeMsg.value = r.ok ? `Closed. PnL: $${(r.pnlUsd ?? 0).toFixed(2)}` : r.msg
  } catch (err) {
    closeMsg.value = err.message || 'Close failed'
  }
  setTimeout(() => { closeMsg.value = null }, 3000)
}

// ── TP/SL modal ───────────────────────────────────────────────────────────────
const tpslModal = ref(null)  // { artworkId, type, posId, currentPrice, side }
const tpInput   = ref('')
const slInput   = ref('')
const tpslQty   = ref('')

function openTpSl(item, type = 'spot') {
  const artworkId = type === 'perp' ? item.artworkId : item.id
  const existing  = store.wallet.tpslOrders.find(o =>
    type === 'perp' ? o.posId === item.id : (o.artworkId === artworkId && o.type === 'spot')
  )
  tpslModal.value = { artworkId, type, posId: type === 'perp' ? item.id : null, currentPrice: store.prices[artworkId], side: item.side ?? 'n/a' }
  tpInput.value   = existing?.tpPrice?.toFixed(4) ?? ''
  slInput.value   = existing?.slPrice?.toFixed(4) ?? ''
  tpslQty.value   = existing?.qty ?? ''
}
async function saveTpSl() {
  const m = tpslModal.value
  await store.setTpSl({
    artworkId: m.artworkId,
    type:      m.type,
    posId:     m.posId,
    tpPrice:   tpInput.value   ? parseFloat(tpInput.value)  : null,
    slPrice:   slInput.value   ? parseFloat(slInput.value)  : null,
    qty:       tpslQty.value   ? parseFloat(tpslQty.value)  : null,
  })
  tpslModal.value = null
}

async function cancelTpSlOrder(orderId) {
  if (!orderId) return
  await store.cancelTpSl(orderId)
}

async function clearCurrentTpSl() {
  const orderId = store.wallet.tpslOrders.find(o => o.artworkId === tpslModal.value.artworkId)?.id
  await cancelTpSlOrder(orderId)
  tpslModal.value = null
}

// ── AI Monitor (小龍蝦) ────────────────────────────────────────────────────────
const monitorDraft = ref({ ...store.aiMonitor })
watch(() => store.aiMonitor, v => { monitorDraft.value = { ...v } }, { deep: true })
function saveMonitor() {
  store.setAiMonitor({ ...monitorDraft.value })
}

// ── Currency settings ─────────────────────────────────────────────────────────
function fmt(n) { return n < 1 ? n.toFixed(4) : n.toFixed(2) }
function fmtK(n) {
  if (n >= 1e6) return '$' + (n / 1e6).toFixed(2) + 'M'
  if (n >= 1e3) return '$' + (n / 1e3).toFixed(1)  + 'K'
  return '$' + n.toFixed(0)
}
function timeAgo(ts) {
  const s = Math.floor((Date.now() - ts) / 1000)
  if (s < 60) return s + 's ago'
  if (s < 3600) return Math.floor(s / 60) + 'm ago'
  return Math.floor(s / 3600) + 'h ago'
}
</script>

<template>
  <!-- Page header -->
  <div class="border-b border-white/[0.06]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-8">
      <div class="flex items-center gap-4 flex-wrap justify-between">
        <!-- User profile -->
        <div class="flex items-center gap-4">
          <span
            class="w-12 h-12 rounded-full flex items-center justify-center text-base font-bold flex-shrink-0"
            :style="{ backgroundColor: auth.color + '22', color: auth.color, border: `1px solid ${auth.color}44` }"
          >{{ auth.initials || '?' }}</span>
          <div>
            <p class="text-white font-medium">{{ auth.displayName || 'Guest' }}</p>
            <p class="text-gray-600 text-[11px] font-light">{{ auth.user?.bio ?? 'Not logged in' }}</p>
          </div>
        </div>

        <!-- Portfolio value -->
        <div class="text-right">
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-1">Total Portfolio</p>
          <CryptoPriceBadge :usd-value="totalValue" size="lg" :show-change="false" />
          <p class="text-[11px] text-gray-600 mt-0.5 font-mono">
            ${{ cashUsd.toFixed(0) }} cash · {{ cashBtc.toFixed(4) }} BTC
          </p>
        </div>
      </div>
    </div>
  </div>

  <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-6">

    <!-- Tabs -->
    <div class="flex gap-0 border-b border-white/[0.07] mb-6 overflow-x-auto">
      <button
        v-for="tab in [
          { id: 'holdings',  label: 'Holdings',   badge: holdings.length },
          { id: 'wishlist',  label: 'Wishlist',   badge: wishlist.items.length },
          { id: 'positions', label: 'Positions',  badge: positions.length },
          { id: 'orders',    label: 'TP / SL',    badge: store.wallet.tpslOrders.length },
          { id: 'monitor',   label: '🦞 AI Monitor' },
          { id: 'settings',  label: 'Settings' },
        ]"
        :key="tab.id"
        class="flex items-center gap-1.5 px-4 py-3 text-[11px] tracking-[0.15em] uppercase font-light transition-colors whitespace-nowrap border-b-2 -mb-px"
        :class="activeTab === tab.id
          ? 'text-white border-[#E8552A]'
          : 'text-gray-500 hover:text-gray-300 border-transparent'"
        @click="activeTab = tab.id"
      >
        {{ tab.label }}
        <span v-if="tab.badge" class="text-[9px] bg-white/10 text-gray-400 px-1.5 py-0.5 rounded-sm">{{ tab.badge }}</span>
      </button>
    </div>

    <!-- ══════════════ HOLDINGS ══════════════ -->
    <div v-if="activeTab === 'holdings'">
      <div v-if="holdings.length === 0" class="py-20 text-center">
        <p class="font-display italic text-gray-600 text-2xl mb-2">No holdings yet</p>
        <p class="text-gray-700 text-sm font-light mb-6">Buy fractional shares on the market to see them here.</p>
        <RouterLink to="/market" class="btn-primary text-sm px-6 py-2.5">Explore Market</RouterLink>
      </div>

      <div v-else class="space-y-2">
        <div
          v-for="h in holdings"
          :key="h.id"
          class="card-dark p-4"
        >
          <div class="flex items-start gap-4 flex-wrap">
            <img :src="h.imageUrl" :alt="h.title" class="w-14 h-14 object-cover flex-shrink-0 bg-[#0d0d10]" />

            <div class="flex-1 min-w-[160px]">
              <p class="font-display italic text-gray-100 text-base leading-snug">{{ h.title }}</p>
              <p class="text-[10px] tracking-[0.15em] uppercase text-gray-500">{{ h.artist }}</p>
              <div class="flex items-baseline gap-3 mt-1.5">
                <span class="font-mono text-sm text-white">${{ fmt(h.price) }}</span>
                <span class="text-xs font-mono" :class="h.chg >= 0 ? 'text-green-400' : 'text-red-400'">
                  {{ h.chg >= 0 ? '+' : '' }}{{ h.chg.toFixed(2) }}%
                </span>
              </div>
            </div>

            <div class="text-right min-w-[100px]">
              <p class="text-[9px] text-gray-600 mb-0.5 uppercase tracking-wide">Holdings</p>
              <p class="font-mono text-white text-sm">{{ h.qty.toFixed(2) }} shares</p>
              <CryptoPriceBadge :usd-value="h.value" size="sm" class="mt-0.5" />
            </div>

            <!-- TP/SL indicator -->
            <div v-if="h.tpsl" class="text-[10px] font-mono text-center min-w-[80px]">
              <p v-if="h.tpsl.tpPrice" class="text-green-500">TP ${{ fmt(h.tpsl.tpPrice) }}</p>
              <p v-if="h.tpsl.slPrice" class="text-red-400">SL ${{ fmt(h.tpsl.slPrice) }}</p>
            </div>

            <!-- Actions -->
            <div class="flex gap-2 flex-wrap items-center">
              <button
                class="text-[10px] tracking-[0.15em] uppercase px-3 py-1.5 bg-white/[0.05] text-gray-400 hover:text-white border border-white/[0.08] hover:border-white/20 transition-colors"
                @click="openTpSl(h, 'spot')"
              >TP / SL</button>
              <button
                class="text-[10px] tracking-[0.15em] uppercase px-3 py-1.5 bg-red-500/10 text-red-400 hover:bg-red-500/20 border border-red-500/20 transition-colors"
                @click="openSell(h, h.qty)"
              >Sell</button>
              <RouterLink
                :to="`/trade/${h.id}`"
                class="text-[10px] tracking-[0.15em] uppercase px-3 py-1.5 bg-[#E8552A]/10 text-[#E8552A] hover:bg-[#E8552A]/20 border border-[#E8552A]/30 transition-colors"
              >Trade</RouterLink>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ══════════════ WISHLIST ══════════════ -->
    <div v-else-if="activeTab === 'wishlist'">
      <div v-if="wishlist.items.length === 0" class="py-20 text-center">
        <p class="font-display italic text-gray-600 text-2xl mb-2">No saved works yet</p>
        <p class="text-gray-700 text-sm font-light mb-6">Save artworks from Discover or artwork detail pages.</p>
        <RouterLink to="/browse" class="btn-primary text-sm px-6 py-2.5">Discover Works</RouterLink>
      </div>

      <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
        <RouterLink
          v-for="art in wishlist.items"
          :key="art.id"
          :to="`/artwork/${art.id}`"
          class="card-dark group overflow-hidden flex flex-col"
        >
          <div class="relative overflow-hidden aspect-[4/3] bg-[#0d0d10]">
            <img
              :src="art.imageUrl"
              :alt="art.title"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
              loading="lazy"
            />
            <button
              class="absolute top-3 right-3 w-8 h-8 border border-[#E8552A]/70 bg-[#E8552A]/10 text-[#E8552A] flex items-center justify-center transition-colors hover:bg-[#E8552A]/20"
              aria-label="Remove from wishlist"
              @click.prevent="toggleWishlist(art)"
            >
              <svg class="w-4 h-4 fill-current" fill="none" stroke="currentColor" stroke-width="1.8" viewBox="0 0 24 24">
                <path d="M4.318 6.318a4.5 4.5 0 0 1 6.364 0L12 7.636l1.318-1.318a4.5 4.5 0 0 1 6.364 6.364L12 20.364l-7.682-7.682a4.5 4.5 0 0 1 0-6.364Z" />
              </svg>
            </button>
          </div>
          <div class="p-4 flex flex-col gap-1 flex-1">
            <p class="text-[10px] tracking-[0.18em] uppercase text-gray-600 font-light">{{ art.artistName }}</p>
            <p class="font-display italic text-gray-100 text-base leading-snug mb-1">{{ art.title }}</p>
            <p class="text-[11px] text-gray-500 font-light">{{ art.medium }}</p>
            <p class="text-sm font-medium text-gray-100 mt-auto pt-3 border-t border-white/[0.05]">€{{ art.price }}</p>
          </div>
        </RouterLink>
      </div>
    </div>

    <!-- ══════════════ POSITIONS ══════════════ -->
    <div v-else-if="activeTab === 'positions'">
      <p v-if="closeMsg" class="text-center text-green-400 text-sm mb-4 font-mono">{{ closeMsg }}</p>

      <div v-if="positions.length === 0" class="py-20 text-center">
        <p class="font-display italic text-gray-600 text-2xl mb-2">No open positions</p>
        <p class="text-gray-700 text-sm font-light mb-6">Open a leveraged perp position on any artwork.</p>
        <RouterLink to="/market" class="btn-primary text-sm px-6 py-2.5">Open Position</RouterLink>
      </div>

      <div v-else class="space-y-2">
        <div
          v-for="pos in positions"
          :key="pos.id"
          class="card-dark p-4"
        >
          <div class="flex items-start gap-4 flex-wrap">
            <img :src="pos.art?.imageUrl" :alt="pos.art?.title" class="w-14 h-14 object-cover flex-shrink-0 bg-[#0d0d10]" />

            <div class="flex-1 min-w-[160px]">
              <div class="flex items-center gap-2 mb-0.5">
                <span
                  class="text-[9px] tracking-[0.15em] uppercase font-medium px-1.5 py-0.5"
                  :class="pos.side === 'long' ? 'bg-green-800/40 text-green-300' : 'bg-red-800/40 text-red-300'"
                >{{ pos.side }} {{ pos.leverage }}×</span>
              </div>
              <p class="font-display italic text-gray-100 text-sm leading-snug">{{ pos.art?.title }}</p>
              <div class="grid grid-cols-2 gap-x-4 gap-y-0.5 mt-1.5 font-mono text-[11px]">
                <span class="text-gray-600">Entry</span><span class="text-gray-300">${{ fmt(pos.entryPrice) }}</span>
                <span class="text-gray-600">Mark</span><span class="text-white">${{ fmt(pos.cp) }}</span>
                <span class="text-gray-600">Liq.</span><span class="text-amber-400">${{ fmt(pos.liq) }}</span>
              </div>
            </div>

            <div class="text-right min-w-[100px]">
              <p class="text-[9px] text-gray-600 mb-0.5 uppercase tracking-wide">Unrealized PnL</p>
              <p class="font-mono text-lg font-semibold" :class="pos.pnlUsd >= 0 ? 'text-green-400' : 'text-red-400'">
                {{ pos.pnlUsd >= 0 ? '+' : '' }}${{ pos.pnlUsd.toFixed(2) }}
              </p>
              <p class="font-mono text-[11px]" :class="pos.pnlPct >= 0 ? 'text-green-600' : 'text-red-600'">
                {{ pos.pnlPct >= 0 ? '+' : '' }}{{ pos.pnlPct.toFixed(1) }}%
              </p>
            </div>

            <!-- TP/SL indicator -->
            <div v-if="pos.tpsl" class="text-[10px] font-mono text-center min-w-[80px]">
              <p v-if="pos.tpsl.tpPrice" class="text-green-500">TP ${{ fmt(pos.tpsl.tpPrice) }}</p>
              <p v-if="pos.tpsl.slPrice" class="text-red-400">SL ${{ fmt(pos.tpsl.slPrice) }}</p>
            </div>

            <div class="flex gap-2 items-center">
              <button
                class="text-[10px] tracking-[0.15em] uppercase px-3 py-1.5 bg-white/[0.05] text-gray-400 hover:text-white border border-white/[0.08] hover:border-white/20 transition-colors"
                @click="openTpSl(pos, 'perp')"
              >TP / SL</button>
              <button
                class="text-[10px] tracking-[0.15em] uppercase px-3 py-1.5 bg-red-500/10 text-red-400 hover:bg-red-500/20 border border-red-500/20 transition-colors"
                @click="closePos(pos.id)"
              >Close</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ══════════════ ORDERS (TP/SL) ══════════════ -->
    <div v-else-if="activeTab === 'orders'">
      <!-- Active orders -->
      <div class="mb-6">
        <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-3">Active Orders</p>
        <div v-if="store.wallet.tpslOrders.length === 0" class="card-dark p-5 text-center text-gray-600 text-sm font-light">
          No active TP/SL orders.
        </div>
        <div v-else class="space-y-2">
          <div
            v-for="o in store.wallet.tpslOrders"
            :key="o.id"
            class="card-dark p-3 flex items-center gap-3 text-sm"
          >
            <div class="flex-1">
              <span class="text-[9px] tracking-wide uppercase px-1.5 py-0.5 mr-2" :class="o.type === 'perp' ? 'bg-purple-800/30 text-purple-300' : 'bg-blue-800/30 text-blue-300'">{{ o.type }}</span>
              <span class="text-gray-300 font-light">{{ store.ARTWORKS.find(a=>a.id===o.artworkId)?.title }}</span>
            </div>
            <div class="flex gap-4 font-mono text-xs">
              <span v-if="o.tpPrice" class="text-green-400">TP ${{ fmt(o.tpPrice) }}</span>
              <span v-if="o.slPrice" class="text-red-400">SL ${{ fmt(o.slPrice) }}</span>
              <span v-if="o.qty"     class="text-gray-500">{{ o.qty.toFixed(2) }} shares</span>
            </div>
            <button class="text-[10px] uppercase text-gray-600 hover:text-red-400 transition-colors" @click="cancelTpSlOrder(o.id)">Cancel</button>
          </div>
        </div>
      </div>

      <!-- Order history -->
      <div>
        <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-3">History</p>
        <div v-if="store.wallet.orderHistory.length === 0" class="card-dark p-5 text-center text-gray-600 text-sm font-light">
          No triggered orders yet.
        </div>
        <div v-else class="space-y-1.5">
          <div
            v-for="o in store.wallet.orderHistory.slice(0, 20)"
            :key="o.id + o.triggeredAt"
            class="flex items-center gap-3 px-3 py-2 border border-white/[0.04] text-xs font-mono"
          >
            <span :class="o.triggerType === 'take_profit' ? 'text-green-400' : 'text-red-400'">
              {{ o.triggerType === 'take_profit' ? '✓ TP' : '✗ SL' }}
            </span>
            <span class="text-gray-400 flex-1">{{ store.ARTWORKS.find(a=>a.id===o.artworkId)?.title }}</span>
            <span class="text-gray-500">@ ${{ fmt(o.triggerPrice ?? 0) }}</span>
            <span class="text-gray-700">{{ timeAgo(o.triggeredAt) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- ══════════════ AI MONITOR (小龍蝦) ══════════════ -->
    <div v-else-if="activeTab === 'monitor'">
      <div class="grid grid-cols-1 lg:grid-cols-[1fr_380px] gap-6">

        <!-- Config -->
        <div class="card-dark p-5 space-y-4">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-white font-medium">AI Account Monitor</p>
              <p class="text-gray-600 text-[11px] font-light mt-0.5">Connect any AI API to monitor and trade your account in real-time</p>
            </div>
            <button
              class="relative w-11 h-6 rounded-full transition-colors flex-shrink-0"
              :class="monitorDraft.enabled ? 'bg-[#E8552A]' : 'bg-white/10'"
              @click="monitorDraft.enabled = !monitorDraft.enabled"
            >
              <span class="absolute top-1 left-1 w-4 h-4 rounded-full bg-white transition-transform"
                :class="monitorDraft.enabled ? 'translate-x-5' : 'translate-x-0'" />
            </button>
          </div>

          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-600 block mb-1.5">API Endpoint URL</label>
            <input
              v-model="monitorDraft.endpoint"
              type="url"
              placeholder="https://your-ai-api.com/trade"
              class="w-full bg-[#0d0d10] border border-white/[0.1] text-gray-200 px-3 py-2.5 text-sm outline-none focus:border-white/25 placeholder:text-gray-700 font-mono"
            />
          </div>

          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-600 block mb-1.5">API Key (optional)</label>
            <input
              v-model="monitorDraft.apiKey"
              type="password"
              placeholder="Bearer token or API key"
              class="w-full bg-[#0d0d10] border border-white/[0.1] text-gray-200 px-3 py-2.5 text-sm outline-none focus:border-white/25 placeholder:text-gray-700"
            />
          </div>

          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-600 block mb-1.5">
              Polling Interval — <span class="text-white font-mono">{{ monitorDraft.intervalSec }}s</span>
            </label>
            <input v-model="monitorDraft.intervalSec" type="range" min="10" max="300" step="10" class="w-full accent-[#E8552A]" />
            <div class="flex justify-between text-[10px] text-gray-700 mt-0.5">
              <span>10s</span><span>1 min</span><span>5 min</span>
            </div>
          </div>

          <button
            class="w-full py-3 bg-[#E8552A] hover:bg-[#d4461c] text-white text-[11px] tracking-[0.2em] uppercase font-medium transition-colors"
            @click="saveMonitor"
          >
            {{ monitorDraft.enabled ? 'Activate Monitor' : 'Save' }}
          </button>

          <div v-if="store.aiMonitor.lastRun" class="text-[11px] text-gray-600 text-center font-mono">
            Last run: {{ timeAgo(store.aiMonitor.lastRun) }}
          </div>
        </div>

        <!-- Protocol documentation -->
        <div class="space-y-4">
          <div class="card-dark p-4">
            <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-3">Request Format (POST body)</p>
            <pre class="text-[10px] text-gray-400 font-mono leading-relaxed overflow-x-auto bg-black/30 p-3 rounded whitespace-pre-wrap">{{`{
  "timestamp": 1748908800,
  "wallet": {
    "usd": 10000,
    "btc": 0.5,
    "shares": { "1": 250.5 }
  },
  "positions": [{
    "id": "abc123",
    "artworkId": 2,
    "side": "long",
    "leverage": 10,
    "notional": 5000,
    "entryPrice": 2.80,
    "currentPrice": 2.94,
    "pnlUsd": 250
  }],
  "market": {
    "1": { "price": 6.90, "change24h": 1.2 }
  }
}`}}</pre>
          </div>

          <div class="card-dark p-4">
            <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-3">Expected Response</p>
            <pre class="text-[10px] text-gray-400 font-mono leading-relaxed overflow-x-auto bg-black/30 p-3 rounded whitespace-pre-wrap">{{`{
  "actions": [
    { "type": "buy_shares",
      "artworkId": 1,
      "usdAmount": 500 },
    { "type": "sell_shares",
      "artworkId": 2,
      "shares": 100 },
    { "type": "open_perp",
      "artworkId": 3,
      "side": "long",
      "leverage": 5,
      "marginBtc": 0.01 },
    { "type": "close_perp",
      "posId": "abc123" },
    { "type": "set_tpsl",
      "artworkId": 1,
      "tpPrice": 7.5,
      "slPrice": 6.0 }
  ]
}`}}</pre>
          </div>

          <!-- Action log -->
          <div v-if="store.aiMonitor.actionLog.length" class="card-dark p-4">
            <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-3">Recent Actions</p>
            <div class="space-y-2 max-h-48 overflow-y-auto">
              <div v-for="(entry, i) in store.aiMonitor.actionLog" :key="i"
                class="text-[11px] border-b border-white/[0.04] pb-2">
                <div class="flex items-center justify-between mb-1">
                  <span class="text-gray-600 font-mono">{{ timeAgo(entry.time) }}</span>
                  <span v-if="entry.error" class="text-red-400">{{ entry.error }}</span>
                  <span v-else class="text-green-500">{{ entry.actions?.length ?? 0 }} actions</span>
                </div>
                <div v-if="entry.actions?.length" class="flex flex-wrap gap-1">
                  <span v-for="(act, j) in entry.actions.slice(0, 3)" :key="j"
                    class="text-[9px] uppercase tracking-wide px-1.5 py-0.5 bg-white/[0.05] text-gray-500">
                    {{ act.type }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- ══════════════ SETTINGS ══════════════ -->
    <div v-else-if="activeTab === 'settings'" class="grid grid-cols-1 lg:grid-cols-2 gap-5 max-w-3xl">

      <!-- Personal info -->
      <div class="card-dark p-5 lg:col-span-2">
        <div class="flex items-center justify-between mb-4">
          <p class="text-[10px] tracking-[0.25em] uppercase text-gray-500 font-light">Personal Info</p>
          <button
            class="text-[10px] tracking-[0.15em] uppercase transition-colors"
            :class="editingProfile ? 'text-[#E8552A]' : 'text-gray-600 hover:text-white'"
            @click="editingProfile ? saveProfile() : (editingProfile = true)"
          >{{ editingProfile ? 'Save' : 'Edit' }}</button>
        </div>
        <div class="flex items-start gap-5 flex-wrap">
          <!-- Avatar -->
          <span
            class="w-14 h-14 rounded-full flex items-center justify-center text-xl font-bold flex-shrink-0"
            :style="{ backgroundColor: auth.color + '22', color: auth.color, border: `2px solid ${auth.color}44` }"
          >{{ auth.initials }}</span>
          <div class="flex-1 min-w-[200px] space-y-3">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label class="text-[10px] uppercase text-gray-600 block mb-1">Username</label>
                <p class="font-mono text-gray-400 text-sm px-3 py-2 bg-white/[0.03] border border-white/[0.05]">
                  {{ auth.user?.username ?? '—' }}
                </p>
              </div>
              <div>
                <label class="text-[10px] uppercase text-gray-600 block mb-1">Display Name</label>
                <input
                  v-if="editingProfile"
                  v-model="profileDraft.displayName"
                  type="text"
                  class="w-full bg-[#0d0d10] border border-white/[0.2] text-white px-3 py-2 text-sm outline-none focus:border-[#E8552A]/50"
                />
                <p v-else class="text-gray-200 text-sm px-3 py-2 bg-white/[0.03] border border-white/[0.05]">
                  {{ auth.user?.displayName ?? '—' }}
                </p>
              </div>
            </div>
            <div>
              <label class="text-[10px] uppercase text-gray-600 block mb-1">Bio</label>
              <textarea
                v-if="editingProfile"
                v-model="profileDraft.bio"
                rows="2"
                class="w-full bg-[#0d0d10] border border-white/[0.2] text-white px-3 py-2 text-sm outline-none focus:border-[#E8552A]/50 resize-none"
              />
              <p v-else class="text-gray-400 text-sm px-3 py-2 bg-white/[0.03] border border-white/[0.05] font-light">
                {{ auth.user?.bio ?? '—' }}
              </p>
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="text-[10px] uppercase text-gray-600 block mb-1">Starting USD</label>
                <p class="font-mono text-gray-500 text-sm px-3 py-2 bg-white/[0.03] border border-white/[0.05]">
                  ${{ auth.user?.startUsd?.toLocaleString() ?? '—' }}
                </p>
              </div>
              <div>
                <label class="text-[10px] uppercase text-gray-600 block mb-1">Starting BTC</label>
                <p class="font-mono text-amber-600 text-sm px-3 py-2 bg-white/[0.03] border border-white/[0.05]">
                  {{ auth.user?.startBtc ?? '—' }}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Display currency -->
      <div class="card-dark p-5">
        <p class="text-[10px] tracking-[0.25em] uppercase text-gray-500 mb-4 font-light">Display Currency</p>
        <div class="mb-4">
          <p class="text-[10px] tracking-[0.15em] uppercase text-gray-600 mb-2">Crypto Pricing</p>
          <div class="grid grid-cols-5 gap-1">
            <button
              v-for="c in prices.CRYPTOS" :key="c.symbol"
              class="py-1.5 text-[10px] font-medium uppercase transition-colors"
              :class="prices.selectedCrypto === c.symbol ? 'bg-[#E8552A] text-white' : 'bg-white/[0.04] text-gray-500 hover:text-white'"
              @click="prices.setCrypto(c.symbol)"
            >{{ c.symbol }}</button>
          </div>
        </div>
        <div>
          <p class="text-[10px] tracking-[0.15em] uppercase text-gray-600 mb-2">Fiat Reference</p>
          <div class="grid grid-cols-3 gap-1">
            <button
              v-for="f in prices.FIATS" :key="f.code"
              class="py-1.5 text-[10px] font-medium uppercase transition-colors"
              :class="prices.selectedFiat === f.code ? 'bg-white/15 text-white' : 'bg-white/[0.03] text-gray-500 hover:text-white'"
              @click="prices.setFiat(f.code)"
            >{{ f.code }}</button>
          </div>
        </div>
      </div>

      <!-- Language -->
      <div class="card-dark p-5">
        <p class="text-[10px] tracking-[0.25em] uppercase text-gray-500 mb-4 font-light">Language</p>
        <div class="grid grid-cols-2 gap-1.5">
          <button
            v-for="l in LANGUAGES" :key="l.code"
            class="flex items-center gap-2 px-3 py-2.5 border transition-colors text-left"
            :class="lang === l.code
              ? 'border-[#E8552A]/60 bg-[#E8552A]/10 text-white'
              : 'border-white/[0.07] text-gray-500 hover:text-gray-200 hover:border-white/20'"
            @click="setLang(l.code)"
          >
            <span class="text-[10px] font-mono tracking-wider text-gray-600">{{ l.code }}</span>
            <span class="text-sm font-light">{{ l.label }}</span>
            <span v-if="lang === l.code" class="ml-auto w-1.5 h-1.5 rounded-full bg-[#E8552A]" />
          </button>
        </div>
        <p class="text-[10px] text-gray-700 mt-3 font-light">
          UI translation coming soon. Selection is saved.
        </p>
      </div>

      <!-- Notifications -->
      <div class="card-dark p-5 lg:col-span-2">
        <p class="text-[10px] tracking-[0.25em] uppercase text-gray-500 mb-4 font-light">Notifications</p>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
          <div
            v-for="item in [
              { key: 'tpslTriggers',  label: 'TP / SL triggered',         desc: 'When a conditional order fires'           },
              { key: 'priceAlerts',   label: 'Price alerts',               desc: 'Significant price moves on watched assets' },
              { key: 'tradeConfirm',  label: 'Trade confirmations',        desc: 'Every buy / sell execution'               },
              { key: 'liquidation',   label: 'Liquidation warnings',       desc: 'When margin ratio approaches limit'       },
              { key: 'aiActions',     label: 'AI monitor actions',         desc: 'Each action taken by the AI agent'        },
              { key: 'marketMoves',   label: 'Market moves (>5%)',         desc: 'Large 24h price swings across market'     },
            ]"
            :key="item.key"
            class="flex items-center justify-between px-3 py-3 border border-white/[0.06] hover:border-white/[0.12] transition-colors"
          >
            <div class="flex-1 min-w-0 pr-4">
              <p class="text-sm text-gray-200 font-light">{{ item.label }}</p>
              <p class="text-[10px] text-gray-600 font-light mt-0.5">{{ item.desc }}</p>
            </div>
            <button
              class="relative w-10 h-5 rounded-full transition-colors flex-shrink-0"
              :class="notifs[item.key] ? 'bg-[#E8552A]' : 'bg-white/10'"
              @click="notifs[item.key] = !notifs[item.key]; saveNotifs()"
            >
              <span
                class="absolute top-0.5 left-0.5 w-4 h-4 rounded-full bg-white transition-transform"
                :class="notifs[item.key] ? 'translate-x-5' : 'translate-x-0'"
              />
            </button>
          </div>
        </div>
      </div>

      <!-- Danger zone / Logout -->
      <div class="card-dark p-5 lg:col-span-2 border-red-900/20">
        <p class="text-[10px] tracking-[0.25em] uppercase text-gray-500 mb-4 font-light">Account</p>
        <div class="flex items-center justify-between flex-wrap gap-4">
          <div>
            <p class="text-gray-300 text-sm font-light">Signed in as <span class="text-white font-medium">{{ auth.user?.displayName }}</span></p>
            <p class="text-gray-600 text-[11px] font-mono mt-0.5">@{{ auth.user?.username }}</p>
          </div>
          <button
            class="flex items-center gap-2 px-5 py-2.5 border border-red-500/30 text-red-400 hover:bg-red-500/10 hover:border-red-500/60 transition-colors text-[11px] tracking-[0.15em] uppercase font-medium"
            @click="logout"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                d="M15.75 9V5.25A2.25 2.25 0 0 0 13.5 3h-6a2.25 2.25 0 0 0-2.25 2.25v13.5A2.25 2.25 0 0 0 7.5 21h6a2.25 2.25 0 0 0 2.25-2.25V15M12 9l-3 3m0 0 3 3m-3-3h12.75"/>
            </svg>
            Sign Out
          </button>
        </div>
      </div>

    </div>

  </div>

  <!-- ══════════════ SELL MODAL ══════════════ -->
  <Teleport to="body">
    <div v-if="sellModal" class="fixed inset-0 z-[9000] bg-black/60 backdrop-blur-sm flex items-center justify-center p-4" @click.self="sellModal = null">
      <div class="bg-[#111116] border border-white/[0.1] w-full max-w-sm p-5 shadow-2xl">
        <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-1">Sell Shares</p>
        <p class="font-display italic text-white text-lg mb-4">{{ sellModal.art?.title }}</p>
        <div class="mb-3">
          <label class="text-[10px] uppercase text-gray-600 block mb-1.5">Shares to sell (max {{ sellModal.maxQty.toFixed(2) }})</label>
          <input v-model="sellQty" type="number" :max="sellModal.maxQty" min="0.01" step="0.01"
            class="w-full bg-[#0d0d10] border border-white/[0.1] text-white px-3 py-2.5 text-sm font-mono outline-none focus:border-white/25" />
          <p class="text-[11px] text-gray-600 mt-1">
            ≈ ${{ (parseFloat(sellQty) * (store.prices[sellModal.art?.id] ?? 0)).toFixed(2) }}
          </p>
        </div>
        <p v-if="sellMsg" class="text-[11px] text-center mb-3" :class="sellMsg.startsWith('Sold') ? 'text-green-400' : 'text-red-400'">{{ sellMsg }}</p>
        <div class="flex gap-2">
          <button class="flex-1 py-2.5 bg-red-600 hover:bg-red-500 text-white text-[11px] tracking-[0.15em] uppercase" @click="executeSell">Sell</button>
          <button class="flex-1 py-2.5 bg-white/[0.05] text-gray-400 text-[11px] tracking-[0.15em] uppercase" @click="sellModal = null">Cancel</button>
        </div>
      </div>
    </div>

    <!-- TP/SL MODAL -->
    <div v-if="tpslModal" class="fixed inset-0 z-[9000] bg-black/60 backdrop-blur-sm flex items-center justify-center p-4" @click.self="tpslModal = null">
      <div class="bg-[#111116] border border-white/[0.1] w-full max-w-sm p-5 shadow-2xl">
        <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-1">Set TP / SL</p>
        <p class="font-display italic text-white text-lg mb-1">{{ store.ARTWORKS.find(a => a.id === tpslModal.artworkId)?.title }}</p>
        <p class="font-mono text-gray-500 text-[11px] mb-4">Current: ${{ fmt(tpslModal.currentPrice) }}</p>

        <div class="space-y-3 mb-4">
          <div>
            <label class="text-[10px] uppercase text-green-600 block mb-1.5">Take Profit Price (USD)</label>
            <input v-model="tpInput" type="number" step="0.0001" placeholder="e.g. 7.50"
              class="w-full bg-[#0d0d10] border border-green-800/40 text-white px-3 py-2 text-sm font-mono outline-none focus:border-green-500/50" />
          </div>
          <div>
            <label class="text-[10px] uppercase text-red-500 block mb-1.5">Stop Loss Price (USD)</label>
            <input v-model="slInput" type="number" step="0.0001" placeholder="e.g. 6.00"
              class="w-full bg-[#0d0d10] border border-red-800/40 text-white px-3 py-2 text-sm font-mono outline-none focus:border-red-500/50" />
          </div>
          <div v-if="tpslModal.type === 'spot'">
            <label class="text-[10px] uppercase text-gray-600 block mb-1.5">Shares (leave blank = all)</label>
            <input v-model="tpslQty" type="number" step="0.01" placeholder="Optional: partial quantity"
              class="w-full bg-[#0d0d10] border border-white/[0.08] text-white px-3 py-2 text-sm font-mono outline-none focus:border-white/20" />
          </div>
        </div>

        <div class="flex gap-2">
          <button class="flex-1 py-2.5 bg-[#E8552A] hover:bg-[#d4461c] text-white text-[11px] tracking-[0.15em] uppercase" @click="saveTpSl">Set Order</button>
          <button class="flex-1 py-2.5 bg-white/[0.05] text-gray-400 text-[11px] tracking-[0.15em] uppercase" @click="tpslModal = null">Cancel</button>
        </div>
        <button
          v-if="tpslModal.type === 'spot' && store.wallet.tpslOrders.find(o => o.artworkId === tpslModal.artworkId && o.type === 'spot')"
          class="w-full mt-2 py-1.5 text-[10px] uppercase text-gray-600 hover:text-red-400 transition-colors"
          @click="clearCurrentTpSl"
        >Remove Order</button>
      </div>
    </div>
  </Teleport>
</template>

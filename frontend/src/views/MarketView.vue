<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useTradingStore, TOTAL_SHARES } from '@/stores/trading'
import { usePricesStore } from '@/stores/prices'
import CryptoPriceBadge from '@/components/ui/CryptoPriceBadge.vue'

const store  = useTradingStore()
const prices = usePricesStore()
onMounted(() => { store.init(); prices.startPolling() })
onUnmounted(() => { store.destroy(); prices.stopPolling() })

// ── Layout toggle ─────────────────────────────────────────────────────────────
const layout = ref('grid')   // 'grid' | 'list'

const artRows = computed(() =>
  store.ARTWORKS.map(art => {
    const p    = store.prices[art.id] ?? art.initPrice
    const chg  = store.priceChange(art.id)
    const vol  = store.volume24h(art.id)
    const mcap = p * TOTAL_SHARES
    const pts  = store.history[art.id] ?? []
    return { ...art, p, chg, vol, mcap, sparkPts: pts }
  })
)

const totalMcap = computed(() => store.totalMcap)
const btcPrice  = computed(() => store.btcPrice)

// ── SVG sparkline helpers ─────────────────────────────────────────────────────
function sparkPoints(pts, w = 80, h = 28) {
  if (pts.length < 2) return ''
  const slice  = pts.slice(-50)
  const prices = slice.map(pt => pt.p)
  const min    = Math.min(...prices)
  const max    = Math.max(...prices)
  const range  = max - min || min * 0.01
  return slice.map((pt, i) => {
    const x = (i / (slice.length - 1)) * w
    const y = h - ((pt.p - min) / range) * h
    return `${x.toFixed(1)},${y.toFixed(1)}`
  }).join(' ')
}

// Full-width sparkline path (for grid cards)
function sparkPath(pts, w, h = 36) {
  if (pts.length < 2) return ''
  const slice  = pts.slice(-60)
  const ps     = slice.map(pt => pt.p)
  const min    = Math.min(...ps)
  const max    = Math.max(...ps)
  const range  = max - min || min * 0.01
  const coords = slice.map((pt, i) => {
    const x = (i / (slice.length - 1)) * w
    const y = h - ((pt.p - min) / range) * h
    return `${x.toFixed(1)},${y.toFixed(1)}`
  })
  return 'M ' + coords.join(' L ')
}

function fmt(n) {
  return n < 1 ? n.toFixed(4) : n.toFixed(2)
}
function fmtK(n) {
  if (n >= 1e6) return '$' + (n / 1e6).toFixed(2) + 'M'
  if (n >= 1e3) return '$' + (n / 1e3).toFixed(1)  + 'K'
  return '$' + n.toFixed(0)
}
</script>

<template>
  <!-- ── Top stats bar ────────────────────────────────────────────────────────── -->
  <div class="bg-[#070709] border-b border-white/[0.06] py-2">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 flex items-center gap-8 text-[11px] tracking-[0.12em] uppercase font-light overflow-x-auto whitespace-nowrap">
      <span class="text-gray-500">Total MCap <span class="text-white font-medium">{{ fmtK(totalMcap) }}</span></span>
      <span class="text-gray-500">Artworks <span class="text-white font-medium">{{ store.ARTWORKS.length }}</span></span>
      <span class="text-gray-500">BTC <span class="text-amber-400 font-medium">${{ btcPrice.toFixed(0) }}</span></span>
      <span class="ml-auto text-gray-700 text-[10px] hidden md:flex items-center gap-1.5">
        VMM Active
        <span class="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
      </span>
    </div>
  </div>

  <!-- ── Page header ───────────────────────────────────────────────────────────── -->
  <div class="border-b border-white/[0.06]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-10 flex items-end justify-between gap-4 flex-wrap">
      <div>
        <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-3 font-light flex items-center gap-2">
          <span class="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
          Live Trading
        </p>
        <h1 class="font-display text-3xl lg:text-[2.75rem] font-normal italic text-white leading-tight">Art Market</h1>
        <p class="text-sm text-gray-500 font-light mt-2">Fractional shares · Perpetual futures · AI-automated strategies</p>
      </div>

      <!-- Layout toggle -->
      <div class="flex items-center gap-1 border border-white/[0.1] p-0.5 flex-shrink-0">
        <!-- Grid -->
        <button
          class="p-2 transition-colors"
          :class="layout === 'grid' ? 'bg-white/10 text-white' : 'text-gray-600 hover:text-gray-400'"
          title="Grid layout"
          @click="layout = 'grid'"
        >
          <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 16 16">
            <rect x="1" y="1" width="6" height="6" rx="0.5"/>
            <rect x="9" y="1" width="6" height="6" rx="0.5"/>
            <rect x="1" y="9" width="6" height="6" rx="0.5"/>
            <rect x="9" y="9" width="6" height="6" rx="0.5"/>
          </svg>
        </button>
        <!-- List -->
        <button
          class="p-2 transition-colors"
          :class="layout === 'list' ? 'bg-white/10 text-white' : 'text-gray-600 hover:text-gray-400'"
          title="List layout"
          @click="layout = 'list'"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 16 16">
            <line x1="2" y1="4"  x2="14" y2="4"  stroke-width="1.5" stroke-linecap="round"/>
            <line x1="2" y1="8"  x2="14" y2="8"  stroke-width="1.5" stroke-linecap="round"/>
            <line x1="2" y1="12" x2="14" y2="12" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
        </button>
      </div>
    </div>
  </div>

  <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-8">

    <!-- ══════════════════════════════════════════════════════════════
         GRID LAYOUT
         ══════════════════════════════════════════════════════════════ -->
    <Transition name="layout" mode="out-in">
      <div v-if="layout === 'grid'" key="grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
        <RouterLink
          v-for="row in artRows"
          :key="row.id"
          :to="`/trade/${row.id}`"
          class="card-dark group flex flex-col overflow-hidden"
        >
          <!-- Artwork image -->
          <div class="relative overflow-hidden aspect-[4/3] bg-[#0d0d10]">
            <img
              :src="row.imageUrl"
              :alt="row.title"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
              loading="lazy"
              @error="e => { e.target.src='https://picsum.photos/seed/' + row.id + '/600/600' }"
            />
            <!-- 24h badge -->
            <span
              class="absolute top-3 right-3 text-[10px] font-mono px-2 py-0.5 border"
              :class="row.chg >= 0
                ? 'bg-green-500/20 text-green-400 border-green-500/30'
                : 'bg-red-500/20 text-red-400 border-red-500/30'"
            >
              {{ row.chg >= 0 ? '+' : '' }}{{ row.chg.toFixed(2) }}%
            </span>
          </div>

          <!-- Info block -->
          <div class="p-4 flex flex-col gap-2 flex-1">
            <!-- Title + artist -->
            <div>
              <p class="font-display italic text-white text-base leading-snug line-clamp-1">{{ row.title }}</p>
              <p class="text-[10px] tracking-[0.18em] uppercase text-gray-500 font-light mt-0.5">{{ row.artist }}</p>
            </div>

            <!-- Price row -->
            <div class="flex items-baseline justify-between gap-2">
              <div>
                <p class="text-[9px] tracking-[0.15em] uppercase text-gray-600 mb-0.5">Per Share</p>
                <span class="font-mono text-sm text-white">${{ fmt(row.p) }}</span>
              </div>
              <div class="text-right">
                <p class="text-[9px] tracking-[0.15em] uppercase text-gray-600 mb-0.5">Market Cap</p>
                <CryptoPriceBadge :usd-value="row.mcap" size="sm" :show-fiat="false" />
              </div>
            </div>

            <!-- Sparkline (full-width SVG) -->
            <div class="w-full h-10 overflow-hidden -mx-0.5">
              <svg
                class="w-full h-full overflow-visible"
                viewBox="0 0 200 36"
                preserveAspectRatio="none"
              >
                <!-- Fill area -->
                <path
                  v-if="sparkPath(row.sparkPts, 200)"
                  :d="sparkPath(row.sparkPts, 200) + ' L 200,36 L 0,36 Z'"
                  :fill="row.chg >= 0 ? 'rgba(34,197,94,0.08)' : 'rgba(239,68,68,0.08)'"
                />
                <!-- Line -->
                <path
                  v-if="sparkPath(row.sparkPts, 200)"
                  :d="sparkPath(row.sparkPts, 200)"
                  fill="none"
                  :stroke="row.chg >= 0 ? '#22c55e' : '#ef4444'"
                  stroke-width="1.5"
                  stroke-linejoin="round"
                  stroke-linecap="round"
                  vector-effect="non-scaling-stroke"
                />
              </svg>
            </div>

            <!-- Trade button -->
            <button
              class="w-full mt-1 py-2.5 text-[11px] tracking-[0.2em] uppercase font-medium transition-colors bg-white/[0.05] group-hover:bg-[#E8552A] text-gray-400 group-hover:text-white border border-white/[0.08] group-hover:border-[#E8552A]"
            >
              Trade
            </button>
          </div>
        </RouterLink>
      </div>

      <!-- ══════════════════════════════════════════════════════════════
           LIST LAYOUT
           ══════════════════════════════════════════════════════════════ -->
      <div v-else key="list">
        <!-- Column headers -->
        <div class="hidden lg:grid grid-cols-[2fr_1fr_1fr_1fr_1fr_100px_120px] gap-4 text-[10px] tracking-[0.2em] uppercase text-gray-600 font-light border-b border-white/[0.07] pb-3 mb-1">
          <span>Artwork</span>
          <span class="text-right">Price / Share</span>
          <span class="text-right">24h</span>
          <span class="text-right">Market Cap</span>
          <span class="text-right">Volume</span>
          <span class="text-right">Chart</span>
          <span />
        </div>

        <!-- Rows -->
        <div class="divide-y divide-white/[0.04]">
          <div
            v-for="row in artRows"
            :key="row.id"
            class="grid grid-cols-1 lg:grid-cols-[2fr_1fr_1fr_1fr_1fr_100px_120px] gap-4 py-4 items-center hover:bg-white/[0.02] transition-colors -mx-2 px-2"
          >
            <!-- Artwork info -->
            <div class="flex items-center gap-3">
              <img :src="row.imageUrl" :alt="row.title" class="w-10 h-10 object-cover flex-shrink-0 bg-[#0d0d10]" @error="e => { e.target.src='https://picsum.photos/seed/' + row.id + '/80/80' }" />
              <div class="min-w-0">
                <p class="font-display italic text-gray-100 text-[0.9rem] leading-snug truncate">{{ row.title }}</p>
                <p class="text-[10px] tracking-[0.15em] uppercase text-gray-500 font-light">{{ row.artist }}</p>
              </div>
            </div>

            <!-- Price / share -->
            <div class="text-right">
              <span class="font-mono text-sm font-medium text-white">${{ fmt(row.p) }}</span>
              <p class="text-[10px] text-gray-600 font-light">per share</p>
            </div>

            <!-- 24h Change -->
            <div class="text-right">
              <span
                class="text-sm font-medium font-mono"
                :class="row.chg >= 0 ? 'text-green-400' : 'text-red-400'"
              >
                {{ row.chg >= 0 ? '+' : '' }}{{ row.chg.toFixed(2) }}%
              </span>
            </div>

            <!-- Market cap -->
            <div class="text-right">
              <span class="text-sm text-gray-300 font-light">{{ fmtK(row.mcap) }}</span>
            </div>

            <!-- Volume -->
            <div class="text-right">
              <span class="text-sm text-gray-500 font-light">{{ fmtK(row.vol) }}</span>
            </div>

            <!-- Sparkline -->
            <div class="flex justify-end">
              <svg width="80" height="30" class="overflow-visible">
                <polyline
                  v-if="sparkPoints(row.sparkPts)"
                  :points="sparkPoints(row.sparkPts)"
                  fill="none"
                  :stroke="row.chg >= 0 ? '#22c55e' : '#ef4444'"
                  stroke-width="1.5"
                  stroke-linejoin="round"
                  stroke-linecap="round"
                />
              </svg>
            </div>

            <!-- Trade button -->
            <div class="flex justify-end">
              <RouterLink
                :to="`/trade/${row.id}`"
                class="text-[11px] tracking-[0.15em] uppercase font-medium px-4 py-2 bg-white/[0.06] text-gray-300 hover:bg-[#E8552A] hover:text-white border border-white/[0.08] hover:border-[#E8552A] transition-colors duration-150"
              >
                Trade
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Disclaimer -->
    <p class="text-[10px] text-gray-700 font-light mt-10 text-center leading-relaxed max-w-2xl mx-auto">
      All prices are simulated for demonstration purposes. Virtual Market Makers (VMM) provide liquidity via stochastic price models.
      This platform does not facilitate real financial transactions.
    </p>
  </div>
</template>

<style scoped>
.layout-enter-active, .layout-leave-active { transition: opacity 0.15s ease; }
.layout-enter-from, .layout-leave-to { opacity: 0; }
</style>

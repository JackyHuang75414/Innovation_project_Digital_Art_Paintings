<script setup>
import { computed, onMounted, onUnmounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useTradingStore, TOTAL_SHARES } from '@/stores/trading'
import { usePricesStore } from '@/stores/prices'
import CryptoPriceBadge from '@/components/ui/CryptoPriceBadge.vue'

const store  = useTradingStore()
const prices = usePricesStore()
onMounted(() => { store.init(); prices.startPolling() })
onUnmounted(() => prices.stopPolling())

const gainers = computed(() =>
  [...store.ARTWORKS]
    .map(a => ({ ...a, chg: store.priceChange(a.id), mcapUsd: (store.prices[a.id] ?? a.initPrice) * TOTAL_SHARES }))
    .sort((a, b) => b.chg - a.chg).slice(0, 3)
)
const losers = computed(() =>
  [...store.ARTWORKS]
    .map(a => ({ ...a, chg: store.priceChange(a.id), mcapUsd: (store.prices[a.id] ?? a.initPrice) * TOTAL_SHARES }))
    .sort((a, b) => a.chg - b.chg).slice(0, 3)
)
const featured = computed(() =>
  store.ARTWORKS.slice(0, 3).map(a => ({
    ...a,
    mcapUsd: (store.prices[a.id] ?? a.initPrice) * TOTAL_SHARES,
    chg: store.priceChange(a.id),
  }))
)

const totalMcap = computed(() => store.totalMcap)
const vol24h    = computed(() => store.ARTWORKS.reduce((s, a) => s + store.volume24h(a.id), 0))

function fmtK(n) {
  if (n >= 1e6) return '$' + (n / 1e6).toFixed(2) + 'M'
  if (n >= 1e3) return '$' + (n / 1e3).toFixed(1)  + 'K'
  return '$' + n.toFixed(0)
}
</script>

<template>
  <!-- ── Hero ──────────────────────────────────────────────────────────────── -->
  <section class="relative min-h-[92vh] flex flex-col justify-end overflow-hidden">
    <!-- Background collage of artwork images -->
    <div class="absolute inset-0 grid grid-cols-3 opacity-25">
      <div
        v-for="art in store.ARTWORKS"
        :key="art.id"
        class="bg-cover bg-center"
        :style="{ backgroundImage: `url(${art.imageUrl.replace('w=400', 'w=600')})` }"
      />
    </div>
    <div class="absolute inset-0 bg-gradient-to-b from-[#09090b]/50 via-[#09090b]/70 to-[#09090b]" />

    <div class="relative z-10 max-w-screen-xl mx-auto px-6 lg:px-16 pb-16 pt-32">
      <p class="text-[10px] tracking-[0.4em] uppercase text-[#E8552A] mb-5 font-light">The Future of Art Finance</p>
      <h1 class="font-display text-5xl md:text-7xl lg:text-[5.5rem] font-normal italic text-white leading-[1.05] mb-6 max-w-4xl">
        Fractional Art.<br/>Perpetual Markets.
      </h1>
      <p class="text-gray-400 text-lg font-light mb-10 max-w-xl leading-relaxed">
        Trade fractional shares of premium artworks using crypto. Deploy AI agents to automate your strategy 24/7.
      </p>
      <div class="flex items-center gap-4 flex-wrap">
        <RouterLink to="/market" class="btn-primary">Enter Market</RouterLink>
        <RouterLink to="/market" class="btn-outline">Discover Art</RouterLink>
      </div>
    </div>

    <!-- Live stats strip -->
    <div class="relative z-10 border-t border-white/[0.08] bg-[#09090b]/80 backdrop-blur-sm">
      <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-4 grid grid-cols-2 md:grid-cols-4 gap-6">
        <div>
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-1">Total MCap</p>
          <p class="font-mono text-white text-lg">{{ fmtK(totalMcap) }}</p>
        </div>
        <div>
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-1">24h Volume</p>
          <p class="font-mono text-white text-lg">{{ fmtK(vol24h) }}</p>
        </div>
        <div>
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-1">Works Listed</p>
          <p class="font-mono text-white text-lg">{{ store.ARTWORKS.length }}</p>
        </div>
        <div>
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-1">BTC / USD</p>
          <p class="font-mono text-amber-400 text-lg">${{ prices.cryptoUsd.BTC?.toLocaleString() }}</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Market Movers ──────────────────────────────────────────────────────── -->
  <section class="border-b border-white/[0.06]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-14">
      <div class="flex items-center justify-between mb-8">
        <div>
          <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-2 font-light flex items-center gap-2">
            <span class="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse" />
            Live
          </p>
          <h2 class="font-display text-2xl font-normal italic text-white">Market Movers</h2>
        </div>
        <RouterLink to="/market" class="text-[11px] tracking-[0.15em] uppercase text-gray-500 hover:text-white transition-colors">
          Full Market →
        </RouterLink>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <p class="text-[10px] tracking-[0.2em] uppercase text-green-600 mb-3 font-light">Top Gainers (24h)</p>
          <div class="space-y-1.5">
            <RouterLink
              v-for="art in gainers" :key="art.id"
              :to="`/trade/${art.id}`"
              class="flex items-center gap-3 card-dark p-3 hover:border-white/20 group"
            >
              <img :src="art.imageUrl" :alt="art.title" class="w-10 h-10 object-cover flex-shrink-0" />
              <div class="flex-1 min-w-0">
                <p class="font-display italic text-[0.82rem] text-gray-200 truncate leading-tight">{{ art.title }}</p>
                <CryptoPriceBadge :usd-value="art.mcapUsd" size="sm" />
              </div>
              <span class="font-mono text-sm text-green-400 flex-shrink-0">+{{ art.chg.toFixed(2) }}%</span>
            </RouterLink>
          </div>
        </div>
        <div>
          <p class="text-[10px] tracking-[0.2em] uppercase text-red-600 mb-3 font-light">Top Losers (24h)</p>
          <div class="space-y-1.5">
            <RouterLink
              v-for="art in losers" :key="art.id"
              :to="`/trade/${art.id}`"
              class="flex items-center gap-3 card-dark p-3 hover:border-white/20 group"
            >
              <img :src="art.imageUrl" :alt="art.title" class="w-10 h-10 object-cover flex-shrink-0" />
              <div class="flex-1 min-w-0">
                <p class="font-display italic text-[0.82rem] text-gray-200 truncate leading-tight">{{ art.title }}</p>
                <CryptoPriceBadge :usd-value="art.mcapUsd" size="sm" />
              </div>
              <span class="font-mono text-sm text-red-400 flex-shrink-0">{{ art.chg.toFixed(2) }}%</span>
            </RouterLink>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Featured Works ─────────────────────────────────────────────────────── -->
  <section class="border-b border-white/[0.06]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-16">
      <div class="flex items-center justify-between mb-9">
        <div>
          <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-2 font-light">Featured</p>
          <h2 class="font-display text-2xl font-normal italic text-white">Selected Works</h2>
        </div>
        <RouterLink to="/market" class="text-[11px] tracking-[0.15em] uppercase text-gray-500 hover:text-white transition-colors">All Works →</RouterLink>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
        <RouterLink
          v-for="art in featured" :key="art.id"
          :to="`/trade/${art.id}`"
          class="card-dark group overflow-hidden flex flex-col"
        >
          <div class="relative overflow-hidden aspect-[4/3] bg-[#0d0d10]">
            <img
              :src="art.imageUrl.replace('w=400', 'w=800')"
              :alt="art.title"
              class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
            />
            <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />
            <span
              class="absolute top-3 right-3 text-[10px] font-mono px-2 py-0.5 border"
              :class="art.chg >= 0
                ? 'bg-green-500/20 text-green-400 border-green-500/30'
                : 'bg-red-500/20 text-red-400 border-red-500/30'"
            >{{ art.chg >= 0 ? '+' : '' }}{{ art.chg.toFixed(2) }}%</span>
          </div>
          <div class="p-4 flex flex-col gap-1.5 flex-1">
            <p class="text-[10px] tracking-[0.2em] uppercase text-gray-500 font-light">{{ art.artist }}</p>
            <p class="font-display italic text-gray-100 text-base leading-snug">{{ art.title }}</p>
            <div class="mt-auto pt-3 border-t border-white/[0.06] flex items-end justify-between">
              <CryptoPriceBadge :usd-value="art.mcapUsd" />
              <span class="text-[10px] tracking-[0.15em] uppercase text-gray-600 group-hover:text-[#E8552A] transition-colors">Trade →</span>
            </div>
          </div>
        </RouterLink>
      </div>
    </div>
  </section>

  <!-- ── Platform capabilities ─────────────────────────────────────────────── -->
  <section class="border-b border-white/[0.06]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-16">
      <div class="text-center mb-12">
        <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-3 font-light">How It Works</p>
        <h2 class="font-display text-3xl font-normal italic text-white">Speculate Like a Pro</h2>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
        <div
          v-for="feat in [
            { icon: '◈', title: 'Fractional Shares', desc: 'Each artwork is tokenised into 1,000,000 shares. Buy any amount. Price per share floats with live supply and demand.' },
            { icon: '⟳', title: 'Perpetual Futures', desc: 'Go long or short on art price with up to 50× leverage. BTC margin means your collateral itself is volatile — compounding exposure.' },
            { icon: '◉', title: 'AI Automation', desc: 'Deploy momentum, mean-reversion, or grid bots. Plug in your own AI via API for custom strategies that run 24/7.' },
          ]"
          :key="feat.title"
          class="card-dark p-7 flex flex-col gap-4"
        >
          <span class="text-3xl text-[#E8552A]">{{ feat.icon }}</span>
          <h3 class="font-display italic text-white text-lg">{{ feat.title }}</h3>
          <p class="text-sm text-gray-500 font-light leading-relaxed">{{ feat.desc }}</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ── AI Curator CTA ─────────────────────────────────────────────────────── -->
  <section>
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-14 flex flex-col md:flex-row items-center justify-between gap-8">
      <div>
        <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-3 font-light">Powered by AI</p>
        <h2 class="font-display text-2xl font-normal italic text-white mb-2">Your Personal Art Curator</h2>
        <p class="text-gray-500 font-light text-sm max-w-sm leading-relaxed">
          Not sure where to start? Let our AI guide you toward works that match your taste and risk appetite.
        </p>
      </div>
      <button
        class="flex items-center gap-3 card-dark hover:border-white/20 px-6 py-4 transition-all text-left flex-shrink-0"
        onclick="document.querySelector('[aria-label=\'Open AI art curator\']')?.click()"
      >
        <svg class="w-5 h-5 text-[#E8552A] flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
            d="M9.813 15.904 9 18.75l-.813-2.846a4.5 4.5 0 0 0-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 0 0 3.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 0 0 3.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 0 0-3.09 3.09Z"/>
        </svg>
        <div>
          <p class="text-white text-sm font-medium">Open AI Curator</p>
          <p class="text-gray-600 text-[11px]">Personalised art recommendations</p>
        </div>
      </button>
    </div>
  </section>
</template>

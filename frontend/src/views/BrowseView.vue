<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useTradingStore, TOTAL_SHARES } from '@/stores/trading'
import { usePricesStore } from '@/stores/prices'
import { useWishlistStore } from '@/stores/wishlist'
import CryptoPriceBadge from '@/components/ui/CryptoPriceBadge.vue'

const store  = useTradingStore()
const prices = usePricesStore()
const wishlist = useWishlistStore()
onMounted(() => { store.init(); prices.startPolling(); wishlist.loadMine() })
onUnmounted(() => prices.stopPolling())

const sortBy  = ref('mcap')   // 'mcap' | 'change_asc' | 'change_desc' | 'volume'
const search  = ref('')

const SORTS = [
  { key: 'mcap',        label: 'Market Cap' },
  { key: 'change_desc', label: 'Gainers First' },
  { key: 'change_asc',  label: 'Losers First'  },
  { key: 'volume',      label: 'Volume'       },
]

const rows = computed(() => {
  let list = store.ARTWORKS.map(a => ({
    ...a,
    price:   store.prices[a.id] ?? a.initPrice,
    mcapUsd: (store.prices[a.id] ?? a.initPrice) * TOTAL_SHARES,
    chg:     store.priceChange(a.id),
    vol:     store.volume24h(a.id),
  }))

  if (search.value.trim()) {
    const q = search.value.toLowerCase()
    list = list.filter(a => a.title.toLowerCase().includes(q) || a.artist.toLowerCase().includes(q))
  }

  if (sortBy.value === 'mcap')        list.sort((a, b) => b.mcapUsd - a.mcapUsd)
  if (sortBy.value === 'change_desc') list.sort((a, b) => b.chg - a.chg)
  if (sortBy.value === 'change_asc')  list.sort((a, b) => a.chg - b.chg)
  if (sortBy.value === 'volume')      list.sort((a, b) => b.vol - a.vol)

  return list
})

async function toggleWishlist(art) {
  await wishlist.toggle(art)
}
</script>

<template>
  <!-- Page header -->
  <div class="border-b border-white/[0.06]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 pt-10 pb-8">
      <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-3 font-light">Explore</p>
      <h1 class="font-display text-3xl lg:text-[2.5rem] font-normal italic text-white leading-tight mb-1">
        Discover Works
      </h1>
      <p class="text-sm text-gray-500 font-light">{{ store.ARTWORKS.length }} artworks listed · all prices live</p>
    </div>
  </div>

  <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-8">
    <!-- Controls -->
    <div class="flex flex-wrap items-center gap-3 mb-8">
      <!-- Search -->
      <div class="relative flex-1 min-w-[200px] max-w-xs">
        <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-4.35-4.35M17 11A6 6 0 1 1 5 11a6 6 0 0 1 12 0z"/>
        </svg>
        <input
          v-model="search"
          type="text"
          placeholder="Search artworks, artists..."
          class="w-full bg-[#111116] border border-white/[0.08] text-gray-200 pl-9 pr-3 py-2 text-sm outline-none focus:border-white/20 placeholder:text-gray-600"
        />
      </div>

      <!-- Sort chips -->
      <div class="flex items-center gap-2 flex-wrap">
        <button
          v-for="s in SORTS" :key="s.key"
          class="text-[10px] tracking-[0.15em] uppercase px-3 py-1.5 border transition-colors"
          :class="sortBy === s.key
            ? 'border-[#E8552A] text-[#E8552A] bg-[#E8552A]/10'
            : 'border-white/[0.08] text-gray-500 hover:text-gray-300 hover:border-white/20'"
          @click="sortBy = s.key"
        >{{ s.label }}</button>
      </div>
    </div>

    <!-- Artwork grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
      <RouterLink
        v-for="art in rows" :key="art.id"
        :to="`/artwork/${art.id}`"
        class="card-dark group overflow-hidden flex flex-col"
      >
        <!-- Image -->
        <div class="relative overflow-hidden aspect-[4/3] bg-[#0d0d10]">
          <img
            :src="art.imageUrl.replace('w=400', 'w=700')"
            :alt="art.title"
            class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700"
            loading="lazy"
          />
          <div class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent" />

          <!-- Wishlist button -->
          <button
            class="absolute top-3 left-3 w-8 h-8 border border-white/15 bg-black/50 backdrop-blur-sm flex items-center justify-center transition-colors hover:border-[#E8552A]/70 hover:text-[#E8552A]"
            :class="wishlist.isWishlisted(art.id) ? 'text-[#E8552A] border-[#E8552A]/70 bg-[#E8552A]/10' : 'text-gray-300'"
            :aria-label="wishlist.isWishlisted(art.id) ? 'Remove from wishlist' : 'Add to wishlist'"
            @click.prevent="toggleWishlist(art)"
          >
            <svg
              class="w-4 h-4"
              :class="wishlist.isWishlisted(art.id) ? 'fill-current' : ''"
              fill="none"
              stroke="currentColor"
              stroke-width="1.8"
              viewBox="0 0 24 24"
            >
              <path d="M4.318 6.318a4.5 4.5 0 0 1 6.364 0L12 7.636l1.318-1.318a4.5 4.5 0 0 1 6.364 6.364L12 20.364l-7.682-7.682a4.5 4.5 0 0 1 0-6.364Z" />
            </svg>
          </button>

          <!-- 24h change badge -->
          <span
            class="absolute top-3 right-3 text-[10px] font-mono px-2 py-0.5 border"
            :class="art.chg >= 0
              ? 'bg-green-500/20 text-green-400 border-green-500/30'
              : 'bg-red-500/20 text-red-400 border-red-500/30'"
          >
            {{ art.chg >= 0 ? '+' : '' }}{{ art.chg.toFixed(2) }}%
          </span>
        </div>

        <!-- Info -->
        <div class="p-4 flex flex-col gap-1 flex-1">
          <p class="text-[10px] tracking-[0.18em] uppercase text-gray-600 font-light">{{ art.artist }}</p>
          <p class="font-display italic text-gray-100 text-base leading-snug mb-1">{{ art.title }}</p>

          <!-- Market cap price -->
          <div class="flex items-end justify-between mt-auto pt-3 border-t border-white/[0.05]">
            <div>
              <p class="text-[9px] tracking-[0.2em] uppercase text-gray-600 mb-0.5">Market Cap</p>
              <CryptoPriceBadge :usd-value="art.mcapUsd" />
            </div>
            <div class="text-right">
              <p class="text-[9px] tracking-[0.2em] uppercase text-gray-600 mb-0.5">Per Share</p>
              <span class="font-mono text-xs text-gray-300">{{ prices.formatCrypto(art.price) }}</span>
            </div>
          </div>
        </div>
      </RouterLink>
    </div>

    <!-- Empty state -->
    <div v-if="rows.length === 0" class="py-24 text-center">
      <p class="font-display italic text-gray-600 text-2xl">No works found</p>
      <button class="mt-4 text-[11px] tracking-[0.15em] uppercase text-[#E8552A]" @click="search = ''">Clear search</button>
    </div>
  </div>
</template>

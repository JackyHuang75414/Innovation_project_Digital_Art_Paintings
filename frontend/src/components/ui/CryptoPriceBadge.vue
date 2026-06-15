<script setup>
import { computed } from 'vue'
import { usePricesStore } from '@/stores/prices'

const props = defineProps({
  usdValue:  { type: Number, required: true },
  size:      { type: String, default: 'md' },  // 'sm' | 'md' | 'lg'
  showFiat:  { type: Boolean, default: true },
  showChange: { type: Boolean, default: false },
  change24h: { type: Number, default: null },
})

const p = usePricesStore()
const cryptoStr = computed(() => p.formatCrypto(props.usdValue))
const fiatStr   = computed(() => p.formatFiat(props.usdValue))
const chg       = computed(() => props.change24h)
</script>

<template>
  <span class="inline-flex items-baseline flex-wrap gap-x-1.5">
    <span
      class="font-mono text-white tabular-nums"
      :class="size === 'lg' ? 'text-2xl font-semibold' : size === 'sm' ? 'text-xs' : 'text-sm font-medium'"
    >{{ cryptoStr }}</span>

    <span v-if="showFiat" class="text-gray-500 tabular-nums"
      :class="size === 'lg' ? 'text-sm' : 'text-[11px]'">
      ≈ {{ fiatStr }}
    </span>

    <span
      v-if="showChange && chg !== null"
      class="font-mono text-[11px] px-1 rounded"
      :class="chg >= 0 ? 'text-green-400' : 'text-red-400'"
    >
      {{ chg >= 0 ? '+' : '' }}{{ chg.toFixed(2) }}%
    </span>
  </span>
</template>

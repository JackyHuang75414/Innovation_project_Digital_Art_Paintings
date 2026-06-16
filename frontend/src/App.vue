<script setup>
import { onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import AppHeader from '@/components/layout/AppHeader.vue'
import AppFooter from '@/components/layout/AppFooter.vue'
import AiRecommendChat from '@/components/ui/AiRecommendChat.vue'
import { usePricesStore } from '@/stores/prices'
import { useUserProfileStore } from '@/stores/userProfile'
import { useTradingStore } from '@/stores/trading'

const route   = useRoute()
const prices  = usePricesStore()
const profile = useUserProfileStore()
const trading = useTradingStore()

onMounted(() => {
  prices.startPolling()
  trading.init()
})
onUnmounted(prices.stopPolling)

// ── Track browsing for AI user profile ────────────────────────────────────
watch(
  () => route.fullPath,
  () => {
    // Extract artwork ID from /trade/:id or /artwork/:id
    const id = Number(route.params.id)
    if (!id) return
    const artwork = trading.ARTWORKS.find(a => a.id === id)
    if (artwork) {
      profile.recordView(artwork)
    }
  },
  { immediate: true }
)
</script>

<template>
  <AppHeader />
  <main class="flex-1">
    <RouterView />
  </main>
  <AppFooter />
  <AiRecommendChat />
</template>

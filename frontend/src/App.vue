<script setup>
import { onMounted, onUnmounted } from 'vue'
import AppHeader from '@/components/layout/AppHeader.vue'
import AppFooter from '@/components/layout/AppFooter.vue'
import AiRecommendChat from '@/components/ui/AiRecommendChat.vue'
import { usePricesStore } from '@/stores/prices'

const prices = usePricesStore()
onMounted(prices.startPolling)
onUnmounted(prices.stopPolling)
</script>

<template>
  <AppHeader />
  <main class="flex-1">
    <RouterView />
  </main>
  <AppFooter />
  <AiRecommendChat />
</template>

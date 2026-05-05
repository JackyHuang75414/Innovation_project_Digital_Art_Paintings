<script setup>
import AppHeader from '@/components/layout/AppHeader.vue'
import AppFooter from '@/components/layout/AppFooter.vue'
import DifyChat from '@/components/ui/DifyChat.vue'
</script>

<template>
  <AppHeader />
  <main class="flex-1">
    <RouterView />
  </main>
  <AppFooter />
  <!-- Dify AI chat widget — injected bottom-right via #dify-chat-root -->
  <DifyChat />
</template>

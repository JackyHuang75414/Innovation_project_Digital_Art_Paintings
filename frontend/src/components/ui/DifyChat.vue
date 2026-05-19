<script setup>
/**
 * DifyChat — wrapper for the Dify embedded chatbot widget.
 *
 * Usage: place <DifyChat /> once in App.vue.
 * Set VITE_DIFY_TOKEN in .env to activate; leave empty to hide the widget.
 *
 * Dify embed script docs: https://docs.dify.ai/guides/deploy/embed-into-website
 */
import { onMounted } from 'vue'

const token = import.meta.env.VITE_DIFY_TOKEN

onMounted(() => {
  if (!token) return

  // Inject Dify embed config
  window.difyChatbotConfig = { token }

  const script = document.createElement('script')
  script.src = 'https://udify.app/embed.min.js'
  script.id = 'dify-chat-script'
  script.async = true
  document.body.appendChild(script)
})
</script>

<template>
  <!-- Dify injects its own button into #dify-chat-root via the embed script -->
  <div id="dify-chat-root" />
</template>

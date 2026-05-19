<script setup>
/**
 * AiRecommendChat — floating AI art-curator chat widget.
 *
 * Backend: DeepSeek Chat API (OpenAI-compatible)
 * The API key lives in .env as LLM_API_KEY (no VITE_ prefix).
 * Vite proxies /llm-api → https://api.deepseek.com with the
 * Authorization header injected server-side — key never reaches the browser.
 */
import { ref, nextTick } from 'vue'
import { RouterLink } from 'vue-router'

const isOpen = ref(false)
const inputText = ref('')
const isTyping = ref(false)
const messagesEl = ref(null)

// ─── Artwork pool (replace with real API data when backend is ready) ──────────
const artworkPool = [
  { id: 1, imageUrl: 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=200&q=80', title: 'Golden Hour Reverie', artistName: 'Sophie Laurent', price: 89 },
  { id: 2, imageUrl: 'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=200&q=80', title: 'Urban Geometry III', artistName: 'Amara Diallo', price: 120 },
  { id: 3, imageUrl: 'https://images.unsplash.com/photo-1620503374956-c942862f0372?w=200&q=80', title: 'Blue Silence', artistName: 'Marco Chen', price: 75 },
  { id: 4, imageUrl: 'https://images.unsplash.com/photo-1605721911519-3dfeb3be25e7?w=200&q=80', title: 'Forest Dream', artistName: 'Jules Moreau', price: 65 },
  { id: 5, imageUrl: 'https://images.unsplash.com/photo-1559762717-99c81ac85059?w=200&q=80', title: 'Desert Wind', artistName: 'Yuki Tanaka', price: 110 },
  { id: 6, imageUrl: 'https://images.unsplash.com/photo-1579763902614-a3fb3927b6a5?w=200&q=80', title: 'Abstract Harmony', artistName: 'Lena Kuznetsov', price: 99 },
]

// ─── System prompt ────────────────────────────────────────────────────────────
const SYSTEM_PROMPT = `You are ArtCanvas AI, a sophisticated art curator for a premium digital art marketplace.
Help visitors discover artworks that match their aesthetic tastes and emotional needs.
Guidelines:
- Respond concisely in 2–3 elegant sentences.
- Suggest specific styles, moods, colours, or techniques the visitor might enjoy.
- Maintain a warm, knowledgeable tone befitting a luxury gallery.
- After your recommendation, naturally mention you will show some matching works.
Available categories: Oil, Watercolour, Acrylic, Digital Art, Photography, Ink.`

// ─── Conversation state ───────────────────────────────────────────────────────
// apiHistory holds text-only turn history sent to the model on each call.
const apiHistory = []

const messages = ref([
  {
    role: 'ai',
    text: 'Hello. I\'m your personal art curator. Tell me about the styles, colours, or emotions you\'re drawn to — and I\'ll find works that speak to you.',
    artworks: [],
  },
])

function scrollToBottom() {
  nextTick(() => {
    if (messagesEl.value) {
      messagesEl.value.scrollTop = messagesEl.value.scrollHeight
    }
  })
}

// ─── DeepSeek API call (OpenAI-compatible) ───────────────────────────────────
async function callLLM(userText) {
  const res = await fetch('/llm-api/v1/chat/completions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model: 'deepseek-chat',
      stream: false,
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        ...apiHistory,
        { role: 'user', content: userText },
      ],
    }),
  })

  if (!res.ok) {
    const raw = await res.text()
    throw new Error(`DeepSeek ${res.status}: ${raw}`)
  }

  const data = await res.json()
  const text = data.choices?.[0]?.message?.content
  if (!text) throw new Error('Unexpected response: ' + JSON.stringify(data).slice(0, 200))

  return text
}

// ─── Send message ─────────────────────────────────────────────────────────────
async function sendMessage() {
  const text = inputText.value.trim()
  if (!text || isTyping.value) return

  messages.value.push({ role: 'user', text, artworks: [] })
  apiHistory.push({ role: 'user', content: text })
  inputText.value = ''
  isTyping.value = true
  scrollToBottom()

  try {
    const replyText = await callLLM(text)

    // Keep multi-turn context
    apiHistory.push({ role: 'assistant', content: replyText })

    // Pair AI text with 2 random artwork cards
    const picks = [...artworkPool].sort(() => Math.random() - 0.5).slice(0, 2)
    messages.value.push({ role: 'ai', text: replyText, artworks: picks })
  } catch (err) {
    console.error('[AiRecommendChat] DeepSeek error:', err)
    messages.value.push({
      role: 'error',
      text: String(err?.message || err),
      artworks: [],
    })
  } finally {
    isTyping.value = false
    scrollToBottom()
  }
}

function handleKeydown(e) {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    sendMessage()
  }
}

function open() {
  isOpen.value = true
  nextTick(scrollToBottom)
}
</script>

<template>
  <!-- ── Floating trigger button ── -->
  <Transition name="btn-fade">
    <button
      v-if="!isOpen"
      class="fixed bottom-6 right-6 z-[9998] flex items-center gap-2.5 bg-[#E8552A] hover:bg-[#d4461c] text-white pl-4 pr-5 py-3 shadow-xl hover:shadow-2xl transition-all duration-200 focus:outline-none"
      aria-label="Open AI art curator"
      @click="open"
    >
      <!-- Sparkle wand icon -->
      <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
          d="M9.813 15.904 9 18.75l-.813-2.846a4.5 4.5 0 0 0-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 0 0 3.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 0 0 3.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 0 0-3.09 3.09Z" />
      </svg>
      <span class="text-[11px] tracking-[0.2em] uppercase font-medium">AI Curator</span>
    </button>
  </Transition>

  <!-- ── Chat panel ── -->
  <Transition name="panel">
    <div
      v-if="isOpen"
      class="fixed bottom-6 right-6 z-[9999] w-[22rem] flex flex-col bg-white shadow-2xl border border-gray-200"
      style="max-height: min(80vh, 600px)"
      role="dialog"
      aria-label="AI Art Curator"
    >
      <!-- Header -->
      <div class="bg-gray-950 px-5 py-4 flex items-start justify-between flex-shrink-0">
        <div>
          <p class="text-white font-display italic font-normal text-[0.95rem] leading-tight">ArtCanvas AI</p>
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light mt-1">Your personal curator</p>
        </div>
        <button
          class="text-gray-500 hover:text-white transition-colors mt-0.5 p-0.5"
          aria-label="Close chat"
          @click="isOpen = false"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18 18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>

      <!-- Message thread -->
      <div ref="messagesEl" class="flex-1 overflow-y-auto px-4 py-5 space-y-5 min-h-0">
        <div
          v-for="(msg, i) in messages"
          :key="i"
          class="flex"
          :class="msg.role === 'user' ? 'justify-end' : 'justify-start'"
        >
          <div :class="msg.role === 'user' ? 'max-w-[85%]' : 'max-w-full w-full'">

            <!-- Error bubble -->
            <template v-if="msg.role === 'error'">
              <div class="bg-red-50 border border-red-200 px-3 py-2.5">
                <p class="text-[10px] tracking-[0.15em] uppercase text-red-400 font-light mb-1">API Error</p>
                <p class="text-xs text-red-600 font-mono break-all">{{ msg.text }}</p>
              </div>
            </template>

            <!-- AI bubble -->
            <template v-else-if="msg.role === 'ai'">
              <p class="text-sm text-gray-700 font-light leading-relaxed">{{ msg.text }}</p>
              <div v-if="msg.artworks?.length" class="mt-3 space-y-2">
                <RouterLink
                  v-for="art in msg.artworks"
                  :key="art.id"
                  :to="`/artwork/${art.id}`"
                  class="flex gap-3 bg-[#F7F4F0] hover:bg-[#EDE8E1] transition-colors p-2.5 group"
                  @click="isOpen = false"
                >
                  <img
                    :src="art.imageUrl"
                    :alt="art.title"
                    class="w-14 h-14 object-cover flex-shrink-0"
                    loading="lazy"
                  />
                  <div class="min-w-0 flex flex-col justify-center gap-0.5">
                    <p class="font-display italic text-sm text-gray-900 leading-tight line-clamp-2">{{ art.title }}</p>
                    <p class="text-[10px] tracking-[0.15em] uppercase text-gray-400 font-light">{{ art.artistName }}</p>
                    <p class="text-xs font-medium text-gray-900">€{{ art.price }}</p>
                  </div>
                  <div class="flex items-center ml-auto pl-1 flex-shrink-0">
                    <svg class="w-3.5 h-3.5 text-gray-300 group-hover:text-[#E8552A] transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                    </svg>
                  </div>
                </RouterLink>
              </div>
            </template>

            <!-- User bubble -->
            <template v-else-if="msg.role === 'user'">
              <p class="text-sm text-white bg-[#E8552A] px-3.5 py-2.5 font-light leading-relaxed inline-block">
                {{ msg.text }}
              </p>
            </template>
          </div>
        </div>

        <!-- Typing indicator -->
        <div v-if="isTyping" class="flex justify-start">
          <div class="flex items-center gap-1 bg-[#F7F4F0] px-3.5 py-3">
            <span class="w-1.5 h-1.5 rounded-full bg-gray-400 animate-bounce" style="animation-delay:0ms"/>
            <span class="w-1.5 h-1.5 rounded-full bg-gray-400 animate-bounce" style="animation-delay:150ms"/>
            <span class="w-1.5 h-1.5 rounded-full bg-gray-400 animate-bounce" style="animation-delay:300ms"/>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <div class="h-px bg-gray-100 flex-shrink-0" />

      <!-- Input bar -->
      <form
        class="flex items-center flex-shrink-0 bg-white"
        @submit.prevent="sendMessage"
      >
        <input
          v-model="inputText"
          type="text"
          placeholder="Describe your taste…"
          class="flex-1 px-4 py-3.5 text-sm outline-none placeholder:text-gray-300 font-light bg-transparent"
          :disabled="isTyping"
          @keydown="handleKeydown"
        />
        <button
          type="submit"
          :disabled="isTyping || !inputText.trim()"
          class="px-4 py-3.5 flex-shrink-0 text-[#E8552A] hover:text-[#d4461c] disabled:text-gray-300 transition-colors"
          aria-label="Send message"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
              d="M6 12 3.269 3.125A59.769 59.769 0 0 1 21.485 12 59.768 59.768 0 0 1 3.27 20.875L5.999 12Zm0 0h7.5"/>
          </svg>
        </button>
      </form>
    </div>
  </Transition>
</template>

<style scoped>
/* Trigger button fade */
.btn-fade-enter-active { transition: opacity 0.15s ease; }
.btn-fade-leave-active { transition: opacity 0.1s ease; }
.btn-fade-enter-from, .btn-fade-leave-to { opacity: 0; }

/* Panel slide-up */
.panel-enter-active { transition: opacity 0.2s ease, transform 0.25s ease; }
.panel-leave-active { transition: opacity 0.15s ease, transform 0.2s ease; }
.panel-enter-from, .panel-leave-to {
  opacity: 0;
  transform: translateY(0.75rem) scale(0.98);
}
</style>

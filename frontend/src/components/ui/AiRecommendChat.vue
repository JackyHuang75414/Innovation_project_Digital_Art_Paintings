<script setup>
/**
 * AiRecommendChat — AI 專屬助理 (Personal Assistant)
 *
 * ── 未登入 / 免費用戶 ──
 *   AI 追蹤用戶瀏覽行為，建立偏好畫像，主動推薦藝術品與投資建議。
 *
 * ── 登入後的付費用戶 ──
 *   AI 提供實時價格監測與預警，協助買入 / 賣出操作。
 *   用戶需在聊天框中授權執行交易。聊天框關閉時顯示紅色未讀標識。
 *
 * Backend: Spring Boot AI chat proxy (/api/ai/chat).
 */
import { ref, nextTick, watch, computed, onMounted, onUnmounted } from 'vue'
import { RouterLink } from 'vue-router'
import { chatWithAi } from '@/api/ai'
import { useAuthStore } from '@/stores/auth'
import { useUserProfileStore } from '@/stores/userProfile'
import { useNotificationsStore } from '@/stores/notifications'
import { useTradingStore } from '@/stores/trading'

const auth    = useAuthStore()
const profile = useUserProfileStore()
const notif   = useNotificationsStore()
const trading = useTradingStore()

const isOpen    = ref(false)
const inputText = ref('')
const isTyping  = ref(false)
const messagesEl = ref(null)

// Whether the trading store has been initialised (needed for price monitoring)
const tradingReady = ref(false)

// ── Artwork pool (used for recommendation cards) ──────────────────────────
const artworkPool = computed(() =>
  trading.ARTWORKS.map(art => ({
    id: art.id,
    imageUrl: art.imageUrl,
    title: art.title,
    artistName: art.artist,
    price: trading.prices[art.id] ?? art.price ?? art.initPrice,
  }))
)

// ── Dynamic system prompt ─────────────────────────────────────────────────
const systemPrompt = computed(() => {
  if (auth.isPaid) {
    return `You are ArtEx AI, a professional crypto-art trading assistant for a premium digital art marketplace.
The user is a PAID subscriber with access to real-time price monitoring and trade execution.
Your role:
- Monitor price movements and alert the user to opportunities or risks.
- When you detect a significant price change (>3% in recent history), suggest a specific trade action (buy/sell).
- For trade suggestions, end your message with exactly: [ACTION:buy|sell|<artworkId>|<usdAmount>]
  Example: "I recommend buying shares. [ACTION:buy|1|200]"
- Keep messages concise and actionable. Use the user's portfolio context when available.
- Use a professional, direct tone suitable for traders.`
  }

  const summary = profile.profileSummary()
  if (summary) {
    return `You are ArtEx AI, a personal art investment curator for a premium digital art marketplace.
You have been observing this visitor's browsing behaviour:
${summary.text}

Guidelines:
- Reference their browsing history naturally — mention specific tags or artists they've shown interest in.
- Provide personalised investment advice based on their taste profile.
- Recommend 2 specific artworks from our collection that match their preferences.
- Be warm and knowledgeable — like a personal art advisor.
- Keep responses to 2-4 sentences plus recommendations.`
  }

  return `You are ArtEx AI, a personal art curator for a premium digital art marketplace.
The visitor has just arrived — guide them to discover their taste.
Guidelines:
- Ask what styles, colours, or emotions they are drawn to.
- Respond concisely in 2-3 elegant sentences.
- Maintain a warm, knowledgeable tone.
- Suggest they browse our collection so you can learn their preferences.`
})

// ── Conversation state ────────────────────────────────────────────────────
const apiHistory = []

const messages = ref([])

// Initialise the first message
function initWelcome() {
  apiHistory.length = 0
  if (auth.isPaid) {
    messages.value = [{
      role: 'ai',
      text: `Welcome back, ${auth.displayName}。我是您的專屬交易助理。我正在實時監控您關注的藝術品價格，一旦有重大變動我會立即通知您。您也可以隨時向我提問或下達交易指令。`,
      artworks: [],
      type: 'welcome',
      actions: null,
    }]
  } else if (profile.hasEnoughData) {
    const s = profile.profileSummary()
    messages.value = [{
      role: 'ai',
      text: `歡迎回來！我注意到您對 ${s.tags} 類型的藝術品很感興趣。我已經根據您的瀏覽記錄準備了一些推薦，隨時可以為您提供投資建議。`,
      artworks: [],
      type: 'welcome',
      actions: null,
    }]
  } else {
    messages.value = [{
      role: 'ai',
      text: 'Hello. I\'m your personal art curator. Tell me about the styles, colours, or emotions you\'re drawn to — and I\'ll find works that speak to you.',
      artworks: [],
      type: 'welcome',
      actions: null,
    }]
  }
}
initWelcome()

// ── Proactive message timers ──────────────────────────────────────────────
let _profileWatcher = null
let _priceWatcher   = null
let _lastProactiveViewCount = profile.totalViews
let _lastPriceAlertAt = {}
const PRICE_ALERT_THRESHOLD = 0.03   // 3% change triggers alert
const PRICE_ALERT_COOLDOWN  = 5 * 60_000  // 5 min cooldown per artwork

function startProactive() {
  stopProactive()

  // ── Pre-login / free user: profile-based recommendations ────────────────
  _profileWatcher = watch(
    () => profile.totalViews,
    (newCount) => {
      if (auth.isPaid) return  // paid users get price alerts instead
      const diff = newCount - _lastProactiveViewCount
      if (diff >= 3 && profile.hasEnoughData) {
        _lastProactiveViewCount = newCount
        generateProactiveRecommendation()
      }
    },
    { immediate: false }
  )

  // ── Paid user: price monitoring ─────────────────────────────────────────
  if (auth.isPaid) {
    _priceWatcher = setInterval(checkPriceAlerts, 30_000)
  }
}

function stopProactive() {
  if (_profileWatcher) { _profileWatcher(); _profileWatcher = null }
  if (_priceWatcher)   { clearInterval(_priceWatcher); _priceWatcher = null }
}

// Watch auth changes to restart proactive logic
watch(() => auth.isPaid, () => {
  initWelcome()
  startProactive()
})

// ── Proactive recommendation (pre-login) ──────────────────────────────────
async function generateProactiveRecommendation() {
  const summary = profile.profileSummary()
  if (!summary) return

  const userMsg = `Based on the visitor's browsing profile (${summary.text}), please provide a personalised recommendation. Reference specific tags or artists they've viewed. Recommend 2 artworks.`

  try {
    const replyText = await callLLM(userMsg, true)
    const picks = [...artworkPool.value].sort(() => Math.random() - 0.5).slice(0, 2)
    notif.push({
      text: replyText,
      artworks: picks,
      type: 'recommendation',
    })
    profile.markProactiveSent()
  } catch { /* silent */ }
}

// ── Price alerts (paid users) ─────────────────────────────────────────────
function checkPriceAlerts() {
  if (!auth.isPaid || !tradingReady.value) return

  trading.ARTWORKS.forEach(art => {
    const p = trading.prices[art.id]
    if (!p) return

    // Check 1-hour price change
    const chg = trading.priceChange(art.id, 72)  // ~1h of 2s ticks
    if (Math.abs(chg) >= PRICE_ALERT_THRESHOLD * 100) {
      const now = Date.now()
      const last = _lastPriceAlertAt[art.id] || 0
      if (now - last < PRICE_ALERT_COOLDOWN) return
      _lastPriceAlertAt[art.id] = now

      // Generate alert via LLM
      const dir = chg >= 0 ? '上漲' : '下跌'
      generatePriceAlert(art, chg, dir)
    }
  })
}

async function generatePriceAlert(art, changePct, direction) {
  const prompt = `A price alert has been triggered:
- Artwork: "${art.title}" by ${art.artist}
- Price change: ${changePct >= 0 ? '+' : ''}${changePct.toFixed(2)}% in the last hour
- Current price: $${(trading.prices[art.id] ?? 0).toFixed(4)}
- User portfolio: USD ${trading.wallet.usd.toFixed(2)}, holds ${(trading.wallet.shares[art.id] || 0).toFixed(2)} shares

Please provide a concise alert and suggest whether to buy/sell/hold. If suggesting a trade, end with [ACTION:buy|sell|<artworkId>|<usdAmount>]. Keep it under 3 sentences.`

  try {
    const replyText = await callLLM(prompt, true)
    const action = parseAction(replyText)
    notif.push({
      text: replyText.replace(/\[ACTION:.*?\]/, '').trim(),
      artworks: [artworkPool.value.find(a => a.id === art.id)].filter(Boolean),
      type: 'price_alert',
      actions: action ? [action] : null,
    })
  } catch { /* silent */ }
}

// ── Parse trade action from AI response ───────────────────────────────────
function parseAction(text) {
  const match = text.match(/\[ACTION:(buy|sell)\|(\d+)\|(\d+(?:\.\d+)?)\]/i)
  if (!match) return null
  return {
    label: match[1] === 'buy' ? `Buy #${match[2]} · $${match[3]}` : `Sell #${match[2]} · $${match[3]}`,
    action: match[1],       // 'buy' | 'sell'
    artworkId: Number(match[2]),
    usdAmount: Number(match[3]),
  }
}

// ── Execute a trade action ────────────────────────────────────────────────
async function executeTrade(action) {
  if (!auth.isPaid) {
    messages.value.push({ role: 'error', text: 'This feature is only available for paid subscribers.', artworks: [], type: 'error', actions: null })
    return
  }

  let result
  try {
    if (action.action === 'buy') {
      result = await trading.buyShares(action.artworkId, action.usdAmount)
    } else {
      result = await trading.sellShares(action.artworkId, action.usdAmount)
    }
  } catch (err) {
    result = { ok: false, msg: err.message || 'Trade failed' }
  }

  if (result.ok) {
    messages.value.push({
      role: 'ai',
      text: `✅ 已執行${action.action === 'buy' ? '買入' : '賣出'}：Artwork #${action.artworkId}，金額 $${action.usdAmount} @ $${(result.price ?? 0).toFixed(4)}。`,
      artworks: [],
      type: 'trade_result',
      actions: null,
    })
  } else {
    messages.value.push({
      role: 'error',
      text: `❌ 交易失敗：${result.msg}`,
      artworks: [],
      type: 'error',
      actions: null,
    })
  }
  scrollToBottom()
}

// ── Spring Boot AI proxy call ─────────────────────────────────────────────
async function callLLM(userText, isProactive = false) {
  // For proactive calls we use a different path to isolate context
  const history = isProactive ? [] : apiHistory

  const res = await chatWithAi({
    model: 'deepseek-chat',
    messages: [
      { role: 'system', content: systemPrompt.value },
      ...history,
      { role: 'user', content: userText },
    ],
  })

  const text = res.data?.reply ?? null

  if (text === null || text === undefined) {
    throw new Error('Cannot parse AI response')
  }

  if (text.trim() === '') {
    return "I'm sorry, I wasn't able to generate a response. Please try again."
  }

  return text
}

// ── Send user message ─────────────────────────────────────────────────────
async function sendMessage() {
  const text = inputText.value.trim()
  if (!text || isTyping.value) return

  messages.value = [...messages.value, { role: 'user', text, artworks: [], type: 'user', actions: null }]
  apiHistory.push({ role: 'user', content: text })
  inputText.value = ''
  isTyping.value = true
  scrollToBottom()

  try {
    const replyText = await callLLM(text)
    apiHistory.push({ role: 'assistant', content: replyText })

    const action = parseAction(replyText)
    const cleanText = replyText.replace(/\[ACTION:.*?\]/, '').trim()
    const picks = [...artworkPool.value].sort(() => Math.random() - 0.5).slice(0, 2)

    messages.value = [...messages.value, {
      role: 'ai',
      text: cleanText,
      artworks: picks,
      type: action ? 'trade_suggestion' : 'reply',
      actions: action ? [action] : null,
    }]
  } catch (err) {
    console.error('[AiRecommendChat] error:', err)
    messages.value = [...messages.value, {
      role: 'error',
      text: String(err?.message || err),
      artworks: [],
      type: 'error',
      actions: null,
    }]
  } finally {
    isTyping.value = false
    scrollToBottom()
  }
}

// ── Handle trade action button clicks ─────────────────────────────────────
function handleAction(action) {
  executeTrade(action)
}

function handleKeydown(e) {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    sendMessage()
  }
}

function open() {
  isOpen.value = true

  // Consume any pending notification messages
  const pending = notif.consumeAll()
  if (pending.length) {
    messages.value = [...messages.value, ...pending.map(p => ({
      role: 'ai',
      text: p.text,
      artworks: p.artworks,
      type: p.type,
      actions: p.actions,
    }))]
  }

  nextTick(scrollToBottom)
}

function scrollToBottom() {
  nextTick(() => {
    if (messagesEl.value) {
      messagesEl.value.scrollTop = messagesEl.value.scrollHeight
    }
  })
}

// ── Lifecycle ─────────────────────────────────────────────────────────────
onMounted(() => {
  startProactive()
  trading.init()
  tradingReady.value = true
})

onUnmounted(() => {
  stopProactive()
})
</script>

<template>
  <!-- ── Floating trigger button ── -->
  <Transition name="btn-fade">
    <button
      v-if="!isOpen"
      class="fixed bottom-6 right-6 z-[9998] flex items-center gap-2.5 bg-[#E8552A] hover:bg-[#d4461c] text-white pl-4 pr-5 py-3 shadow-[0_0_30px_rgba(232,85,42,0.35)] hover:shadow-[0_0_40px_rgba(232,85,42,0.5)] transition-all duration-200 focus:outline-none"
      aria-label="Open AI assistant"
      @click="open"
    >
      <!-- Sparkle wand icon -->
      <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
          d="M9.813 15.904 9 18.75l-.813-2.846a4.5 4.5 0 0 0-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 0 0 3.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 0 0 3.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 0 0-3.09 3.09Z" />
      </svg>
      <span class="text-[11px] tracking-[0.2em] uppercase font-medium">
        {{ auth.isPaid ? 'AI Assistant' : 'AI Curator' }}
      </span>

      <!-- Red notification badge (like WeChat) -->
      <span
        v-if="notif.hasUnread"
        class="absolute -top-1.5 -right-1.5 min-w-[20px] h-5 px-1.5 flex items-center justify-center bg-red-500 text-white text-[10px] font-bold rounded-full shadow-[0_0_8px_rgba(239,68,68,0.5)] animate-pulse"
      >
        {{ notif.unreadCount > 99 ? '99+' : notif.unreadCount }}
      </span>
    </button>
  </Transition>

  <!-- ── Chat panel ── -->
  <Transition name="panel">
    <div
      v-if="isOpen"
      class="fixed bottom-6 right-6 z-[9999] w-[24rem] flex flex-col bg-[#0f0f13] shadow-2xl border border-white/[0.1]"
      style="max-height: min(85vh, 650px)"
      role="dialog"
      aria-label="AI Assistant"
    >
      <!-- Header -->
      <div class="bg-gray-950 px-5 py-4 flex items-start justify-between flex-shrink-0">
        <div>
          <p class="text-white font-display italic font-normal text-[0.95rem] leading-tight">
            {{ auth.isPaid ? 'ArtEx AI Assistant' : 'ArtCanvas AI' }}
          </p>
          <p class="text-[10px] tracking-[0.2em] uppercase font-light mt-1"
            :class="auth.isPaid ? 'text-amber-400' : 'text-gray-400'">
            {{ auth.isPaid ? 'Real-time Trading · Premium' : 'Your personal curator' }}
          </p>
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
      <div ref="messagesEl" class="flex-1 overflow-y-auto px-4 py-5 space-y-5 min-h-0 bg-[#0f0f13]">
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
                <p class="text-[10px] tracking-[0.15em] uppercase text-red-400 font-light mb-1">Error</p>
                <p class="text-xs text-red-600 font-mono break-all">{{ msg.text }}</p>
              </div>
            </template>

            <!-- AI bubble -->
            <template v-else-if="msg.role === 'ai'">
              <!-- Type badge -->
              <p
                v-if="msg.type === 'price_alert'"
                class="text-[9px] tracking-[0.2em] uppercase text-amber-400 mb-1 font-medium"
              >Price Alert</p>
              <p
                v-else-if="msg.type === 'trade_suggestion'"
                class="text-[9px] tracking-[0.2em] uppercase text-green-400 mb-1 font-medium"
              >Trade Suggestion</p>
              <p
                v-else-if="msg.type === 'recommendation'"
                class="text-[9px] tracking-[0.2em] uppercase text-[#E8552A] mb-1 font-medium"
              >AI Recommendation</p>

              <p class="text-sm text-gray-300 font-light leading-relaxed">{{ msg.text }}</p>

              <!-- Artwork cards -->
              <div v-if="msg.artworks?.length" class="mt-3 space-y-2">
                <RouterLink
                  v-for="art in msg.artworks"
                  :key="art.id"
                  :to="`/trade/${art.id}`"
                  class="flex gap-3 bg-[#111116] border border-white/[0.08] hover:border-white/20 transition-colors p-2.5 group"
                  @click="isOpen = false"
                >
                  <img :src="art.imageUrl" :alt="art.title" class="w-14 h-14 object-cover flex-shrink-0 bg-[#0d0d10]" loading="lazy" />
                  <div class="min-w-0 flex flex-col justify-center gap-0.5">
                    <p class="font-display italic text-sm text-gray-100 leading-tight line-clamp-2">{{ art.title }}</p>
                    <p class="text-[10px] tracking-[0.15em] uppercase text-gray-500 font-light">{{ art.artistName }}</p>
                    <p class="text-[10px] font-mono text-gray-400">
                      ${{ art.price >= 1e6 ? (art.price / 1e6).toFixed(2) + 'M' : art.price >= 1 ? art.price.toFixed(2) : art.price.toFixed(4) }}
                    </p>
                  </div>
                  <div class="flex items-center ml-auto pl-1 flex-shrink-0">
                    <svg class="w-3.5 h-3.5 text-gray-700 group-hover:text-[#E8552A] transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                    </svg>
                  </div>
                </RouterLink>
              </div>

              <!-- Trade action buttons -->
              <div v-if="msg.actions?.length" class="mt-3 flex gap-2">
                <button
                  v-for="act in msg.actions"
                  :key="act.label"
                  class="px-4 py-2 text-[11px] tracking-[0.1em] uppercase font-medium transition-colors"
                  :class="act.action === 'buy'
                    ? 'bg-green-600 hover:bg-green-500 text-white'
                    : 'bg-red-600 hover:bg-red-500 text-white'"
                  @click="handleAction(act)"
                >
                  {{ act.action === 'buy' ? 'Buy' : 'Sell' }} · ${{ act.usdAmount }}
                </button>
              </div>
            </template>

            <!-- User bubble -->
            <template v-else-if="msg.role === 'user'">
              <p class="text-sm text-white bg-[#E8552A] px-3.5 py-2.5 font-light leading-relaxed inline-block">{{ msg.text }}</p>
            </template>
          </div>
        </div>

        <!-- Typing indicator -->
        <div v-if="isTyping" class="flex justify-start">
          <div class="flex items-center gap-1 bg-[#111116] px-3.5 py-3 border border-white/[0.06]">
            <span class="w-1.5 h-1.5 rounded-full bg-gray-500 animate-bounce" style="animation-delay:0ms"/>
            <span class="w-1.5 h-1.5 rounded-full bg-gray-500 animate-bounce" style="animation-delay:150ms"/>
            <span class="w-1.5 h-1.5 rounded-full bg-gray-500 animate-bounce" style="animation-delay:300ms"/>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <div class="h-px bg-white/[0.07] flex-shrink-0" />

      <!-- Input bar -->
      <form
        class="flex items-center flex-shrink-0 bg-[#0f0f13]"
        @submit.prevent="sendMessage"
      >
        <input
          v-model="inputText"
          type="text"
          :placeholder="auth.isPaid ? 'Ask or command a trade…' : 'Describe your taste…'"
          class="flex-1 px-4 py-3.5 text-sm outline-none placeholder:text-gray-600 font-light bg-transparent text-gray-200"
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

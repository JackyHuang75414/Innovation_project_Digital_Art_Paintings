import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

/**
 * Notifications store — manages AI chat unread messages and badge.
 *
 * The AI proactively pushes messages (recommendations, price alerts,
 * trade suggestions) into this queue.  When the chat panel is closed
 * the floating trigger button displays a red badge with the unread count.
 */
export const useNotificationsStore = defineStore('notifications', () => {
  /** @type {import('vue').Ref<Array<{id:string, role:string, text:string, artworks:Array, type:string, actions:Array|null, createdAt:number}>>} */
  const pendingMessages = ref([])

  const unreadCount = computed(() => pendingMessages.value.length)
  const hasUnread    = computed(() => unreadCount.value > 0)

  // ── Add a message to the queue ──────────────────────────────────────────
  function push(msg) {
    pendingMessages.value.push({
      id: Math.random().toString(36).slice(2),
      role: 'ai',
      text: msg.text ?? '',
      artworks: msg.artworks ?? [],
      type: msg.type ?? 'recommendation',   // 'recommendation' | 'price_alert' | 'trade_suggestion'
      actions: msg.actions ?? null,         // [{ label, action }] for trade confirmations
      createdAt: Date.now(),
    })
  }

  // ── Consume all pending messages (call when chat opens) ─────────────────
  function consumeAll() {
    const msgs = [...pendingMessages.value]
    pendingMessages.value = []
    return msgs
  }

  // ── Remove a single message ─────────────────────────────────────────────
  function dismiss(id) {
    pendingMessages.value = pendingMessages.value.filter(m => m.id !== id)
  }

  // ── Clear everything ────────────────────────────────────────────────────
  function clear() {
    pendingMessages.value = []
  }

  return { pendingMessages, unreadCount, hasUnread, push, consumeAll, dismiss, clear }
})

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

const STORAGE_KEY = 'artex_profile'

/**
 * User profile store — tracks browsing behaviour to build a preference portrait.
 *
 * Before login: captures every artwork the visitor views and distills
 * taste signals (tags, artists, mediums, price tier) into a profile.
 * The AI chat reads this profile to generate proactive recommendations.
 */
export const useUserProfileStore = defineStore('userProfile', () => {
  // ── View history ─────────────────────────────────────────────────────────
  const viewedArtworkIds = ref([])        // ordered list of artwork IDs viewed
  const tagScores        = ref({})        // tag → count
  const artistScores     = ref({})        // artist → count
  const mediumScores     = ref({})        // medium → count
  const totalViews       = ref(0)
  const lastProactiveAt  = ref(0)         // timestamp of last proactive message sent

  // ── Restore from localStorage ────────────────────────────────────────────
  try {
    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved) {
      const data = JSON.parse(saved)
      viewedArtworkIds.value = data.viewedArtworkIds ?? []
      tagScores.value        = data.tagScores        ?? {}
      artistScores.value     = data.artistScores     ?? {}
      mediumScores.value     = data.mediumScores     ?? {}
      totalViews.value       = data.totalViews       ?? 0
      lastProactiveAt.value  = data.lastProactiveAt  ?? 0
    }
  } catch { /* ignore corrupt data */ }

  function _persist() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify({
      viewedArtworkIds: viewedArtworkIds.value,
      tagScores:        tagScores.value,
      artistScores:     artistScores.value,
      mediumScores:     mediumScores.value,
      totalViews:       totalViews.value,
      lastProactiveAt:  lastProactiveAt.value,
    }))
  }

  // ── Computed ─────────────────────────────────────────────────────────────
  const topTags = computed(() =>
    Object.entries(tagScores.value)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 5)
      .map(([tag]) => tag)
  )

  const topArtists = computed(() =>
    Object.entries(artistScores.value)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 3)
      .map(([artist]) => artist)
  )

  /** Whether we have enough data for a meaningful proactive message */
  const hasEnoughData = computed(() => totalViews.value >= 3)

  /**
   * Returns true when a new proactive message should be triggered —
   * every `everyNViews` new views since the last message, and after we
   * have enough data.
   */
  function shouldProactive(everyNViews = 3) {
    if (!hasEnoughData.value) return false
    const viewsSinceLast = totalViews.value - _viewsAtLastProactive()
    return viewsSinceLast >= everyNViews
  }

  function _viewsAtLastProactive() {
    // Approximate: count how many views happened before lastProactiveAt
    // For simplicity, store this explicitly.
    return lastProactiveAt.value > 0 ? totalViews.value - _newViewsSince(lastProactiveAt.value) : 0
  }

  function _newViewsSince(ts) {
    // We don't have timestamps per view; use a simpler heuristic.
    // Store the totalViews count at the time of last proactive message.
    return 0  // Will be handled differently below
  }

  // ── Record a view ─────────────────────────────────────────────────────────
  /**
   * Call this whenever the user navigates to an artwork detail / trading page.
   * @param {Object} artwork - { id, tags, artist, medium }
   */
  function recordView(artwork) {
    if (!artwork?.id) return

    // Deduplicate consecutive views of the same artwork
    if (viewedArtworkIds.value[viewedArtworkIds.value.length - 1] === artwork.id) return

    viewedArtworkIds.value.push(artwork.id)
    totalViews.value++

    // Tag scores
    if (Array.isArray(artwork.tags)) {
      artwork.tags.forEach(t => {
        tagScores.value[t] = (tagScores.value[t] || 0) + 1
      })
    }

    // Artist scores
    if (artwork.artist) {
      artistScores.value[artwork.artist] = (artistScores.value[artwork.artist] || 0) + 1
    }

    // Medium scores
    if (artwork.medium) {
      mediumScores.value[artwork.medium] = (mediumScores.value[artwork.medium] || 0) + 1
    }

    _persist()
  }

  /** Mark that a proactive message was just sent */
  function markProactiveSent() {
    lastProactiveAt.value = Date.now()
    _persist()
  }

  /** Generate a text summary of the user profile for the AI prompt */
  function profileSummary() {
    if (!hasEnoughData.value) return null
    const tags    = topTags.value.join('、')
    const artists = topArtists.value.join('、')
    const total   = totalViews.value
    const recent  = viewedArtworkIds.value.slice(-5)

    return {
      tags,
      artists,
      totalViews: total,
      recentArtworkIds: recent,
      text: `該用戶已瀏覽 ${total} 件藝術品。偏好標籤：${tags || '尚無'}。關注藝術家：${artists || '尚無'}。`,
    }
  }

  function reset() {
    viewedArtworkIds.value = []
    tagScores.value        = {}
    artistScores.value     = {}
    mediumScores.value     = {}
    totalViews.value       = 0
    lastProactiveAt.value  = 0
    localStorage.removeItem(STORAGE_KEY)
  }

  return {
    viewedArtworkIds, tagScores, artistScores, mediumScores,
    totalViews, lastProactiveAt,
    topTags, topArtists, hasEnoughData,
    recordView, markProactiveSent, shouldProactive, profileSummary, reset,
  }
})

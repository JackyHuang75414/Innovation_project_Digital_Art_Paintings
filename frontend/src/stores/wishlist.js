import { computed, ref } from 'vue'
import { defineStore } from 'pinia'
import { addWishlist, getMyWishlist, removeWishlist } from '@/api/wishlist'
import { useAuthStore } from '@/stores/auth'

export const useWishlistStore = defineStore('wishlist', () => {
  const items = ref([])
  const loading = ref(false)
  const loadedForUserId = ref(null)

  const ids = computed(() => new Set(items.value.map(item => Number(item.id))))

  function isWishlisted(artworkId) {
    return ids.value.has(Number(artworkId))
  }

  async function loadMine({ force = false } = {}) {
    const auth = useAuthStore()
    if (!auth.isLoggedIn) {
      reset()
      return []
    }
    if (!force && loadedForUserId.value === auth.user?.id) return items.value

    loading.value = true
    try {
      const { data } = await getMyWishlist()
      items.value = data ?? []
      loadedForUserId.value = auth.user?.id ?? null
      return items.value
    } finally {
      loading.value = false
    }
  }

  async function toggle(artwork) {
    const auth = useAuthStore()
    if (!auth.isLoggedIn) {
      window.dispatchEvent(new CustomEvent('artex:open-auth', { detail: { mode: 'login' } }))
      return { ok: false, needsLogin: true }
    }

    const artworkId = Number(artwork.id)
    if (isWishlisted(artworkId)) {
      const { data } = await removeWishlist(artworkId)
      items.value = items.value.filter(item => Number(item.id) !== artworkId)
      return { ok: true, wishlisted: data?.wishlisted ?? false }
    }

    const { data } = await addWishlist(artworkId)
    if (!isWishlisted(artworkId)) {
      items.value = [normalizeArtwork(artwork), ...items.value]
    }
    return { ok: true, wishlisted: data?.wishlisted ?? true }
  }

  function reset() {
    items.value = []
    loadedForUserId.value = null
  }

  return { items, loading, ids, isWishlisted, loadMine, toggle, reset }
})

function normalizeArtwork(artwork) {
  return {
    id: Number(artwork.id),
    imageUrl: artwork.imageUrl,
    title: artwork.title,
    artistName: artwork.artistName ?? artwork.artist,
    price: artwork.price ?? artwork.initPrice,
    medium: artwork.medium,
    badge: artwork.badge,
  }
}

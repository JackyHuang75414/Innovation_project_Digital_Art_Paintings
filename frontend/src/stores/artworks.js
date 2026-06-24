import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getArtworks } from '@/api/artworks'

export const useArtworksStore = defineStore('artworks', () => {
  const items = ref([])
  const loading = ref(false)
  const error = ref(null)
  const filters = ref({ category: '', priceMin: null, priceMax: null, medium: '', sort: 'recommended' })

  async function fetchAll(params = {}) {
    loading.value = true
    error.value = null
    try {
      // http interceptor unwraps Result<T>, so we get the array directly
      const data = await getArtworks({ ...filters.value, ...params })
      items.value = Array.isArray(data) ? data : (data?.items ?? data ?? [])
    } catch (e) {
      error.value = e.message
      console.warn('[artworks] fetchAll failed:', e.message)
    } finally {
      loading.value = false
    }
  }

  function setFilter(key, value) {
    filters.value[key] = value
  }

  return { items, loading, error, filters, fetchAll, setFilter }
})

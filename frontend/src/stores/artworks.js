import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getArtworks } from '@/api/artworks'

export const useArtworksStore = defineStore('artworks', () => {
  const items = ref([])
  const loading = ref(false)
  const filters = ref({ category: '', priceMin: null, priceMax: null, medium: '', sort: 'recommended' })

  async function fetchAll(params = {}) {
    loading.value = true
    try {
      const { data } = await getArtworks({ ...filters.value, ...params })
      items.value = data
    } finally {
      loading.value = false
    }
  }

  function setFilter(key, value) {
    filters.value[key] = value
  }

  return { items, loading, filters, fetchAll, setFilter }
})

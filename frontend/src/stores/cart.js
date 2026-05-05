import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useCartStore = defineStore('cart', () => {
  const items = ref([])

  const count = computed(() => items.value.reduce((sum, i) => sum + i.quantity, 0))
  const total = computed(() => items.value.reduce((sum, i) => sum + i.price * i.quantity, 0))

  function add(artwork, size, quantity = 1) {
    const key = `${artwork.id}-${size}`
    const existing = items.value.find((i) => i.key === key)
    if (existing) {
      existing.quantity += quantity
    } else {
      items.value.push({ key, artwork, size, quantity, price: artwork.price })
    }
  }

  function remove(key) {
    items.value = items.value.filter((i) => i.key !== key)
  }

  function clear() {
    items.value = []
  }

  return { items, count, total, add, remove, clear }
}, { persist: true })

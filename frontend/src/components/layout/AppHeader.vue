<script setup>
import { ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'

const cart = useCartStore()
const router = useRouter()
const searchOpen = ref(false)
const searchQuery = ref('')

const categories = [
  { label: 'Paintings', slug: 'paintings' },
  { label: 'Photography', slug: 'photography' },
  { label: 'Prints', slug: 'prints' },
  { label: 'Digital Art', slug: 'digital' },
  { label: 'Collections', slug: 'collections' },
]

function submitSearch() {
  if (searchQuery.value.trim()) {
    router.push({ path: '/browse', query: { q: searchQuery.value.trim() } })
    searchOpen.value = false
    searchQuery.value = ''
  }
}
</script>

<template>
  <!-- Trust bar -->
  <div class="bg-gray-900 text-gray-400 text-center py-2 px-4">
    <p class="text-[10px] tracking-[0.25em] uppercase font-light">
      Free worldwide shipping on orders over €80 &ensp;·&ensp; Secure checkout &ensp;·&ensp; Authentic digital art
    </p>
  </div>

  <!-- Main header -->
  <header class="sticky top-0 z-40 bg-white border-b border-gray-100">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 h-[4.5rem] flex items-center justify-between gap-4">
      <!-- Logo -->
      <RouterLink to="/" class="flex-shrink-0 font-display italic text-[1.35rem] font-normal tracking-normal text-gray-900">
        ArtCanvas
      </RouterLink>

      <!-- Category nav (desktop) -->
      <nav class="hidden lg:flex items-center gap-8">
        <RouterLink
          v-for="cat in categories"
          :key="cat.slug"
          :to="{ path: '/browse', query: { category: cat.slug } }"
          class="text-[11px] tracking-[0.18em] uppercase text-gray-500 hover:text-gray-900 transition-colors duration-150 font-light"
        >
          {{ cat.label }}
        </RouterLink>
      </nav>

      <!-- Right icons -->
      <div class="flex items-center gap-3">
        <!-- Search toggle -->
        <button
          class="p-2 rounded-full hover:bg-gray-100 transition-colors"
          aria-label="Search"
          @click="searchOpen = true"
        >
          <svg class="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M21 21l-4.35-4.35M17 11A6 6 0 1 1 5 11a6 6 0 0 1 12 0z" />
          </svg>
        </button>

        <!-- Wishlist -->
        <button class="p-2 rounded-full hover:bg-gray-100 transition-colors hidden sm:block" aria-label="Wishlist">
          <svg class="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
          </svg>
        </button>

        <!-- Account -->
        <RouterLink to="/account" class="p-2 rounded-full hover:bg-gray-100 transition-colors hidden sm:block" aria-label="Account">
          <svg class="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
          </svg>
        </RouterLink>

        <!-- Cart -->
        <RouterLink to="/cart" class="relative p-2 rounded-full hover:bg-gray-100 transition-colors" aria-label="Cart">
          <svg class="w-5 h-5 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-1.4 6h12.8M10 21a1 1 0 100-2 1 1 0 000 2zm8 0a1 1 0 100-2 1 1 0 000 2z" />
          </svg>
          <span
            v-if="cart.count > 0"
            class="absolute -top-0.5 -right-0.5 bg-[#E8552A] text-white text-[10px] font-bold rounded-full w-4 h-4 flex items-center justify-center"
          >
            {{ cart.count }}
          </span>
        </RouterLink>
      </div>
    </div>
  </header>

  <!-- Search overlay -->
  <Transition name="fade">
    <div
      v-if="searchOpen"
      class="fixed inset-0 z-50 bg-black/50 flex items-start justify-center pt-24"
      @click.self="searchOpen = false"
    >
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl mx-4 p-6">
        <form class="flex gap-3" @submit.prevent="submitSearch">
          <input
            v-model="searchQuery"
            autofocus
            type="text"
            placeholder="Search artworks, artists, styles..."
            class="flex-1 border border-gray-200 rounded-lg px-4 py-3 text-base outline-none focus:ring-2 focus:ring-[#E8552A]"
          />
          <button type="submit" class="btn-primary">Search</button>
        </form>
        <button class="mt-3 text-sm text-gray-500 hover:text-gray-700" @click="searchOpen = false">
          Cancel
        </button>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active { transition: opacity 0.2s; }
.fade-enter-from,
.fade-leave-to { opacity: 0; }
</style>

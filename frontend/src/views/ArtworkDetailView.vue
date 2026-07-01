<script setup>
import { computed, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { useRoute } from 'vue-router'
import { useCartStore } from '@/stores/cart'
import { useWishlistStore } from '@/stores/wishlist'
import { getArtwork, getRecommendations } from '@/api/artworks'

const cart = useCartStore()
const wishlist = useWishlistStore()
const route = useRoute()

const artwork = ref(null)
const recommendations = ref([])
const selectedSize = ref('')
const added = ref(false)
const loading = ref(false)
const error = ref('')

const sizes = computed(() => artwork.value?.availableSizes?.length ? artwork.value.availableSizes : ['A4 Print'])

watch(
  () => route.params.id,
  async id => {
    loading.value = true
    error.value = ''
    try {
      const [artRes, recRes] = await Promise.all([
        getArtwork(id),
        getRecommendations(id),
      ])
      artwork.value = artRes.data
      recommendations.value = recRes.data ?? []
      selectedSize.value = sizes.value[0]
      await wishlist.loadMine()
    } catch (err) {
      error.value = err.message || 'Artwork not found'
    } finally {
      loading.value = false
    }
  },
  { immediate: true }
)

function addToCart() {
  if (!artwork.value) return
  cart.add(artwork.value, selectedSize.value)
  added.value = true
  setTimeout(() => { added.value = false }, 2000)
}

async function toggleWishlist() {
  if (!artwork.value) return
  await wishlist.toggle(artwork.value)
}
</script>

<template>
<div class="bg-white text-gray-900">
  <!-- Breadcrumb -->
  <div class="bg-[#F7F4F0] border-b border-[#E0D8CE]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-3.5">
      <nav class="flex items-center gap-2 text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light">
        <RouterLink to="/" class="hover:text-gray-700 transition-colors">Home</RouterLink>
        <span class="text-gray-300">/</span>
        <RouterLink to="/browse" class="hover:text-gray-700 transition-colors">Browse</RouterLink>
        <span class="text-gray-300">/</span>
        <span class="text-gray-600">{{ artwork.title }}</span>
      </nav>
    </div>
  </div>

  <div v-if="loading" class="max-w-screen-xl mx-auto px-6 lg:px-16 py-24 text-sm text-gray-500">
    Loading artwork...
  </div>
  <div v-else-if="error || !artwork" class="max-w-screen-xl mx-auto px-6 lg:px-16 py-24 text-sm text-gray-500">
    {{ error || 'Artwork not found' }}
  </div>
  <div v-else class="max-w-screen-xl mx-auto px-6 lg:px-16 py-12 lg:py-16">
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20">

      <!-- Image -->
      <div class="bg-[#F7F4F0]">
        <img
          :src="artwork.imageUrl"
          :alt="artwork.title"
          class="w-full h-auto object-cover"
        />
      </div>

      <!-- Info panel -->
      <div class="flex flex-col gap-6 lg:py-2">

        <!-- Artist + title -->
        <div>
          <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-3">
            {{ artwork.artistName }}&ensp;·&ensp;{{ artwork.artistCountry }}
          </p>
          <h1 class="font-display italic font-normal text-gray-900 leading-tight"
              style="font-size: clamp(1.75rem, 3.5vw, 2.75rem)">
            {{ artwork.title }}
          </h1>
          <p class="text-[11px] tracking-[0.15em] text-gray-400 mt-2.5 font-light">
            {{ artwork.medium }}&ensp;·&ensp;{{ artwork.year }}
          </p>
        </div>

        <!-- Price -->
        <div class="flex items-baseline gap-3">
          <p class="font-display italic text-4xl font-normal text-gray-900">€{{ artwork.price }}</p>
          <p class="text-xs text-gray-400 font-light tracking-wide">per print</p>
        </div>

        <div class="h-px bg-gray-100" />

        <!-- Description -->
        <p class="text-gray-600 leading-relaxed text-sm font-light">{{ artwork.description }}</p>

        <!-- Tags -->
        <div class="flex flex-wrap gap-2">
          <span
            v-for="tag in artwork.tags"
            :key="tag"
            class="border border-gray-200 text-gray-500 text-[10px] tracking-[0.15em] uppercase px-3 py-1 font-light"
          >
            {{ tag }}
          </span>
        </div>

        <div class="h-px bg-gray-100" />

        <!-- Size selector -->
        <div>
          <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-3">Select size</p>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="size in sizes"
              :key="size"
              class="px-4 py-2 border text-xs tracking-wide font-light transition-colors"
              :class="selectedSize === size
                ? 'border-gray-900 bg-gray-900 text-white'
                : 'border-gray-200 text-gray-600 hover:border-gray-400'"
              @click="selectedSize = size"
            >
              {{ size }}
            </button>
          </div>
        </div>

        <!-- Add to cart -->
        <div class="grid grid-cols-[1fr_auto] gap-3">
          <button class="btn-primary text-center" @click="addToCart">
            {{ added ? 'Added to Cart' : 'Add to Cart' }}
          </button>
          <button
            class="w-12 border flex items-center justify-center transition-colors"
            :class="wishlist.isWishlisted(artwork.id)
              ? 'border-[#E8552A] bg-[#E8552A]/10 text-[#E8552A]'
              : 'border-gray-200 text-gray-500 hover:border-gray-400 hover:text-gray-900'"
            :aria-label="wishlist.isWishlisted(artwork.id) ? 'Remove from wishlist' : 'Add to wishlist'"
            @click="toggleWishlist"
          >
            <svg
              class="w-4 h-4"
              :class="wishlist.isWishlisted(artwork.id) ? 'fill-current' : ''"
              fill="none"
              stroke="currentColor"
              stroke-width="1.8"
              viewBox="0 0 24 24"
            >
              <path d="M4.318 6.318a4.5 4.5 0 0 1 6.364 0L12 7.636l1.318-1.318a4.5 4.5 0 0 1 6.364 6.364L12 20.364l-7.682-7.682a4.5 4.5 0 0 1 0-6.364Z" />
            </svg>
          </button>
        </div>

        <!-- Trust signals -->
        <div class="grid grid-cols-3 gap-4 pt-4 border-t border-gray-100">
          <div class="flex flex-col items-center gap-2 text-center">
            <svg class="w-5 h-5 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 0 0-3.213-9.193 2.056 2.056 0 0 0-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 0 0-10.026 0 1.106 1.106 0 0 0-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/>
            </svg>
            <p class="text-[10px] tracking-[0.08em] uppercase text-gray-400 font-light leading-snug">Free shipping<br/>over €80</p>
          </div>
          <div class="flex flex-col items-center gap-2 text-center">
            <svg class="w-5 h-5 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99"/>
            </svg>
            <p class="text-[10px] tracking-[0.08em] uppercase text-gray-400 font-light leading-snug">Free<br/>returns</p>
          </div>
          <div class="flex flex-col items-center gap-2 text-center">
            <svg class="w-5 h-5 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                d="M9 12.75 11.25 15 15 9.75m-3-7.036A11.959 11.959 0 0 1 3.598 6 11.99 11.99 0 0 0 3 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285Z"/>
            </svg>
            <p class="text-[10px] tracking-[0.08em] uppercase text-gray-400 font-light leading-snug">Authenticity<br/>cert.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- AI Recommendations -->
    <section class="mt-20 lg:mt-24 pt-12 border-t border-gray-100">
      <div class="flex items-end justify-between mb-10">
        <div>
          <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-3 font-light">AI-Curated</p>
          <h2 class="font-display text-3xl lg:text-4xl font-normal italic text-gray-900">
            You May Also Like
          </h2>
        </div>
      </div>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-6 lg:gap-8">
        <RouterLink
          v-for="rec in recommendations"
          :key="rec.id"
          :to="`/artwork/${rec.id}`"
          class="group block"
        >
          <div class="overflow-hidden bg-[#F7F4F0]">
            <img
              :src="rec.imageUrl"
              :alt="rec.title"
              class="w-full h-44 object-cover transition-transform duration-700 group-hover:scale-[1.04]"
              loading="lazy"
            />
          </div>
          <div class="mt-3">
            <p class="text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light">{{ rec.artistName }}</p>
            <p class="font-display italic text-base text-gray-900 mt-1 leading-snug">{{ rec.title }}</p>
            <p class="text-sm font-medium text-gray-900 mt-1">€{{ rec.price }}</p>
          </div>
        </RouterLink>
      </div>
    </section>
  </div>
</div>
</template>

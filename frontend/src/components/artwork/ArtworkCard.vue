<script setup>
import { RouterLink } from 'vue-router'
import { useWishlistStore } from '@/stores/wishlist'

const props = defineProps({
  artwork: { type: Object, required: true },
})

const wishlist = useWishlistStore()

async function toggleWishlist() {
  await wishlist.toggle(props.artwork)
}
</script>

<template>
  <div class="masonry-item group">
    <RouterLink :to="`/artwork/${artwork.id}`" class="block">
      <div class="relative overflow-hidden bg-[#F7F4F0]">
        <img
          :src="artwork.imageUrl"
          :alt="artwork.title"
          class="w-full h-auto object-cover transition-transform duration-700 ease-out group-hover:scale-[1.04]"
          loading="lazy"
        />

        <!-- Wishlist button -->
        <button
          class="absolute top-3 right-3 w-7 h-7 rounded-full bg-white/80 backdrop-blur-sm flex items-center justify-center shadow-sm transition-all duration-200 opacity-0 group-hover:opacity-100"
          :class="{ '!opacity-100': wishlist.isWishlisted(artwork.id) }"
          :aria-label="wishlist.isWishlisted(artwork.id) ? 'Remove from wishlist' : 'Add to wishlist'"
          @click.prevent="toggleWishlist"
        >
          <svg
            class="w-3.5 h-3.5 transition-colors"
            :class="wishlist.isWishlisted(artwork.id) ? 'text-[#E8552A] fill-current' : 'text-gray-500'"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            viewBox="0 0 24 24"
          >
            <path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
          </svg>
        </button>

        <!-- Badge -->
        <div v-if="artwork.badge" class="absolute top-3 left-3">
          <span class="bg-gray-900/80 text-white text-[10px] tracking-[0.15em] uppercase font-light px-2.5 py-1">
            {{ artwork.badge }}
          </span>
        </div>
      </div>

      <!-- Metadata -->
      <div class="mt-3">
        <p class="text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light truncate">{{ artwork.artistName }}</p>
        <p class="font-display italic text-[0.9rem] text-gray-900 leading-snug line-clamp-2 mt-1">{{ artwork.title }}</p>
        <p class="text-[11px] text-gray-400 mt-0.5 font-light">{{ artwork.medium }}</p>
        <p class="text-sm font-medium text-gray-900 mt-1">€{{ artwork.price }}</p>
      </div>
    </RouterLink>
  </div>
</template>

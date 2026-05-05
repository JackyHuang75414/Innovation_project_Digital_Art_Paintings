<script setup>
import { ref } from 'vue'
import { RouterLink } from 'vue-router'

const props = defineProps({
  artwork: { type: Object, required: true },
})

const wishlisted = ref(false)
</script>

<template>
  <div class="masonry-item group">
    <RouterLink :to="`/artwork/${artwork.id}`" class="block">
      <div class="relative overflow-hidden rounded-xl bg-gray-100">
        <!-- Natural aspect-ratio image (no forced crop) -->
        <img
          :src="artwork.imageUrl"
          :alt="artwork.title"
          class="w-full h-auto object-cover transition-transform duration-300 group-hover:scale-[1.02]"
          loading="lazy"
        />

        <!-- Wishlist button -->
        <button
          class="absolute top-3 right-3 w-8 h-8 rounded-full bg-white/80 backdrop-blur-sm flex items-center justify-center shadow transition-opacity duration-200 opacity-0 group-hover:opacity-100"
          :class="{ '!opacity-100': wishlisted }"
          aria-label="Add to wishlist"
          @click.prevent="wishlisted = !wishlisted"
        >
          <svg
            class="w-4 h-4 transition-colors"
            :class="wishlisted ? 'text-[#E8552A] fill-current' : 'text-gray-500'"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            viewBox="0 0 24 24"
          >
            <path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
          </svg>
        </button>

        <!-- Badges -->
        <div v-if="artwork.badge" class="absolute top-3 left-3">
          <span class="bg-gray-900/80 text-white text-[11px] font-medium px-2 py-0.5 rounded-full">
            {{ artwork.badge }}
          </span>
        </div>
      </div>

      <!-- Card metadata -->
      <div class="mt-2.5 px-0.5">
        <p class="text-xs text-gray-500 truncate">{{ artwork.artistName }}</p>
        <p class="text-sm font-medium text-gray-900 mt-0.5 leading-snug line-clamp-2 italic">
          {{ artwork.title }}
        </p>
        <p class="text-xs text-gray-400 mt-0.5">{{ artwork.medium }}</p>
        <p class="text-sm font-semibold text-gray-900 mt-1">€{{ artwork.price }}</p>
      </div>
    </RouterLink>
  </div>
</template>

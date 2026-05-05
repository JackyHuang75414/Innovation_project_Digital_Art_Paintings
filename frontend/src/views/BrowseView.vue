<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import ArtworkCard from '@/components/artwork/ArtworkCard.vue'
import ArtworkFilters from '@/components/artwork/ArtworkFilters.vue'

const route = useRoute()
const filtersOpen = ref(false)

// Placeholder data — replace with useArtworksStore + API call
const artworks = ref([
  { id: 1, imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=500', title: 'Abstract Harmony', artistName: 'Sophie Laurent', price: 89, medium: 'Acrylic' },
  { id: 2, imageUrl: 'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=500', title: 'Urban Geometry', artistName: 'Marco Chen', price: 120, medium: 'Digital', badge: 'New' },
  { id: 3, imageUrl: 'https://images.unsplash.com/photo-1620503374956-c942862f0372?w=500', title: 'Blue Silence', artistName: 'Amara Diallo', price: 75, medium: 'Oil' },
  { id: 4, imageUrl: 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=500', title: 'Golden Hour', artistName: 'Lena Kuznetsov', price: 99, medium: 'Photograph' },
  { id: 5, imageUrl: 'https://images.unsplash.com/photo-1605721911519-3dfeb3be25e7?w=500', title: 'Forest Dream', artistName: 'Jules Moreau', price: 65, medium: 'Watercolour', badge: 'Trending' },
  { id: 6, imageUrl: 'https://images.unsplash.com/photo-1559762717-99c81ac85059?w=500', title: 'Desert Wind', artistName: 'Yuki Tanaka', price: 110, medium: 'Ink' },
  { id: 7, imageUrl: 'https://images.unsplash.com/photo-1531913223931-b0d3198229ee?w=500', title: 'Night Garden', artistName: 'Elif Yıldız', price: 85, medium: 'Oil' },
  { id: 8, imageUrl: 'https://images.unsplash.com/photo-1549490349-8643362247b5?w=500', title: 'Soft Focus', artistName: 'Kai Bergström', price: 55, medium: 'Photograph' },
  { id: 9, imageUrl: 'https://images.unsplash.com/photo-1574169208507-84376144848b?w=500', title: 'Crimson Flow', artistName: 'Nadia Rousseau', price: 145, medium: 'Acrylic', badge: 'Limited' },
  { id: 10, imageUrl: 'https://images.unsplash.com/photo-1605108040932-db63d52c4d88?w=500', title: 'Still Waters', artistName: 'Tomás García', price: 79, medium: 'Watercolour' },
  { id: 11, imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500', title: 'Electric Sky', artistName: 'Priya Nair', price: 95, medium: 'Digital' },
  { id: 12, imageUrl: 'https://images.unsplash.com/photo-1561214115-f2f134cc4912?w=500', title: 'Clay Forms', artistName: 'Hassan Al-Farsi', price: 130, medium: 'Photograph' },
])

function onFiltersUpdate(newFilters) {
  console.log('Filters updated:', newFilters)
  // TODO: call useArtworksStore().fetchAll(newFilters)
}
</script>

<template>
  <div class="max-w-screen-xl mx-auto px-4 py-8">
    <!-- Page header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Browse Artworks</h1>
        <p class="text-sm text-gray-500 mt-0.5">{{ artworks.length }} artworks found</p>
      </div>
      <!-- Mobile filter toggle -->
      <button
        class="lg:hidden btn-outline flex items-center gap-2 text-sm"
        @click="filtersOpen = true"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4h18M7 8h10M11 12h4" />
        </svg>
        Filters
      </button>
    </div>

    <div class="flex gap-8">
      <!-- Sidebar filters (desktop) -->
      <div class="hidden lg:block w-56 flex-shrink-0">
        <ArtworkFilters @update:filters="onFiltersUpdate" />
      </div>

      <!-- Artwork masonry grid -->
      <div class="flex-1">
        <div class="masonry">
          <ArtworkCard v-for="artwork in artworks" :key="artwork.id" :artwork="artwork" />
        </div>

        <!-- Load more -->
        <div class="text-center mt-10">
          <button class="btn-outline px-8">Load more</button>
        </div>
      </div>
    </div>

    <!-- Mobile filter drawer -->
    <Transition name="slide">
      <div
        v-if="filtersOpen"
        class="fixed inset-0 z-50 flex"
      >
        <div class="absolute inset-0 bg-black/40" @click="filtersOpen = false" />
        <div class="relative ml-auto w-72 bg-white h-full overflow-y-auto p-6 shadow-xl">
          <div class="flex items-center justify-between mb-6">
            <h2 class="font-bold text-lg">Filters</h2>
            <button @click="filtersOpen = false" class="text-gray-500 hover:text-gray-900">✕</button>
          </div>
          <ArtworkFilters @update:filters="onFiltersUpdate" />
        </div>
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.slide-enter-active, .slide-leave-active { transition: transform 0.3s ease; }
.slide-enter-from, .slide-leave-to { transform: translateX(100%); }
</style>

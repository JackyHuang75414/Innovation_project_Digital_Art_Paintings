<script setup>
import { ref } from 'vue'
import { useCartStore } from '@/stores/cart'

const cart = useCartStore()

// Placeholder artwork — replace with API fetch using useRoute().params.id
const artwork = ref({
  id: 1,
  imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=800',
  title: 'Abstract Harmony',
  artistName: 'Sophie Laurent',
  artistCountry: 'France',
  price: 89,
  medium: 'Acrylic on Canvas',
  dimensions: '60 × 80 cm',
  year: 2024,
  description: 'A vivid exploration of colour and emotion. This piece captures the tension between stillness and movement through layered brushwork and a bold chromatic palette.',
  tags: ['abstract', 'colourful', 'expressive'],
})

const sizes = ['A4 Print', 'A3 Print', 'A2 Print', '50×70 cm', '60×80 cm']
const selectedSize = ref('A3 Print')
const added = ref(false)

function addToCart() {
  cart.add(artwork.value, selectedSize.value)
  added.value = true
  setTimeout(() => { added.value = false }, 2000)
}

// Recommendations placeholder
const recommendations = ref([
  { id: 2, imageUrl: 'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=300', title: 'Urban Geometry', artistName: 'Marco Chen', price: 120 },
  { id: 3, imageUrl: 'https://images.unsplash.com/photo-1620503374956-c942862f0372?w=300', title: 'Blue Silence', artistName: 'Amara Diallo', price: 75 },
  { id: 4, imageUrl: 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=300', title: 'Golden Hour', artistName: 'Lena Kuznetsov', price: 99 },
  { id: 5, imageUrl: 'https://images.unsplash.com/photo-1605721911519-3dfeb3be25e7?w=300', title: 'Forest Dream', artistName: 'Jules Moreau', price: 65 },
])
</script>

<template>
  <div class="max-w-screen-xl mx-auto px-4 py-10">
    <!-- Breadcrumb -->
    <nav class="text-sm text-gray-500 mb-6">
      <RouterLink to="/" class="hover:text-gray-900">Home</RouterLink>
      <span class="mx-2">/</span>
      <RouterLink to="/browse" class="hover:text-gray-900">Browse</RouterLink>
      <span class="mx-2">/</span>
      <span class="text-gray-900">{{ artwork.title }}</span>
    </nav>

    <!-- Main product layout -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-12">
      <!-- Artwork image -->
      <div>
        <img
          :src="artwork.imageUrl"
          :alt="artwork.title"
          class="w-full h-auto rounded-2xl shadow-xl object-cover"
        />
      </div>

      <!-- Artwork info & purchase -->
      <div class="flex flex-col gap-5">
        <div>
          <p class="text-sm text-gray-500">{{ artwork.artistName }} &nbsp;·&nbsp; {{ artwork.artistCountry }}</p>
          <h1 class="text-3xl font-bold text-gray-900 mt-1 italic">{{ artwork.title }}</h1>
          <p class="text-gray-500 text-sm mt-1">{{ artwork.medium }} &nbsp;·&nbsp; {{ artwork.year }}</p>
        </div>

        <p class="text-3xl font-bold text-gray-900">€{{ artwork.price }}</p>

        <p class="text-gray-700 leading-relaxed">{{ artwork.description }}</p>

        <!-- Tags -->
        <div class="flex flex-wrap gap-2">
          <span
            v-for="tag in artwork.tags"
            :key="tag"
            class="px-3 py-1 rounded-full bg-gray-100 text-gray-600 text-xs font-medium"
          >
            #{{ tag }}
          </span>
        </div>

        <!-- Size selector -->
        <div>
          <p class="text-sm font-semibold text-gray-700 mb-2">Select size</p>
          <div class="flex flex-wrap gap-2">
            <button
              v-for="size in sizes"
              :key="size"
              class="px-3.5 py-2 rounded-lg border text-sm font-medium transition-colors"
              :class="selectedSize === size
                ? 'border-[#E8552A] bg-[#E8552A]/10 text-[#E8552A]'
                : 'border-gray-200 text-gray-600 hover:border-gray-400'"
              @click="selectedSize = size"
            >
              {{ size }}
            </button>
          </div>
        </div>

        <!-- Add to cart -->
        <button
          class="btn-primary w-full text-base py-3 mt-2 flex items-center justify-center gap-2"
          @click="addToCart"
        >
          <svg v-if="!added" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-1.4 6h12.8" />
          </svg>
          <span>{{ added ? '✓ Added to cart!' : 'Add to Cart' }}</span>
        </button>

        <!-- Trust signals -->
        <div class="grid grid-cols-3 gap-3 pt-4 border-t border-gray-100 text-center">
          <div class="text-xs text-gray-500">
            <p class="text-base mb-1">🚚</p>
            Free shipping over €80
          </div>
          <div class="text-xs text-gray-500">
            <p class="text-base mb-1">↩️</p>
            Free returns
          </div>
          <div class="text-xs text-gray-500">
            <p class="text-base mb-1">✅</p>
            Authenticity cert.
          </div>
        </div>
      </div>
    </div>

    <!-- AI Recommendations (below fold) -->
    <section class="mt-16">
      <h2 class="text-xl font-bold text-gray-900 mb-6">
        ✨ You might also like
        <span class="text-sm font-normal text-gray-400 ml-2">— AI-recommended</span>
      </h2>
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
        <RouterLink
          v-for="rec in recommendations"
          :key="rec.id"
          :to="`/artwork/${rec.id}`"
          class="group block"
        >
          <div class="overflow-hidden rounded-xl bg-gray-100">
            <img
              :src="rec.imageUrl"
              :alt="rec.title"
              class="w-full h-40 object-cover group-hover:scale-105 transition-transform duration-300"
            />
          </div>
          <p class="text-xs text-gray-500 mt-2">{{ rec.artistName }}</p>
          <p class="text-sm font-medium italic text-gray-900">{{ rec.title }}</p>
          <p class="text-sm font-semibold text-gray-900 mt-0.5">€{{ rec.price }}</p>
        </RouterLink>
      </div>
    </section>
  </div>
</template>

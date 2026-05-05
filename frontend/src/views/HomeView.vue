<script setup>
import { RouterLink } from 'vue-router'

// Placeholder artwork data for the hero grid — replace with API data
const featuredArtworks = [
  { id: 1, imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=400', title: 'Abstract Harmony', artistName: 'Sophie Laurent', price: 89 },
  { id: 2, imageUrl: 'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=400', title: 'Urban Geometry', artistName: 'Marco Chen', price: 120 },
  { id: 3, imageUrl: 'https://images.unsplash.com/photo-1620503374956-c942862f0372?w=400', title: 'Blue Silence', artistName: 'Amara Diallo', price: 75 },
  { id: 4, imageUrl: 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=400', title: 'Golden Hour', artistName: 'Lena Kuznetsov', price: 99 },
  { id: 5, imageUrl: 'https://images.unsplash.com/photo-1605721911519-3dfeb3be25e7?w=400', title: 'Forest Dream', artistName: 'Jules Moreau', price: 65 },
  { id: 6, imageUrl: 'https://images.unsplash.com/photo-1559762717-99c81ac85059?w=400', title: 'Desert Wind', artistName: 'Yuki Tanaka', price: 110 },
]

const categories = [
  { label: 'Paintings', icon: '🖌️', slug: 'paintings' },
  { label: 'Photography', icon: '📷', slug: 'photography' },
  { label: 'Digital Art', icon: '💻', slug: 'digital' },
  { label: 'Prints', icon: '🖼️', slug: 'prints' },
]
</script>

<template>
  <!-- Hero Section -->
  <section class="relative bg-gray-950 text-white overflow-hidden">
    <div class="max-w-screen-xl mx-auto px-4 py-20 lg:py-28 flex flex-col lg:flex-row items-center gap-12">
      <!-- Copy -->
      <div class="flex-1 text-center lg:text-left">
        <p class="text-[#E8552A] font-semibold text-sm uppercase tracking-widest mb-4">
          AI-Powered Art Discovery
        </p>
        <h1 class="text-4xl lg:text-6xl font-bold leading-tight mb-6">
          Find Art That<br />
          <span class="text-[#E8552A]">Speaks to You</span>
        </h1>
        <p class="text-gray-400 text-lg mb-8 max-w-md mx-auto lg:mx-0">
          Browse thousands of original digital artworks. Our AI learns your taste and curates a collection just for you.
        </p>
        <div class="flex flex-col sm:flex-row gap-3 justify-center lg:justify-start">
          <RouterLink to="/browse" class="btn-primary text-center">
            Explore Artworks
          </RouterLink>
          <RouterLink to="/browse?category=collections" class="btn-outline text-center">
            View Collections
          </RouterLink>
        </div>
        <p class="mt-6 text-gray-500 text-sm">
          Free shipping on orders over €80 &nbsp;·&nbsp; Print-on-demand &nbsp;·&nbsp; Zero stock
        </p>
      </div>

      <!-- Mini masonry preview grid -->
      <div class="flex-1 hidden lg:grid grid-cols-3 gap-3 max-w-lg">
        <img
          v-for="art in featuredArtworks.slice(0, 6)"
          :key="art.id"
          :src="art.imageUrl"
          :alt="art.title"
          class="rounded-xl object-cover w-full h-40 hover:scale-105 transition-transform duration-300"
        />
      </div>
    </div>
  </section>

  <!-- Category pills -->
  <section class="bg-white border-b border-gray-100 py-6">
    <div class="max-w-screen-xl mx-auto px-4 flex flex-wrap gap-3 justify-center">
      <RouterLink
        v-for="cat in categories"
        :key="cat.slug"
        :to="`/browse?category=${cat.slug}`"
        class="flex items-center gap-2 px-5 py-2.5 rounded-full border border-gray-200 hover:border-[#E8552A] hover:text-[#E8552A] text-sm font-medium text-gray-700 transition-colors"
      >
        <span>{{ cat.icon }}</span>
        {{ cat.label }}
      </RouterLink>
    </div>
  </section>

  <!-- Trending artworks -->
  <section class="max-w-screen-xl mx-auto px-4 py-14">
    <div class="flex items-baseline justify-between mb-8">
      <h2 class="text-2xl font-bold text-gray-900">Trending Now</h2>
      <RouterLink to="/browse?sort=trending" class="text-sm text-[#E8552A] hover:underline font-medium">
        View all →
      </RouterLink>
    </div>

    <!-- Masonry preview (static placeholders) -->
    <div class="masonry">
      <RouterLink
        v-for="art in featuredArtworks"
        :key="art.id"
        :to="`/artwork/${art.id}`"
        class="masonry-item group block"
      >
        <div class="relative overflow-hidden rounded-xl bg-gray-100">
          <img
            :src="art.imageUrl"
            :alt="art.title"
            class="w-full h-auto object-cover transition-transform duration-300 group-hover:scale-[1.03]"
            loading="lazy"
          />
          <div class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/60 to-transparent p-4 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
            <p class="text-white text-sm font-medium italic">{{ art.title }}</p>
            <p class="text-gray-300 text-xs mt-0.5">{{ art.artistName }} &nbsp;·&nbsp; €{{ art.price }}</p>
          </div>
        </div>
      </RouterLink>
    </div>
  </section>

  <!-- AI recommendation banner -->
  <section class="bg-gray-950 text-white py-16">
    <div class="max-w-screen-xl mx-auto px-4 text-center">
      <div class="inline-flex items-center gap-2 bg-[#E8552A]/20 text-[#E8552A] rounded-full px-4 py-1.5 text-sm font-semibold mb-6">
        ✨ Powered by AI
      </div>
      <h2 class="text-3xl lg:text-4xl font-bold mb-4">
        Art Recommendations Tailored to You
      </h2>
      <p class="text-gray-400 text-lg max-w-xl mx-auto mb-8">
        Our AI agent analyses your browsing behaviour, favourite styles, and colour preferences to suggest artworks you'll love.
      </p>
      <RouterLink to="/browse" class="btn-primary inline-block">
        Start Discovering
      </RouterLink>
    </div>
  </section>
</template>

<script setup>
import { RouterLink } from 'vue-router'

const newArrivals = [
  {
    id: 1,
    imageUrl: 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=700&q=80',
    title: 'Golden Hour Reverie',
    artistName: 'Sophie Laurent',
    country: 'France',
    price: 89,
    medium: 'Oil on Canvas',
  },
  {
    id: 2,
    imageUrl: 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=700&q=80',
    title: 'Nocturne in Blue',
    artistName: 'Marco Chen',
    country: 'Italy',
    price: 145,
    medium: 'Digital Painting',
  },
  {
    id: 3,
    imageUrl: 'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=700&q=80',
    title: 'Urban Geometry III',
    artistName: 'Amara Diallo',
    country: 'Senegal',
    price: 120,
    medium: 'Acrylic',
  },
]

const galleryWorks = [
  { id: 1, imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=600&q=80', title: 'Abstract Harmony', artistName: 'Sophie Laurent', price: 89 },
  { id: 2, imageUrl: 'https://images.unsplash.com/photo-1620503374956-c942862f0372?w=600&q=80', title: 'Blue Silence', artistName: 'Amara Diallo', price: 75 },
  { id: 3, imageUrl: 'https://images.unsplash.com/photo-1605721911519-3dfeb3be25e7?w=600&q=80', title: 'Forest Dream', artistName: 'Jules Moreau', price: 65 },
  { id: 4, imageUrl: 'https://images.unsplash.com/photo-1559762717-99c81ac85059?w=600&q=80', title: 'Desert Wind', artistName: 'Yuki Tanaka', price: 110 },
  { id: 5, imageUrl: 'https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=600&q=80', title: 'Urban Geometry', artistName: 'Marco Chen', price: 120 },
  { id: 6, imageUrl: 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=600&q=80', title: 'Golden Hour', artistName: 'Lena Kuznetsov', price: 99 },
]
</script>

<template>

  <!-- ═══════════════════════════════════════════════
       HERO — full-bleed editorial, bottom-anchored text
       ═══════════════════════════════════════════════ -->
  <section class="relative min-h-[92vh] flex items-end overflow-hidden bg-gray-900">
    <img
      src="https://images.unsplash.com/photo-1579762715118-a6f1d4b934f1?w=1800&q=80"
      alt=""
      class="absolute inset-0 w-full h-full object-cover opacity-55 select-none"
      draggable="false"
    />
    <!-- Bottom-heavy gradient for text legibility -->
    <div class="absolute inset-0 bg-gradient-to-t from-black/85 via-black/25 to-transparent" />

    <div class="relative z-10 w-full max-w-screen-xl mx-auto px-6 lg:px-16 pb-20 lg:pb-32">
      <p class="text-[#E8552A] text-[10px] tracking-[0.35em] uppercase mb-6 font-light">
        Digital Art &ensp;·&ensp; Print on Demand &ensp;·&ensp; AI Curation
      </p>

      <h1 class="font-display italic font-normal text-white leading-[1.08] mb-10"
          style="font-size: clamp(3rem, 8vw, 7rem)">
        Art That Speaks<br />
        <span class="not-italic font-medium">to the Soul</span>
      </h1>

      <div class="flex flex-col sm:flex-row items-start gap-8">
        <RouterLink
          to="/browse"
          class="inline-flex items-center gap-3 text-white text-[11px] tracking-[0.25em] uppercase border-b border-white/50 pb-0.5 hover:border-white transition-colors duration-200"
        >
          Explore Collection
          <svg class="w-3.5 h-3.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
          </svg>
        </RouterLink>
        <RouterLink
          to="/browse?category=collections"
          class="inline-flex items-center gap-3 text-white/50 text-[11px] tracking-[0.25em] uppercase border-b border-white/20 pb-0.5 hover:text-white/90 hover:border-white/50 transition-colors duration-200"
        >
          Our Collections
        </RouterLink>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════
       STATEMENT BAR
       ═══════════════════════════════════════════════ -->
  <section class="bg-[#F7F4F0] border-y border-[#E0D8CE]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-4 flex flex-col sm:flex-row items-center justify-between gap-3">
      <p class="text-[10px] tracking-[0.3em] uppercase text-gray-500 font-light">
        Free worldwide shipping on orders over €80
      </p>
      <div class="w-8 h-px bg-[#E8552A] hidden sm:block flex-shrink-0" />
      <p class="text-[10px] tracking-[0.3em] uppercase text-gray-500 font-light">
        500+ Original Works &ensp;·&ensp; 120+ Artists
      </p>
      <div class="w-8 h-px bg-[#E8552A] hidden sm:block flex-shrink-0" />
      <p class="text-[10px] tracking-[0.3em] uppercase text-gray-500 font-light">
        Printed &amp; Dispatched within 24 Hours
      </p>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════
       NEW ARRIVALS — editorial 3-column grid
       ═══════════════════════════════════════════════ -->
  <section class="bg-white py-20 lg:py-28">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16">

      <div class="flex items-end justify-between mb-14">
        <div>
          <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-3 font-light">Just Arrived</p>
          <h2 class="font-display text-4xl lg:text-[3.25rem] font-normal italic text-gray-900 leading-tight">
            New Arrivals
          </h2>
        </div>
        <RouterLink
          to="/browse?sort=newest"
          class="hidden sm:inline-flex items-center gap-2.5 text-[10px] tracking-[0.25em] uppercase text-gray-400 hover:text-gray-900 border-b border-gray-300 hover:border-gray-900 pb-0.5 transition-colors duration-200"
        >
          View all works
        </RouterLink>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-8 lg:gap-14">
        <RouterLink
          v-for="art in newArrivals"
          :key="art.id"
          :to="`/artwork/${art.id}`"
          class="group block"
        >
          <div class="overflow-hidden bg-[#F7F4F0]">
            <img
              :src="art.imageUrl"
              :alt="art.title"
              class="w-full h-72 lg:h-[22rem] object-cover transition-transform duration-700 ease-out group-hover:scale-[1.04]"
              loading="lazy"
            />
          </div>
          <div class="mt-5 pt-4 border-t border-gray-200">
            <p class="text-[10px] tracking-[0.25em] uppercase text-gray-400 mb-2 font-light">
              {{ art.artistName }}&ensp;·&ensp;{{ art.country }}
            </p>
            <p class="font-display italic text-xl text-gray-900 leading-snug mb-3">
              {{ art.title }}
            </p>
            <div class="flex items-center justify-between">
              <p class="text-[11px] text-gray-400 tracking-wide font-light">{{ art.medium }}</p>
              <p class="text-sm font-medium text-gray-900">€{{ art.price }}</p>
            </div>
          </div>
        </RouterLink>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════
       EDITORIAL FEATURE — asymmetric image + text
       ═══════════════════════════════════════════════ -->
  <section class="bg-[#F7F4F0] py-20 lg:py-28 overflow-hidden">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16">
      <div class="grid grid-cols-1 lg:grid-cols-5 gap-0 lg:gap-16 items-center">

        <!-- Image: 3/5 -->
        <div class="lg:col-span-3 overflow-hidden">
          <img
            src="https://images.unsplash.com/photo-1541516160071-4bb0c5af65ba?w=1000&q=80"
            alt="The Abstract Expressions Collection"
            class="w-full h-[50vh] lg:h-[62vh] object-cover"
          />
        </div>

        <!-- Text: 2/5 -->
        <div class="lg:col-span-2 lg:pl-6 pt-10 lg:pt-0">
          <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-6 font-light">
            Featured Collection
          </p>
          <h2 class="font-display text-3xl lg:text-5xl font-normal italic text-gray-900 leading-tight mb-6">
            The Abstract<br />Expressions
          </h2>
          <div class="w-10 h-px bg-[#E8552A] mb-7" />
          <p class="text-gray-600 text-sm leading-relaxed mb-10 font-light">
            A curated selection of bold, gestural works by emerging artists across Europe and West Africa.
            Each piece is available as a museum-quality fine-art print, hand-finished and delivered worldwide.
          </p>
          <RouterLink
            to="/browse?category=abstract"
            class="inline-flex items-center gap-3 text-[11px] tracking-[0.25em] uppercase text-gray-900 border-b border-gray-900 pb-0.5 hover:text-[#E8552A] hover:border-[#E8552A] transition-colors duration-200"
          >
            Discover the Collection
            <svg class="w-3.5 h-3.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
            </svg>
          </RouterLink>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════
       SELECTED WORKS — masonry gallery
       ═══════════════════════════════════════════════ -->
  <section class="bg-white py-20 lg:py-28">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16">

      <div class="flex items-end justify-between mb-14">
        <div>
          <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-3 font-light">Curated Selection</p>
          <h2 class="font-display text-4xl lg:text-[3.25rem] font-normal italic text-gray-900 leading-tight">
            Selected Works
          </h2>
        </div>
        <RouterLink
          to="/browse?sort=trending"
          class="hidden sm:inline-flex items-center gap-2.5 text-[10px] tracking-[0.25em] uppercase text-gray-400 hover:text-gray-900 border-b border-gray-300 hover:border-gray-900 pb-0.5 transition-colors duration-200"
        >
          Browse all
        </RouterLink>
      </div>

      <div class="masonry">
        <RouterLink
          v-for="art in galleryWorks"
          :key="art.id"
          :to="`/artwork/${art.id}`"
          class="masonry-item group block"
        >
          <div class="overflow-hidden bg-[#F7F4F0] relative">
            <img
              :src="art.imageUrl"
              :alt="art.title"
              class="w-full h-auto object-cover transition-transform duration-700 ease-out group-hover:scale-[1.04]"
              loading="lazy"
            />
            <div class="absolute inset-0 bg-black/0 group-hover:bg-black/15 transition-colors duration-500" />
          </div>
          <div class="mt-3 mb-1">
            <p class="text-[10px] tracking-[0.2em] uppercase text-gray-400 mb-1 font-light">{{ art.artistName }}</p>
            <p class="font-display italic text-[0.95rem] text-gray-900 leading-snug line-clamp-1">{{ art.title }}</p>
            <p class="text-xs text-gray-400 mt-0.5">€{{ art.price }}</p>
          </div>
        </RouterLink>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════
       AI CURATOR — dark editorial section with stats
       ═══════════════════════════════════════════════ -->
  <section class="bg-gray-950 text-white py-24 lg:py-32">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16">
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-16 lg:gap-24 items-center">

        <!-- Left: copy -->
        <div>
          <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-7 font-light">AI-Powered Discovery</p>
          <h2 class="font-display text-4xl lg:text-6xl font-normal italic text-white leading-tight mb-7">
            Your Personal<br />Art Curator
          </h2>
          <div class="w-10 h-px bg-[#E8552A] mb-8" />
          <p class="text-gray-400 text-sm leading-relaxed mb-12 font-light max-w-sm">
            Our AI analyses your browsing history, favourite styles, and colour preferences to compose a collection that is entirely your own — refreshed with every visit.
          </p>
          <RouterLink
            to="/browse"
            class="inline-flex items-center gap-3 text-[11px] tracking-[0.25em] uppercase text-white border-b border-white/40 pb-0.5 hover:border-white transition-colors duration-200"
          >
            Begin Your Journey
            <svg class="w-3.5 h-3.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
            </svg>
          </RouterLink>
        </div>

        <!-- Right: stat grid -->
        <div class="grid grid-cols-2 gap-px bg-white/[0.08]">
          <div class="bg-gray-950 p-8 lg:p-10">
            <p class="font-display text-4xl lg:text-5xl font-normal italic text-white mb-2">500+</p>
            <p class="text-[10px] tracking-[0.25em] uppercase text-gray-500 font-light">Original Works</p>
          </div>
          <div class="bg-gray-950 p-8 lg:p-10">
            <p class="font-display text-4xl lg:text-5xl font-normal italic text-white mb-2">120+</p>
            <p class="text-[10px] tracking-[0.25em] uppercase text-gray-500 font-light">Artists Worldwide</p>
          </div>
          <div class="bg-gray-950 p-8 lg:p-10">
            <p class="font-display text-4xl lg:text-5xl font-normal italic text-[#E8552A] mb-2">24h</p>
            <p class="text-[10px] tracking-[0.25em] uppercase text-gray-500 font-light">Print &amp; Dispatch</p>
          </div>
          <div class="bg-gray-950 p-8 lg:p-10">
            <p class="font-display text-4xl lg:text-5xl font-normal italic text-white mb-2">∞</p>
            <p class="text-[10px] tracking-[0.25em] uppercase text-gray-500 font-light">Possibilities</p>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ═══════════════════════════════════════════════
       NEWSLETTER — minimal strip
       ═══════════════════════════════════════════════ -->
  <section class="bg-[#F7F4F0] border-t border-[#E0D8CE] py-16 lg:py-20">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 text-center">
      <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-4 font-light">Stay Informed</p>
      <h2 class="font-display text-3xl lg:text-4xl font-normal italic text-gray-900 mb-4">
        New Works, Every Week
      </h2>
      <p class="text-sm text-gray-500 font-light mb-8 max-w-sm mx-auto leading-relaxed">
        Receive our curated weekly selection of new arrivals and artist spotlights.
      </p>
      <form class="flex flex-col sm:flex-row gap-3 justify-center max-w-md mx-auto" @submit.prevent>
        <input
          type="email"
          placeholder="your@email.com"
          class="flex-1 border border-gray-300 bg-white px-4 py-3 text-sm outline-none focus:border-gray-900 transition-colors placeholder:text-gray-400 font-light"
        />
        <button type="submit" class="btn-primary flex-shrink-0">
          Subscribe
        </button>
      </form>
    </div>
  </section>

</template>

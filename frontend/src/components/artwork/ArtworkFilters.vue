<script setup>
import { ref } from 'vue'

const emit = defineEmits(['update:filters'])

const filters = ref({
  category: '',
  medium: '',
  priceMin: '',
  priceMax: '',
  orientation: '',
  sort: 'recommended',
})

const categories = ['Paintings', 'Photography', 'Prints', 'Digital Art', 'Sculpture']
const mediums = ['Oil', 'Watercolour', 'Acrylic', 'Ink', 'Photograph', 'Digital', 'Mixed Media']
const orientations = ['Landscape', 'Portrait', 'Square']

const colorSwatches = [
  { label: 'Black & White', color: '#555555' },
  { label: 'Red',    color: '#D94F3C' },
  { label: 'Orange', color: '#E8792A' },
  { label: 'Yellow', color: '#F5C542' },
  { label: 'Green',  color: '#3CA66A' },
  { label: 'Blue',   color: '#3C7DD9' },
  { label: 'Purple', color: '#8A4DD9' },
  { label: 'Pink',   color: '#D94D8A' },
  { label: 'Brown',  color: '#8A6040' },
]
const activeColor = ref('')

function apply() {
  emit('update:filters', { ...filters.value, color: activeColor.value })
}

function reset() {
  filters.value = { category: '', medium: '', priceMin: '', priceMax: '', orientation: '', sort: 'recommended' }
  activeColor.value = ''
  apply()
}
</script>

<template>
  <aside class="w-full space-y-7">

    <!-- Sort -->
    <div>
      <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-3">Sort by</p>
      <select
        v-model="filters.sort"
        class="w-full border border-gray-200 px-3 py-2.5 text-sm outline-none focus:border-gray-900 transition-colors bg-white font-light text-gray-700"
        @change="apply"
      >
        <option value="recommended">Recommended</option>
        <option value="newest">New Arrivals</option>
        <option value="price_asc">Price: Low to High</option>
        <option value="price_desc">Price: High to Low</option>
        <option value="trending">Trending</option>
      </select>
    </div>

    <div class="h-px bg-gray-100" />

    <!-- Category -->
    <div>
      <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-3">Category</p>
      <div class="space-y-2">
        <label
          v-for="cat in categories"
          :key="cat"
          class="flex items-center gap-2.5 cursor-pointer group"
        >
          <input
            type="radio"
            :value="cat"
            v-model="filters.category"
            name="category"
            class="accent-[#E8552A] w-3.5 h-3.5"
            @change="apply"
          />
          <span class="text-sm text-gray-600 group-hover:text-gray-900 transition-colors font-light">{{ cat }}</span>
        </label>
        <label class="flex items-center gap-2.5 cursor-pointer group">
          <input type="radio" value="" v-model="filters.category" name="category" class="accent-[#E8552A] w-3.5 h-3.5" @change="apply" />
          <span class="text-sm text-gray-400 group-hover:text-gray-700 transition-colors font-light">All categories</span>
        </label>
      </div>
    </div>

    <div class="h-px bg-gray-100" />

    <!-- Medium -->
    <div>
      <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-3">Medium</p>
      <div class="space-y-2">
        <label v-for="m in mediums" :key="m" class="flex items-center gap-2.5 cursor-pointer group">
          <input type="checkbox" :value="m" v-model="filters.medium" class="accent-[#E8552A] w-3.5 h-3.5" @change="apply" />
          <span class="text-sm text-gray-600 group-hover:text-gray-900 transition-colors font-light">{{ m }}</span>
        </label>
      </div>
    </div>

    <div class="h-px bg-gray-100" />

    <!-- Price range -->
    <div>
      <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-3">Price (€)</p>
      <div class="flex items-center gap-2">
        <input
          v-model="filters.priceMin"
          type="number"
          placeholder="Min"
          class="w-1/2 border border-gray-200 px-3 py-2 text-sm outline-none focus:border-gray-900 transition-colors font-light"
        />
        <span class="text-gray-300 text-xs">—</span>
        <input
          v-model="filters.priceMax"
          type="number"
          placeholder="Max"
          class="w-1/2 border border-gray-200 px-3 py-2 text-sm outline-none focus:border-gray-900 transition-colors font-light"
        />
      </div>
      <button
        class="mt-2.5 text-[11px] tracking-[0.1em] uppercase text-[#E8552A] hover:opacity-70 transition-opacity font-light"
        @click="apply"
      >
        Apply
      </button>
    </div>

    <div class="h-px bg-gray-100" />

    <!-- Orientation -->
    <div>
      <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-3">Orientation</p>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="o in orientations"
          :key="o"
          class="px-3 py-1.5 border text-xs font-light tracking-wide transition-colors"
          :class="filters.orientation === o
            ? 'border-gray-900 bg-gray-900 text-white'
            : 'border-gray-200 text-gray-600 hover:border-gray-400'"
          @click="filters.orientation = filters.orientation === o ? '' : o; apply()"
        >
          {{ o }}
        </button>
      </div>
    </div>

    <div class="h-px bg-gray-100" />

    <!-- Color -->
    <div>
      <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-3">Dominant Colour</p>
      <div class="flex flex-wrap gap-2.5">
        <button
          v-for="swatch in colorSwatches"
          :key="swatch.label"
          class="w-6 h-6 rounded-full border-2 transition-all"
          :style="{ backgroundColor: swatch.color }"
          :class="activeColor === swatch.label ? 'border-gray-900 scale-110' : 'border-transparent hover:scale-110'"
          :title="swatch.label"
          @click="activeColor = activeColor === swatch.label ? '' : swatch.label; apply()"
        />
      </div>
    </div>

    <div class="h-px bg-gray-100" />

    <!-- Reset -->
    <button
      class="w-full text-[11px] tracking-[0.2em] uppercase text-gray-400 hover:text-gray-900 border border-gray-200 hover:border-gray-900 py-2.5 transition-colors font-light"
      @click="reset"
    >
      Clear all filters
    </button>
  </aside>
</template>

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
  { label: 'Red', color: '#D94F3C' },
  { label: 'Orange', color: '#E8792A' },
  { label: 'Yellow', color: '#F5C542' },
  { label: 'Green', color: '#3CA66A' },
  { label: 'Blue', color: '#3C7DD9' },
  { label: 'Purple', color: '#8A4DD9' },
  { label: 'Pink', color: '#D94D8A' },
  { label: 'Brown', color: '#8A6040' },
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
  <aside class="w-full space-y-6">
    <!-- Sort -->
    <div>
      <label class="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Sort by</label>
      <select
        v-model="filters.sort"
        class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-[#E8552A]"
        @change="apply"
      >
        <option value="recommended">Recommended</option>
        <option value="newest">New Arrivals</option>
        <option value="price_asc">Price: Low to High</option>
        <option value="price_desc">Price: High to Low</option>
        <option value="trending">Trending</option>
      </select>
    </div>

    <!-- Category -->
    <div>
      <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Category</p>
      <div class="space-y-1.5">
        <label
          v-for="cat in categories"
          :key="cat"
          class="flex items-center gap-2 cursor-pointer group"
        >
          <input
            type="radio"
            :value="cat"
            v-model="filters.category"
            name="category"
            class="accent-[#E8552A]"
            @change="apply"
          />
          <span class="text-sm text-gray-700 group-hover:text-gray-900">{{ cat }}</span>
        </label>
        <label class="flex items-center gap-2 cursor-pointer group">
          <input type="radio" value="" v-model="filters.category" name="category" class="accent-[#E8552A]" @change="apply" />
          <span class="text-sm text-gray-400 group-hover:text-gray-700">All categories</span>
        </label>
      </div>
    </div>

    <!-- Medium -->
    <div>
      <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Medium</p>
      <div class="space-y-1.5">
        <label v-for="m in mediums" :key="m" class="flex items-center gap-2 cursor-pointer group">
          <input type="checkbox" :value="m" v-model="filters.medium" class="accent-[#E8552A]" @change="apply" />
          <span class="text-sm text-gray-700 group-hover:text-gray-900">{{ m }}</span>
        </label>
      </div>
    </div>

    <!-- Price range -->
    <div>
      <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Price (€)</p>
      <div class="flex items-center gap-2">
        <input
          v-model="filters.priceMin"
          type="number"
          placeholder="Min"
          class="w-1/2 border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-[#E8552A]"
        />
        <span class="text-gray-400">–</span>
        <input
          v-model="filters.priceMax"
          type="number"
          placeholder="Max"
          class="w-1/2 border border-gray-200 rounded-lg px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-[#E8552A]"
        />
      </div>
      <button class="mt-2 text-xs text-[#E8552A] hover:underline" @click="apply">Apply price</button>
    </div>

    <!-- Orientation -->
    <div>
      <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Orientation</p>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="o in orientations"
          :key="o"
          class="px-3 py-1.5 rounded-full border text-xs font-medium transition-colors"
          :class="filters.orientation === o
            ? 'border-[#E8552A] bg-[#E8552A]/10 text-[#E8552A]'
            : 'border-gray-200 text-gray-600 hover:border-gray-400'"
          @click="filters.orientation = filters.orientation === o ? '' : o; apply()"
        >
          {{ o }}
        </button>
      </div>
    </div>

    <!-- Color -->
    <div>
      <p class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Dominant Color</p>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="swatch in colorSwatches"
          :key="swatch.label"
          class="w-7 h-7 rounded-full border-2 transition-all"
          :style="{ backgroundColor: swatch.color }"
          :class="activeColor === swatch.label ? 'border-gray-900 scale-110' : 'border-transparent hover:scale-110'"
          :title="swatch.label"
          @click="activeColor = activeColor === swatch.label ? '' : swatch.label; apply()"
        />
      </div>
    </div>

    <!-- Reset -->
    <button class="w-full btn-outline text-sm" @click="reset">Clear all filters</button>
  </aside>
</template>

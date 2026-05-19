<script setup>
import { RouterLink } from 'vue-router'
import { useCartStore } from '@/stores/cart'

const cart = useCartStore()
</script>

<template>
  <!-- Page header -->
  <div class="bg-[#F7F4F0] border-b border-[#E0D8CE]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-10 lg:py-14">
      <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-3 font-light">Your Selection</p>
      <h1 class="font-display text-3xl lg:text-[2.75rem] font-normal italic text-gray-900 leading-tight">
        Your Cart
      </h1>
    </div>
  </div>

  <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-12 lg:py-16">

    <!-- Empty state -->
    <div v-if="cart.items.length === 0" class="py-24 text-center">
      <svg class="w-10 h-10 text-gray-200 mx-auto mb-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1"
          d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-1.4 6h12.8M10 21a1 1 0 100-2 1 1 0 000 2zm8 0a1 1 0 100-2 1 1 0 000 2z" />
      </svg>
      <p class="font-display italic text-2xl text-gray-400 mb-2">Your cart is empty</p>
      <p class="text-sm text-gray-400 font-light mb-10">Discover works that speak to you.</p>
      <RouterLink to="/browse" class="btn-primary">Discover Artworks</RouterLink>
    </div>

    <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-12 lg:gap-16">
      <!-- Items list -->
      <div class="lg:col-span-2 divide-y divide-gray-100">
        <div
          v-for="item in cart.items"
          :key="item.key"
          class="flex gap-5 py-7 first:pt-0"
        >
          <div class="bg-[#F7F4F0] flex-shrink-0">
            <img
              :src="item.artwork.imageUrl"
              :alt="item.artwork.title"
              class="w-24 h-24 object-cover"
            />
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light">{{ item.artwork.artistName }}</p>
            <p class="font-display italic text-lg text-gray-900 mt-1 leading-snug">{{ item.artwork.title }}</p>
            <p class="text-[11px] tracking-wide text-gray-400 mt-1 font-light">{{ item.size }}</p>
            <div class="flex items-center justify-between mt-4">
              <p class="text-base font-medium text-gray-900">€{{ item.price }}</p>
              <button
                class="text-[10px] tracking-[0.15em] uppercase text-gray-300 hover:text-gray-700 transition-colors font-light"
                @click="cart.remove(item.key)"
              >
                Remove
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Order summary -->
      <div class="lg:col-span-1 h-fit">
        <div class="border border-gray-200 p-8">
          <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-7">Order Summary</p>
          <div class="space-y-3.5 text-sm text-gray-600 font-light">
            <div class="flex justify-between">
              <span>Subtotal ({{ cart.count }} {{ cart.count === 1 ? 'item' : 'items' }})</span>
              <span>€{{ cart.total.toFixed(2) }}</span>
            </div>
            <div class="flex justify-between">
              <span>Shipping</span>
              <span :class="cart.total >= 80 ? 'text-green-600' : ''">
                {{ cart.total >= 80 ? 'Free' : '€9.90' }}
              </span>
            </div>
            <p v-if="cart.total < 80" class="text-[11px] text-gray-400 font-light pt-1">
              Add €{{ (80 - cart.total).toFixed(2) }} more for free shipping.
            </p>
          </div>

          <div class="border-t border-gray-100 my-6" />

          <div class="flex justify-between items-baseline mb-7">
            <span class="text-sm font-medium text-gray-900">Total</span>
            <span class="font-display italic text-2xl font-normal text-gray-900">
              €{{ (cart.total >= 80 ? cart.total : cart.total + 9.9).toFixed(2) }}
            </span>
          </div>

          <RouterLink to="/checkout" class="btn-primary block text-center">Proceed to Checkout</RouterLink>
          <RouterLink
            to="/browse"
            class="block text-center text-[11px] tracking-[0.15em] uppercase text-gray-400 hover:text-gray-700 mt-5 transition-colors font-light"
          >
            Continue Shopping
          </RouterLink>
        </div>
      </div>
    </div>
  </div>
</template>

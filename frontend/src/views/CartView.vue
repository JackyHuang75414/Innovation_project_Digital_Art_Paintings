<script setup>
import { RouterLink } from 'vue-router'
import { useCartStore } from '@/stores/cart'

const cart = useCartStore()
</script>

<template>
  <div class="max-w-screen-lg mx-auto px-4 py-10">
    <h1 class="text-2xl font-bold text-gray-900 mb-8">Your Cart</h1>

    <div v-if="cart.items.length === 0" class="text-center py-20">
      <p class="text-4xl mb-4">🛒</p>
      <p class="text-gray-500 text-lg mb-6">Your cart is empty.</p>
      <RouterLink to="/browse" class="btn-primary">Discover Artworks</RouterLink>
    </div>

    <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-10">
      <!-- Items list -->
      <div class="lg:col-span-2 space-y-4">
        <div
          v-for="item in cart.items"
          :key="item.key"
          class="flex gap-4 p-4 border border-gray-100 rounded-xl"
        >
          <img
            :src="item.artwork.imageUrl"
            :alt="item.artwork.title"
            class="w-24 h-24 object-cover rounded-lg flex-shrink-0"
          />
          <div class="flex-1">
            <p class="text-xs text-gray-500">{{ item.artwork.artistName }}</p>
            <p class="font-semibold italic text-gray-900">{{ item.artwork.title }}</p>
            <p class="text-sm text-gray-500 mt-0.5">{{ item.size }}</p>
            <div class="flex items-center justify-between mt-3">
              <p class="font-bold text-gray-900">€{{ item.price }}</p>
              <button
                class="text-xs text-gray-400 hover:text-red-500 transition-colors"
                @click="cart.remove(item.key)"
              >
                Remove
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Order summary -->
      <div class="bg-gray-50 rounded-2xl p-6 h-fit">
        <h2 class="font-bold text-lg text-gray-900 mb-4">Order Summary</h2>
        <div class="flex justify-between text-sm text-gray-600 mb-2">
          <span>Subtotal ({{ cart.count }} items)</span>
          <span>€{{ cart.total.toFixed(2) }}</span>
        </div>
        <div class="flex justify-between text-sm text-gray-600 mb-2">
          <span>Shipping</span>
          <span class="text-green-600">{{ cart.total >= 80 ? 'Free' : '€9.90' }}</span>
        </div>
        <div class="border-t border-gray-200 my-4" />
        <div class="flex justify-between font-bold text-gray-900 text-base mb-6">
          <span>Total</span>
          <span>€{{ (cart.total >= 80 ? cart.total : cart.total + 9.9).toFixed(2) }}</span>
        </div>
        <button class="btn-primary w-full text-base py-3">Proceed to Checkout</button>
        <RouterLink to="/browse" class="block text-center text-sm text-gray-500 hover:text-gray-900 mt-4">
          Continue Shopping
        </RouterLink>
      </div>
    </div>
  </div>
</template>

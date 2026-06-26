<script setup>
import { onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'
import { usePricesStore, CRYPTOS, FIATS } from '@/stores/prices'
import { useWalletStore } from '@/stores/wallet'
import { useAuthStore } from '@/stores/auth'
import { useWishlistStore } from '@/stores/wishlist'
import WalletConnectModal from '@/components/ui/WalletConnectModal.vue'
import LoginModal from '@/components/ui/LoginModal.vue'

const cart   = useCartStore()
const prices = usePricesStore()
const wallet = useWalletStore()
const auth   = useAuthStore()
const wishlist = useWishlistStore()
const router = useRouter()

const showCurrencyMenu = ref(false)
const showWalletModal  = ref(false)
const showLoginModal   = ref(false)
const authModalMode    = ref('login')

function selectCrypto(sym) { prices.setCrypto(sym) }
function selectFiat(code)  { prices.setFiat(code); showCurrencyMenu.value = false }

function openAuth(mode) {
  authModalMode.value = mode
  showLoginModal.value = true
}

function openWallet() {
  if (!auth.isLoggedIn) {
    openAuth('login')
    return
  }
  showWalletModal.value = true
}

function signOut() {
  auth.logout()
  wishlist.reset()
  wallet.clearLocal()
  router.push('/')
}

function handleOpenAuth(event) {
  openAuth(event.detail?.mode === 'register' ? 'register' : 'login')
}

watch(() => auth.isLoggedIn, loggedIn => {
  if (loggedIn) {
    wallet.loadConnection()
  } else {
    wallet.clearLocal()
  }
})

onMounted(() => {
  window.addEventListener('artex:open-auth', handleOpenAuth)
  if (auth.isLoggedIn) wallet.loadConnection()
})
onUnmounted(() => window.removeEventListener('artex:open-auth', handleOpenAuth))
</script>

<template>
  <!-- ── Crypto ticker bar ──────────────────────────────────────────────────── -->
  <div class="bg-[#070709] border-b border-white/[0.05] overflow-hidden select-none py-1.5">
    <div class="flex items-center gap-10 px-6 lg:px-16 overflow-x-auto no-scrollbar whitespace-nowrap">
      <span
        v-for="c in CRYPTOS"
        :key="c.symbol"
        class="flex items-center gap-2 flex-shrink-0"
      >
        <span class="text-[10px] tracking-[0.18em] uppercase text-gray-500">{{ c.symbol }}</span>
        <span class="font-mono text-[11px] text-white tabular-nums">
          ${{ prices.cryptoUsd[c.symbol]?.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }}
        </span>
        <span
          class="text-[10px] font-mono tabular-nums"
          :class="(prices.cryptoChange24h[c.symbol] ?? 0) >= 0 ? 'text-green-500' : 'text-red-500'"
        >
          {{ (prices.cryptoChange24h[c.symbol] ?? 0) >= 0 ? '▲' : '▼' }}
          {{ Math.abs(prices.cryptoChange24h[c.symbol] ?? 0).toFixed(2) }}%
        </span>
      </span>

      <span class="ml-auto flex-shrink-0 text-[10px] text-gray-700 tracking-[0.2em] uppercase hidden lg:block">
        Live · VMM Active
        <span class="inline-block w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse align-middle ml-1" />
      </span>
    </div>
  </div>

  <!-- ── Main header ────────────────────────────────────────────────────────── -->
  <header class="sticky top-0 z-40 bg-[#09090b]/95 backdrop-blur-md border-b border-white/[0.06]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 h-16 flex items-center justify-between gap-6">

      <!-- Logo -->
      <RouterLink to="/" class="flex-shrink-0 flex items-center gap-2.5 hover:opacity-80 transition-opacity">
        <img src="/logo.gif" alt="ArtEx" class="h-9 w-9 object-cover rounded-full mix-blend-lighten flex-shrink-0" />
        <span class="font-display italic text-[1.2rem] font-normal text-white">ArtEx</span>
      </RouterLink>

      <!-- Nav -->
      <nav class="hidden md:flex items-center gap-7">
        <RouterLink
          to="/market"
          class="flex items-center gap-1.5 text-[11px] tracking-[0.18em] uppercase transition-colors duration-150 font-light"
          :class="$route.path.startsWith('/market') || $route.path.startsWith('/trade') ? 'text-[#E8552A]' : 'text-gray-400 hover:text-white'"
        >
          <span class="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse flex-shrink-0" />
          Market
        </RouterLink>
        <RouterLink
          to="/browse"
          class="text-[11px] tracking-[0.18em] uppercase transition-colors duration-150 font-light"
          :class="$route.path === '/browse' ? 'text-white' : 'text-gray-400 hover:text-white'"
        >
          Discover
        </RouterLink>
        <RouterLink
          to="/account"
          class="text-[11px] tracking-[0.18em] uppercase transition-colors duration-150 font-light"
          :class="$route.path === '/account' ? 'text-white' : 'text-gray-400 hover:text-white'"
        >
          Portfolio
        </RouterLink>
      </nav>

      <!-- Right: currency selector + icons -->
      <div class="flex items-center gap-2 ml-auto md:ml-0">

        <!-- Currency selector -->
        <div class="relative">
          <button
            class="flex items-center gap-1.5 px-3 py-1.5 border border-white/[0.1] hover:border-white/20 text-[11px] text-gray-400 hover:text-white transition-colors"
            @click="showCurrencyMenu = !showCurrencyMenu"
          >
            <span class="font-medium text-white">{{ prices.selectedCrypto }}</span>
            <span class="text-gray-600">·</span>
            <span>{{ prices.selectedFiat }}</span>
            <svg class="w-3 h-3 ml-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
            </svg>
          </button>

          <!-- Click-outside overlay -->
          <div v-if="showCurrencyMenu" class="fixed inset-0 z-40" @click="showCurrencyMenu = false" />

          <!-- Dropdown -->
          <Transition name="dropdown">
            <div
              v-if="showCurrencyMenu"
              class="absolute right-0 top-full mt-1 w-64 bg-[#111116] border border-white/[0.1] shadow-2xl z-50 p-3"
            >
              <p class="text-[9px] tracking-[0.25em] uppercase text-gray-600 mb-2">Price Currency</p>
              <div class="grid grid-cols-5 gap-1 mb-3">
                <button
                  v-for="c in CRYPTOS"
                  :key="c.symbol"
                  class="py-1.5 text-[10px] font-medium tracking-wide uppercase transition-colors"
                  :class="prices.selectedCrypto === c.symbol
                    ? 'bg-[#E8552A] text-white'
                    : 'bg-white/[0.05] text-gray-400 hover:text-white hover:bg-white/10'"
                  @click="selectCrypto(c.symbol)"
                >{{ c.symbol }}</button>
              </div>

              <p class="text-[9px] tracking-[0.25em] uppercase text-gray-600 mb-2">Fiat Reference</p>
              <div class="grid grid-cols-3 gap-1">
                <button
                  v-for="f in FIATS"
                  :key="f.code"
                  class="py-1.5 text-[10px] font-medium tracking-wide uppercase transition-colors"
                  :class="prices.selectedFiat === f.code
                    ? 'bg-white/10 text-white'
                    : 'bg-white/[0.03] text-gray-400 hover:text-white hover:bg-white/[0.07]'"
                  @click="selectFiat(f.code)"
                >{{ f.code }}</button>
              </div>
            </div>
          </Transition>
        </div>

        <!-- Connect Wallet button -->
        <button
          v-if="!wallet.isConnected"
          class="hidden sm:flex items-center gap-2 px-3 py-1.5 border border-[#E8552A]/50 hover:border-[#E8552A] text-[#E8552A] text-[11px] tracking-[0.1em] uppercase font-medium transition-colors"
          @click="openWallet"
        >
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
              d="M21 12a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 12m18 0v6a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 18v-6m18 0V9M3 12V9m18-3a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 9m18 0V6a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 6v3"/>
          </svg>
          Connect Wallet
        </button>

        <!-- Connected wallet pill -->
        <button
          v-else
          class="hidden sm:flex items-center gap-2 px-3 py-1.5 border border-green-500/30 bg-green-500/10 text-green-400 text-[11px] tracking-[0.1em] uppercase font-medium transition-colors hover:border-red-500/40 hover:bg-red-500/5 hover:text-red-400 group"
          @click="wallet.disconnect()"
          :title="`${wallet.shortAddress} — click to disconnect`"
        >
          <span class="w-1.5 h-1.5 rounded-full bg-green-500 flex-shrink-0" />
          <span class="font-mono normal-case tracking-normal">{{ wallet.shortAddress }}</span>
          <span class="hidden group-hover:inline text-[9px] uppercase tracking-wide">Disconnect</span>
        </button>

        <!-- Cart -->
        <RouterLink
          to="/cart"
          class="relative p-2 text-gray-400 hover:text-white transition-colors"
          aria-label="Cart"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
              d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-1.4 6h12.8M10 21a1 1 0 100-2 1 1 0 000 2zm8 0a1 1 0 100-2 1 1 0 000 2z"/>
          </svg>
          <span
            v-if="cart.count > 0"
            class="absolute -top-0.5 -right-0.5 bg-[#E8552A] text-white text-[9px] font-bold rounded-full w-4 h-4 flex items-center justify-center"
          >{{ cart.count }}</span>
        </RouterLink>

        <!-- Account / Login -->
        <RouterLink
          v-if="auth.isLoggedIn"
          to="/account"
          class="flex items-center gap-2 p-1 hover:opacity-80 transition-opacity"
          :title="auth.displayName"
        >
          <span
            class="w-7 h-7 rounded-full flex items-center justify-center text-[10px] font-bold flex-shrink-0"
            :style="{ backgroundColor: auth.color + '33', color: auth.color, border: `1px solid ${auth.color}55` }"
          >{{ auth.initials }}</span>
        </RouterLink>
        <button
          v-if="auth.isLoggedIn"
          class="hidden sm:flex items-center gap-2 px-3 py-1.5 border border-red-500/30 text-red-400 hover:bg-red-500/10 hover:border-red-500/60 text-[11px] tracking-[0.1em] uppercase font-medium transition-colors"
          aria-label="Sign out"
          title="Sign out"
          @click="signOut"
        >
          Sign Out
        </button>
        <button
          v-if="auth.isLoggedIn"
          class="sm:hidden p-2 text-red-400 hover:text-red-300 transition-colors"
          aria-label="Sign out"
          title="Sign out"
          @click="signOut"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
              d="M15.75 9V5.25A2.25 2.25 0 0 0 13.5 3h-6a2.25 2.25 0 0 0-2.25 2.25v13.5A2.25 2.25 0 0 0 7.5 21h6a2.25 2.25 0 0 0 2.25-2.25V15M12 9l-3 3m0 0 3 3m-3-3h12.75"/>
          </svg>
        </button>
        <button
          v-else
          class="hidden sm:flex items-center gap-2 px-3 py-1.5 border border-white/[0.1] hover:border-white/20 text-gray-400 hover:text-white text-[11px] tracking-[0.1em] uppercase font-medium transition-colors"
          aria-label="Sign in"
          title="Sign in"
          @click="openAuth('login')"
        >
          Sign In
        </button>
        <button
          v-if="!auth.isLoggedIn"
          class="hidden sm:flex items-center gap-2 px-3 py-1.5 bg-[#E8552A] hover:bg-[#d4461c] text-white text-[11px] tracking-[0.1em] uppercase font-medium transition-colors"
          aria-label="Create account"
          title="Create account"
          @click="openAuth('register')"
        >
          Create Account
        </button>
        <button
          v-if="!auth.isLoggedIn"
          class="sm:hidden p-2 text-gray-400 hover:text-white transition-colors"
          aria-label="Sign in"
          title="Sign in"
          @click="openAuth('login')"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
              d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
          </svg>
        </button>
      </div>
    </div>
  </header>

  <!-- Modals -->
  <Teleport to="body">
    <WalletConnectModal v-if="showWalletModal" @close="showWalletModal = false" />
    <LoginModal v-if="showLoginModal" :initial-mode="authModalMode" @close="showLoginModal = false" />
  </Teleport>
</template>

<style scoped>
.no-scrollbar::-webkit-scrollbar { display: none; }
.no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

.dropdown-enter-active, .dropdown-leave-active { transition: opacity 0.12s ease, transform 0.12s ease; }
.dropdown-enter-from, .dropdown-leave-to { opacity: 0; transform: translateY(-4px); }
</style>

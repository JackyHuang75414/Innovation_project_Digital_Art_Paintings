<script setup>
import { ref } from 'vue'
import { useAuthStore, DEMO_ACCOUNTS } from '@/stores/auth'
import { useTradingStore } from '@/stores/trading'

const emit = defineEmits(['close'])
const auth   = useAuthStore()
const store  = useTradingStore()

const username = ref('')
const password = ref('')
const error    = ref('')
const loading  = ref(false)

async function submit() {
  if (!username.value || !password.value) { error.value = 'Please enter both fields'; return }
  loading.value = true
  error.value = ''
  await new Promise(r => setTimeout(r, 400))  // simulate network
  const result = auth.login(username.value.trim(), password.value)
  loading.value = false
  if (!result.ok) { error.value = result.msg; return }
  // Seed trading wallet with account's starting balance
  store.wallet.usd = result.account.startUsd
  store.wallet.btc = result.account.startBtc
  emit('close')
}

function quickLogin(account) {
  username.value = account.username
  password.value = account.password
  submit()
}
</script>

<template>
  <div class="fixed inset-0 z-[9000] bg-black/70 backdrop-blur-sm flex items-center justify-center p-4" @click.self="$emit('close')">
    <div class="bg-[#111116] border border-white/[0.1] w-full max-w-md shadow-2xl">

      <!-- Header -->
      <div class="px-6 py-5 border-b border-white/[0.07]">
        <p class="text-[10px] tracking-[0.25em] uppercase text-[#E8552A] font-light mb-0.5">Welcome</p>
        <p class="font-display italic text-white text-xl">Sign in to ArtEx</p>
      </div>

      <div class="px-6 py-5 space-y-5">

        <!-- Quick login accounts -->
        <div>
          <p class="text-[10px] tracking-[0.2em] uppercase text-gray-600 mb-2.5">Demo Accounts</p>
          <div class="space-y-1.5">
            <button
              v-for="acc in DEMO_ACCOUNTS"
              :key="acc.id"
              class="w-full flex items-center gap-3 px-3 py-2.5 border border-white/[0.07] hover:border-white/20 hover:bg-white/[0.03] transition-all text-left group"
              @click="quickLogin(acc)"
            >
              <span
                class="w-8 h-8 rounded-full flex items-center justify-center text-[11px] font-bold flex-shrink-0"
                :style="{ backgroundColor: acc.color + '22', color: acc.color, border: `1px solid ${acc.color}44` }"
              >{{ acc.initials }}</span>
              <div class="flex-1 min-w-0">
                <p class="text-white text-sm font-medium">{{ acc.displayName }}</p>
                <p class="text-gray-600 text-[10px] font-light truncate">{{ acc.bio }}</p>
              </div>
              <div class="text-right flex-shrink-0">
                <p class="text-[10px] text-gray-600 font-mono">${{ (acc.startUsd / 1000).toFixed(0) }}K</p>
                <p class="text-[10px] text-amber-600 font-mono">{{ acc.startBtc }} BTC</p>
              </div>
              <svg class="w-3.5 h-3.5 text-gray-700 group-hover:text-gray-400 transition-colors ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
              </svg>
            </button>
          </div>
        </div>

        <div class="flex items-center gap-3">
          <div class="flex-1 h-px bg-white/[0.07]" />
          <span class="text-[10px] text-gray-700 uppercase tracking-wide">or enter manually</span>
          <div class="flex-1 h-px bg-white/[0.07]" />
        </div>

        <!-- Manual form -->
        <form class="space-y-3" @submit.prevent="submit">
          <input
            v-model="username"
            type="text"
            placeholder="Username"
            class="w-full bg-[#0d0d10] border border-white/[0.1] text-gray-200 px-3 py-2.5 text-sm outline-none focus:border-white/25 placeholder:text-gray-700"
          />
          <input
            v-model="password"
            type="password"
            placeholder="Password"
            class="w-full bg-[#0d0d10] border border-white/[0.1] text-gray-200 px-3 py-2.5 text-sm outline-none focus:border-white/25 placeholder:text-gray-700"
          />

          <p v-if="error" class="text-[11px] text-red-400">{{ error }}</p>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3 bg-[#E8552A] hover:bg-[#d4461c] disabled:opacity-50 text-white text-[11px] tracking-[0.2em] uppercase font-medium transition-colors"
          >
            {{ loading ? 'Signing in…' : 'Sign In' }}
          </button>
        </form>

        <p class="text-[10px] text-gray-700 text-center font-light">
          This is a demo platform. No real funds or transactions.
        </p>
      </div>
    </div>
  </div>
</template>

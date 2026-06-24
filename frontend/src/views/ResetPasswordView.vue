<script setup>
import { ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { resetPassword } from '@/api/auth'

const route  = useRoute()
const router = useRouter()
const token  = route.query.token

const password = ref('')
const confirm  = ref('')
const error    = ref('')
const loading  = ref(false)
const done     = ref(false)

async function submit() {
  error.value = ''
  if (!token) { error.value = 'Invalid or expired reset link. Please request a new one.'; return }
  if (!password.value || password.value.length < 6) { error.value = 'Password must be at least 6 characters'; return }
  if (password.value !== confirm.value) { error.value = 'Passwords do not match'; return }

  loading.value = true
  try {
    await resetPassword(token, password.value)
    done.value = true
    setTimeout(() => router.push('/'), 2500)
  } catch (e) {
    error.value = e.message || 'Reset failed. The link may have expired.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0f] flex items-center justify-center p-4">
    <div class="w-full max-w-md">

      <div class="text-center mb-8">
        <RouterLink to="/" class="inline-block">
          <p class="font-display italic text-white text-2xl tracking-wide hover:text-gray-200 transition-colors">ArtEx</p>
        </RouterLink>
        <p class="text-gray-600 text-[10px] tracking-[0.3em] uppercase mt-1">Digital Art Exchange</p>
      </div>

      <div class="bg-[#111116] border border-white/[0.1] shadow-2xl">

        <div class="px-6 py-5 border-b border-white/[0.07]">
          <p class="text-[10px] tracking-[0.25em] uppercase text-[#E8552A] font-light mb-0.5">New Password</p>
          <p class="font-display italic text-white text-xl">Reset your password</p>
        </div>

        <!-- Success -->
        <div v-if="done" class="px-6 py-12 text-center">
          <div class="w-12 h-12 rounded-full bg-green-500/10 border border-green-500/30 flex items-center justify-center mx-auto mb-4">
            <svg class="w-6 h-6 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
            </svg>
          </div>
          <p class="text-white font-medium mb-1">Password updated</p>
          <p class="text-gray-500 text-sm font-light">Redirecting you to sign in…</p>
        </div>

        <!-- Invalid token -->
        <div v-else-if="!token" class="px-6 py-12 text-center">
          <p class="text-red-400 text-sm mb-4">This reset link is invalid or has expired.</p>
          <RouterLink to="/forgot-password" class="text-[11px] tracking-[0.2em] uppercase text-[#E8552A] hover:text-[#d4461c] transition-colors">
            Request a new link →
          </RouterLink>
        </div>

        <!-- Form -->
        <form v-else class="px-6 py-5 space-y-4" @submit.prevent="submit">
          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-600 block mb-1.5">New Password</label>
            <input
              v-model="password"
              type="password"
              autocomplete="new-password"
              placeholder="Minimum 6 characters"
              class="w-full bg-[#0d0d10] border border-white/[0.1] text-gray-200 px-3 py-2.5 text-sm outline-none focus:border-white/25 placeholder:text-gray-700"
            />
          </div>
          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-600 block mb-1.5">Confirm New Password</label>
            <input
              v-model="confirm"
              type="password"
              autocomplete="new-password"
              placeholder="Repeat your password"
              class="w-full bg-[#0d0d10] border border-white/[0.1] text-gray-200 px-3 py-2.5 text-sm outline-none focus:border-white/25 placeholder:text-gray-700"
            />
          </div>

          <p v-if="error" class="text-[11px] text-red-400 bg-red-500/5 border border-red-500/20 px-3 py-2">{{ error }}</p>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3 bg-[#E8552A] hover:bg-[#d4461c] disabled:opacity-50 text-white text-[11px] tracking-[0.2em] uppercase font-medium transition-colors"
          >
            {{ loading ? 'Updating…' : 'Set New Password' }}
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

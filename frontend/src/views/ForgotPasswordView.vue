<script setup>
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
import { forgotPassword } from '@/api/auth'

const email   = ref('')
const error   = ref('')
const loading = ref(false)
const sent    = ref(false)

async function submit() {
  if (!email.value) { error.value = 'Please enter your email address'; return }
  loading.value = true
  error.value = ''
  try {
    await forgotPassword(email.value.trim())
    sent.value = true
  } catch (e) {
    error.value = e.message || 'Something went wrong. Please try again.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-[#0a0a0f] flex items-center justify-center p-4">
    <div class="w-full max-w-md">

      <!-- Logo -->
      <div class="text-center mb-8">
        <RouterLink to="/" class="inline-block">
          <p class="font-display italic text-white text-2xl tracking-wide hover:text-gray-200 transition-colors">ArtEx</p>
        </RouterLink>
        <p class="text-gray-600 text-[10px] tracking-[0.3em] uppercase mt-1">Digital Art Exchange</p>
      </div>

      <div class="bg-[#111116] border border-white/[0.1] shadow-2xl">

        <!-- Header -->
        <div class="px-6 py-5 border-b border-white/[0.07]">
          <p class="text-[10px] tracking-[0.25em] uppercase text-[#E8552A] font-light mb-0.5">Password Reset</p>
          <p class="font-display italic text-white text-xl">Forgot your password?</p>
        </div>

        <!-- Email sent confirmation -->
        <div v-if="sent" class="px-6 py-12 text-center">
          <div class="w-12 h-12 rounded-full bg-[#E8552A]/10 border border-[#E8552A]/30 flex items-center justify-center mx-auto mb-4">
            <svg class="w-6 h-6 text-[#E8552A]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75"/>
            </svg>
          </div>
          <p class="text-white font-medium mb-1">Check your inbox</p>
          <p class="text-gray-500 text-sm font-light mb-1">
            We've sent a password reset link to
          </p>
          <p class="text-gray-300 text-sm font-mono mb-6">{{ email }}</p>
          <p class="text-gray-600 text-[11px] mb-6 font-light">
            The link expires in 30 minutes. Check your spam folder if you don't see it.
          </p>
          <RouterLink to="/" class="text-[11px] tracking-[0.2em] uppercase text-gray-500 hover:text-white transition-colors">
            ← Back to Sign In
          </RouterLink>
        </div>

        <!-- Form -->
        <form v-else class="px-6 py-5 space-y-4" @submit.prevent="submit">
          <p class="text-gray-500 text-sm font-light leading-relaxed">
            Enter the email address linked to your account and we'll send you a reset link.
          </p>

          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-600 block mb-1.5">Email Address</label>
            <input
              v-model="email"
              type="email"
              autocomplete="email"
              placeholder="you@example.com"
              class="w-full bg-[#0d0d10] border border-white/[0.1] text-gray-200 px-3 py-2.5 text-sm outline-none focus:border-white/25 placeholder:text-gray-700"
            />
          </div>

          <p v-if="error" class="text-[11px] text-red-400 bg-red-500/5 border border-red-500/20 px-3 py-2">{{ error }}</p>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3 bg-[#E8552A] hover:bg-[#d4461c] disabled:opacity-50 text-white text-[11px] tracking-[0.2em] uppercase font-medium transition-colors"
          >
            {{ loading ? 'Sending…' : 'Send Reset Link' }}
          </button>

          <p class="text-center text-[11px] text-gray-600">
            <RouterLink to="/" class="text-gray-500 hover:text-white transition-colors">← Back to Sign In</RouterLink>
          </p>
        </form>
      </div>
    </div>
  </div>
</template>

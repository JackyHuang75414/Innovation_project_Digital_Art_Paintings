<script setup>
import { ref, reactive } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth   = useAuthStore()
const router = useRouter()

const fields = reactive({ name: '', email: '', password: '', confirm: '' })
const errors = reactive({ name: '', email: '', password: '', confirm: '', general: '' })
const loading = ref(false)
const done    = ref(false)

function validateName() {
  if (!fields.name) { errors.name = 'Username is required'; return false }
  if (/\s/.test(fields.name)) { errors.name = 'Username cannot contain spaces'; return false }
  if (fields.name.length < 3) { errors.name = 'Username must be at least 3 characters'; return false }
  if (fields.name.length > 16) { errors.name = 'Username cannot exceed 16 characters'; return false }
  errors.name = ''; return true
}

function validateEmail() {
  if (!fields.email) { errors.email = 'Email address is required'; return false }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(fields.email)) {
    errors.email = 'Please enter a valid email address (e.g. you@example.com)'; return false
  }
  errors.email = ''; return true
}

function validatePassword() {
  if (!fields.password) { errors.password = 'Password is required'; return false }
  if (/\s/.test(fields.password)) { errors.password = 'Password cannot contain spaces'; return false }
  if (fields.password.length < 5) { errors.password = 'Password must be at least 5 characters'; return false }
  if (fields.password.length > 16) { errors.password = 'Password cannot exceed 16 characters'; return false }
  errors.password = ''; return true
}

function validateConfirm() {
  if (!fields.confirm) { errors.confirm = 'Please confirm your password'; return false }
  if (fields.confirm !== fields.password) { errors.confirm = 'Passwords do not match'; return false }
  errors.confirm = ''; return true
}

async function submit() {
  errors.general = ''
  const ok = validateName() & validateEmail() & validatePassword() & validateConfirm()
  if (!ok) return

  loading.value = true
  const reg = await auth.registerReal(fields.name.trim(), fields.email.trim(), fields.password)
  if (!reg.ok) {
    loading.value = false
    const msg = reg.msg || ''
    if (msg.includes('username') || msg.includes('name')) {
      errors.name = 'This username is already taken. Please choose another.'
    } else if (msg.includes('email')) {
      errors.email = 'This email is already registered. Try signing in instead.'
    } else {
      errors.general = msg || 'Registration failed. Please try again.'
    }
    return
  }

  const login = await auth.loginReal(fields.name.trim(), fields.password)
  loading.value = false
  if (login.ok) {
    router.push('/account')
  } else {
    done.value = true
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
          <p class="text-[10px] tracking-[0.25em] uppercase text-[#E8552A] font-light mb-0.5">New Account</p>
          <p class="font-display italic text-white text-xl">Create your ArtEx account</p>
        </div>

        <!-- Success -->
        <div v-if="done" class="px-6 py-12 text-center">
          <div class="w-12 h-12 rounded-full bg-green-500/10 border border-green-500/30 flex items-center justify-center mx-auto mb-4">
            <svg class="w-6 h-6 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
            </svg>
          </div>
          <p class="text-white font-medium mb-1">Account created successfully</p>
          <p class="text-gray-500 text-sm font-light mb-6">You can now sign in with your credentials.</p>
          <RouterLink to="/" class="text-[11px] tracking-[0.2em] uppercase text-[#E8552A] hover:text-[#d4461c] transition-colors">
            Back to Homepage →
          </RouterLink>
        </div>

        <!-- Form -->
        <form v-else class="px-6 py-5 space-y-4" @submit.prevent="submit">

          <!-- Username -->
          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-500 block mb-1.5">Username</label>
            <input
              v-model="fields.name"
              type="text"
              autocomplete="username"
              placeholder="e.g. jane_collector"
              class="w-full bg-[#0d0d10] border text-gray-200 px-3 py-2.5 text-sm outline-none transition-colors placeholder:text-gray-700"
              :class="errors.name ? 'border-red-500/60 focus:border-red-500' : 'border-white/[0.1] focus:border-white/25'"
              @blur="validateName"
            />
            <p v-if="errors.name" class="mt-1.5 text-[11px] text-red-400 flex items-start gap-1">
              <span class="mt-px">⚠</span> {{ errors.name }}
            </p>
            <p v-else class="mt-1.5 text-[11px] text-gray-700 font-light">
              * 3–16 characters, letters/numbers/underscores only, no spaces
            </p>
          </div>

          <!-- Email -->
          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-500 block mb-1.5">Email</label>
            <input
              v-model="fields.email"
              type="email"
              autocomplete="email"
              placeholder="e.g. you@example.com"
              class="w-full bg-[#0d0d10] border text-gray-200 px-3 py-2.5 text-sm outline-none transition-colors placeholder:text-gray-700"
              :class="errors.email ? 'border-red-500/60 focus:border-red-500' : 'border-white/[0.1] focus:border-white/25'"
              @blur="validateEmail"
            />
            <p v-if="errors.email" class="mt-1.5 text-[11px] text-red-400 flex items-start gap-1">
              <span class="mt-px">⚠</span> {{ errors.email }}
            </p>
            <p v-else class="mt-1.5 text-[11px] text-gray-700 font-light">
              * Used for account recovery — make sure you have access to it
            </p>
          </div>

          <!-- Password -->
          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-500 block mb-1.5">Password</label>
            <input
              v-model="fields.password"
              type="password"
              autocomplete="new-password"
              placeholder="Set your password"
              class="w-full bg-[#0d0d10] border text-gray-200 px-3 py-2.5 text-sm outline-none transition-colors placeholder:text-gray-700"
              :class="errors.password ? 'border-red-500/60 focus:border-red-500' : 'border-white/[0.1] focus:border-white/25'"
              @blur="validatePassword"
            />
            <p v-if="errors.password" class="mt-1.5 text-[11px] text-red-400 flex items-start gap-1">
              <span class="mt-px">⚠</span> {{ errors.password }}
            </p>
            <p v-else class="mt-1.5 text-[11px] text-gray-700 font-light">
              * 5–16 characters, no spaces
            </p>
          </div>

          <!-- Confirm Password -->
          <div>
            <label class="text-[10px] tracking-[0.15em] uppercase text-gray-500 block mb-1.5">Confirm Password</label>
            <input
              v-model="fields.confirm"
              type="password"
              autocomplete="new-password"
              placeholder="Re-enter your password"
              class="w-full bg-[#0d0d10] border text-gray-200 px-3 py-2.5 text-sm outline-none transition-colors placeholder:text-gray-700"
              :class="errors.confirm ? 'border-red-500/60 focus:border-red-500' : 'border-white/[0.1] focus:border-white/25'"
              @blur="validateConfirm"
            />
            <p v-if="errors.confirm" class="mt-1.5 text-[11px] text-red-400 flex items-start gap-1">
              <span class="mt-px">⚠</span> {{ errors.confirm }}
            </p>
            <p v-else class="mt-1.5 text-[11px] text-gray-700 font-light">
              * Must match the password entered above
            </p>
          </div>

          <!-- General error -->
          <p v-if="errors.general" class="text-[11px] text-red-400 bg-red-500/5 border border-red-500/20 px-3 py-2">
            {{ errors.general }}
          </p>

          <button
            type="submit"
            :disabled="loading"
            class="w-full py-3 bg-[#E8552A] hover:bg-[#d4461c] disabled:opacity-50 text-white text-[11px] tracking-[0.2em] uppercase font-medium transition-colors mt-1"
          >
            {{ loading ? 'Creating account…' : 'Create Account' }}
          </button>

          <div class="flex items-center gap-3 py-1">
            <div class="flex-1 h-px bg-white/[0.07]" />
            <span class="text-[10px] text-gray-700 uppercase tracking-wide">or</span>
            <div class="flex-1 h-px bg-white/[0.07]" />
          </div>

          <p class="text-center text-[11px] text-gray-600">
            Already have an account?
            <RouterLink to="/" class="text-[#E8552A] hover:text-[#d4461c] ml-1 transition-colors">Sign in →</RouterLink>
          </p>

        </form>
      </div>
    </div>
  </div>
</template>

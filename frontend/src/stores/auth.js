import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { loginBackend, register as registerApi, getMe, googleLogin as googleLoginApi, deleteAccount as deleteAccountApi } from '@/api/auth'

export const DEMO_ACCOUNTS = [
  {
    id: 1,
    username: 'demo',
    password: 'demo123',
    displayName: 'Demo Trader',
    initials: 'DT',
    color: '#E8552A',
    startUsd: 10_000,
    startBtc: 0.5,
    bio: 'New to crypto art trading. Starting with a balanced portfolio.',
    isPaid: false,
  },
  {
    id: 2,
    username: 'whale',
    password: 'whale888',
    displayName: 'Whale Investor',
    initials: 'WI',
    color: '#9945ff',
    startUsd: 200_000,
    startBtc: 3.0,
    bio: 'High-conviction NFT collector. Focus on blue-chip digital works.',
    isPaid: true,
  },
  {
    id: 3,
    username: 'algo',
    password: 'algo2025',
    displayName: 'Algo Trader',
    initials: 'AT',
    color: '#22c55e',
    startUsd: 50_000,
    startBtc: 1.2,
    bio: 'Fully automated. All positions managed by AI agents.',
    isPaid: true,
  },
]

const STORAGE_KEY = 'artex_user'

export const useAuthStore = defineStore('auth', () => {
  const _saved = localStorage.getItem(STORAGE_KEY)
  const user = ref(_saved ? JSON.parse(_saved) : null)

  const isLoggedIn  = computed(() => !!user.value)
  const isPaid      = computed(() => !!user.value?.isPaid)
  const displayName = computed(() => user.value?.displayName ?? '')
  const initials    = computed(() => user.value?.initials ?? '')
  const color       = computed(() => user.value?.color ?? '#E8552A')

  function login(username, password) {
    const account = DEMO_ACCOUNTS.find(
      a => a.username === username && a.password === password
    )
    if (!account) return { ok: false, msg: 'Invalid username or password' }

    const profile = {
      id: account.id,
      username: account.username,
      displayName: account.displayName,
      initials: account.initials,
      color: account.color,
      bio: account.bio,
      startUsd: account.startUsd,
      startBtc: account.startBtc,
      isPaid: account.isPaid,
    }
    user.value = profile
    localStorage.setItem(STORAGE_KEY, JSON.stringify(profile))
    return { ok: true, account: profile }
  }

  function loginAsGuest() {
    return login('demo', 'demo123')
  }

  function logout() {
    user.value = null
    localStorage.removeItem(STORAGE_KEY)
    localStorage.removeItem('artex_jwt')
  }

  // Real backend login — saves JWT, fetches user profile
  async function loginReal(name, password) {
    try {
      const token = await loginBackend(name, password)
      if (!token) return { ok: false, msg: 'No token returned' }
      localStorage.setItem('artex_jwt', token)
      const profile = await getMe()
      const enriched = {
        id: profile.id,
        username: profile.name,
        displayName: profile.name,
        initials: profile.name.slice(0, 2).toUpperCase(),
        color: '#22c55e',
        bio: '',
        isPaid: false,
        isRealUser: true,
      }
      user.value = enriched
      localStorage.setItem(STORAGE_KEY, JSON.stringify(enriched))
      return { ok: true, account: enriched }
    } catch (e) {
      return { ok: false, msg: e.message }
    }
  }

  // Real backend register
  async function registerReal(name, email, password) {
    try {
      await registerApi(name, email, password)
      return { ok: true }
    } catch (e) {
      let msg = e.message || 'Registration failed'
      if (msg.includes('S{3,16}')) msg = 'Username must be 3–16 characters with no spaces'
      if (msg.includes('S{5,16}')) msg = 'Password must be 5–16 characters with no spaces'
      if (msg.includes('well-formed email') || msg.includes('Email')) msg = 'Please enter a valid email address'
      return { ok: false, msg }
    }
  }

  async function googleLogin(credential) {
    try {
      const token = await googleLoginApi(credential)
      if (!token) return { ok: false, msg: 'No token returned' }
      localStorage.setItem('artex_jwt', token)
      const profile = await getMe()
      const enriched = {
        id: profile.id,
        username: profile.name,
        displayName: profile.name,
        initials: profile.name.slice(0, 2).toUpperCase(),
        color: '#4285F4',
        bio: 'Google account',
        isPaid: false,
        isRealUser: true,
        isGoogleUser: true,
      }
      user.value = enriched
      localStorage.setItem(STORAGE_KEY, JSON.stringify(enriched))
      return { ok: true, account: enriched }
    } catch (e) {
      return { ok: false, msg: e.message }
    }
  }

  async function deleteAccount() {
    try {
      await deleteAccountApi()
      user.value = null
      localStorage.removeItem(STORAGE_KEY)
      localStorage.removeItem('artex_jwt')
      return { ok: true }
    } catch (e) {
      return { ok: false, msg: e.message }
    }
  }

  const hasJwt = computed(() => !!localStorage.getItem('artex_jwt'))

  return {
    user, isLoggedIn, isPaid, displayName, initials, color, hasJwt,
    login, loginAsGuest, loginReal, registerReal, googleLogin, deleteAccount, logout,
    DEMO_ACCOUNTS,
  }
})

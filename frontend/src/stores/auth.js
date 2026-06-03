import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

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
  },
]

const STORAGE_KEY = 'artex_user'

export const useAuthStore = defineStore('auth', () => {
  const _saved = localStorage.getItem(STORAGE_KEY)
  const user = ref(_saved ? JSON.parse(_saved) : null)

  const isLoggedIn  = computed(() => !!user.value)
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
  }

  return { user, isLoggedIn, displayName, initials, color, login, loginAsGuest, logout, DEMO_ACCOUNTS }
})

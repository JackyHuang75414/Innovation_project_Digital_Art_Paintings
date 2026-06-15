import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const CRYPTOS = [
  { id: 'bitcoin',     symbol: 'BTC', name: 'Bitcoin',  color: '#f7931a' },
  { id: 'ethereum',    symbol: 'ETH', name: 'Ethereum', color: '#627eea' },
  { id: 'binancecoin', symbol: 'BNB', name: 'BNB',      color: '#f0b90b' },
  { id: 'solana',      symbol: 'SOL', name: 'Solana',   color: '#9945ff' },
  { id: 'ripple',      symbol: 'XRP', name: 'XRP',      color: '#0085c3' },
]

export const FIATS = [
  { code: 'USD', symbol: '$',  name: 'US Dollar'      },
  { code: 'EUR', symbol: '€',  name: 'Euro'           },
  { code: 'GBP', symbol: '£',  name: 'British Pound'  },
  { code: 'JPY', symbol: '¥',  name: 'Japanese Yen'   },
  { code: 'CNY', symbol: '¥',  name: 'Chinese Yuan'   },
  { code: 'CHF', symbol: 'Fr', name: 'Swiss Franc'    },
]

// Approximate fixed rates vs USD (refreshed manually or via separate API)
const FIAT_RATES_USD = { USD: 1, EUR: 0.92, GBP: 0.79, JPY: 157.4, CNY: 7.24, CHF: 0.90 }

export const usePricesStore = defineStore('prices', () => {
  // Seed prices — overwritten by CoinGecko poll
  const cryptoUsd = ref({ BTC: 64_800, ETH: 3_240, BNB: 582, SOL: 178, XRP: 0.618 })
  const cryptoChange24h = ref({ BTC: 1.2, ETH: -0.8, BNB: 2.1, SOL: -3.4, XRP: 0.5 })

  const selectedCrypto = ref(localStorage.getItem('artex_crypto') || 'ETH')
  const selectedFiat   = ref(localStorage.getItem('artex_fiat')   || 'USD')

  let _timer = null

  // ── Fetch from CoinGecko (via Vite proxy) ────────────────────────────────────
  async function fetchPrices() {
    try {
      const ids = 'bitcoin,ethereum,binancecoin,solana,ripple'
      const res = await fetch(
        `/coingecko/api/v3/simple/price?ids=${ids}&vs_currencies=usd&include_24hr_change=true`,
        { signal: AbortSignal.timeout(8000) }
      )
      if (!res.ok) return
      const data = await res.json()
      const MAP = { bitcoin: 'BTC', ethereum: 'ETH', binancecoin: 'BNB', solana: 'SOL', ripple: 'XRP' }
      Object.entries(MAP).forEach(([cgId, sym]) => {
        if (data[cgId]?.usd) {
          cryptoUsd.value[sym]       = data[cgId].usd
          cryptoChange24h.value[sym] = data[cgId].usd_24h_change ?? 0
        }
      })
    } catch { /* keep seed values on error */ }
  }

  function startPolling() { fetchPrices(); _timer = setInterval(fetchPrices, 60_000) }
  function stopPolling()  { clearInterval(_timer) }

  // ── User preferences ─────────────────────────────────────────────────────────
  function setCrypto(sym) { selectedCrypto.value = sym; localStorage.setItem('artex_crypto', sym) }
  function setFiat(code)  { selectedFiat.value   = code; localStorage.setItem('artex_fiat',   code) }

  // ── Conversion helpers ────────────────────────────────────────────────────────
  function usdToCrypto(usdAmt, sym) {
    const s = sym ?? selectedCrypto.value
    return usdAmt / (cryptoUsd.value[s] || 1)
  }

  function usdToFiat(usdAmt, code) {
    const c = code ?? selectedFiat.value
    return usdAmt * (FIAT_RATES_USD[c] ?? 1)
  }

  function fiatSymbol(code) {
    return FIATS.find(f => f.code === (code ?? selectedFiat.value))?.symbol ?? '$'
  }

  function formatCrypto(usdAmt, sym) {
    const s = sym ?? selectedCrypto.value
    const v = usdToCrypto(usdAmt, s)
    if (v < 0.0001)  return v.toFixed(8) + ' ' + s
    if (v < 0.01)    return v.toFixed(6) + ' ' + s
    if (v < 1)       return v.toFixed(4) + ' ' + s
    if (v < 10_000)  return v.toFixed(2) + ' ' + s
    return v.toFixed(0) + ' ' + s
  }

  function formatFiat(usdAmt, code) {
    const c   = code ?? selectedFiat.value
    const v   = usdToFiat(usdAmt, c)
    const sym = fiatSymbol(c)
    if (v >= 1e6) return sym + (v / 1e6).toFixed(2) + 'M'
    if (v >= 1e3) return sym + (v / 1e3).toFixed(1)  + 'K'
    return sym + v.toFixed(2)
  }

  const activeCrypto = computed(() => CRYPTOS.find(c => c.symbol === selectedCrypto.value) ?? CRYPTOS[1])
  const activeFiat   = computed(() => FIATS.find(f => f.code   === selectedFiat.value)   ?? FIATS[0])

  return {
    cryptoUsd, cryptoChange24h,
    selectedCrypto, selectedFiat,
    activeCrypto, activeFiat,
    CRYPTOS, FIATS,
    startPolling, stopPolling,
    setCrypto, setFiat,
    usdToCrypto, usdToFiat, fiatSymbol,
    formatCrypto, formatFiat,
  }
})

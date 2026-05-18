<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'
import QRCode from 'qrcode'
import { generateBtcAddress, getBtcReceived, EUR_TO_BTC, luhn } from '@/api/payments'

const cart = useCartStore()
const router = useRouter()

// ── Contact ───────────────────────────────────────────────────────────────────
const name = ref('')
const email = ref('')

// ── Payment tabs ──────────────────────────────────────────────────────────────
const method = ref('card') // 'card' | 'bitcoin'

// ── Shared state ──────────────────────────────────────────────────────────────
const processing = ref(false)
const formError = ref('')
const paymentSuccess = ref(false)
const orderNumber = ref('')

function handleSuccess() {
  orderNumber.value = 'AC-' + Math.random().toString(36).slice(2, 8).toUpperCase()
  paymentSuccess.value = true
  cart.clear()
}

// ── Stripe ────────────────────────────────────────────────────────────────────
/**
 * Get your free test key from https://dashboard.stripe.com/test/apikeys
 * Add it to .env as VITE_STRIPE_PUBLIC_KEY=pk_test_...
 */
const STRIPE_KEY = import.meta.env.VITE_STRIPE_PUBLIC_KEY || ''
let stripe = null
let cardEl = null
const stripeError = ref('')
const stripeReady = ref(false)
const stripeLoading = ref(true)

async function initStripe() {
  if (!STRIPE_KEY || stripe) return
  // Load Stripe.js from CDN
  if (!window.Stripe) {
    await new Promise((resolve, reject) => {
      const s = document.createElement('script')
      s.src = 'https://js.stripe.com/v3/'
      s.onload = resolve
      s.onerror = reject
      document.head.appendChild(s)
    })
  }
  stripe = window.Stripe(STRIPE_KEY)
  const elements = stripe.elements({
    fonts: [{ cssSrc: 'https://fonts.googleapis.com/css2?family=Inter:wght@300;400&display=swap' }],
  })
  cardEl = elements.create('card', {
    style: {
      base: {
        fontFamily: "'Inter', sans-serif",
        fontSize: '14px',
        color: '#111827',
        fontWeight: '300',
        '::placeholder': { color: '#9CA3AF' },
        lineHeight: '2',
      },
      invalid: { color: '#E8552A' },
    },
    hidePostalCode: true,
  })
  cardEl.mount('#stripe-card-element')
  cardEl.on('change', e => { stripeError.value = e.error?.message || '' })
  stripeReady.value = true
  stripeLoading.value = false
}

async function submitStripe() {
  formError.value = ''
  if (!name.value.trim()) { formError.value = 'Please enter your full name.'; return }
  if (!email.value.trim()) { formError.value = 'Please enter your email.'; return }
  processing.value = true
  try {
    const { paymentMethod, error } = await stripe.createPaymentMethod({
      type: 'card',
      card: cardEl,
      billing_details: { name: name.value, email: email.value },
    })
    if (error) {
      stripeError.value = error.message
    } else {
      // Production: POST paymentMethod.id to backend → /api/payments/charge
      console.log('[Stripe] paymentMethod.id:', paymentMethod.id)
      handleSuccess()
    }
  } finally {
    processing.value = false
  }
}

// ── Demo card form (no Stripe key) ────────────────────────────────────────────
const demoCard = ref('')
const demoExpiry = ref('')
const demoCVV = ref('')
const demoError = ref('')

function formatCardNumber(e) {
  let v = e.target.value.replace(/\D/g, '').slice(0, 16)
  demoCard.value = v.replace(/(.{4})/g, '$1 ').trim()
}

function formatExpiry(e) {
  let v = e.target.value.replace(/\D/g, '').slice(0, 4)
  if (v.length > 2) v = v.slice(0, 2) + '/' + v.slice(2)
  demoExpiry.value = v
}

async function submitDemo() {
  demoError.value = ''
  formError.value = ''
  if (!name.value.trim()) { formError.value = 'Please enter your full name.'; return }
  if (!email.value.trim()) { formError.value = 'Please enter your email.'; return }
  const raw = demoCard.value.replace(/\s/g, '')
  if (raw.length < 13 || !luhn(raw)) { demoError.value = 'Invalid card number.'; return }
  const [mm, yy] = demoExpiry.value.split('/')
  const now = new Date()
  if (!yy || parseInt(mm) < 1 || parseInt(mm) > 12 ||
      new Date(2000 + parseInt(yy), parseInt(mm) - 1) <= now) {
    demoError.value = 'Invalid or expired expiry date.'
    return
  }
  if (demoCVV.value.length < 3) { demoError.value = 'Invalid CVV.'; return }
  processing.value = true
  await new Promise(r => setTimeout(r, 1500))
  processing.value = false
  handleSuccess()
}

// ── Bitcoin ───────────────────────────────────────────────────────────────────
const btcAddress = ref('')
const btcLoading = ref(false)
const btcError = ref('')
const qrDataUrl = ref('')
const btcPaid = ref(false)
const copied = ref(false)
let pollTimer = null

const btcAmount = computed(() => (cart.total * EUR_TO_BTC).toFixed(8))
const btcUri = computed(() => `bitcoin:${btcAddress.value}?amount=${btcAmount.value}`)

async function loadBitcoin() {
  if (btcAddress.value || method.value !== 'bitcoin') return
  btcLoading.value = true
  btcError.value = ''
  try {
    btcAddress.value = await generateBtcAddress()
    qrDataUrl.value = await QRCode.toDataURL(btcUri.value, {
      width: 192,
      margin: 1,
      color: { dark: '#111827', light: '#F7F4F0' },
    })
    startBtcPolling()
  } catch (err) {
    btcError.value = 'Could not reach BlockCypher testnet. Check your network.'
    console.error(err)
  } finally {
    btcLoading.value = false
  }
}

function startBtcPolling() {
  pollTimer = setInterval(async () => {
    if (!btcAddress.value) return
    const received = await getBtcReceived(btcAddress.value)
    if (received > 0) {
      btcPaid.value = true
      stopBtcPolling()
      handleSuccess()
    }
  }, 12000)
}

function stopBtcPolling() {
  clearInterval(pollTimer)
}

async function copyAddress() {
  await navigator.clipboard.writeText(btcAddress.value)
  copied.value = true
  setTimeout(() => { copied.value = false }, 2000)
}

function simulateBtcPayment() {
  stopBtcPolling()
  btcPaid.value = true
  handleSuccess()
}

// ── Tab switching ─────────────────────────────────────────────────────────────
async function setMethod(m) {
  method.value = m
  if (m === 'bitcoin') await loadBitcoin()
}

// ── Lifecycle ─────────────────────────────────────────────────────────────────
onMounted(async () => {
  if (cart.items.length === 0) { router.replace('/browse'); return }
  await nextTick()
  await initStripe()
  stripeLoading.value = false
})

onUnmounted(stopBtcPolling)

// ── Order summary ─────────────────────────────────────────────────────────────
const shipping = computed(() => cart.total >= 80 ? 0 : 9.9)
const orderTotal = computed(() => cart.total + shipping.value)
</script>

<template>
  <!-- ── Page header ── -->
  <div class="bg-[#F7F4F0] border-b border-[#E0D8CE]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-3.5">
      <nav class="flex items-center gap-2 text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light">
        <RouterLink to="/" class="hover:text-gray-700 transition-colors">Home</RouterLink>
        <span class="text-gray-300">/</span>
        <RouterLink to="/cart" class="hover:text-gray-700 transition-colors">Cart</RouterLink>
        <span class="text-gray-300">/</span>
        <span class="text-gray-600">Checkout</span>
      </nav>
    </div>
  </div>

  <div class="bg-[#F7F4F0] border-b border-[#E0D8CE]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-10">
      <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-3 font-light">Secure Payment</p>
      <h1 class="font-display text-3xl lg:text-[2.75rem] font-normal italic text-gray-900 leading-tight">
        Checkout
      </h1>
    </div>
  </div>

  <!-- ── Success state ── -->
  <div v-if="paymentSuccess" class="max-w-screen-xl mx-auto px-6 lg:px-16 py-24 lg:py-32 text-center">
    <div class="inline-flex items-center justify-center w-16 h-16 border border-gray-200 mb-8">
      <svg class="w-7 h-7 text-[#E8552A]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4.5 12.75l6 6 9-13.5"/>
      </svg>
    </div>
    <p class="font-display italic text-3xl text-gray-900 mb-3">Order Confirmed</p>
    <p class="text-[11px] tracking-[0.25em] uppercase text-gray-400 font-light mb-2">Order number</p>
    <p class="font-display italic text-2xl text-[#E8552A] mb-8">{{ orderNumber }}</p>
    <p class="text-sm text-gray-500 font-light mb-10 max-w-sm mx-auto leading-relaxed">
      Thank you, {{ name }}. A confirmation will be sent to {{ email }}. Your prints will be dispatched within 24 hours.
    </p>
    <RouterLink to="/" class="btn-primary">Back to Home</RouterLink>
  </div>

  <!-- ── Main checkout layout ── -->
  <div v-else class="max-w-screen-xl mx-auto px-6 lg:px-16 py-12 lg:py-16">
    <div class="grid grid-cols-1 lg:grid-cols-5 gap-12 lg:gap-16 items-start">

      <!-- ── LEFT: Form ───────────────────────────────────────────────────── -->
      <div class="lg:col-span-3 space-y-10">

        <!-- Contact section -->
        <section>
          <p class="text-[10px] tracking-[0.35em] uppercase text-gray-400 font-light mb-6">01 — Contact</p>
          <div class="space-y-5">
            <div>
              <label class="block text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light mb-2">Full Name</label>
              <input
                v-model="name"
                type="text"
                placeholder="Sophie Laurent"
                class="w-full border-b border-gray-200 focus:border-gray-900 outline-none py-2 text-sm font-light bg-transparent transition-colors placeholder:text-gray-300"
              />
            </div>
            <div>
              <label class="block text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light mb-2">Email</label>
              <input
                v-model="email"
                type="email"
                placeholder="hello@example.com"
                class="w-full border-b border-gray-200 focus:border-gray-900 outline-none py-2 text-sm font-light bg-transparent transition-colors placeholder:text-gray-300"
              />
            </div>
          </div>
          <p v-if="formError" class="text-[#E8552A] text-xs mt-3 font-light">{{ formError }}</p>
        </section>

        <div class="h-px bg-gray-200" />

        <!-- Payment method section -->
        <section>
          <p class="text-[10px] tracking-[0.35em] uppercase text-gray-400 font-light mb-6">02 — Payment Method</p>

          <!-- Tab switcher -->
          <div class="flex gap-0 border border-gray-200 mb-8 w-fit">
            <button
              class="px-6 py-2.5 text-[11px] tracking-[0.2em] uppercase font-light transition-colors"
              :class="method === 'card'
                ? 'bg-gray-900 text-white'
                : 'bg-white text-gray-500 hover:text-gray-900'"
              @click="setMethod('card')"
            >
              Card
            </button>
            <button
              class="px-6 py-2.5 text-[11px] tracking-[0.2em] uppercase font-light transition-colors border-l border-gray-200"
              :class="method === 'bitcoin'
                ? 'bg-gray-900 text-white'
                : 'bg-white text-gray-500 hover:text-gray-900'"
              @click="setMethod('bitcoin')"
            >
              Bitcoin
            </button>
          </div>

          <!-- ── Card payment ── -->
          <div v-show="method === 'card'">
            <!-- Stripe Elements (when key is configured) -->
            <div v-if="STRIPE_KEY">
              <div v-if="stripeLoading" class="flex items-center gap-2 py-6 text-gray-400">
                <svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="3"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                </svg>
                <span class="text-xs tracking-wide font-light">Loading secure card form…</span>
              </div>
              <div :class="{ 'opacity-0 h-0 overflow-hidden': stripeLoading }">
                <div class="border border-gray-200 focus-within:border-gray-900 transition-colors">
                  <div id="stripe-card-element" class="px-4 py-4" />
                </div>
                <p v-if="stripeError" class="text-[#E8552A] text-xs mt-2 font-light">{{ stripeError }}</p>
                <p class="text-[11px] text-gray-400 font-light mt-3">
                  Test card: <span class="tracking-wider font-mono">4242 4242 4242 4242</span> · 12/26 · 123
                </p>
                <button
                  class="btn-primary w-full mt-6 flex items-center justify-center gap-2"
                  :disabled="processing"
                  @click="submitStripe"
                >
                  <svg v-if="processing" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="3"/>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                  </svg>
                  {{ processing ? 'Processing…' : 'Pay €' + orderTotal.toFixed(2) }}
                </button>
              </div>
            </div>

            <!-- Demo card form (no Stripe key) -->
            <div v-else class="space-y-5">
              <div class="border border-dashed border-amber-300 bg-amber-50 px-4 py-3 mb-6">
                <p class="text-[11px] text-amber-700 font-light leading-relaxed">
                  Demo mode — Stripe key not configured.
                  Add <span class="font-mono text-[10px]">VITE_STRIPE_PUBLIC_KEY=pk_test_…</span> to <span class="font-mono text-[10px]">.env</span>
                  for live Stripe integration. Card validation still runs client-side.
                </p>
              </div>
              <div>
                <label class="block text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light mb-2">Card Number</label>
                <input
                  :value="demoCard"
                  type="text"
                  inputmode="numeric"
                  maxlength="19"
                  placeholder="4242 4242 4242 4242"
                  class="w-full border-b border-gray-200 focus:border-gray-900 outline-none py-2 text-sm font-light font-mono bg-transparent transition-colors placeholder:text-gray-300 placeholder:font-sans"
                  @input="formatCardNumber"
                />
              </div>
              <div class="flex gap-6">
                <div class="flex-1">
                  <label class="block text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light mb-2">Expiry</label>
                  <input
                    :value="demoExpiry"
                    type="text"
                    inputmode="numeric"
                    maxlength="5"
                    placeholder="MM/YY"
                    class="w-full border-b border-gray-200 focus:border-gray-900 outline-none py-2 text-sm font-light font-mono bg-transparent transition-colors placeholder:text-gray-300 placeholder:font-sans"
                    @input="formatExpiry"
                  />
                </div>
                <div class="flex-1">
                  <label class="block text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light mb-2">CVV</label>
                  <input
                    v-model="demoCVV"
                    type="text"
                    inputmode="numeric"
                    maxlength="4"
                    placeholder="123"
                    class="w-full border-b border-gray-200 focus:border-gray-900 outline-none py-2 text-sm font-light font-mono bg-transparent transition-colors placeholder:text-gray-300 placeholder:font-sans"
                  />
                </div>
              </div>
              <p v-if="demoError" class="text-[#E8552A] text-xs font-light">{{ demoError }}</p>
              <p class="text-[11px] text-gray-400 font-light">
                Test card: <span class="font-mono tracking-wider">4242 4242 4242 4242</span> · 12/26 · 123
              </p>
              <button
                class="btn-primary w-full flex items-center justify-center gap-2 mt-2"
                :disabled="processing"
                @click="submitDemo"
              >
                <svg v-if="processing" class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="3"/>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
                </svg>
                {{ processing ? 'Processing…' : 'Pay €' + orderTotal.toFixed(2) }}
              </button>
            </div>
          </div>

          <!-- ── Bitcoin payment ── -->
          <div v-show="method === 'bitcoin'">
            <!-- Loading state -->
            <div v-if="btcLoading" class="flex flex-col items-center gap-3 py-12 text-gray-400">
              <svg class="w-5 h-5 animate-spin" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="3"/>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
              </svg>
              <p class="text-xs tracking-wide font-light">Generating testnet address…</p>
            </div>

            <!-- Error state -->
            <div v-else-if="btcError" class="py-6">
              <p class="text-[#E8552A] text-xs font-light">{{ btcError }}</p>
              <button class="mt-3 text-[11px] tracking-[0.15em] uppercase text-gray-500 hover:text-gray-900 border-b border-gray-300 font-light" @click="btcAddress = ''; loadBitcoin()">
                Retry
              </button>
            </div>

            <!-- QR + address -->
            <div v-else-if="btcAddress" class="space-y-7">
              <!-- QR code -->
              <div class="flex flex-col items-center gap-5 bg-[#F7F4F0] p-8">
                <img v-if="qrDataUrl" :src="qrDataUrl" alt="Bitcoin payment QR code" class="w-48 h-48" />
                <div class="text-center">
                  <p class="text-[10px] tracking-[0.25em] uppercase text-gray-400 font-light mb-3">Bitcoin Testnet3 Address</p>
                  <div class="flex items-center gap-2 justify-center">
                    <code class="text-xs font-mono text-gray-700 break-all max-w-xs">{{ btcAddress }}</code>
                    <button
                      class="flex-shrink-0 text-gray-400 hover:text-gray-900 transition-colors"
                      aria-label="Copy address"
                      @click="copyAddress"
                    >
                      <svg v-if="!copied" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                          d="M15.666 3.888A2.25 2.25 0 0 0 13.5 2.25h-3c-1.03 0-1.9.693-2.166 1.638m7.332 0c.055.194.084.4.084.612v0a.75.75 0 0 1-.75.75H9a.75.75 0 0 1-.75-.75v0c0-.212.03-.418.084-.612m7.332 0c.646.049 1.288.11 1.927.184 1.1.128 1.907 1.077 1.907 2.185V19.5a2.25 2.25 0 0 1-2.25 2.25H6.75A2.25 2.25 0 0 1 4.5 19.5V6.257c0-1.108.806-2.057 1.907-2.185a48.208 48.208 0 0 1 1.927-.184"/>
                      </svg>
                      <svg v-else class="w-4 h-4 text-[#E8552A]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M4.5 12.75l6 6 9-13.5"/>
                      </svg>
                    </button>
                  </div>
                </div>
              </div>

              <!-- Amount -->
              <div class="flex items-baseline justify-between border-b border-gray-100 pb-4">
                <div>
                  <p class="text-[10px] tracking-[0.25em] uppercase text-gray-400 font-light mb-1">Amount to send</p>
                  <p class="font-display italic text-2xl text-gray-900">{{ btcAmount }} <span class="text-base not-italic font-light text-gray-400">BTC</span></p>
                </div>
                <div class="text-right">
                  <p class="text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light mb-1">Network</p>
                  <p class="text-xs text-gray-600 font-light">Bitcoin Testnet3</p>
                </div>
              </div>

              <!-- Payment status -->
              <div class="flex items-center gap-3">
                <span class="relative flex h-2.5 w-2.5">
                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-amber-400 opacity-75"/>
                  <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-amber-400"/>
                </span>
                <p class="text-xs text-gray-500 font-light tracking-wide">Awaiting payment — polling every 12 seconds</p>
              </div>

              <!-- Demo button -->
              <div class="pt-2">
                <p class="text-[10px] tracking-[0.2em] uppercase text-gray-400 font-light mb-3">Demo only</p>
                <button
                  class="text-[11px] tracking-[0.2em] uppercase text-gray-600 hover:text-gray-900 border border-gray-300 hover:border-gray-900 px-5 py-2.5 transition-colors font-light"
                  @click="simulateBtcPayment"
                >
                  Simulate Payment Received
                </button>
              </div>
            </div>
          </div>
        </section>
      </div>

      <!-- ── RIGHT: Order summary ────────────────────────────────────────── -->
      <div class="lg:col-span-2">
        <div class="border border-gray-200 p-7 lg:sticky lg:top-24">
          <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-6">Order Summary</p>

          <!-- Items -->
          <div class="space-y-4 mb-6">
            <div
              v-for="item in cart.items"
              :key="item.key"
              class="flex gap-3 items-start"
            >
              <div class="bg-[#F7F4F0] flex-shrink-0">
                <img
                  :src="item.artwork.imageUrl"
                  :alt="item.artwork.title"
                  class="w-14 h-14 object-cover"
                />
              </div>
              <div class="flex-1 min-w-0">
                <p class="font-display italic text-sm text-gray-900 leading-snug line-clamp-1">{{ item.artwork.title }}</p>
                <p class="text-[10px] tracking-[0.15em] uppercase text-gray-400 font-light mt-0.5">{{ item.size }}</p>
              </div>
              <p class="text-sm font-medium text-gray-900 flex-shrink-0">€{{ item.price }}</p>
            </div>
          </div>

          <div class="h-px bg-gray-100 mb-5" />

          <!-- Pricing -->
          <div class="space-y-2.5 text-sm font-light text-gray-600 mb-5">
            <div class="flex justify-between">
              <span>Subtotal</span>
              <span>€{{ cart.total.toFixed(2) }}</span>
            </div>
            <div class="flex justify-between">
              <span>Shipping</span>
              <span :class="shipping === 0 ? 'text-green-600' : ''">
                {{ shipping === 0 ? 'Free' : '€' + shipping.toFixed(2) }}
              </span>
            </div>
          </div>

          <div class="h-px bg-gray-100 mb-5" />

          <div class="flex justify-between items-baseline">
            <span class="text-sm font-medium text-gray-900">Total</span>
            <span class="font-display italic text-2xl text-gray-900">€{{ orderTotal.toFixed(2) }}</span>
          </div>

          <!-- Secure badges -->
          <div class="mt-6 pt-5 border-t border-gray-100 flex items-center gap-2 text-gray-400">
            <svg class="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"
                d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z"/>
            </svg>
            <p class="text-[10px] tracking-[0.15em] uppercase font-light">SSL encrypted · Secure checkout</p>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

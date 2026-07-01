<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const auth   = useAuthStore()

const billing = ref('monthly')  // 'monthly' | 'annual'

const plans = computed(() => [
  {
    id:        'explorer',
    name:      'Explorer',
    price:     { monthly: 0, annual: 0 },
    badge:     null,
    color:     '#6b7280',
    accent:    'border-white/[0.1]',
    btn:       'bg-white/[0.07] text-gray-300 hover:bg-white/[0.12]',
    isCurrent: !auth.isPaid,
    features: [
      { ok: true,  text: 'Art market — browse & spot trade'         },
      { ok: true,  text: 'AI Curator chat (recommendations)'        },
      { ok: true,  text: 'Up to 5 spot positions'                   },
      { ok: true,  text: 'Standard order execution'                 },
      { ok: false, text: 'AI Trading Agent'                         },
      { ok: false, text: 'Real-time price alerts'                   },
      { ok: false, text: 'Perpetual futures'                        },
      { ok: false, text: 'Custom AI endpoint (Lobster interface)'   },
    ],
  },
  {
    id:        'pro',
    name:      'Pro',
    price:     { monthly: 14.99, annual: 11.99 },
    badge:     'Most Popular',
    color:     '#E8552A',
    accent:    'border-[#E8552A]/50',
    btn:       'bg-[#E8552A] hover:bg-[#d4461c] text-white',
    isCurrent: auth.isPaid,
    features: [
      { ok: true,  text: 'Everything in Explorer'                   },
      { ok: true,  text: 'AI Trading Agent (3 built-in strategies)' },
      { ok: true,  text: 'Real-time price alerts via ArtEx AI'      },
      { ok: true,  text: 'Perpetual futures — unlimited positions'  },
      { ok: true,  text: 'ArtEx default AI (DeepSeek powered)'      },
      { ok: true,  text: 'Trade history & analytics'                },
      { ok: false, text: 'Custom AI endpoint (Lobster interface)'   },
      { ok: false, text: 'Dedicated account manager'                },
    ],
  },
  {
    id:        'institutional',
    name:      'Institutional',
    price:     { monthly: 49.99, annual: 39.99 },
    badge:     'For Power Users',
    color:     '#9945ff',
    accent:    'border-[#9945ff]/40',
    btn:       'bg-[#9945ff] hover:bg-[#7b35d9] text-white',
    isCurrent: false,
    features: [
      { ok: true, text: 'Everything in Pro'                          },
      { ok: true, text: 'Custom AI API endpoint (Lobster interface)' },
      { ok: true, text: 'Bring your own model (OpenAI / Claude / …)'},
      { ok: true, text: 'Multi-artwork simultaneous agent monitoring'},
      { ok: true, text: 'Early access to new artwork listings'       },
      { ok: true, text: 'Advanced risk analytics dashboard'          },
      { ok: true, text: 'Dedicated account manager'                  },
      { ok: true, text: 'SLA: 99.9% uptime guarantee'                },
    ],
  },
])

function fmtPrice(plan) {
  const p = plan.price[billing.value]
  if (p === 0) return 'Free'
  return `€${p.toFixed(2)}`
}

// Demo: simulate upgrade (toggle isPaid on demo account)
const upgrading  = ref(null)
const upgradeMsg = ref(null)

function handleCta(plan) {
  if (plan.id === 'explorer') {
    router.push('/market')
    return
  }
  if (plan.isCurrent) {
    router.push('/account')
    return
  }
  // Demo upgrade
  upgrading.value = plan.id
  setTimeout(() => {
    upgrading.value  = null
    upgradeMsg.value = plan.name
    // Persist isPaid for demo session
    if (auth.user) {
      auth.user.isPaid = true
      localStorage.setItem('artex_user', JSON.stringify(auth.user))
    }
    setTimeout(() => { upgradeMsg.value = null; router.push('/account') }, 2200)
  }, 1400)
}
</script>

<template>
  <div class="min-h-screen bg-[#09090c]">

    <!-- Hero -->
    <div class="border-b border-white/[0.06] bg-gradient-to-b from-white/[0.02] to-transparent">
      <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-16 text-center">
        <p class="text-[10px] tracking-[0.3em] uppercase text-[#E8552A] mb-4">ArtEx Premium</p>
        <h1 class="font-display italic text-4xl lg:text-5xl text-white mb-4">
          Unlock AI-Powered Trading
        </h1>
        <p class="text-gray-400 font-light max-w-xl mx-auto text-base leading-relaxed">
          Automate your art portfolio with intelligent strategies, real-time alerts,
          and a custom AI agent that trades while you sleep.
        </p>

        <!-- Billing toggle -->
        <div class="flex items-center justify-center gap-3 mt-8">
          <button
            class="text-sm transition-colors"
            :class="billing === 'monthly' ? 'text-white' : 'text-gray-500'"
            @click="billing = 'monthly'"
          >Monthly</button>
          <button
            class="relative w-12 h-6 rounded-full transition-colors"
            :class="billing === 'annual' ? 'bg-[#E8552A]' : 'bg-white/10'"
            @click="billing = billing === 'annual' ? 'monthly' : 'annual'"
          >
            <span
              class="absolute top-1 left-1 w-4 h-4 rounded-full bg-white transition-transform"
              :class="billing === 'annual' ? 'translate-x-6' : 'translate-x-0'"
            />
          </button>
          <button
            class="text-sm transition-colors flex items-center gap-1.5"
            :class="billing === 'annual' ? 'text-white' : 'text-gray-500'"
            @click="billing = 'annual'"
          >
            Annual
            <span class="text-[10px] bg-green-500/20 text-green-400 px-1.5 py-0.5 rounded-sm tracking-wide">
              SAVE 20%
            </span>
          </button>
        </div>
      </div>
    </div>

    <!-- Pricing cards -->
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-12">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 items-start">

        <div
          v-for="plan in plans"
          :key="plan.id"
          class="relative rounded-sm border p-6 transition-all"
          :class="[plan.accent, plan.isCurrent ? 'bg-white/[0.04]' : 'bg-white/[0.02]']"
        >
          <!-- Badge -->
          <div
            v-if="plan.badge"
            class="absolute -top-3 left-1/2 -translate-x-1/2 text-[10px] tracking-[0.2em] uppercase px-3 py-1 rounded-sm font-medium whitespace-nowrap"
            :style="{ backgroundColor: plan.color + '22', color: plan.color, border: `1px solid ${plan.color}44` }"
          >{{ plan.badge }}</div>

          <!-- Current plan indicator -->
          <div v-if="plan.isCurrent" class="text-[9px] tracking-[0.25em] uppercase text-green-400 mb-3">
            ✓ Current Plan
          </div>

          <!-- Plan name & price -->
          <p class="text-white font-medium text-lg mb-1" :style="{ color: plan.color === '#6b7280' ? 'white' : plan.color }">
            {{ plan.name }}
          </p>
          <div class="flex items-baseline gap-1 mb-1">
            <span class="text-3xl font-bold text-white">{{ fmtPrice(plan) }}</span>
            <span v-if="plan.price[billing] > 0" class="text-gray-500 text-sm">
              / {{ billing === 'annual' ? 'mo · billed annually' : 'month' }}
            </span>
          </div>
          <p v-if="billing === 'annual' && plan.price.annual > 0" class="text-[11px] text-gray-600 mb-4">
            €{{ (plan.price.annual * 12).toFixed(0) }} per year
          </p>
          <div v-else class="mb-4"></div>

          <!-- CTA button -->
          <button
            class="w-full py-2.5 text-[11px] tracking-[0.2em] uppercase font-medium transition-all mb-6 rounded-sm relative overflow-hidden"
            :class="plan.btn"
            :disabled="!!upgrading"
            @click="handleCta(plan)"
          >
            <span v-if="upgrading === plan.id" class="flex items-center justify-center gap-2">
              <svg class="animate-spin w-3.5 h-3.5" viewBox="0 0 24 24" fill="none">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"/>
              </svg>
              Processing…
            </span>
            <span v-else-if="plan.isCurrent">
              {{ plan.id === 'explorer' ? 'Explore Market' : 'Manage Plan' }}
            </span>
            <span v-else-if="plan.id === 'explorer'">Get Started Free</span>
            <span v-else>Upgrade to {{ plan.name }}</span>
          </button>

          <!-- Features list -->
          <ul class="space-y-2.5">
            <li
              v-for="feat in plan.features"
              :key="feat.text"
              class="flex items-start gap-2.5 text-[12px] leading-snug"
              :class="feat.ok ? 'text-gray-300' : 'text-gray-600'"
            >
              <span class="flex-shrink-0 mt-px text-[11px]">
                {{ feat.ok ? '✓' : '—' }}
              </span>
              {{ feat.text }}
            </li>
          </ul>
        </div>

      </div>
    </div>

    <!-- Success toast -->
    <Transition name="fade">
      <div
        v-if="upgradeMsg"
        class="fixed bottom-8 left-1/2 -translate-x-1/2 bg-green-500/20 border border-green-500/40 text-green-400 px-6 py-3 rounded-sm text-sm flex items-center gap-2.5 z-50"
      >
        <span class="text-base">✓</span>
        Upgraded to <strong>{{ upgradeMsg }}</strong>! Redirecting to your account…
      </div>
    </Transition>

    <!-- FAQ -->
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-12 border-t border-white/[0.06]">
      <p class="text-[10px] tracking-[0.3em] uppercase text-gray-600 mb-8 text-center">Common Questions</p>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-3xl mx-auto">
        <div v-for="faq in [
          { q: 'What is the AI Trading Agent?',
            a: 'The agent monitors real-time artwork prices via our VMM engine and executes trades automatically based on your chosen strategy — momentum, mean-reversion, or grid.' },
          { q: 'What is the Lobster interface?',
            a: 'Institutional subscribers can plug in their own AI model (OpenAI, Anthropic, or any OpenAI-compatible API). The agent receives live market data and your portfolio state, then fires buy/sell orders.' },
          { q: 'Can I cancel anytime?',
            a: 'Yes. Your subscription is month-to-month. Downgrade to Explorer at any time and retain access until the end of your billing period.' },
          { q: 'Is the default AI secure?',
            a: 'ArtEx uses DeepSeek as its default model. Your API key is stored server-side and never exposed to the browser.' },
        ]" :key="faq.q" class="space-y-2">
          <p class="text-white text-sm font-medium">{{ faq.q }}</p>
          <p class="text-gray-500 text-[12px] leading-relaxed font-light">{{ faq.a }}</p>
        </div>
      </div>
    </div>

  </div>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.3s, transform 0.3s; }
.fade-enter-from, .fade-leave-to { opacity: 0; transform: translate(-50%, 1rem); }
</style>

<script setup>
import { ref, computed } from 'vue'
import { useWalletStore, WALLETS } from '@/stores/wallet'

const emit = defineEmits(['close'])

const wallet = useWalletStore()

const step       = ref('choose')   // 'choose' | 'connecting' | 'qr' | 'error_notinstalled' | 'success'
const activeId   = ref(null)
const errorCode  = ref(null)

const activeWalletDef = computed(() => WALLETS.find(w => w.id === activeId.value))

async function tryConnect(walletId) {
  activeId.value = walletId
  step.value     = 'connecting'

  const result = await wallet.connect(walletId)

  if (result.ok) {
    step.value = 'success'
    setTimeout(() => emit('close'), 1200)
    return
  }

  if (result.code === 'not_installed') { step.value = 'error_notinstalled'; return }
  if (result.code === 'show_qr')       { step.value = 'qr';                 return }
  if (result.code === 'rejected')      { step.value = 'choose'; return }

  errorCode.value = result.msg
  step.value = 'choose'
}

function back() { step.value = 'choose'; activeId.value = null; errorCode.value = null }

// Chain labels
const CHAIN_LABELS = { ETH: 'Ethereum', SOL: 'Solana', Multi: 'Multi-chain' }
</script>

<template>
  <!-- Backdrop -->
  <div class="fixed inset-0 z-[9000] bg-black/70 backdrop-blur-sm flex items-center justify-center p-4" @click.self="$emit('close')">

    <div class="bg-[#111116] border border-white/[0.1] w-full max-w-md shadow-2xl">

      <!-- Header -->
      <div class="flex items-center justify-between px-6 py-5 border-b border-white/[0.07]">
        <div>
          <p class="text-[10px] tracking-[0.25em] uppercase text-[#E8552A] font-light mb-0.5">
            {{ step === 'success' ? 'Connected' : 'Connect Wallet' }}
          </p>
          <p class="text-white font-display italic text-lg leading-tight">
            {{ step === 'choose' ? 'Choose your wallet'
             : step === 'connecting' ? 'Connecting…'
             : step === 'qr' ? 'Scan with your wallet'
             : step === 'error_notinstalled' ? 'Wallet not installed'
             : step === 'success' ? wallet.shortAddress
             : 'Connect Wallet' }}
          </p>
        </div>
        <button class="text-gray-600 hover:text-white transition-colors" @click="$emit('close')">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18 18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>

      <!-- Body -->
      <div class="px-6 py-5">

        <!-- ── Choose wallet ── -->
        <div v-if="step === 'choose'" class="space-y-2">
          <button
            v-for="w in WALLETS"
            :key="w.id"
            class="w-full flex items-center gap-4 p-3.5 border border-white/[0.07] hover:border-white/20 hover:bg-white/[0.03] transition-all group text-left"
            @click="tryConnect(w.id)"
          >
            <!-- Wallet icon -->
            <span
              class="w-9 h-9 flex-shrink-0 flex items-center justify-center text-[11px] font-bold tracking-wide"
              :style="{ backgroundColor: w.color + '22', color: w.color, border: `1px solid ${w.color}44` }"
            >{{ w.name.slice(0, 2).toUpperCase() }}</span>

            <div class="flex-1 min-w-0">
              <p class="text-white text-sm font-medium">{{ w.name }}</p>
              <p class="text-gray-500 text-[11px] font-light">{{ w.description }}</p>
            </div>

            <div class="flex items-center gap-2 flex-shrink-0">
              <!-- Installed badge -->
              <span
                v-if="wallet.isInstalled(w.id)"
                class="text-[9px] tracking-[0.1em] uppercase px-1.5 py-0.5 bg-green-500/10 text-green-500 border border-green-500/20"
              >Installed</span>
              <span class="text-[10px] tracking-[0.1em] uppercase text-gray-600">{{ CHAIN_LABELS[w.chain] }}</span>
              <svg class="w-3.5 h-3.5 text-gray-700 group-hover:text-gray-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
              </svg>
            </div>
          </button>

          <p class="text-[11px] text-gray-700 text-center pt-2 font-light leading-relaxed">
            By connecting, you agree to our Terms of Service.<br/>This platform simulates transactions for demo purposes.
          </p>
        </div>

        <!-- ── Connecting spinner ── -->
        <div v-else-if="step === 'connecting'" class="py-8 text-center">
          <div class="w-14 h-14 border-2 border-white/10 border-t-[#E8552A] rounded-full animate-spin mx-auto mb-5" />
          <p class="text-white text-sm font-light mb-1">Requesting access from</p>
          <p class="font-display italic text-lg text-white">{{ activeWalletDef?.name }}</p>
          <p class="text-gray-600 text-[11px] mt-3 font-light">Approve the connection in your wallet extension</p>
        </div>

        <!-- ── WalletConnect QR ── -->
        <div v-else-if="step === 'qr'" class="py-4 text-center">
          <!-- Fake QR grid -->
          <div class="w-44 h-44 mx-auto bg-white p-3 mb-5">
            <div class="w-full h-full grid grid-cols-8 gap-px">
              <div
                v-for="i in 64" :key="i"
                :class="[i % 3 === 0 || i % 7 === 0 || i % 11 === 0 ? 'bg-black' : 'bg-white']"
              />
            </div>
          </div>
          <p class="text-white text-sm font-light mb-1">Scan with WalletConnect</p>
          <p class="text-gray-500 text-[11px] font-light mb-4">Open any WalletConnect-compatible app and scan this QR code</p>
          <p class="text-[10px] text-amber-500/80 font-light">WalletConnect SDK integration coming soon — this QR is a placeholder</p>
          <button class="mt-4 text-[11px] tracking-[0.15em] uppercase text-gray-500 hover:text-white transition-colors" @click="back">Back</button>
        </div>

        <!-- ── Not installed ── -->
        <div v-else-if="step === 'error_notinstalled'" class="py-6 text-center">
          <div
            class="w-14 h-14 mx-auto mb-5 flex items-center justify-center text-lg font-bold"
            :style="{ backgroundColor: (activeWalletDef?.color ?? '#888') + '22', color: activeWalletDef?.color ?? '#888', border: `1px solid ${activeWalletDef?.color ?? '#888'}44` }"
          >{{ activeWalletDef?.name.slice(0, 2).toUpperCase() }}</div>
          <p class="text-white font-medium mb-2">{{ activeWalletDef?.name }} not detected</p>
          <p class="text-gray-500 text-[11px] font-light mb-5 leading-relaxed">
            Install the browser extension or mobile app to continue.
          </p>
          <a
            v-if="activeWalletDef?.installUrl"
            :href="activeWalletDef.installUrl"
            target="_blank"
            rel="noopener"
            class="inline-block btn-primary text-[11px] px-6 py-2 mb-3"
          >Install {{ activeWalletDef?.name }}</a>
          <br/>
          <button class="text-[11px] tracking-[0.15em] uppercase text-gray-500 hover:text-white transition-colors" @click="back">Choose another wallet</button>
        </div>

        <!-- ── Success ── -->
        <div v-else-if="step === 'success'" class="py-8 text-center">
          <div class="w-14 h-14 border-2 border-green-500 rounded-full flex items-center justify-center mx-auto mb-5">
            <svg class="w-6 h-6 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
            </svg>
          </div>
          <p class="text-green-400 font-medium mb-1">Wallet connected</p>
          <p class="font-mono text-gray-400 text-sm">{{ wallet.shortAddress }}</p>
          <p v-if="wallet.balanceEth" class="text-[11px] text-gray-600 mt-1">Balance: {{ wallet.balanceEth }} ETH</p>
        </div>

      </div>
    </div>
  </div>
</template>

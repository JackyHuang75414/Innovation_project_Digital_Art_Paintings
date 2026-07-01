<template>
  <footer class="bg-[#070709] border-t border-white/[0.06] text-gray-500 mt-auto">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-14 grid grid-cols-2 md:grid-cols-4 gap-10">

      <!-- Brand -->
      <div class="col-span-2 md:col-span-1">
        <div class="flex items-center gap-2.5 mb-4">
          <img src="/logo.gif" alt="ArtEx" class="h-10 w-10 object-cover rounded-full mix-blend-lighten flex-shrink-0" />
          <p class="font-display italic text-white text-xl font-normal">ArtEx</p>
        </div>
        <p class="text-sm leading-relaxed font-light">
          Fractional art trading powered by crypto. Perpetual futures. AI automation.
        </p>
      </div>

      <!-- Trade -->
      <div>
        <p class="text-[10px] tracking-[0.3em] uppercase text-gray-500 font-light mb-5">Trade</p>
        <ul class="space-y-3 text-sm font-light">
          <li><a href="/market"    class="hover:text-white transition-colors">Market</a></li>
          <li><a href="/market"    class="hover:text-white transition-colors">Discover Works</a></li>
          <li><a href="/account"   class="hover:text-white transition-colors">Portfolio</a></li>
          <li><a href="/checkout"  class="hover:text-white transition-colors">Checkout</a></li>
        </ul>
      </div>

      <!-- Platform -->
      <div>
        <p class="text-[10px] tracking-[0.3em] uppercase text-gray-500 font-light mb-5">Platform</p>
        <ul class="space-y-3 text-sm font-light">
          <li><a href="#" class="hover:text-white transition-colors">Fractional Shares</a></li>
          <li><a href="#" class="hover:text-white transition-colors">Perpetual Futures</a></li>
          <li><a href="#" class="hover:text-white transition-colors">AI Trading Agents</a></li>
          <li><a href="#" class="hover:text-white transition-colors">VMM Liquidity</a></li>
        </ul>
      </div>

      <!-- Legal -->
      <div>
        <p class="text-[10px] tracking-[0.3em] uppercase text-gray-500 font-light mb-5">Legal</p>
        <ul class="space-y-3 text-sm font-light">
          <li><a href="#" class="hover:text-white transition-colors">Risk Disclaimer</a></li>
          <li><a href="#" class="hover:text-white transition-colors">Privacy Policy</a></li>
          <li><a href="#" class="hover:text-white transition-colors">Terms of Service</a></li>
        </ul>
        <p class="text-[10px] text-gray-700 mt-5 leading-relaxed">
          All trading is simulated. This platform does not facilitate real financial transactions.
        </p>
      </div>
    </div>

    <!-- Sustainability banner -->
    <div class="border-t border-green-500/10 bg-green-500/[0.03]">
      <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-4 flex flex-col sm:flex-row items-center justify-between gap-3">
        <div class="flex items-center gap-3">
          <span class="w-1.5 h-1.5 rounded-full bg-green-500 animate-pulse flex-shrink-0" />
          <p class="text-[11px] text-green-600 font-light tracking-wide">
            ArtEx is committed to zero Proof-of-Work transactions and 100% renewable energy hosting.
          </p>
        </div>
        <a
          href="/sustainability"
          class="text-[10px] tracking-[0.2em] uppercase text-green-500 hover:text-green-300 transition-colors font-medium flex-shrink-0 flex items-center gap-1.5"
        >
          Our Environmental Commitments
          <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
          </svg>
        </a>
      </div>
    </div>

    <div class="border-t border-white/[0.04]">
      <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-5 flex flex-col sm:flex-row items-center justify-between gap-3">
        <p class="text-[10px] tracking-[0.2em] uppercase font-light">© 2025 ArtEx — EFREI Innovation Project</p>
        <p class="text-[10px] tracking-[0.2em] uppercase font-light">Vue 3 · Tailwind · DeepSeek AI · VMM</p>
      </div>
    </div>
  </footer>
</template>

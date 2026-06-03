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
          <li><a href="/browse"    class="hover:text-white transition-colors">Discover Works</a></li>
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

    <div class="border-t border-white/[0.04]">
      <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-5 flex flex-col sm:flex-row items-center justify-between gap-3">
        <p class="text-[10px] tracking-[0.2em] uppercase font-light">© 2025 ArtEx — EFREI Innovation Project</p>
        <p class="text-[10px] tracking-[0.2em] uppercase font-light">Vue 3 · Tailwind · DeepSeek AI · VMM</p>
      </div>
    </div>
  </footer>
</template>

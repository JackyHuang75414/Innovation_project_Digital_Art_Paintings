<template>
  <footer class="bg-gray-950 text-gray-500 mt-auto">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-14 lg:py-16 grid grid-cols-2 md:grid-cols-4 gap-10">

      <!-- Brand -->
      <div class="col-span-2 md:col-span-1">
        <p class="font-display italic text-white text-xl font-normal mb-4">ArtCanvas</p>
        <p class="text-sm leading-relaxed font-light">
          Discover and own unique digital art from independent artists worldwide.
        </p>
      </div>

      <!-- Browse -->
      <div>
        <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-5">Browse</p>
        <ul class="space-y-3 text-sm font-light">
          <li><a href="/browse?category=paintings"   class="hover:text-white transition-colors">Paintings</a></li>
          <li><a href="/browse?category=photography" class="hover:text-white transition-colors">Photography</a></li>
          <li><a href="/browse?category=prints"      class="hover:text-white transition-colors">Prints</a></li>
          <li><a href="/browse?category=digital"     class="hover:text-white transition-colors">Digital Art</a></li>
        </ul>
      </div>

      <!-- Help -->
      <div>
        <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-5">Help</p>
        <ul class="space-y-3 text-sm font-light">
          <li><a href="#" class="hover:text-white transition-colors">Shipping &amp; Returns</a></li>
          <li><a href="#" class="hover:text-white transition-colors">Print Quality</a></li>
          <li><a href="#" class="hover:text-white transition-colors">Artist FAQ</a></li>
          <li><a href="#" class="hover:text-white transition-colors">Contact Us</a></li>
        </ul>
      </div>

      <!-- Promise -->
      <div>
        <p class="text-[10px] tracking-[0.3em] uppercase text-gray-400 font-light mb-5">Our Promise</p>
        <ul class="space-y-3 text-sm font-light">
          <li>Secure checkout</li>
          <li>Free returns</li>
          <li>Authenticity guaranteed</li>
          <li>Print-on-demand</li>
        </ul>
      </div>
    </div>

    <!-- Bottom bar -->
    <div class="border-t border-gray-800">
      <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-5 flex flex-col sm:flex-row items-center justify-between gap-3">
        <p class="text-[10px] tracking-[0.2em] uppercase font-light">
          © 2025 ArtCanvas — EFREI Innovation Project
        </p>
        <p class="text-[10px] tracking-[0.2em] uppercase font-light">
          Built with Vue 3 · Tailwind CSS · Dify AI
        </p>
      </div>
    </div>
  </footer>
</template>

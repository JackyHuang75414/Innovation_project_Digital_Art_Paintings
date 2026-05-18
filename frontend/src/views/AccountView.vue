<template>
  <!-- Page header -->
  <div class="bg-[#F7F4F0] border-b border-[#E0D8CE]">
    <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-10 lg:py-14">
      <p class="text-[10px] tracking-[0.35em] uppercase text-[#E8552A] mb-3 font-light">Member</p>
      <h1 class="font-display text-3xl lg:text-[2.75rem] font-normal italic text-gray-900 leading-tight">
        My Account
      </h1>
    </div>
  </div>

  <div class="max-w-screen-xl mx-auto px-6 lg:px-16 py-24 lg:py-32 text-center">
    <svg class="w-10 h-10 text-gray-200 mx-auto mb-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1"
        d="M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/>
    </svg>
    <p class="font-display italic text-2xl text-gray-400 mb-3">Coming Soon</p>
    <p class="text-sm text-gray-400 font-light mb-10 max-w-xs mx-auto leading-relaxed">
      Account management, order history, and wishlists will be available shortly.
    </p>
    <RouterLink to="/browse" class="btn-primary">Back to Browse</RouterLink>
  </div>
</template>

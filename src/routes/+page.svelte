<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import type { Session } from '@supabase/supabase-js';

  type PublicWishlistItem = {
    id: number;
    name: string;
    description: string | null;
    status: string;
    categoryName: string;
  };

  export let data: {
    session: Session | null;
    wishlist: PublicWishlistItem[];
    openWishlistCount: number;
    loadError: string | null;
  };

  let boxes: Array<{ id: number; x: number; y: number; delay: number; duration: number }> = [];

  onMount(async () => {
    boxes = Array.from({ length: 12 }, (_, index) => ({
      id: index,
      x: Math.random() * 90,
      y: Math.random() * 90,
      delay: Math.random() * 5,
      duration: 6 + Math.random() * 4
    }));

    if (data.session) {
      goto('/dashboard');
    }
  });
</script>

<div class="landing-container min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-violet-100 px-4 py-8 sm:px-6 lg:px-8">
  <div class="background">
    {#each boxes as box (box.id)}
      <div
        class="box-wrapper"
        style={`left: ${box.x}%; top: ${box.y}%; animation-delay: ${box.delay}s; animation-duration: ${box.duration}s;`}
      >
        <svg class="delivery-box" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
          <rect class="box-base" x="20" y="40" width="60" height="40" rx="4" fill="#D2B48C" stroke="#8B4513" stroke-width="3" />
          <path class="flap-left" d="M20 40 L50 40 L45 25 L15 25 Z" fill="#C4A484" stroke="#8B4513" stroke-width="2" />
          <path class="flap-right" d="M50 40 L80 40 L85 25 L55 25 Z" fill="#C4A484" stroke="#8B4513" stroke-width="2" />
          <rect x="35" y="55" width="15" height="10" rx="1" fill="#fff" opacity="0.8" />
        </svg>
      </div>
    {/each}
  </div>

  <div class="relative z-10 mx-auto grid w-full max-w-6xl gap-8 lg:grid-cols-[1.1fr_1fr] lg:items-start">
    <section class="rounded-2xl bg-white/80 p-8 shadow-xl backdrop-blur">
      <p class="mb-3 inline-flex rounded-full bg-indigo-100 px-3 py-1 text-sm font-semibold text-indigo-700">Community Wishlist</p>
      <h1 class="mb-4 text-4xl font-bold leading-tight text-gray-900 sm:text-5xl">Turn generosity into real impact today</h1>
      <p class="mb-6 text-lg text-gray-600">Browse the most urgent wishlist requests and help families receive essentials faster.</p>

      <div class="mb-8 grid gap-3 sm:grid-cols-2">
        <div class="rounded-xl border border-indigo-100 bg-indigo-50 p-4">
          <p class="text-sm font-medium text-indigo-700">Open Requests</p>
          <p class="mt-1 text-2xl font-bold text-indigo-900">{data.openWishlistCount}</p>
        </div>
        <div class="rounded-xl border border-emerald-100 bg-emerald-50 p-4">
          <p class="text-sm font-medium text-emerald-700">Every Item Helps</p>
          <p class="mt-1 text-2xl font-bold text-emerald-900">Make a Difference</p>
        </div>
      </div>

      <div class="flex flex-wrap gap-3">
        <a href="/wishlist/public" class="rounded-lg bg-blue-600 px-6 py-3 font-semibold text-white transition hover:bg-blue-700">View Full Wishlist</a>
        <a href="/signup" class="rounded-lg border-2 border-blue-600 px-6 py-3 font-semibold text-blue-600 transition hover:bg-blue-50">Sign Up</a>
        <a href="/sign-in" class="rounded-lg border border-gray-300 px-6 py-3 font-semibold text-gray-700 transition hover:bg-gray-100">Sign In</a>
      </div>
    </section>

    <section class="rounded-2xl bg-white/85 p-6 shadow-xl backdrop-blur sm:p-8">
      <div class="mb-5 flex items-center justify-between">
        <h2 class="text-xl font-bold text-gray-900">Urgent Wishlist Items</h2>
        <a href="/wishlist/public" class="text-sm font-semibold text-blue-700 hover:text-blue-800">See all</a>
      </div>

      {#if data.loadError}
        <p class="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">Unable to load wishlist right now. Please try again shortly.</p>
      {:else if data.wishlist.length === 0}
        <p class="rounded-lg border border-gray-200 bg-gray-50 px-4 py-3 text-sm text-gray-600">No active requests at the moment. Please check back soon.</p>
      {:else}
        <ul class="space-y-3">
          {#each data.wishlist as item}
            <li class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm transition hover:shadow-md">
              <div class="mb-2">
                <h3 class="font-semibold text-gray-900">{item.name}</h3>
              </div>
              <p class="mb-2 text-sm font-medium text-indigo-700">{item.categoryName}</p>
              {#if item.description}
                <p class="text-sm text-gray-600">{item.description}</p>
              {/if}
            </li>
          {/each}
        </ul>
      {/if}
    </section>
  </div>

  <div class="relative z-10 mx-auto mt-8 w-full max-w-6xl rounded-2xl border border-blue-100 bg-blue-600/90 p-6 text-center text-white shadow-lg">
    <h2 class="text-2xl font-bold">Your donation can change someone’s week</h2>
    <p class="mt-2 text-blue-100">Choose an item from the wishlist and support needs that are active right now.</p>
    <div class="mt-4">
      <a href="/wishlist/public" class="inline-flex rounded-lg bg-white px-6 py-3 font-semibold text-blue-700 transition hover:bg-blue-50">Donate from Wishlist</a>
    </div>
  </div>
</div>

<style>
  .landing-container {
    position: relative;
    overflow: hidden;
  }

  .background {
    position: absolute;
    inset: 0;
    z-index: 1;
    pointer-events: none;
  }

  .box-wrapper {
    position: absolute;
    width: 80px;
    height: 80px;
    opacity: 0;
    animation: float-and-unpack infinite linear;
  }

  @keyframes float-and-unpack {
    0% {
      transform: translateY(100vh) rotate(0deg);
      opacity: 0;
    }

    10% {
      opacity: 1;
    }

    40% {
      transform: translateY(40vh) rotate(10deg);
    }

    50% {
      transform: translateY(40vh) scale(1.2);
    }

    80% {
      transform: translateY(-20vh) rotate(-10deg);
      opacity: 1;
    }

    100% {
      transform: translateY(-30vh) rotate(-20deg);
      opacity: 0;
    }
  }

  .flap-left,
  .flap-right {
    transition: transform 0.5s ease;
    transform-origin: center bottom;
  }

  .box-wrapper:nth-child(even) .flap-left {
    animation: open-flap 6s infinite ease-in-out;
  }

  @keyframes open-flap {
    0%,
    45% {
      transform: rotateX(0deg);
    }

    55%,
    100% {
      transform: rotateX(-110deg);
    }
  }
</style>

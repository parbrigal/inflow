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

<div class="landing-container flex min-h-screen items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 px-4 py-10">
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

  <div class="relative z-10 mx-auto w-full max-w-5xl space-y-8">
    <section class="rounded-3xl bg-white/85 p-8 text-center shadow-xl backdrop-blur sm:p-10">
      <h1 class="mb-4 text-5xl font-bold text-gray-900">Welcome to Inflow</h1>
      <p class="mx-auto mb-7 max-w-2xl text-xl text-gray-600">Your personal donation management platform for supporting community needs in real time.</p>

      <div class="mb-7 flex flex-wrap justify-center gap-4">
        <a href="/sign-in" class="rounded-lg bg-blue-600 px-6 py-3 font-semibold text-white transition hover:bg-blue-700">Sign In</a>
        <a href="/signup" class="rounded-lg border-2 border-blue-600 px-6 py-3 font-semibold text-blue-600 transition hover:bg-blue-50">Sign Up</a>
      </div>

      <div class="inline-flex items-center gap-2 rounded-full bg-indigo-50 px-4 py-2 text-sm font-medium text-indigo-700">
        <span class="h-2.5 w-2.5 rounded-full bg-indigo-500"></span>
        {data.openWishlistCount} open wishlist requests
      </div>
    </section>

    <section class="rounded-3xl bg-white/90 p-6 shadow-xl backdrop-blur sm:p-8">
      <div class="mb-5 flex items-center justify-between gap-4">
        <h2 class="text-xl font-bold text-gray-900">Current Wishlist Requests</h2>
        <a href="/wishlist/public" class="rounded-md border border-blue-200 px-3 py-1.5 text-sm font-semibold text-blue-700 transition hover:bg-blue-50">View Full Wishlist</a>
      </div>

      {#if data.loadError}
        <p class="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">Unable to load wishlist right now. Please try again shortly.</p>
      {:else if data.wishlist.length === 0}
        <p class="rounded-lg border border-gray-200 bg-gray-50 px-4 py-3 text-sm text-gray-600">No active requests at the moment. Please check back soon.</p>
      {:else}
        <ul class="grid gap-3 md:grid-cols-2">
          {#each data.wishlist as item}
            <li class="rounded-xl border border-gray-200 bg-white p-4 shadow-sm transition hover:shadow-md">
              <h3 class="font-semibold text-gray-900">{item.name}</h3>
              <p class="mt-1 text-sm font-medium text-indigo-700">{item.categoryName}</p>
              {#if item.description}
                <p class="mt-2 text-sm text-gray-600">{item.description}</p>
              {/if}
            </li>
          {/each}
        </ul>
      {/if}
    </section>
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

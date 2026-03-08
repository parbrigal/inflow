<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { derived } from 'svelte/store';
  import type { Session } from '@supabase/supabase-js';
  import { Home } from 'lucide-svelte';
  export let session: Session | null = null;
  export let signOut: () => Promise<void> = async () => {};

  let sidebarOpen = false;
  let showFooter = true;

  const breadcrumbs = derived(page, ($page) => {
    const parts = $page.url.pathname.split('/').filter(Boolean);
    const crumbs = [{ name: 'Home', href: '/' }];
    let path = '';
    parts.forEach((part) => {
      path += '/' + part;
      crumbs.push({ name: part.charAt(0).toUpperCase() + part.slice(1), href: path });
    });
    return crumbs;
  });

  function toggleSidebar() {
    sidebarOpen = !sidebarOpen;
  }

  function closeSidebar() {
    sidebarOpen = false;
  }
</script>

<div class="flex h-screen bg-gray-50">
  <!-- sidebar -->
  <aside class={`fixed inset-y-0 z-20 w-64 transform bg-white shadow-lg transition-transform duration-300 lg:relative lg:translate-x-0 ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
    <div class="flex h-full flex-col justify-between">
      <nav class="p-4">
        <a href="/" class="flex items-center rounded px-3 py-2 text-gray-500 hover:bg-gray-100 bg-gray-50" on:click={closeSidebar}>
          <Home class="h-4 w-4 mr-2" />
          <span>Home</span>
        </a>
        <a href="/dashboard" class="mt-1 block rounded px-3 py-2 text-gray-700 hover:bg-gray-100" on:click={closeSidebar}>Dashboard</a>
        <a href="/items/list" class="mt-1 block rounded px-3 py-2 text-gray-700 hover:bg-gray-100" on:click={closeSidebar}>Inventory</a>
        <a href="/items" class="mt-1 block rounded px-3 py-2 text-gray-700 hover:bg-gray-100" on:click={closeSidebar}>Items</a>
        <a href="/donations" class="mt-1 block rounded px-3 py-2 text-gray-700 hover:bg-gray-100" on:click={closeSidebar}>Donations</a>
        <a href="/settings" class="mt-1 block rounded px-3 py-2 text-gray-700 hover:bg-gray-100" on:click={closeSidebar}>Settings</a>
      </nav>
      <div class="border-t p-4">
        {#if session}
        <div class="flex items-center">
          <div class="flex items-center">
            <img src="https://robohash.org/pixel-cat-1?set=set4&size=32x32" alt="avatar" class="h-8 w-8 rounded-full" />
            <div class="ml-3">
              <p class="text-sm font-semibold text-gray-800">{session.user.email}</p>
              <a href="/profile" class="mt-1 block text-xs text-blue-600 hover:underline">View profile</a>
              <button class="mt-1 block text-xs text-red-600 hover:underline" on:click={signOut}>Sign out</button>
            </div>
          </div>
        </div>
        {:else}
        <div class="text-center">
          <a href="/sign-in" class="rounded bg-blue-600 px-4 py-2 text-white">Sign in</a>
        </div>
        {/if}
      </div>
    </div>
  </aside>

  <!-- mobile overlay -->
  {#if sidebarOpen}
    <div class="fixed inset-0 z-10 bg-black bg-opacity-50 lg:hidden" on:click={closeSidebar} on:keydown={(e) => {if (e.key === 'Enter' || e.key === ' ') closeSidebar();}} role="button" tabindex="0" aria-label="Close sidebar" ></div>
  {/if}

  <!-- content area -->
  <div class="flex flex-1 flex-col">
    <!-- header -->
    <header class="flex items-center justify-between border-b bg-white p-4 shadow-sm">
      <button class="lg:hidden" on:click={toggleSidebar} aria-label="Open sidebar">
        <svg class="h-6 w-6 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>
      <nav class="text-sm" aria-label="Breadcrumb">
        {#each $breadcrumbs as crumb, i}
          {#if i > 0} <span class="mx-1 text-gray-400">/</span> {/if}
          <a href={crumb.href} class="text-gray-600 hover:underline">{crumb.name}</a>
        {/each}
      </nav>
      <div></div>
    </header>

    <main class={`flex-1 overflow-auto bg-gray-50 px-6 py-4 ${showFooter ? 'pb-28' : 'pb-4'}`}>
      <slot />
    </main>

    <!-- funky under construction footer -->
    {#if showFooter}
      <footer class="fixed bottom-0 left-0 right-0 z-10 bg-gradient-to-r from-purple-500 via-pink-500 to-orange-400 px-6 py-4 text-white shadow-lg lg:left-64">
        <div class="flex items-start justify-between gap-2">
          <div class="flex-1">
            <div class="flex items-center justify-center gap-2 text-center">
              <span class="text-lg">🚀</span>
              <p class="text-sm font-bold">We're cooking up something amazing! But it's not quite done baking.</p>
              <span class="text-lg">✨</span>
            </div>
            <p class="mt-1 text-center text-xs opacity-90">This app is under construction • Check back soon!</p>
          </div>
          <button
            type="button"
            class="shrink-0 rounded px-2 text-white hover:bg-white/20"
            aria-label="Close footer"
            on:click={() => (showFooter = false)}
          >
            ×
          </button>
        </div>
      </footer>
    {/if}
  </div>
</div>

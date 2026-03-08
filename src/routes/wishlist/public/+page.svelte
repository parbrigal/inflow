<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import { ArrowLeft, Search } from 'lucide-svelte';

  interface WishlistRequest {
    id: number;
    category_id: number | null;
    name: string;
    description: string | null;
    status: string;
    requested_by: string;
    created_at: string;
    updated_at: string;
    categories?: { name: string } | null;
  }

  let requests: WishlistRequest[] = [];
  let categories: Array<{ id: number; name: string }> = [];
  let loading = true;
  let error: string | null = null;
  let searchTerm = '';
  let selectedCategoryFilter: number | null = null;

  $: filteredRequests = requests.filter((request) => {
    const matchesSearch = request.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategoryFilter === null || request.category_id === selectedCategoryFilter;
    return matchesSearch && matchesCategory;
  });

  async function loadRequests() {
    loading = true;
    const { data, error: fetchError } = await supabase.from('requests').select('*, categories(name)').order('created_at', { ascending: false });

    if (fetchError) {
      error = fetchError.message;
    } else {
      requests = (data as WishlistRequest[]) || [];
    }

    loading = false;
  }

  onMount(async () => {
    const catRes = await supabase.from('categories').select('id, name').order('name', { ascending: true });

    if (catRes.data) {
      categories = catRes.data as Array<{ id: number; name: string }>;
    }

    await loadRequests();
  });
</script>

<div class="mx-auto w-full max-w-5xl px-4 py-8 sm:px-6 lg:px-8">
  <div class="space-y-4">
    <a href="/" class="inline-flex items-center gap-2 rounded border border-gray-300 bg-white px-3 py-2 text-sm font-medium text-gray-700 transition hover:bg-gray-50">
      <ArrowLeft class="h-4 w-4" />
      Back to Home
    </a>

    <div class="space-y-2">
      <h1 class="text-3xl font-bold">Wishlist</h1>
      <p class="text-sm text-gray-600">Read-only public view</p>
    </div>

    <div class="flex flex-col gap-3 sm:flex-row">
      <div class="relative flex-1">
        <Search class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
        <input
          type="text"
          placeholder="Search wishlist..."
          bind:value={searchTerm}
          class="w-full rounded border border-gray-300 py-2 pl-10 pr-4 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
        />
      </div>
      <div class="w-full sm:w-64">
        <select
          bind:value={selectedCategoryFilter}
          class="w-full rounded border border-gray-300 py-2 px-4 focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
        >
          <option value={null}>All Categories</option>
          {#each categories as category}
            <option value={category.id}>{category.name}</option>
          {/each}
        </select>
      </div>
    </div>

    {#if loading}
      <p>Loading…</p>
    {:else if error}
      <p class="text-red-500">Error: {error}</p>
    {:else}
      <ul class="space-y-2">
        {#each filteredRequests as request}
          <li class="rounded bg-white p-4 shadow">
            <div>
              <h2 class="font-semibold">{request.name}</h2>
              {#if request.description}
                <p class="text-sm text-gray-500">{request.description}</p>
              {/if}
            </div>
            {#if request.categories}
              <span class="mt-2 inline-flex rounded bg-blue-100 px-3 py-1 text-sm text-blue-700">{request.categories.name}</span>
            {/if}
          </li>
        {/each}
      </ul>
    {/if}
  </div>
</div>

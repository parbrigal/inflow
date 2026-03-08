<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import { Edit, Search, Trash2 } from 'lucide-svelte';

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

  type EditableRequest = {
    category_id: number | null;
    name: string;
    description: string;
  };

  let requests: WishlistRequest[] = [];
  let categories: Array<{ id: number; name: string }> = [];
  let loading = true;
  let error: string | null = null;
  let toast: string | null = null;

  let currentUserId: string | null = null;
  let showAddModal = false;
  let editingRequestId: number | null = null;
  let searchTerm = '';
  let selectedCategoryFilter: number | null = null;
  let selectedRequestIds: number[] = [];

  let newRequest: EditableRequest = {
    category_id: null,
    name: '',
    description: ''
  };

  $: hasSelectedRequests = selectedRequestIds.length > 0;

  $: filteredRequests = requests.filter((request) => {
    const matchesSearch = request.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategoryFilter === null || request.category_id === selectedCategoryFilter;
    return matchesSearch && matchesCategory;
  });

  function resetForm() {
    newRequest = {
      category_id: null,
      name: '',
      description: ''
    };
    editingRequestId = null;
  }

  function openEditModal(request: WishlistRequest) {
    editingRequestId = request.id;
    newRequest = {
      category_id: request.category_id,
      name: request.name,
      description: request.description ?? ''
    };
    showAddModal = true;
  }

  function toggleRequestSelection(requestId: number, checked: boolean) {
    if (checked) {
      selectedRequestIds = [...new Set([...selectedRequestIds, requestId])];
    } else {
      selectedRequestIds = selectedRequestIds.filter((id) => id !== requestId);
    }
  }

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

  async function saveRequest() {
    if (!newRequest.name.trim()) {
      error = 'Name is required.';
      return;
    }

    if (!currentUserId && !editingRequestId) {
      error = 'You must be signed in to create wishlist requests.';
      return;
    }

    loading = true;
    error = null;

    const payload = {
      category_id: newRequest.category_id,
      name: newRequest.name.trim(),
      description: newRequest.description.trim() || null
    };

    if (editingRequestId) {
      const { error: updateError } = await supabase
        .from('requests')
        .update(payload)
        .eq('id', editingRequestId);

      if (updateError) {
        error = updateError.message;
      } else {
        showAddModal = false;
        resetForm();
        toast = 'Wishlist request updated successfully';
        setTimeout(() => (toast = null), 3000);
      }
    } else {
      const { error: insertError } = await supabase.from('requests').insert({
        ...payload,
        requested_by: currentUserId
      });

      if (insertError) {
        error = insertError.message;
      } else {
        showAddModal = false;
        resetForm();
        toast = 'Wishlist request added successfully';
        setTimeout(() => (toast = null), 3000);
      }
    }

    await loadRequests();
  }

  async function deleteRequest(request: WishlistRequest) {
    const { error: deleteError } = await supabase.from('requests').delete().eq('id', request.id);

    if (deleteError) {
      error = deleteError.message;
      return;
    }

    selectedRequestIds = selectedRequestIds.filter((id) => id !== request.id);
    await loadRequests();
    toast = 'Wishlist request deleted successfully';
    setTimeout(() => (toast = null), 3000);
  }

  async function deleteSelectedRequests() {
    if (!hasSelectedRequests) {
      return;
    }

    const { error: deleteError } = await supabase.from('requests').delete().in('id', selectedRequestIds);

    if (deleteError) {
      error = deleteError.message;
      return;
    }

    selectedRequestIds = [];
    await loadRequests();
    toast = 'Selected wishlist requests deleted successfully';
    setTimeout(() => (toast = null), 3000);
  }

  onMount(async () => {
    const [{ data: sessionData }, catRes] = await Promise.all([
      supabase.auth.getSession(),
      supabase.from('categories').select('id, name').order('name', { ascending: true })
    ]);

    if (sessionData.session?.user) {
      currentUserId = sessionData.session.user.id;
    }

    if (catRes.data) {
      categories = catRes.data as Array<{ id: number; name: string }>;
    }

    await loadRequests();
  });
</script>

<div class="space-y-4">
  <div class="space-y-3 sm:space-y-0 sm:flex sm:items-center sm:justify-between">
    <h1 class="text-3xl font-bold">Wishlist</h1>
    <div class="flex items-center gap-2">
      <button
        type="button"
        class="flex items-center gap-2 rounded bg-red-600 px-4 py-2 text-white hover:bg-red-700 disabled:cursor-not-allowed disabled:bg-gray-400"
        on:click={deleteSelectedRequests}
        disabled={!hasSelectedRequests}
      >
        <Trash2 class="h-4 w-4" />
        Delete Selected
      </button>
      <button
        type="button"
        class="rounded bg-green-600 px-4 py-2 text-white hover:bg-green-700"
        on:click={() => {
          resetForm();
          showAddModal = true;
        }}
      >
        + Add Wishlist Item
      </button>
    </div>
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

  {#if toast}
    <div class="fixed bottom-4 right-4 rounded bg-green-600 px-4 py-2 text-white shadow">
      {toast}
    </div>
  {/if}

  {#if loading}
    <p>Loading…</p>
  {:else if error}
    <p class="text-red-500">Error: {error}</p>
  {:else}
    <ul class="space-y-2">
      {#each filteredRequests as request}
        <li class="flex items-center rounded bg-white p-4 shadow">
          <div class="flex flex-1 items-center gap-3">
            <input
              type="checkbox"
              checked={selectedRequestIds.includes(request.id)}
              on:change={(event) => toggleRequestSelection(request.id, (event.currentTarget as HTMLInputElement).checked)}
              aria-label={`Select ${request.name}`}
            />
            <div>
              <h2 class="font-semibold">{request.name}</h2>
              {#if request.description}
                <p class="text-sm text-gray-500">{request.description}</p>
              {/if}
            </div>
            {#if request.categories}
              <span class="rounded bg-blue-100 px-3 py-1 text-sm text-blue-700">{request.categories.name}</span>
            {/if}
          </div>
          <div class="ml-2 flex items-center gap-1">
            <button
              type="button"
              class="rounded p-2 text-gray-600 hover:bg-gray-100 hover:text-gray-900"
              on:click={() => openEditModal(request)}
              aria-label="Edit request"
            >
              <Edit class="h-4 w-4" />
            </button>
            <button
              type="button"
              class="rounded p-2 text-red-600 hover:bg-red-50 hover:text-red-700"
              on:click={() => deleteRequest(request)}
              aria-label="Delete request"
            >
              <Trash2 class="h-4 w-4" />
            </button>
          </div>
        </li>
      {/each}
    </ul>
  {/if}
</div>

{#if showAddModal}
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
    <div class="w-full max-w-md rounded-lg bg-white p-6">
      <h3 class="mb-4 text-xl font-bold">{editingRequestId ? 'Edit Wishlist Item' : 'New Wishlist Item'}</h3>
      <form on:submit|preventDefault={saveRequest} class="space-y-4">
        <div>
          <label for="wishlist-category" class="block text-sm font-medium">Category</label>
          <select id="wishlist-category" bind:value={newRequest.category_id} class="mt-1 w-full rounded border p-2">
            <option value={null}>Select a category</option>
            {#each categories as category}
              <option value={category.id}>{category.name}</option>
            {/each}
          </select>
        </div>
        <div>
          <label for="wishlist-name" class="block text-sm font-medium">Name</label>
          <input id="wishlist-name" bind:value={newRequest.name} class="mt-1 w-full rounded border p-2" required />
        </div>
        <div>
          <label for="wishlist-description" class="block text-sm font-medium">Description</label>
          <textarea id="wishlist-description" bind:value={newRequest.description} class="mt-1 w-full rounded border p-2" rows="3"></textarea>
        </div>
        <div class="flex justify-end gap-2">
          <button
            type="button"
            class="px-4 py-2"
            on:click={() => {
              showAddModal = false;
              resetForm();
            }}
          >
            Cancel
          </button>
          <button type="submit" class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">
            {editingRequestId ? 'Update' : 'Save'}
          </button>
        </div>
      </form>
    </div>
  </div>
{/if}

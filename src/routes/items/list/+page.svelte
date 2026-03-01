<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import { Edit, Lock, Search, Trash2 } from 'lucide-svelte';

  interface Item {
    id: number;
    donation_id: number | null;
    category_id: number | null;
    name: string;
    description: string | null;
    quantity: number;
    status: string;
    created_by: string;
    created_at: string;
    updated_at: string;
    categories?: { name: string } | null;
  }

  let items: Item[] = [];
  let loading = true;
  let error: string | null = null;

  let donations: Array<{ id: number; name: string }> = [];
  let categories: Array<{ id: number; name: string }> = [];
  let showAddModal = false;
  let showLinkDonationModal = false;
  let editingItemId: number | null = null;
  let newItem: Partial<Item> = { name: '', quantity: 1, status: 'pending', donation_id: null, category_id: undefined };
  let toast: string | null = null;
  let currentUserId: string | null = null;
  let searchTerm: string = '';
  let selectedCategoryFilter: number | null = null;
  let selectedItemIds: number[] = [];
  let selectedDonationId: number | null = null;

  $: hasSelectedItems = selectedItemIds.length > 0;

  $: filteredItems = items.filter(item => {
    const matchesSearch = item.name.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory = selectedCategoryFilter === null || item.category_id === selectedCategoryFilter;
    return matchesSearch && matchesCategory;
  });

  async function addItem() {
    loading = true;
    const itemToInsert = { ...newItem, created_by: currentUserId };
    
    if (editingItemId) {
      // Update existing item
      const { error: updateError } = await supabase
        .from('items')
        .update(itemToInsert)
        .eq('id', editingItemId);
      if (updateError) {
        error = updateError.message;
      } else {
        // reload list with category details
        const res = await supabase.from('items').select('*, categories(name)');
        items = (res.data as Item[]) || [];
        showAddModal = false;
        editingItemId = null;
        newItem = { name: '', quantity: 1, status: 'pending', donation_id: null, category_id: undefined };
        // show toast
        toast = 'Item updated successfully';
        setTimeout(() => (toast = null), 3000);
      }
    } else {
      // Insert new item
      const { data, error: insertError } = await supabase.from('items').insert(itemToInsert);
      if (insertError) {
        error = insertError.message;
      } else {
        // reload list with category details
        const res = await supabase.from('items').select('*, categories(name)');
        items = (res.data as Item[]) || [];
        showAddModal = false;
        newItem = { name: '', quantity: 1, status: 'pending', donation_id: null, category_id: undefined };
        // show toast
        toast = 'Item added successfully';
        setTimeout(() => (toast = null), 3000);
      }
    }
    loading = false;
  }

  function toggleItemSelection(itemId: number, checked: boolean) {
    if (checked) {
      if (!selectedItemIds.includes(itemId)) {
        selectedItemIds = [...selectedItemIds, itemId];
      }
      return;
    }

    selectedItemIds = selectedItemIds.filter((id) => id !== itemId);
  }

  async function linkSelectedItemsToDonation() {
    if (selectedDonationId === null || selectedItemIds.length === 0) {
      return;
    }

    loading = true;
    const { error: updateError } = await supabase
      .from('items')
      .update({ donation_id: selectedDonationId })
      .in('id', selectedItemIds);

    if (updateError) {
      error = updateError.message;
    } else {
      const res = await supabase.from('items').select('*, categories(name)');
      items = (res.data as Item[]) || [];
      toast = 'Items linked to donation successfully';
      setTimeout(() => (toast = null), 3000);
      selectedItemIds = [];
      selectedDonationId = null;
      showLinkDonationModal = false;
    }

    loading = false;
  }

  function openEditModal(item: Item) {
    editingItemId = item.id;
    newItem = {
      name: item.name,
      quantity: item.quantity,
      status: item.status,
      donation_id: item.donation_id,
      category_id: item.category_id,
      description: item.description
    };
    showAddModal = true;
  }

  async function toggleReserve(item: Item) {
    const newReservedStatus = item.status !== 'reserved';
    const { error: updateError } = await supabase
      .from('items')
      .update({ status: newReservedStatus ? 'reserved' : 'pending' })
      .eq('id', item.id);
    if (updateError) {
      error = updateError.message;
    } else {
      const res = await supabase.from('items').select('*, categories(name)');
      items = (res.data as Item[]) || [];
      toast = newReservedStatus ? 'Item reserved' : 'Item unreserved';
      setTimeout(() => (toast = null), 3000);
    }
  }

  async function deleteItem(item: Item) {
    const { error: deleteError } = await supabase.from('items').delete().eq('id', item.id);

    if (deleteError) {
      error = deleteError.message;
      return;
    }

    const res = await supabase.from('items').select('*, categories(name)');
    items = (res.data as Item[]) || [];
    selectedItemIds = selectedItemIds.filter((id) => id !== item.id);
    toast = 'Item deleted successfully';
    setTimeout(() => (toast = null), 3000);
  }

  onMount(async () => {
    // get current user
    const { data: sessionData } = await supabase.auth.getSession();
    if (sessionData.session?.user) {
      currentUserId = sessionData.session.user.id;
    }

    // fetch donations
    const donRes = await supabase.from('donations').select('id, name');
    if (donRes.data) donations = donRes.data as Array<{ id: number; name: string }>;

    // fetch categories
    const catRes = await supabase.from('categories').select('id, name');
    if (catRes.data) categories = catRes.data as Array<{ id: number; name: string }>;

    // fetch items with category details
    const res = await supabase.from('items').select('*, categories(name)');
    if (res.error) {
      error = res.error.message;
    } else if (res.data) {
      items = res.data as Item[];
    }
    loading = false;
  });
</script>

<div class="space-y-4">
  <div class="flex items-center justify-between">
    <h1 class="text-3xl font-bold">All Items</h1>
    <div class="flex items-center gap-2">
      <button
        class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-gray-400"
        on:click={() => {
          selectedDonationId = null;
          showLinkDonationModal = true;
        }}
        disabled={!hasSelectedItems}
      >
        Link to Donation
      </button>
      <button
        class="rounded bg-green-600 px-4 py-2 text-white hover:bg-green-700"
        on:click={() => (showAddModal = true)}
      >
        + Add Item
      </button>
    </div>
  </div>

  <!-- Search and Filter Section -->
  <div class="flex flex-col gap-3 sm:flex-row">
    <div class="relative flex-1">
      <Search class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
      <input
        type="text"
        placeholder="Search items..."
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
        {#each categories as cat}
          <option value={cat.id}>{cat.name}</option>
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
      {#each filteredItems as item}
        <li class="flex items-start justify-between rounded bg-white p-4 shadow">
          <div class="flex items-center gap-3">
            <input
              type="checkbox"
              checked={selectedItemIds.includes(item.id)}
              on:change={(event) => toggleItemSelection(item.id, (event.currentTarget as HTMLInputElement).checked)}
              aria-label={`Select ${item.name}`}
            />
            <div>
              <h2 class="font-semibold">{item.name}</h2>
              <p class="text-sm text-gray-500">Qty: {item.quantity} — {item.status}</p>
            </div>
            {#if item.categories}
              <span class="rounded bg-blue-100 px-3 py-1 text-sm text-blue-700">{item.categories.name}</span>
            {/if}
          </div>
          <div class="flex items-center gap-1">
            <button
              type="button"
              class="rounded p-2 {item.status === 'reserved' ? 'text-yellow-600 bg-yellow-50 hover:bg-yellow-100' : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'}"
              on:click={() => toggleReserve(item)}
              aria-label="Toggle reserve"
            >
              <Lock class="h-4 w-4" />
            </button>
            <button
              type="button"
              class="rounded p-2 text-gray-600 hover:bg-gray-100 hover:text-gray-900"
              on:click={() => openEditModal(item)}
              aria-label="Edit item"
            >
              <Edit class="h-4 w-4" />
            </button>
            <button
              type="button"
              class="rounded p-2 text-red-600 hover:bg-red-50 hover:text-red-700"
              on:click={() => deleteItem(item)}
              aria-label="Delete item"
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
      <h3 class="text-xl font-bold mb-4">{editingItemId ? 'Edit Item' : 'New Item'}</h3>
      <form on:submit|preventDefault={addItem} class="space-y-4">
        <div>
          <label for="item-donation" class="block text-sm font-medium">Donation</label>
          <select id="item-donation" bind:value={newItem.donation_id} class="mt-1 w-full rounded border p-2">
            <option value={null}>No donation</option>
            {#each donations as d}
              <option value={d.id}>{d.name}</option>
            {/each}
          </select>
        </div>
        <div>
          <label for="item-category" class="block text-sm font-medium">Category</label>
          <select id="item-category" bind:value={newItem.category_id} class="mt-1 w-full rounded border p-2">
            <option value={undefined}>Select a category</option>
            {#each categories as c}
              <option value={c.id}>{c.name}</option>
            {/each}
          </select>
        </div>
        <div>
          <label for="item-name" class="block text-sm font-medium">Name</label>
          <input id="item-name" bind:value={newItem.name} class="mt-1 w-full rounded border p-2" required />
        </div>
        <div>
          <label for="item-quantity" class="block text-sm font-medium">Quantity</label>
          <input id="item-quantity" type="number" bind:value={newItem.quantity} class="mt-1 w-full rounded border p-2" required />
        </div>
        <div>
          <label for="item-status" class="block text-sm font-medium">Status</label>
          <input id="item-status" bind:value={newItem.status} class="mt-1 w-full rounded border p-2" required />
        </div>
        <div class="flex justify-end gap-2">
          <button type="button" class="px-4 py-2" on:click={() => { showAddModal = false; editingItemId = null; newItem = { name: '', quantity: 1, status: 'pending', donation_id: null, category_id: undefined }; }}>
            Cancel
          </button>
          <button type="submit" class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700">
            {editingItemId ? 'Update' : 'Save'}
          </button>
        </div>
      </form>
    </div>
  </div>
{/if}

{#if showLinkDonationModal}
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
    <div class="w-full max-w-md rounded-lg bg-white p-6">
      <h3 class="mb-4 text-xl font-bold">Link Selected Items to Donation</h3>
      <p class="mb-4 text-sm text-gray-600">Selected items: {selectedItemIds.length}</p>
      <div class="max-h-64 space-y-2 overflow-y-auto">
        {#each donations as donation}
          <label class="flex cursor-pointer items-center gap-2 rounded border p-2 hover:bg-gray-50">
            <input
              type="radio"
              name="selectedDonation"
              checked={selectedDonationId === donation.id}
              on:change={() => (selectedDonationId = donation.id)}
            />
            <span>{donation.name}</span>
          </label>
        {/each}
      </div>
      <div class="mt-6 flex justify-end gap-2">
        <button
          type="button"
          class="px-4 py-2"
          on:click={() => {
            showLinkDonationModal = false;
            selectedDonationId = null;
          }}
        >
          Cancel
        </button>
        <button
          type="button"
          class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-gray-400"
          disabled={selectedDonationId === null}
          on:click={linkSelectedItemsToDonation}
        >
          Save
        </button>
      </div>
    </div>
  </div>
{/if}
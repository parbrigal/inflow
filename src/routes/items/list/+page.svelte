<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import { Edit, Lock } from 'lucide-svelte';

  interface Item {
    id: number;
    donation_id: number;
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
  let editingItemId: number | null = null;
  let newItem: Partial<Item> = { name: '', quantity: 1, status: 'pending', donation_id: undefined, category_id: undefined };
  let toast: string | null = null;
  let currentUserId: string | null = null;

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
        newItem = { name: '', quantity: 1, status: 'pending', donation_id: undefined, category_id: undefined };
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
        newItem = { name: '', quantity: 1, status: 'pending', donation_id: undefined, category_id: undefined };
        // show toast
        toast = 'Item added successfully';
        setTimeout(() => (toast = null), 3000);
      }
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
    <button
      class="rounded bg-green-600 px-4 py-2 text-white hover:bg-green-700"
      on:click={() => (showAddModal = true)}
    >
      + Add Item
    </button>
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
      {#each items as item}
        <li class="flex items-start justify-between rounded bg-white p-4 shadow">
          <div class="flex items-center gap-3">
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
          <select id="item-donation" bind:value={newItem.donation_id} class="mt-1 w-full rounded border p-2" required>
            <option value={undefined}>Select a donation</option>
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
          <button type="button" class="px-4 py-2" on:click={() => { showAddModal = false; editingItemId = null; newItem = { name: '', quantity: 1, status: 'pending', donation_id: undefined, category_id: undefined }; }}>
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
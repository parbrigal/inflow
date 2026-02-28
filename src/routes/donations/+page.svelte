<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import type { Session } from '@supabase/supabase-js';

  interface Donation {
    id: number;
    name: string;
    description: string | null;
    status: string;
    created_by: string;
    created_at: string;
    updated_at: string;
  }

  let donations: Donation[] = [];
  let showModal = false;
  let selected: Donation | null = null;

  onMount(async () => {
    const res = await supabase.from('donations').select('*');
    const data = res.data as Donation[] | null;
    const error = res.error;
    if (error) {
      console.error('fetch donations error', error);
    } else if (data) {
      donations = data;
    }
  });

  function openModal(d: Donation) {
    selected = d;
    showModal = true;
  }

  function closeModal() {
    showModal = false;
    selected = null;
  }
</script>

<div class="space-y-6">
  <h1 class="text-3xl font-bold">Donations</h1>
  <div class="grid gap-6 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
    {#each donations as d}
      <button
        type="button"
        class="w-full text-left rounded-lg bg-white p-6 shadow hover:shadow-lg transition"
        on:click={() => openModal(d)}
      >
        <h2 class="text-xl font-semibold text-gray-800">{d.name}</h2>
        <p class="mt-2 text-gray-500">Status: {d.status}</p>
      </button>
    {/each}
  </div>
</div>

{#if showModal && selected}
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
    <div class="w-full max-w-md rounded-lg bg-white p-6">
      <div class="flex justify-between items-center">
        <h3 class="text-2xl font-bold">{selected.name}</h3>
        <button class="text-gray-600 hover:text-gray-800" on:click={closeModal}>&times;</button>
      </div>
      <div class="mt-4 space-y-2 text-gray-700">
        <p><strong>Description:</strong> {selected.description || '—'}</p>
        <p><strong>Status:</strong> {selected.status}</p>
        <p><strong>Created by:</strong> {selected.created_by}</p>
        <p><strong>Created at:</strong> {new Date(selected.created_at).toLocaleString()}</p>
        <p><strong>Updated at:</strong> {new Date(selected.updated_at).toLocaleString()}</p>
      </div>
      <div class="mt-6 flex justify-end">
        <button
          class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700"
          on:click={closeModal}
        >
          Close
        </button>
      </div>
    </div>
  </div>
{/if}

<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';

  interface Donation {
    id: number;
    name: string;
    description: string | null;
    status: string;
    created_by: string;
    created_at: string;
    updated_at: string;
  }

  interface NewDonation {
    name: string;
    description: string;
    status: string;
  }

  let donations: Donation[] = [];
  let showModal = false;
  let selected: Donation | null = null;
  let showAddDonationModal = false;
  let toast: string | null = null;
  let error: string | null = null;
  let addingDonation = false;
  let newDonation: NewDonation = {
    name: '',
    description: '',
    status: 'active'
  };

  async function fetchDonations() {
    const res = await supabase.from('donations').select('*');
    const data = res.data as Donation[] | null;
    const donationError = res.error;
    if (donationError) {
      error = donationError.message;
      return;
    }

    donations = data || [];
  }

  onMount(async () => {
    await fetchDonations();
  });

  function openModal(d: Donation) {
    selected = d;
    showModal = true;
  }

  function closeModal() {
    showModal = false;
    selected = null;
  }

  async function addDonation() {
    const {
      data: { user },
      error: userError
    } = await supabase.auth.getUser();

    if (userError || !user) {
      error = 'You must be signed in to add a donation.';
      return;
    }

    addingDonation = true;

    const { error: donationInsertError } = await supabase
      .from('donations')
      .insert({
        name: newDonation.name,
        description: newDonation.description || null,
        status: newDonation.status,
        created_by: user.id
      });

    if (donationInsertError) {
      error = donationInsertError?.message || 'Failed to create donation.';
      addingDonation = false;
      return;
    }

    showAddDonationModal = false;
    newDonation = {
      name: '',
      description: '',
      status: 'active'
    };
    await fetchDonations();
    toast = 'Donation added successfully';
    setTimeout(() => (toast = null), 3000);
    addingDonation = false;
  }
</script>

<div class="space-y-6">
  <div class="flex items-center justify-between">
    <h1 class="text-3xl font-bold">Donations</h1>
    <button
      class="rounded bg-green-600 px-4 py-2 text-white hover:bg-green-700"
      on:click={() => {
        error = null;
        showAddDonationModal = true;
      }}
    >
      + Add Donation
    </button>
  </div>

  {#if toast}
    <div class="fixed bottom-4 right-4 rounded bg-green-600 px-4 py-2 text-white shadow">
      {toast}
    </div>
  {/if}

  {#if error}
    <p class="text-red-500">Error: {error}</p>
  {/if}

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

{#if showAddDonationModal}
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
    <div class="w-full max-w-md rounded-lg bg-white p-6">
      <h3 class="mb-4 text-xl font-bold">New Donation</h3>
      <form on:submit|preventDefault={addDonation} class="space-y-4">
        <div>
          <label for="donation-name" class="block text-sm font-medium">Name</label>
          <input id="donation-name" bind:value={newDonation.name} class="mt-1 w-full rounded border p-2" required />
        </div>
        <div>
          <label for="donation-description" class="block text-sm font-medium">Description</label>
          <textarea id="donation-description" bind:value={newDonation.description} class="mt-1 w-full rounded border p-2"></textarea>
        </div>
     
        <div class="flex justify-end gap-2">
          <button
            type="button"
            class="px-4 py-2"
            on:click={() => {
              showAddDonationModal = false;
              newDonation = {
                name: '',
                description: '',
                status: 'active'
              };
            }}
          >
            Cancel
          </button>
          <button
            type="submit"
            class="rounded bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-gray-400"
            disabled={addingDonation}
          >
            {addingDonation ? 'Saving...' : 'Save'}
          </button>
        </div>
      </form>
    </div>
  </div>
{/if}

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

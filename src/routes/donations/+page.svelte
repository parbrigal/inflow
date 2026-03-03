<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';

  interface Donation {
    id: number;
    name: string;
    description: string | null;
    donor_name: string;
    donor_lastname: string;
    address: string;
    contact_no: string;
    status: string;
    created_by: string;
    created_at: string;
    updated_at: string;
  }

  interface NewDonation {
    name: string;
    description: string;
    donor_type: 'Individual' | 'Organization';
    organization_name: string;
    donor_name: string;
    donor_lastname: string;
    address: string;
    country_code: string;
    contact_no: string;
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
    donor_type: 'Individual',
    organization_name: '',
    donor_name: '',
    donor_lastname: '',
    address: '',
    country_code: '+1',
    contact_no: '',
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
    const formattedContactNo = `${newDonation.country_code} ${newDonation.contact_no}`.trim();

    const { error: donationInsertError } = await supabase
      .from('donations')
      .insert({
        name: newDonation.name,
        description: newDonation.description || null,
        donor_name: newDonation.donor_name,
        donor_lastname: newDonation.donor_lastname,
        address: newDonation.address,
        contact_no: formattedContactNo,
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
      donor_type: 'Individual',
      organization_name: '',
      donor_name: '',
      donor_lastname: '',
      address: '',
      country_code: '+1',
      contact_no: '',
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
        newDonation.donor_type = 'Individual';
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
        <p class="mt-1 text-gray-600">Contact: {d.donor_name} {d.donor_lastname}</p>
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
        <div>
          <label for="donor-type" class="block text-sm font-medium">Donor Type</label>
          <select id="donor-type" bind:value={newDonation.donor_type} class="mt-1 w-full rounded border p-2" required>
            <option value="Individual">Individual</option>
            <option value="Organization">Organization</option>
          </select>
        </div>
        {#if newDonation.donor_type === 'Organization'}
          <div>
            <label for="organization-name" class="block text-sm font-medium">Organization Name</label>
            <input
              id="organization-name"
              bind:value={newDonation.organization_name}
              class="mt-1 w-full rounded border p-2"
              required
            />
          </div>
        {/if}
        <div>
          <label for="donor-name" class="block text-sm font-medium">Contact Name</label>
          <input id="donor-name" bind:value={newDonation.donor_name} class="mt-1 w-full rounded border p-2" required />
        </div>
        <div>
          <label for="donor-lastname" class="block text-sm font-medium">Contact Last Name</label>
          <input id="donor-lastname" bind:value={newDonation.donor_lastname} class="mt-1 w-full rounded border p-2" required />
        </div>
        <div>
          <label for="donor-address" class="block text-sm font-medium">Address</label>
          <textarea
            id="donor-address"
            bind:value={newDonation.address}
            class="mt-1 w-full rounded border p-2"
            rows="3"
            required
          ></textarea>
        </div>
        <div>
          <label for="donor-contact" class="block text-sm font-medium">Contact No</label>
          <div class="mt-1 grid grid-cols-3 gap-2">
            <input
              id="donor-country-code"
              bind:value={newDonation.country_code}
              class="rounded border p-2"
              placeholder="+1"
              required
            />
            <input
              id="donor-contact"
              bind:value={newDonation.contact_no}
              class="col-span-2 rounded border p-2"
              placeholder="Phone number"
              required
            />
          </div>
          <p class="mt-1 text-xs text-gray-500">Country code defaults to US (+1)</p>
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
                donor_type: 'Individual',
                organization_name: '',
                donor_name: '',
                donor_lastname: '',
                address: '',
                country_code: '+1',
                contact_no: '',
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
        <p><strong>Contact Name:</strong> {selected.donor_name}</p>
        <p><strong>Contact Last Name:</strong> {selected.donor_lastname}</p>
        <p><strong>Address:</strong> {selected.address}</p>
        <p><strong>Contact No:</strong> {selected.contact_no}</p>
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

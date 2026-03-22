<script lang="ts">
  import type { ActionData } from './$types';

  export let form: ActionData;
</script>

<section class="mx-auto max-w-lg p-4">
  <h1 class="mb-2 text-2xl font-bold">Create Admin</h1>
  <p class="mb-6 text-sm text-gray-600">Create a new administrator account. This action is restricted to current administrators.</p>

  {#if form?.success}
    <p class="mb-4 rounded-lg border border-emerald-200 bg-emerald-50 px-3 py-2 text-sm text-emerald-700">{form.message}</p>
  {:else if form?.message}
    <p class="mb-4 rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">{form.message}</p>
  {/if}

  <form method="POST" class="space-y-4 rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
    <div>
      <label for="full_name" class="mb-1 block text-sm font-medium text-gray-700">Full name</label>
      <input
        id="full_name"
        name="full_name"
        type="text"
        autocomplete="name"
        class="w-full rounded-lg border border-gray-300 px-3 py-2 focus:border-blue-500 focus:outline-none"
        placeholder="Admin User"
      />
    </div>

    <div>
      <label for="email" class="mb-1 block text-sm font-medium text-gray-700">Email</label>
      <input
        id="email"
        name="email"
        type="email"
        autocomplete="email"
        required
        class="w-full rounded-lg border border-gray-300 px-3 py-2 focus:border-blue-500 focus:outline-none"
        placeholder="admin@example.com"
      />
    </div>

    <div>
      <label for="password" class="mb-1 block text-sm font-medium text-gray-700">Temporary password</label>
      <input
        id="password"
        name="password"
        type="password"
        autocomplete="new-password"
        minlength="6"
        required
        class="w-full rounded-lg border border-gray-300 px-3 py-2 focus:border-blue-500 focus:outline-none"
        placeholder="At least 6 characters"
      />
    </div>

    <button type="submit" class="w-full rounded-lg bg-blue-600 px-4 py-2.5 font-semibold text-white transition hover:bg-blue-700">
      Create administrator
    </button>
  </form>
</section>

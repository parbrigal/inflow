<script lang="ts">
  import { Users, Gift, Box } from 'lucide-svelte';

  // mock statistics
  const stats = [
    { label: 'Users', value: 3, icon: Users, color: 'text-blue-500' },
    { label: 'Donations', value: 6, icon: Gift, color: 'text-green-500' },
    { label: 'Items', value: 15, icon: Box, color: 'text-indigo-500' }
  ];
</script>

<div class="grid gap-6 sm:grid-cols-1 md:grid-cols-3">
  {#each stats as stat}
    <div class="flex items-center rounded-lg bg-white p-6 shadow">
      <div class="mr-4 rounded-full bg-gray-100 p-3">
        <svelte:component this={stat.icon} class={`h-6 w-6 ${stat.color}`} />
      </div>
      <div>
        <p class="text-2xl font-semibold text-gray-800">{stat.value}</p>
        <p class="text-sm text-gray-500">{stat.label}</p>
      </div>
    </div>
  {/each}
</div>

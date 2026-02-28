<script lang="ts">
  const categories = [
    {
      name: 'Furniture',
      image: 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=400&h=400&fit=crop',
      count: 24
    },
    {
      name: 'Clothing',
      image: 'https://images.unsplash.com/photo-1556821552-7f41c5d440db?w=400&h=400&fit=crop',
      count: 156
    },
    {
      name: 'Food',
      image: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=400&fit=crop',
      count: 89
    },
    {
      name: 'Bathroom Products',
      image: 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=400&h=400&fit=crop',
      count: 42
    },
    {
      name: 'Cleaning Supplies',
      image: 'https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=400&h=400&fit=crop',
      count: 67
    },
    {
      name: 'Other',
      image: 'https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=400&h=400&fit=crop',
      count: 112
    }
  ];
</script>

<div class="mb-6">
  <h1 class="text-3xl font-bold text-gray-900">Items by Category</h1>
  <p class="mt-2 text-gray-600">Browse and manage donated items by category</p>
</div>

<div class="grid gap-6 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
  {#each categories as category}
    <a href="/items/{category.name.toLowerCase().replace(/\s+/g, '-')}" class="group cursor-pointer">
      <div class="relative h-64 overflow-hidden rounded-lg shadow-md transition-transform hover:shadow-lg hover:scale-105">
        <img
          src={category.image}
          alt={category.name}
          class="h-full w-full object-cover transition-transform group-hover:scale-110"
        />
        <div class="absolute inset-0 bg-gradient-to-t from-black via-transparent to-transparent"></div>
        <div class="absolute inset-0 flex flex-col items-center justify-center text-center">
          <h2 class="text-2xl font-bold text-white">{category.name}</h2>
          <p class="mt-2 text-lg text-gray-200">{category.count} items</p>
        </div>
      </div>
    </a>
  {/each}
</div>

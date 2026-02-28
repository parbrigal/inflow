<script lang="ts">
  import { onMount } from 'svelte';
  import { supabase } from '$lib/supabaseClient';
  import { goto } from '$app/navigation';

  onMount(async () => {
    const { data } = await supabase.auth.getSession();
    if (data.session) {
      goto('/dashboard');
    }
  });
</script>

<div class="flex min-h-screen items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 px-4">
	<div class="text-center">
		<h1 class="mb-4 text-5xl font-bold text-gray-900">Welcome to SourDough</h1>
		<p class="mb-8 text-xl text-gray-600">Your personal donation management platform</p>
		<div class="flex gap-4 justify-center">
			<a href="/sign-in" class="rounded-lg bg-blue-600 px-6 py-3 font-semibold text-white transition hover:bg-blue-700">
				Sign In
			</a>
			<a href="/signup" class="rounded-lg border-2 border-blue-600 px-6 py-3 font-semibold text-blue-600 transition hover:bg-blue-50">
				Sign Up
			</a>
		</div>
	</div>
</div>

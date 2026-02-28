<script lang="ts">
	import { Auth } from '@supabase/auth-ui-svelte';
	import { supabase } from '$lib/supabaseClient';
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	onMount(() => {
		supabase.auth.onAuthStateChange((_event, session) => {
			if (session) {
				goto('/dashboard');
			}
		});
	});
</script>

<section class="max-w-md mx-auto p-4">
	<h1 class="text-2xl font-bold mb-4">Create an account</h1>
	<Auth
		supabaseClient={supabase}
		providers={[]}
		view="sign_up"
		socialLayout="horizontal"
	/>
</section>

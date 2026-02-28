<script lang="ts">
	import "../app.css";
	import favicon from '$lib/assets/favicon.svg';
	import { onMount } from 'svelte';
	import { supabase } from '$lib/supabaseClient';
	import type { Session } from '@supabase/supabase-js';
	import AppLayout from '$lib/AppLayout.svelte';

	export let data: { session: Session | null };

	let session: Session | null = null;

	onMount(() => {
		session = data.session;
		supabase.auth.onAuthStateChange((_event, s) => {
			session = s;
		});
	});

	const signOut = async () => {
		await supabase.auth.signOut();
	};
</script>

<svelte:head>
	<link rel="icon" href="{favicon}" />
</svelte:head>

{#if session}
	<AppLayout {session} {signOut}>
		<slot />
	</AppLayout>
{:else}
	<nav class="p-4 bg-gray-100 flex justify-end">
		<a class="mr-4 text-blue-600" href="/sign-in">Sign in</a>
		<a class="text-blue-600" href="/signup">Sign up</a>
	</nav>
	<slot />
{/if}


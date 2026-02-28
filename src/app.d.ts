// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
import type { Session } from '@supabase/supabase-js';

declare global {
	namespace App {
		// interface Error {}
		interface Locals {
			/** current Supabase session, if logged in */
			session: Session | null;
			/** helper client available in server loads/actions */
			supabase: import('@supabase/supabase-js').SupabaseClient;
		}
		interface PageData {
			session: Session | null;
		}
		// interface PageState {}
		// interface Platform {}
	}
}

export { };

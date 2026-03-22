// We no longer rely on the deprecated auth-helpers package; instead
// create a fresh server-side Supabase client on every request. This
// implementation mirrors what the old `handleAuth()` helper provided
// (populating `event.locals.session`/`supabase` and automatically
// persisting any cookie changes).

import { createServerClient } from '@supabase/ssr';
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';
import type { Handle } from '@sveltejs/kit';

export const handle: Handle = async ({ event, resolve }) => {
    // make a Supabase client bound to the incoming request's cookies
    const supabase = createServerClient(PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY, {
        cookies: {
            getAll() {
                return event.cookies.getAll();
            },
            setAll(cookiesToSet) {
                cookiesToSet.forEach(({ name, value, options }) => {
                    event.cookies.set(name, value, {
                        ...options,
                        path: options.path ?? '/'
                    });
                });
            }
        }
    });

    // expose to load functions / actions
    event.locals.supabase = supabase;

    // populate session in locals so layouts/pages can read it server-side
    const {
        data: { session }
    } = await supabase.auth.getSession();
    event.locals.session = session;

    // resolve the event; cookies will be set as the client mutates state
    const response = await resolve(event);
    return response;
};

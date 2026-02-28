import { createClient } from '@supabase/supabase-js';
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public';
import { browser } from '$app/environment';

// a single shared client for browser/server use
export const supabase = createClient(
    PUBLIC_SUPABASE_URL ?? '',
    PUBLIC_SUPABASE_ANON_KEY ?? '',
    {
        auth: {
            // only reference sessionStorage in the browser environment
            storage: browser ? sessionStorage : undefined,
            // optionally disable persistence entirely if you only want manual control
            // persistSession: false
        }
    }
);

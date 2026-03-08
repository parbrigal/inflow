import type { PageServerLoad } from './$types';
import { env } from '$env/dynamic/private';
import { PUBLIC_SUPABASE_URL } from '$env/static/public';
import { createClient } from '@supabase/supabase-js';

type RawRequestRow = {
    id: number;
    name: string;
    description: string | null;
    status: string;
    categories?: { name: string }[] | { name: string } | null;
};

export const load: PageServerLoad = async ({ locals }) => {
    const openStatuses = ['pending', 'reserved'];
    const supabase = env.SUPABASE_SERVICE_ROLE_KEY
        ? createClient(PUBLIC_SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
            auth: { persistSession: false }
        })
        : locals.supabase;

    const [wishlistResult, countResult] = await Promise.all([
        supabase
            .from('requests')
            .select('id, name, description, status, categories(name)')
            .in('status', openStatuses)
            .order('created_at', { ascending: false })
            .limit(4),
        supabase
            .from('requests')
            .select('id', { count: 'exact', head: true })
            .in('status', openStatuses)
    ]);

    const loadError = wishlistResult.error?.message ?? countResult.error?.message ?? null;

    const wishlist = ((wishlistResult.data ?? []) as RawRequestRow[]).map((row) => {
        const categoryName = Array.isArray(row.categories)
            ? row.categories[0]?.name
            : row.categories?.name;

        return {
            id: row.id,
            name: row.name,
            description: row.description,
            status: row.status,
            categoryName: categoryName ?? 'General'
        };
    });

    return {
        wishlist,
        openWishlistCount: countResult.count ?? wishlist.length,
        loadError
    };
};
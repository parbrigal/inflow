import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals }) => {
    let isAdmin = false;

    if (locals.session) {
        const { data: profile } = await locals.supabase
            .from('profiles')
            .select('role_id')
            .eq('id', locals.session.user.id)
            .maybeSingle();

        if (profile?.role_id) {
            const { data: role } = await locals.supabase
                .from('roles')
                .select('name')
                .eq('id', profile.role_id)
                .maybeSingle();

            isAdmin = String(role?.name ?? '').toLowerCase() === 'administrator';
        }
    }

    return {
        session: locals.session,
        isAdmin
    };
};

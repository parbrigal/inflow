import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { env } from '$env/dynamic/private';
import { PUBLIC_SUPABASE_URL } from '$env/static/public';
import { createClient } from '@supabase/supabase-js';

const getCurrentUserRole = async (locals: App.Locals): Promise<string | null> => {
    if (!locals.session) {
        return null;
    }

    const { data: profile, error: profileError } = await locals.supabase
        .from('profiles')
        .select('role_id')
        .eq('id', locals.session.user.id)
        .maybeSingle();

    if (profileError || !profile?.role_id) {
        return null;
    }

    const { data: role, error: roleError } = await locals.supabase
        .from('roles')
        .select('name')
        .eq('id', profile.role_id)
        .maybeSingle();

    if (roleError || !role?.name) {
        return null;
    }

    return String(role.name).toLowerCase();
};

export const load: PageServerLoad = async ({ locals }) => {
    if (!locals.session) {
        throw redirect(303, '/sign-in');
    }

    const currentRole = await getCurrentUserRole(locals);
    if (currentRole !== 'administrator') {
        throw redirect(303, '/dashboard');
    }

    return {
        session: locals.session
    };
};

export const actions: Actions = {
    default: async ({ request, locals }) => {
        if (!locals.session) {
            throw redirect(303, '/sign-in');
        }

        const currentRole = await getCurrentUserRole(locals);
        if (currentRole !== 'administrator') {
            return fail(403, {
                message: 'Only administrators can create administrator accounts.'
            });
        }

        if (!env.SUPABASE_SERVICE_ROLE_KEY) {
            return fail(500, {
                message: 'Server is missing SUPABASE_SERVICE_ROLE_KEY.'
            });
        }

        const formData = await request.formData();
        const fullName = String(formData.get('full_name') ?? '').trim();
        const email = String(formData.get('email') ?? '').trim().toLowerCase();
        const password = String(formData.get('password') ?? '');

        if (!email || !password) {
            return fail(400, {
                message: 'Email and password are required.'
            });
        }

        if (password.length < 6) {
            return fail(400, {
                message: 'Password must be at least 6 characters.'
            });
        }

        const adminClient = createClient(PUBLIC_SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
            auth: { persistSession: false }
        });

        const { error } = await adminClient.auth.admin.createUser({
            email,
            password,
            email_confirm: true,
            user_metadata: {
                full_name: fullName || null,
                signup_role: 'administrator'
            }
        });

        if (error) {
            return fail(400, {
                message: error.message
            });
        }

        return {
            success: true,
            message: 'Administrator account created successfully.'
        };
    }
};

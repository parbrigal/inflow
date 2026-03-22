import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
    if (locals.session) {
        throw redirect(303, '/dashboard');
    }

    return {
        session: locals.session
    };
};

export const actions: Actions = {
    default: async ({ request, locals }) => {
        const formData = await request.formData();
        const fullName = String(formData.get('full_name') ?? '').trim();
        const email = String(formData.get('email') ?? '').trim().toLowerCase();
        const password = String(formData.get('password') ?? '');
        const requestedRole = String(formData.get('signup_role') ?? 'donor').trim().toLowerCase();

        if (!email || !password) {
            return fail(400, {
                message: 'Email and password are required.'
            });
        }

        if (requestedRole !== 'donor') {
            return fail(403, {
                message: 'Public signup is donor-only. Use Create Admin for administrator accounts.'
            });
        }

        const { error } = await locals.supabase.auth.signUp({
            email,
            password,
            options: {
                data: {
                    full_name: fullName || null,
                    signup_role: 'donor'
                }
            }
        });

        if (error) {
            return fail(400, {
                message: error.message
            });
        }

        return {
            success: true,
            message: 'Account created. Check your email to confirm your account.'
        };
    }
};

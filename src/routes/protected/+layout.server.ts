import { redirect } from '@sveltejs/kit';
import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals }) => {
    if (!locals.session) {
        // not logged in; send to sign-in page
        throw redirect(303, '/sign-in');
    }

    return {
        session: locals.session
    };
};

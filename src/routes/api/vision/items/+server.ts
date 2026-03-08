import { env } from '$env/dynamic/private';
import { json, type RequestHandler } from '@sveltejs/kit';

interface VisionLabel {
    description?: string;
    score?: number;
}

interface VisionObject {
    name?: string;
    score?: number;
}

const EXCLUDED_TERMS = new Set([
    'font',
    'text',
    'design',
    'material',
    'product',
    'brand',
    'logo',
    'graphics'
]);

export const POST: RequestHandler = async ({ request, fetch }) => {
    const googleVisionApiKey = env.GOOGLE_VISION_API_KEY;

    if (!googleVisionApiKey) {
        return json({ error: 'Google Vision API key is not configured.' }, { status: 500 });
    }

    const formData = await request.formData();
    const image = formData.get('image');

    if (!(image instanceof File)) {
        return json({ error: 'Image file is required.' }, { status: 400 });
    }

    const mimeType = (image.type || '').toLowerCase();
    if (mimeType && !mimeType.startsWith('image/')) {
        return json({ error: 'Only image files are supported.' }, { status: 400 });
    }

    const buffer = Buffer.from(await image.arrayBuffer());
    const imageBase64 = buffer.toString('base64');

    const visionResponse = await fetch(
        `https://vision.googleapis.com/v1/images:annotate?key=${googleVisionApiKey}`,
        {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                requests: [
                    {
                        image: { content: imageBase64 },
                        features: [
                            { type: 'OBJECT_LOCALIZATION', maxResults: 20 },
                            { type: 'LABEL_DETECTION', maxResults: 20 }
                        ]
                    }
                ]
            })
        }
    );

    if (!visionResponse.ok) {
        const body = await visionResponse.text();
        return json({ error: `Vision API request failed: ${body}` }, { status: 502 });
    }

    const visionPayload = await visionResponse.json();
    const result = visionPayload?.responses?.[0];

    const objectNames: string[] = (result?.localizedObjectAnnotations ?? [])
        .filter((item: VisionObject) => (item.score ?? 0) >= 0.55)
        .map((item: VisionObject) => item.name)
        .filter((name: string | undefined): name is string => Boolean(name));

    const labelNames: string[] = (result?.labelAnnotations ?? [])
        .filter((label: VisionLabel) => (label.score ?? 0) >= 0.7)
        .map((label: VisionLabel) => label.description)
        .filter((name: string | undefined): name is string => Boolean(name));

    const merged = [...objectNames, ...labelNames]
        .map((name) => name.trim())
        .filter((name) => name.length > 1)
        .filter((name) => !EXCLUDED_TERMS.has(name.toLowerCase()));

    const uniqueItems: string[] = [];
    const seen = new Set<string>();

    for (const name of merged) {
        const key = name.toLowerCase();
        if (!seen.has(key)) {
            seen.add(key);
            uniqueItems.push(name);
        }

        if (uniqueItems.length >= 12) {
            break;
        }
    }

    return json({ items: uniqueItems });
};

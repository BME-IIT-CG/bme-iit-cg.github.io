import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';
import { docsLoader } from '@astrojs/starlight/loaders';
import { docsSchema } from '@astrojs/starlight/schema';

export const collections = {
	docs: defineCollection({
		loader: docsLoader(),
		schema: docsSchema({
			extend: z.object({
				// tutorial steps: whether the step has a running demo, and where it comes from
				demo: z.boolean().optional(),
				step: z.string().optional(),
				commit: z.string().optional(),
			}),
		}),
	}),
};

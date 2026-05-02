import type { Db } from '~~/server/utils/db'
import { isNull } from 'drizzle-orm'
import { topics } from './schema'

export const TOP_LEVEL_DOMAINS = [
  { slug: 'mathematics-foundations', name: 'Mathematics Foundations' },
  { slug: 'algorithms-data-structures', name: 'Algorithms & Data Structures' },
  { slug: 'programming-languages-compilers', name: 'Programming Languages & Compilers' },
  { slug: 'computer-architecture', name: 'Computer Architecture' },
  { slug: 'operating-systems', name: 'Operating Systems' },
  { slug: 'networking', name: 'Networking' },
  { slug: 'databases', name: 'Databases' },
  { slug: 'concurrency-parallelism', name: 'Concurrency & Parallelism' },
  { slug: 'distributed-systems', name: 'Distributed Systems' },
  { slug: 'systems-design', name: 'Systems Design' },
  { slug: 'cloud-infrastructure', name: 'Cloud Infrastructure' },
  { slug: 'data-engineering', name: 'Data Engineering' },
  { slug: 'security', name: 'Security' },
  { slug: 'api-design', name: 'API Design' },
  { slug: 'software-architecture', name: 'Software Architecture' },
  { slug: 'testing-quality', name: 'Testing & Quality' },
  { slug: 'performance-observability', name: 'Performance & Observability' },
  { slug: 'artificial-intelligence', name: 'Artificial Intelligence' },
  { slug: 'engineering-leadership', name: 'Engineering Leadership' },
] as const

// Additive only — never deletes or renames. NULL-distinct on
// (parent_id, slug) means we can't lean on ON CONFLICT for top-level rows,
// so we read existing slugs and insert what's missing.
export async function seedDomains(db: Db): Promise<void> {
  const existing = await db
    .select({ slug: topics.slug })
    .from(topics)
    .where(isNull(topics.parentId))

  const have = new Set(existing.map(r => r.slug))
  const missing = TOP_LEVEL_DOMAINS.filter(d => !have.has(d.slug))

  if (missing.length > 0) {
    await db.insert(topics).values(missing)
  }
}

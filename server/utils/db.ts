import type { PostgresJsDatabase } from 'drizzle-orm/postgres-js'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from '~~/server/db/schema'
import { seedDomains } from '~~/server/db/seed-domains'

export type Db = PostgresJsDatabase<typeof schema>

let ready: Promise<Db> | undefined

export function useDb(): Promise<Db> {
  if (ready)
    return ready

  const url = useRuntimeConfig().databaseUrl
  if (!url) {
    throw createError({
      statusCode: 500,
      statusMessage: 'DATABASE_URL not configured (set NUXT_DATABASE_URL)',
    })
  }

  ready = (async () => {
    const pool = postgres(url)
    const db = drizzle(pool, { schema })
    await seedDomains(db)
    return db
  })()

  return ready
}

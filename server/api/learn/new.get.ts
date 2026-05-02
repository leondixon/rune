import { and, asc, eq, isNull } from 'drizzle-orm'
import { mastery, topics } from '~~/server/db/schema'

export default defineEventHandler(async (event) => {
  const user = await requireUser(event)
  const db = await useDb()

  const raw = Number(getQuery(event).limit)
  const limit = Number.isFinite(raw) && raw > 0 ? Math.min(Math.floor(raw), 20) : 5

  const items = await db
    .select({
      topicId: topics.id,
      slug: topics.slug,
      name: topics.name,
    })
    .from(topics)
    .leftJoin(mastery, and(eq(mastery.topicId, topics.id), eq(mastery.userId, user.id)))
    .where(isNull(mastery.userId))
    .orderBy(asc(topics.name))
    .limit(limit)

  return { items }
})

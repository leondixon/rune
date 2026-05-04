import { and, asc, eq, lte } from 'drizzle-orm'
import { mastery, topics } from '~~/server/db/schema'

export default defineEventHandler(async (event) => {
  const user = await requireUser(event)
  const db = await useDb()

  const raw = Number(getQuery(event).limit)
  const limit = Number.isFinite(raw) && raw > 0 ? Math.min(Math.floor(raw), 50) : 10

  const items = await db
    .select({
      topicId: topics.id,
      slug: topics.slug,
      name: topics.name,
      dueAt: mastery.dueAt,
      stability: mastery.stability,
      difficulty: mastery.difficulty,
      reps: mastery.reps,
      lapses: mastery.lapses,
    })
    .from(mastery)
    .innerJoin(topics, eq(topics.id, mastery.topicId))
    .where(and(eq(mastery.userId, user.id), lte(mastery.dueAt, new Date())))
    .orderBy(asc(mastery.dueAt))
    .limit(limit)

  return { items }
})

import { eq } from 'drizzle-orm'
import { users } from '~~/server/db/schema'
import { loginSchema } from '~~/shared/utils/auth-schemas'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const result = loginSchema.safeParse(body)

  if (!result.success) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Invalid login',
      data: { issues: result.error.flatten().fieldErrors },
    })
  }

  const { email, password } = result.data
  const db = await useDb()
  const [row] = await db
    .select({ id: users.id, passwordHash: users.passwordHash })
    .from(users)
    .where(eq(users.email, email))
    .limit(1)

  if (!row || !verifyPassword(password, row.passwordHash)) {
    throw createError({
      statusCode: 401,
      statusMessage: 'The scroll did not recognise you',
    })
  }

  await endSession(event)
  const user = await startSession(event, row.id)
  return { user }
})

import { eq } from 'drizzle-orm'
import { users } from '~~/server/db/schema'
import { registerSchema } from '~~/shared/utils/auth-schemas'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const result = registerSchema.safeParse(body)

  if (!result.success) {
    throw createError({
      statusCode: 400,
      statusMessage: 'Invalid registration',
      data: { issues: result.error.flatten().fieldErrors },
    })
  }

  const { email, password, firstName, lastName } = result.data
  const db = await useDb()

  const [existing] = await db
    .select({ id: users.id })
    .from(users)
    .where(eq(users.email, email))
    .limit(1)

  if (existing) {
    throw createError({
      statusCode: 409,
      statusMessage: 'That sigil is already bound',
      data: { issues: { email: ['That sigil is already bound'] } },
    })
  }

  const [inserted] = await db
    .insert(users)
    .values({
      email,
      passwordHash: hashPassword(password),
      firstName,
      lastName,
    })
    .returning({ id: users.id })

  if (!inserted) {
    throw createError({ statusCode: 500, statusMessage: 'Insert returned no row' })
  }

  const user = await startSession(event, inserted.id)
  return { user }
})

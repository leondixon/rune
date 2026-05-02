import type { H3Event } from 'h3'
import type { SessionUser } from '~~/shared/utils/auth-types'
import { randomBytes } from 'node:crypto'
import process from 'node:process'
import { eq } from 'drizzle-orm'
import { sessions, users } from '~~/server/db/schema'

const COOKIE_NAME = 'rune_session'
const SESSION_TTL_MS = 30 * 24 * 60 * 60 * 1000

const userColumns = {
  id: users.id,
  email: users.email,
  firstName: users.firstName,
  lastName: users.lastName,
} as const

export async function startSession(event: H3Event, userId: string): Promise<SessionUser> {
  const db = await useDb()
  const token = randomBytes(32).toString('base64url')
  const expiresAt = new Date(Date.now() + SESSION_TTL_MS)

  await db.insert(sessions).values({ id: token, userId, expiresAt })

  setCookie(event, COOKIE_NAME, token, {
    httpOnly: true,
    sameSite: 'lax',
    secure: process.env.NODE_ENV === 'production',
    path: '/',
    maxAge: Math.floor(SESSION_TTL_MS / 1000),
  })

  const [user] = await db
    .select(userColumns)
    .from(users)
    .where(eq(users.id, userId))
    .limit(1)

  if (!user) {
    throw createError({ statusCode: 500, statusMessage: 'Session user vanished' })
  }
  return user
}

export async function getSessionUser(event: H3Event): Promise<SessionUser | undefined> {
  const token = getCookie(event, COOKIE_NAME)
  if (!token)
    return undefined

  const db = await useDb()
  const [row] = await db
    .select({ ...userColumns, expiresAt: sessions.expiresAt })
    .from(sessions)
    .innerJoin(users, eq(users.id, sessions.userId))
    .where(eq(sessions.id, token))
    .limit(1)

  if (!row)
    return undefined

  if (row.expiresAt.getTime() < Date.now()) {
    await db.delete(sessions).where(eq(sessions.id, token))
    deleteCookie(event, COOKIE_NAME, { path: '/' })
    return undefined
  }

  const { expiresAt: _expiresAt, ...user } = row
  return user
}

export async function requireUser(event: H3Event): Promise<SessionUser> {
  const user = await getSessionUser(event)
  if (!user) {
    throw createError({ statusCode: 401, statusMessage: 'Sign in to continue' })
  }
  return user
}

export async function endSession(event: H3Event): Promise<void> {
  const token = getCookie(event, COOKIE_NAME)
  if (token) {
    const db = await useDb()
    await db.delete(sessions).where(eq(sessions.id, token))
  }
  deleteCookie(event, COOKIE_NAME, { path: '/' })
}

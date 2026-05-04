import type { SessionUser } from '~~/shared/utils/auth-types'

export default defineNuxtPlugin(async () => {
  if (!import.meta.server)
    return

  const user = useState<SessionUser | undefined>('auth.user', () => undefined)
  try {
    const res = await $fetch<{ user?: SessionUser }>('/api/auth/me', {
      headers: useRequestHeaders(['cookie']),
    })
    user.value = res.user
  }
  catch {
    user.value = undefined
  }
})

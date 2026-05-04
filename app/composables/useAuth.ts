import type { SessionUser } from '~~/shared/utils/auth-types'

export function useAuth() {
  const user = useState<SessionUser | undefined>('auth.user', () => undefined)
  const loggedIn = computed(() => user.value !== undefined)

  function setUser(next: SessionUser | undefined) {
    user.value = next
  }

  async function logout() {
    await $fetch('/api/auth/logout', { method: 'POST' })
    user.value = undefined
  }

  return { user, loggedIn, setUser, logout }
}

<script setup lang="ts">
import type { SessionUser } from '~~/shared/utils/auth-types'
import { loginSchema } from '~~/shared/utils/auth-schemas'

useHead({ title: 'RUNE — Enter the scroll' })

const { setUser } = useAuth()

const form = reactive({ email: '', password: '' })
const errors = ref<Partial<Record<keyof typeof form, string>>>({})
const submitting = ref(false)
const serverError = ref<string | undefined>()

function validateField(field: keyof typeof form) {
  const result = loginSchema.shape[field].safeParse(form[field])
  errors.value = {
    ...errors.value,
    [field]: result.success ? undefined : result.error.issues[0]?.message,
  }
}

async function submit() {
  serverError.value = undefined
  const result = loginSchema.safeParse(form)
  if (!result.success) {
    const next: Partial<Record<keyof typeof form, string>> = {}
    for (const issue of result.error.issues) {
      const key = issue.path[0] as keyof typeof form
      if (key && !next[key])
        next[key] = issue.message
    }
    errors.value = next
    return
  }
  errors.value = {}
  submitting.value = true
  try {
    const res = await $fetch<{ user: SessionUser }>('/api/auth/login', { method: 'POST', body: result.data })
    setUser(res.user)
    await navigateTo('/')
  }
  catch (caught: any) {
    serverError.value = caught?.data?.message ?? 'The scroll did not recognise you.'
  }
  finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="max-w-[480px] mx-auto px-5 pt-10 pb-16 relative z-[1]">
    <NuxtLink to="/" class="font-display text-[0.78rem] uppercase tracking-[0.2em] text-parchment-dim hover:text-spark-soft no-underline mb-6 inline-block">
      ⟵ Back to the scroll
    </NuxtLink>

    <Card>
      <h1 class="mb-2">
        <span class="text-gold [text-shadow:0_0_12px_rgba(201,169,97,0.6)]">Enter</span> the scroll
      </h1>
      <p class="text-parchment-dim mb-7 leading-[1.7]">
        Speak your sigil. The runemaster will know its own.
      </p>

      <form class="flex flex-col gap-5" novalidate @submit.prevent="submit">
        <FormField
          id="email"
          v-model="form.email"
          label="Email"
          type="email"
          autocomplete="email"
          :error="errors.email"
          @blur="validateField('email')"
        />

        <FormField
          id="password"
          v-model="form.password"
          label="Password"
          type="password"
          autocomplete="current-password"
          :error="errors.password"
          @blur="validateField('password')"
        />

        <p v-if="serverError" class="text-[0.78rem] text-red-400 mt-1.5 font-display tracking-[0.1em]">
          {{ serverError }}
        </p>

        <div class="flex items-center gap-4 flex-wrap mt-2">
          <Button type="submit" variant="primary" :disabled="submitting">
            {{ submitting ? '≫ Entering…' : '≫ Enter' }}
          </Button>
          <NuxtLink to="/register" class="font-display text-[0.78rem] uppercase tracking-[0.2em] text-parchment-dim hover:text-spark-soft no-underline">
            New here? Inscribe
          </NuxtLink>
        </div>
      </form>
    </Card>
  </div>
</template>

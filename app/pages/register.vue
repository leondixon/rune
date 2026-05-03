<script setup lang="ts">
import type { SessionUser } from '~~/shared/utils/auth-types'
import { registerSchema } from '~~/shared/utils/auth-schemas'

useHead({ title: 'RUNE — Inscribe your name' })

const { setUser } = useAuth()

const form = reactive({
  firstName: '',
  lastName: '',
  email: '',
  password: '',
})

const errors = ref<Partial<Record<keyof typeof form, string>>>({})
const submitting = ref(false)
const serverError = ref<string | undefined>()

function validateField(field: keyof typeof form) {
  const result = registerSchema.shape[field].safeParse(form[field])
  errors.value = {
    ...errors.value,
    [field]: result.success ? undefined : result.error.issues[0]?.message,
  }
}

async function submit() {
  serverError.value = undefined
  const result = registerSchema.safeParse(form)
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
    const res = await $fetch<{ user: SessionUser }>('/api/auth/register', { method: 'POST', body: result.data })
    setUser(res.user)
    await navigateTo('/')
  }
  catch (caught: any) {
    serverError.value = caught?.data?.message ?? 'The scroll rejected your inscription.'
  }
  finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="max-w-[560px] mx-auto px-5 pt-10 pb-16 relative z-[1]">
    <NuxtLink to="/" class="font-display text-[0.78rem] uppercase tracking-[0.2em] text-parchment-dim hover:text-spark-soft no-underline mb-6 inline-block">
      ⟵ Back to the scroll
    </NuxtLink>

    <Card>
      <h1 class="mb-2">
        <span class="text-gold [text-shadow:0_0_12px_rgba(201,169,97,0.6)]">Inscribe</span> your name
      </h1>
      <p class="text-parchment-dim mb-7 leading-[1.7]">
        The runemaster needs a sigil to bind. Choose well — passwords here must hold against the void.
      </p>

      <form class="flex flex-col gap-5" novalidate @submit.prevent="submit">
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
          <FormField
            id="firstName"
            v-model="form.firstName"
            label="First name"
            autocomplete="given-name"
            :error="errors.firstName"
            @blur="validateField('firstName')"
          />
          <FormField
            id="lastName"
            v-model="form.lastName"
            label="Last name"
            autocomplete="family-name"
            :error="errors.lastName"
            @blur="validateField('lastName')"
          />
        </div>

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
          autocomplete="new-password"
          :error="errors.password"
          hint="8+ chars · upper · lower · digit · symbol"
          @blur="validateField('password')"
        />

        <p v-if="serverError" class="text-[0.78rem] text-red-400 mt-1.5 font-display tracking-[0.1em]">
          {{ serverError }}
        </p>

        <div class="flex items-center gap-4 flex-wrap mt-2">
          <Button type="submit" variant="primary" :disabled="submitting">
            {{ submitting ? '≫ Inscribing…' : '≫ Inscribe' }}
          </Button>
          <NuxtLink to="/login" class="font-display text-[0.78rem] uppercase tracking-[0.2em] text-parchment-dim hover:text-spark-soft no-underline">
            Already inscribed? Enter
          </NuxtLink>
        </div>
      </form>
    </Card>
  </div>
</template>

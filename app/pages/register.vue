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
  catch (err: any) {
    serverError.value = err?.data?.message ?? 'The scroll rejected your inscription.'
  }
  finally {
    submitting.value = false
  }
}

const card = 'relative bg-panel/80 border-2 border-arcane [box-shadow:6px_6px_0_var(--color-arcane-deep),0_0_28px_rgba(0,217,255,0.06)_inset] p-7 before:absolute before:inset-0 before:pointer-events-none before:border before:border-gold/20 before:m-1'
const label = 'font-display text-[0.78rem] uppercase tracking-[0.22em] text-gold mb-2 block'
const input = 'w-full bg-void-soft/70 border-2 border-arcane text-parchment px-4 py-3 font-body text-[0.95rem] focus:outline-none focus:border-spark focus:[box-shadow:0_0_12px_rgba(0,217,255,0.4)] transition-colors'
const err = 'text-[0.78rem] text-red-400 mt-1.5 font-display tracking-[0.1em]'
const btnPrimary = 'inline-block font-display text-[0.88rem] uppercase tracking-[0.2em] px-6 py-3 border-2 !border-spark text-spark-soft bg-arcane/40 [box-shadow:0_0_14px_rgba(0,217,255,0.25)] transition-all hover:bg-spark hover:text-void disabled:opacity-50 disabled:cursor-not-allowed'
</script>

<template>
  <div class="max-w-[560px] mx-auto px-5 pt-10 pb-16 relative z-[1]">
    <NuxtLink to="/" class="font-display text-[0.78rem] uppercase tracking-[0.2em] text-parchment-dim hover:text-spark-soft no-underline mb-6 inline-block">
      ⟵ Back to the scroll
    </NuxtLink>

    <section :class="card">
      <h1 class="mb-2">
        <span class="text-gold [text-shadow:0_0_12px_rgba(201,169,97,0.6)]">Inscribe</span> your name
      </h1>
      <p class="text-parchment-dim mb-7 leading-[1.7]">
        The runemaster needs a sigil to bind. Choose well — passwords here must hold against the void.
      </p>

      <form class="flex flex-col gap-5" novalidate @submit.prevent="submit">
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
          <div>
            <label for="firstName" :class="label">First name</label>
            <input
              id="firstName"
              v-model="form.firstName"
              type="text"
              autocomplete="given-name"
              :class="input"
              :aria-invalid="!!errors.firstName"
              @blur="validateField('firstName')"
            >
            <p v-if="errors.firstName" :class="err">
              {{ errors.firstName }}
            </p>
          </div>
          <div>
            <label for="lastName" :class="label">Last name</label>
            <input
              id="lastName"
              v-model="form.lastName"
              type="text"
              autocomplete="family-name"
              :class="input"
              :aria-invalid="!!errors.lastName"
              @blur="validateField('lastName')"
            >
            <p v-if="errors.lastName" :class="err">
              {{ errors.lastName }}
            </p>
          </div>
        </div>

        <div>
          <label for="email" :class="label">Email</label>
          <input
            id="email"
            v-model="form.email"
            type="email"
            autocomplete="email"
            :class="input"
            :aria-invalid="!!errors.email"
            @blur="validateField('email')"
          >
          <p v-if="errors.email" :class="err">
            {{ errors.email }}
          </p>
        </div>

        <div>
          <label for="password" :class="label">Password</label>
          <input
            id="password"
            v-model="form.password"
            type="password"
            autocomplete="new-password"
            :class="input"
            :aria-invalid="!!errors.password"
            @blur="validateField('password')"
          >
          <p v-if="errors.password" :class="err">
            {{ errors.password }}
          </p>
          <p v-else class="text-[0.74rem] text-parchment-dim mt-1.5 leading-[1.5]">
            8+ chars · upper · lower · digit · symbol
          </p>
        </div>

        <p v-if="serverError" :class="err">
          {{ serverError }}
        </p>

        <div class="flex items-center gap-4 flex-wrap mt-2">
          <button type="submit" :class="btnPrimary" :disabled="submitting">
            {{ submitting ? '≫ Inscribing…' : '≫ Inscribe' }}
          </button>
          <NuxtLink to="/login" class="font-display text-[0.78rem] uppercase tracking-[0.2em] text-parchment-dim hover:text-spark-soft no-underline">
            Already inscribed? Enter
          </NuxtLink>
        </div>
      </form>
    </section>
  </div>
</template>

<script setup lang="ts">
defineOptions({ inheritAttrs: false })
const props = withDefaults(defineProps<{
  variant?: 'default' | 'primary'
  to?: string
  href?: string
}>(), { variant: 'default' })

const classes = computed(() => [
  'inline-block font-display text-[0.88rem] uppercase tracking-[0.2em] px-6 py-3 border-2 border-arcane text-parchment no-underline transition-all hover:bg-spark hover:text-void hover:border-spark hover:[text-shadow:none] hover:[box-shadow:0_0_22px_var(--color-spark),inset_0_0_12px_rgba(255,255,255,0.4)] disabled:opacity-50 disabled:cursor-not-allowed',
  props.variant === 'primary' && '!border-spark text-spark-soft bg-arcane/40 [box-shadow:0_0_14px_rgba(0,217,255,0.25)]',
])
</script>

<template>
  <NuxtLink v-if="to" :to="to" v-bind="$attrs" :class="classes">
    <slot />
  </NuxtLink>
  <a v-else-if="href" :href="href" v-bind="$attrs" :class="classes">
    <slot />
  </a>
  <button v-else v-bind="$attrs" :class="classes">
    <slot />
  </button>
</template>

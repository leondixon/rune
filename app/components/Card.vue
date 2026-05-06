<script setup lang="ts">
withDefaults(defineProps<{ tag?: string }>(), { tag: 'section' })
</script>

<template>
  <component
    :is="tag"
    class="relative bg-panel/80 border-2 border-arcane [box-shadow:6px_6px_0_var(--color-arcane-deep),0_0_28px_rgba(0,217,255,0.06)_inset] p-7 transition-transform duration-200 hover:-translate-x-0.5 hover:-translate-y-0.5 hover:[box-shadow:8px_8px_0_var(--color-spark-deep),0_0_42px_rgba(0,217,255,0.14)_inset] before:absolute before:inset-0 before:pointer-events-none before:border before:border-gold/20 before:m-1"
  >
    <slot />
  </component>
</template>

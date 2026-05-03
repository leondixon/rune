<script setup lang="ts">
defineProps<{
  id: string
  label: string
  modelValue: string
  type?: string
  autocomplete?: string
  error?: string
  hint?: string
}>()
defineEmits<{
  (event: 'update:modelValue', value: string): void
  (event: 'blur'): void
}>()
</script>

<template>
  <div>
    <label
      :for="id"
      class="font-display text-[0.78rem] uppercase tracking-[0.22em] text-gold mb-2 block"
    >{{ label }}</label>
    <input
      :id="id"
      :type="type ?? 'text'"
      :value="modelValue"
      :autocomplete="autocomplete"
      :aria-invalid="!!error"
      class="w-full bg-void-soft/70 border-2 border-arcane text-parchment px-4 py-3 font-body text-[0.95rem] focus:outline-none focus:border-spark focus:[box-shadow:0_0_12px_rgba(0,217,255,0.4)] transition-colors"
      @input="$emit('update:modelValue', ($event.target as HTMLInputElement).value)"
      @blur="$emit('blur')"
    >
    <p
      v-if="error"
      class="text-[0.78rem] text-red-400 mt-1.5 font-display tracking-[0.1em]"
    >
      {{ error }}
    </p>
    <p
      v-else-if="hint"
      class="text-[0.74rem] text-parchment-dim mt-1.5 leading-[1.5]"
    >
      {{ hint }}
    </p>
  </div>
</template>

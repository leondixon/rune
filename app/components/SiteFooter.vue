<script setup lang="ts">
const year = new Date().getFullYear()
const line = ' ✦ ◇ ◆ ⟡ ◈ ⟡ ◆ ◇ '.repeat(5)
</script>

<template>
  <footer class="mt-16 border-t border-arcane bg-void-soft text-parchment-dim pt-6 pb-8 relative z-[2] [box-shadow:0_-2px_0_var(--color-arcane-deep)]">
    <div class="max-w-[920px] mx-auto px-5 text-center">
      <p class="text-arcane-soft text-[0.7rem] opacity-60 mb-3 overflow-hidden whitespace-nowrap font-body">{{ line }}</p>
      <p class="font-display text-[0.78rem] uppercase tracking-[0.22em]">
        <span class="text-parchment-dim">© {{ year }} · RUNE</span>
        <span class="mx-3 text-gold">⟡</span>
        <span class="text-parchment-dim">the scroll remembers what the mind forgets</span>
      </p>
    </div>
  </footer>
</template>

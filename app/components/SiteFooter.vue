<script setup lang="ts">
const year = new Date().getFullYear()
const line = '01'.repeat(36)
</script>

<template>
  <footer class="mt-16 border-t-2 border-dashed border-phosphor-deep bg-void-soft text-phosphor-dim pt-6 pb-8 relative z-[2]">
    <div class="max-w-[880px] mx-auto px-5 text-center">
      <p class="text-phosphor-deep text-[0.7rem] opacity-50 mb-2 overflow-hidden font-mono">{{ line }}</p>
      <p>
        <span class="font-mono text-[0.85rem] text-phosphor-dim">© {{ year }} · RUNE</span>
        <span class="mx-2 text-phosphor-deep">//</span>
        <span class="font-mono text-[0.85rem] text-phosphor-dim">there is no spoon — there is only the loop</span>
      </p>
    </div>
  </footer>
</template>

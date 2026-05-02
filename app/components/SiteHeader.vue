<script setup lang="ts">
const sigil = ` ⬥ ─ ◇ ─ ⬥
  ╲ ◆ ╱
   ◈
  ╱ ◆ ╲
 ⬥ ─ ◇ ─ ⬥`
</script>

<template>
  <header class="bg-void-soft text-parchment border-b border-arcane [box-shadow:0_3px_0_var(--color-arcane-deep),0_0_24px_rgba(0,217,255,0.08)] mb-10 relative z-[2]">
    <div class="max-w-[920px] mx-auto px-5 py-6 flex items-center justify-between gap-6 max-sm:flex-col max-sm:items-start">
      <NuxtLink to="/" class="flex items-center gap-5 no-underline text-parchment hover:text-spark-soft">
        <pre class="text-arcane-soft text-[0.55rem] m-0 font-body whitespace-pre leading-tight max-sm:hidden [text-shadow:0_0_8px_rgba(0,217,255,0.4)]">{{ sigil }}</pre>
        <div class="flex flex-col">
          <span class="font-decorative text-[2.6rem] tracking-[0.32em] leading-none text-parchment animate-pulse-arcane">RUNE</span>
          <span class="font-display text-[0.75rem] tracking-[0.32em] uppercase text-gold mt-1.5">⟡ inscribe · retrieve · ascend ⟡</span>
        </div>
      </NuxtLink>
      <nav class="flex gap-2 font-display text-[0.85rem] uppercase tracking-[0.18em] items-center">
        <NuxtLink
          to="/"
          active-class="!border-spark !text-spark-soft"
          class="text-parchment no-underline px-3 py-1.5 border border-transparent transition-colors hover:bg-arcane/40 hover:text-spark-soft"
        >
          Home
        </NuxtLink>
        <NuxtLink
          to="/#sigils"
          class="text-parchment no-underline px-3 py-1.5 border border-transparent transition-colors hover:bg-arcane/40 hover:text-spark-soft"
        >
          Codex
        </NuxtLink>
        <NuxtLink
          to="/#begin"
          class="text-spark-soft no-underline px-4 py-1.5 border border-spark bg-arcane/30 transition-all hover:bg-spark hover:text-void hover:[box-shadow:0_0_18px_var(--color-spark)]"
        >
          ≫ Scribe
        </NuxtLink>
      </nav>
    </div>
  </header>
</template>

<script setup lang="ts">
const glyphs = `  ┌─┐ ┌─┐ ┌─┐
  │█│ │█│ │█│
  └┬┘ └┬┘ └┬┘
   01  10  11`
</script>

<template>
  <header class="bg-void-soft text-phosphor border-b-2 border-phosphor-deep [box-shadow:0_4px_0_var(--color-phosphor-deep)] mb-10 relative z-[2]">
    <div class="max-w-[880px] mx-auto px-5 py-6 flex items-center justify-between gap-6 max-sm:flex-col max-sm:items-start">
      <NuxtLink to="/" class="group flex items-center gap-4 no-underline text-phosphor hover:text-phosphor-soft">
        <pre class="text-phosphor-deep text-[0.55rem] m-0 font-mono whitespace-pre leading-tight max-sm:hidden">{{ glyphs }}</pre>
        <div class="flex flex-col">
          <span class="font-pixel text-[2.4rem] tracking-[0.18em] leading-none text-phosphor [text-shadow:0_0_12px_var(--color-phosphor)]">RUNE</span>
          <span class="font-mono text-[0.78rem] text-phosphor-deep mt-1">// jack in. learn faster.</span>
        </div>
      </NuxtLink>
      <nav class="flex gap-3 font-mono text-[0.95rem] items-center">
        <NuxtLink
          to="/"
          active-class="!border-phosphor !text-phosphor-soft"
          class="text-phosphor no-underline px-3 py-1 border border-transparent transition-colors hover:bg-phosphor hover:text-void hover:[text-shadow:none]"
        >
          Home
        </NuxtLink>
        <NuxtLink
          to="/#how"
          class="text-phosphor no-underline px-3 py-1 border border-transparent transition-colors hover:bg-phosphor hover:text-void hover:[text-shadow:none]"
        >
          Method
        </NuxtLink>
        <NuxtLink
          to="/#start"
          class="text-phosphor no-underline px-3 py-1 border border-phosphor bg-phosphor/10 transition-colors hover:bg-phosphor hover:text-void hover:[text-shadow:none]"
        >
          _start
        </NuxtLink>
      </nav>
    </div>
  </header>
</template>

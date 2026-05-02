<script setup lang="ts">
const open = ref(false)
const route = useRoute()

watch(() => route.fullPath, () => {
  open.value = false
})

const navLinkCls = 'text-parchment no-underline px-3 py-2 border border-transparent transition-colors hover:bg-arcane/40 hover:text-spark-soft'
const ctaCls = 'text-spark-soft no-underline px-4 py-2 border border-spark bg-arcane/30 transition-all hover:bg-spark hover:text-void hover:[box-shadow:0_0_18px_var(--color-spark)]'
</script>

<template>
  <header class="bg-void-soft text-parchment border-b border-arcane [box-shadow:0_3px_0_var(--color-arcane-deep),0_0_24px_rgba(0,217,255,0.08)] mb-10 relative z-[2]">
    <div class="max-w-[920px] mx-auto px-5 py-5 flex items-center justify-between gap-6">
      <NuxtLink to="/" class="flex items-center gap-4 no-underline text-parchment hover:text-spark-soft">
        <span
          class="font-decorative text-[2.4rem] sm:text-[3rem] leading-none text-spark-soft [text-shadow:0_0_10px_rgba(0,217,255,0.7),0_0_22px_rgba(91,62,143,0.55)] flex items-center justify-center w-10 h-10 sm:w-12 sm:h-12 border border-arcane bg-arcane/20 rounded-full shrink-0"
          aria-hidden="true"
        >⟡</span>
        <div class="flex flex-col leading-none">
          <span class="font-decorative text-[1.9rem] sm:text-[2.6rem] tracking-[0.28em] sm:tracking-[0.32em] leading-none text-parchment animate-pulse-arcane">RUNE</span>
          <span class="hidden sm:block font-display text-[0.75rem] tracking-[0.32em] uppercase text-gold mt-1.5">⟡ inscribe · retrieve · ascend ⟡</span>
        </div>
      </NuxtLink>

      <button
        type="button"
        class="sm:hidden flex flex-col justify-center items-center gap-1.5 p-2.5 border border-arcane bg-arcane/20 transition-colors hover:bg-arcane/40 focus:outline-none focus:border-spark"
        :aria-expanded="open"
        aria-label="Toggle menu"
        aria-controls="mobile-nav"
        @click="open = !open"
      >
        <span
          class="block w-6 h-0.5 bg-spark-soft transition-transform duration-200 origin-center"
          :class="open ? 'translate-y-2 rotate-45' : ''"
        />
        <span
          class="block w-6 h-0.5 bg-spark-soft transition-opacity duration-200"
          :class="open ? 'opacity-0' : 'opacity-100'"
        />
        <span
          class="block w-6 h-0.5 bg-spark-soft transition-transform duration-200 origin-center"
          :class="open ? '-translate-y-2 -rotate-45' : ''"
        />
      </button>

      <nav class="hidden sm:flex gap-2 font-display text-[0.85rem] uppercase tracking-[0.18em] items-center">
        <NuxtLink to="/" active-class="!border-spark !text-spark-soft" :class="navLinkCls">Home</NuxtLink>
        <NuxtLink to="/#sigils" :class="navLinkCls">Codex</NuxtLink>
        <NuxtLink to="/#begin" :class="ctaCls">≫ Scribe</NuxtLink>
      </nav>
    </div>

    <Transition
      enter-active-class="transition-[max-height,opacity] duration-300 ease-out overflow-hidden"
      leave-active-class="transition-[max-height,opacity] duration-200 ease-in overflow-hidden"
      enter-from-class="max-h-0 opacity-0"
      enter-to-class="max-h-96 opacity-100"
      leave-from-class="max-h-96 opacity-100"
      leave-to-class="max-h-0 opacity-0"
    >
      <nav
        v-show="open"
        id="mobile-nav"
        class="sm:hidden border-t border-arcane bg-void-soft/95 backdrop-blur-sm font-display text-[0.85rem] uppercase tracking-[0.2em]"
      >
        <div class="max-w-[920px] mx-auto px-5 py-4 flex flex-col gap-2">
          <NuxtLink to="/" active-class="!border-spark !text-spark-soft" :class="navLinkCls" @click="open = false">Home</NuxtLink>
          <NuxtLink to="/#sigils" :class="navLinkCls" @click="open = false">Codex</NuxtLink>
          <NuxtLink to="/#begin" :class="ctaCls" @click="open = false">≫ Scribe</NuxtLink>
        </div>
      </nav>
    </Transition>
  </header>
</template>

<script setup lang="ts">
useHead({ title: 'RUNE — become a 10x developer through guided self-learning' })

const banner = `    ____  __  ___   ________
   / __ \\/ / / / | / / ____/
  / /_/ / / / /  |/ / __/
 / _, _/ /_/ / /|  / /___
/_/ |_|\\____/_/ |_/_____/

  > wake up, neo. the curriculum is loading_`

const pillars = [
  {
    code: '01',
    title: 'Feynman Loop',
    body: 'You don\'t learn it until you can teach it. Rune asks you to explain every concept back in plain language — then probes the gaps you didn\'t know you had.',
  },
  {
    code: '02',
    title: 'Interleaved Drills',
    body: 'Block practice feels productive but rots fast. Rune shuffles topics across sessions so retrieval gets harder — and the wiring gets deeper.',
  },
  {
    code: '03',
    title: 'Gamified Reps',
    body: 'XP, streaks, mastery tiers, boss-fight reviews. Spaced repetition with a scoreboard, so showing up tomorrow feels obvious.',
  },
  {
    code: '04',
    title: 'AI-Guided Path',
    body: 'A model that watches where you stall, where you bluff, and where you\'re strong — and rewrites tomorrow\'s queue accordingly.',
  },
]

const steps = [
  { n: '00', t: 'Calibrate', d: 'A short placement run maps what you actually know vs. what you think you know.' },
  { n: '01', t: 'Explain', d: 'Pick a concept. Teach it back to the agent. It plays the curious student — and the skeptical reviewer.' },
  { n: '02', t: 'Drill', d: 'Mixed-topic retrieval prompts. Short bursts. Daily streak. No skipping the hard ones.' },
  { n: '03', t: 'Review', d: 'Spaced repetition queue surfaces what\'s decaying before it\'s gone.' },
  { n: '04', t: 'Level', d: 'Mastery tiers unlock harder material. The tree grows. So do you.' },
]

const cardCls = 'bg-panel border-2 border-phosphor-deep [box-shadow:6px_6px_0_var(--color-phosphor-deep),0_0_24px_rgba(57,255,20,0.08)_inset] p-7 transition-transform duration-150 hover:-translate-x-0.5 hover:-translate-y-0.5 hover:[box-shadow:8px_8px_0_var(--color-phosphor),0_0_32px_rgba(57,255,20,0.15)_inset]'
const btnCls = 'inline-block font-mono text-[0.92rem] px-4 py-2 border-2 border-phosphor-deep text-phosphor no-underline tracking-wider transition-all hover:bg-phosphor hover:text-void hover:[text-shadow:none] hover:[box-shadow:0_0_18px_var(--color-phosphor)]'
const btnPrimaryCls = `${btnCls} !border-phosphor bg-phosphor/10`
const sectionHeading = 'font-mono text-[0.95rem] uppercase tracking-[0.18em] text-phosphor-deep mb-5 pb-2 border-b border-dashed border-phosphor-deep [text-shadow:none]'
</script>

<template>
  <div class="max-w-[880px] mx-auto px-5 pt-8 pb-16 relative z-[1]">
    <section :class="`${cardCls} mb-12`">
      <pre class="text-phosphor text-[0.72rem] leading-[1.05] mb-6 overflow-x-auto whitespace-pre font-mono [text-shadow:0_0_8px_var(--color-phosphor)]">{{ banner }}</pre>
      <h1 class="mb-4">
        10x is not a myth.<br>It's a <span class="text-amber [text-shadow:0_0_10px_rgba(255,176,0,0.5)]">training regimen</span>.
      </h1>
      <p class="text-[1.05rem] my-5 max-w-[62ch] text-phosphor-soft">
        RUNE is an AI-guided self-learning agent for developers. It runs you through the
        <strong class="font-bold">Feynman technique</strong>, <strong class="font-bold">interleaved practice</strong>, and
        <strong class="font-bold">spaced repetition</strong> — wrapped in a gamified loop that makes
        deliberate study the path of least resistance.
      </p>
      <div class="flex gap-3 flex-wrap my-5">
        <a id="start" href="#how" :class="btnPrimaryCls">&gt; jack_in</a>
        <a href="#how" :class="btnCls">read the protocol</a>
      </div>
      <p class="font-mono text-[0.85rem] text-phosphor-dim">
        booting curriculum daemon<span class="ml-1 text-phosphor animate-blink inline-block">_</span>
      </p>
    </section>

    <section id="how" class="mb-12">
      <h2 :class="sectionHeading">// the four pillars</h2>
      <div class="grid gap-6 grid-cols-[repeat(auto-fit,minmax(260px,1fr))]">
        <article v-for="p in pillars" :key="p.code" :class="cardCls">
          <span class="inline-block font-mono text-[0.72rem] uppercase tracking-[0.12em] text-phosphor px-2 py-0.5 border border-phosphor-deep mr-2">{{ p.code }}</span>
          <h3 class="mt-2 mb-2">{{ p.title }}</h3>
          <p>{{ p.body }}</p>
        </article>
      </div>
    </section>

    <section class="mb-12">
      <h2 :class="sectionHeading">// the loop</h2>
      <ol class="list-none p-0 flex flex-col gap-4">
        <li v-for="s in steps" :key="s.n" class="flex gap-5 px-5 py-4 border-l-[3px] border-phosphor-deep bg-panel-dark">
          <span class="font-pixel text-[2rem] text-phosphor leading-none min-w-[3ch] [text-shadow:0_0_8px_var(--color-phosphor)]">{{ s.n }}</span>
          <div>
            <h3 class="text-[1.2rem] mb-1">{{ s.t }}</h3>
            <p class="m-0 text-phosphor-soft">{{ s.d }}</p>
          </div>
        </li>
      </ol>
    </section>

    <section :class="`${cardCls} mb-12`">
      <h2 :class="sectionHeading">// why 10x</h2>
      <p class="mb-4">
        The 10x developer isn't a unicorn. It's someone who learns one notch faster than
        the loop they're in — compounded over years. The bottleneck isn't talent. It's
        the <strong class="font-bold">method</strong>: what you study, how you encode it, how often you
        retrieve it under pressure.
      </p>
      <p class="mb-4">
        Rune is that method, automated. An agent that won't let you fool yourself
        into thinking you understood the docs because you nodded at them.
      </p>
      <blockquote>
        "I cannot create what I do not understand." — R. Feynman
      </blockquote>
    </section>

    <section :class="`${cardCls} text-center`">
      <h2 class="mb-3">Ready to plug in?</h2>
      <p class="mb-5">The agent is waiting. The queue is empty until you fill it.</p>
      <div class="flex gap-3 flex-wrap justify-center">
        <a href="#start" :class="btnPrimaryCls">&gt; begin_calibration</a>
      </div>
    </section>
  </div>
</template>

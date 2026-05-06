<script setup lang="ts">
useHead({ title: 'RUNE — the rite of ten-fold ascension' })

const banner = `        .   ✦   .   ✦   .   ✦   .
     ╔══════════════════════════════╗
     ║  ⟡   ◈   ⟡   ◈   ⟡   ◈   ⟡  ║
     ║                              ║
     ║       R  ·  U  ·  N  ·  E    ║
     ║                              ║
     ║  ◈   ⟡   ◈   ⟡   ◈   ⟡   ◈  ║
     ╚══════════════════════════════╝
        .   ✦   .   ✦   .   ✦   .

        > the scroll opens. inscribe what you would remember.`

const divider = `   ── ⟡ ── ◇ ── ◆ ── ◇ ── ⟡ ──`

const pillars = [
  {
    code: 'I',
    sigil: '◇◆◇',
    title: 'The Feynman Loop',
    body: 'You do not know it until you can teach it. RUNE asks you to explain every concept back in plain tongue — then probes the seams of the explanations you only half-believe.',
  },
  {
    code: 'II',
    sigil: '⟡◈⟡',
    title: 'Interleaved Drills',
    body: 'Block practice flatters the mind and rots the memory. RUNE shuffles topics across sessions so retrieval bites — and the wiring deepens with each return.',
  },
  {
    code: 'III',
    sigil: '◈◆◈',
    title: 'Gamified Reps',
    body: 'XP, streaks, mastery tiers, boss-rite reviews. Spaced repetition with a scoreboard, so showing up tomorrow is the path of least resistance.',
  },
  {
    code: 'IV',
    sigil: '⬥◇⬥',
    title: 'AI-Guided Path',
    body: 'A runemaster that watches where you stall, where you bluff, and where you are strong — and re-inscribes tomorrow\'s queue accordingly.',
  },
]

const steps = [
  { n: '00', t: 'Attune', d: 'A short placement rite maps what you know vs. what you only think you know.' },
  { n: 'I', t: 'Inscribe', d: 'Pick a sigil. Teach it back. The agent plays the curious novice — and the skeptical scribe.' },
  { n: 'II', t: 'Drill', d: 'Mixed-topic retrieval prompts. Short bursts. Daily streak. No skipping the hard runes.' },
  { n: 'III', t: 'Recur', d: 'A spaced-repetition queue surfaces what is decaying — before it slips the scroll entirely.' },
  { n: 'IV', t: 'Ascend', d: 'Mastery tiers unlock graver material. The codex grows. So do you.' },
]

const sectionHeading = 'font-display text-[1rem] uppercase tracking-[0.28em] text-gold mb-6 pb-3 border-b border-arcane flex items-center gap-3 [text-shadow:0_0_10px_rgba(201,169,97,0.4)]'
</script>

<template>
  <div class="max-w-[920px] mx-auto px-5 pt-8 pb-16 relative z-[1]">
    <Card class="mb-12">
      <pre class="text-spark-soft text-[0.78rem] leading-[1.1] mb-6 overflow-x-auto whitespace-pre font-body [text-shadow:0_0_8px_rgba(0,217,255,0.5),0_0_20px_rgba(91,62,143,0.4)]">{{ banner }}</pre>
      <h1 class="mb-5">
        Ten-fold is not a myth.<br>
        It is a <span class="text-gold [text-shadow:0_0_12px_rgba(201,169,97,0.6)]">rite of inscription</span>.
      </h1>
      <p class="text-[1.08rem] my-5 max-w-[64ch] text-parchment leading-[1.75]">
        RUNE is an AI-guided self-learning agent for developers — named for the World Runes themselves,
        fragments of pure knowledge so dangerous they reshape what they touch. RUNE binds three forces of
        mastery: the <strong>Feynman technique</strong>, <strong>interleaved practice</strong>, and
        <strong>spaced repetition</strong> — woven into a gamified rite that turns deliberate study into
        a habit you actually keep.
      </p>
      <div class="flex gap-3 flex-wrap items-center my-6">
        <Button id="begin" to="/register" variant="primary">
          ≫ Inscribe
        </Button>
        <Button href="#sigils">
          Read the Codex
        </Button>
        <NuxtLink to="/login" class="ml-2 font-display text-[0.78rem] uppercase tracking-[0.2em] text-parchment-dim hover:text-spark-soft no-underline border-b border-transparent hover:border-spark">
          Already inscribed? Enter
        </NuxtLink>
      </div>
      <p class="font-display text-[0.78rem] uppercase tracking-[0.24em] text-parchment-dim">
        the runemaster awakens<span class="ml-1 text-spark animate-blink inline-block">_</span>
      </p>
    </Card>

    <pre class="text-arcane-soft text-center text-[0.85rem] mb-10 opacity-70 font-body animate-glow-drift">{{ divider }}</pre>

    <section id="sigils" class="mb-12">
      <h2 :class="sectionHeading">
        <span class="text-spark">⟡</span> The Four Sigils
      </h2>
      <div class="grid gap-6 grid-cols-[repeat(auto-fit,minmax(280px,1fr))]">
        <Card v-for="p in pillars" :key="p.code" tag="article">
          <div class="flex items-center justify-between mb-3">
            <span class="font-decorative text-[1.4rem] tracking-[0.18em] text-gold [text-shadow:0_0_8px_rgba(201,169,97,0.5)]">{{ p.code }}</span>
            <span class="font-body text-[1.1rem] text-spark-soft [text-shadow:0_0_10px_rgba(0,217,255,0.6)]">{{ p.sigil }}</span>
          </div>
          <h3 class="mb-3">
            {{ p.title }}
          </h3>
          <p class="text-parchment leading-[1.7]">
            {{ p.body }}
          </p>
        </Card>
      </div>
    </section>

    <pre class="text-arcane-soft text-center text-[0.85rem] mb-10 opacity-70 font-body animate-glow-drift">{{ divider }}</pre>

    <section class="mb-12">
      <h2 :class="sectionHeading">
        <span class="text-spark">⟡</span> The Rite
      </h2>
      <ol class="list-none p-0 flex flex-col gap-4">
        <li
          v-for="s in steps"
          :key="s.n"
          class="flex gap-6 px-6 py-5 border-l-[3px] border-gold bg-panel-dark/70 relative before:absolute before:left-0 before:top-0 before:h-full before:w-px before:bg-spark/40 before:translate-x-[3px]"
        >
          <span class="font-decorative text-[2.2rem] text-spark-soft leading-none min-w-[3.5ch] [text-shadow:0_0_10px_rgba(0,217,255,0.7),0_0_22px_rgba(91,62,143,0.5)]">{{ s.n }}</span>
          <div>
            <h3 class="text-[1.15rem] mb-1.5 text-gold-soft">
              {{ s.t }}
            </h3>
            <p class="m-0 text-parchment leading-[1.7]">
              {{ s.d }}
            </p>
          </div>
        </li>
      </ol>
    </section>

    <pre class="text-arcane-soft text-center text-[0.85rem] mb-10 opacity-70 font-body animate-glow-drift">{{ divider }}</pre>

    <Card class="mb-12">
      <h2 :class="sectionHeading">
        <span class="text-spark">⟡</span> Why Ascend
      </h2>
      <p class="mb-4 text-parchment leading-[1.75]">
        The ten-fold developer is no unicorn. It is one who learns a single notch faster than the loop
        they walk in — compounded across years. The bottleneck is not talent. It is the
        <strong>method</strong>: what you study, how you encode it, how often you retrieve it under pressure.
      </p>
      <p class="mb-5 text-parchment leading-[1.75]">
        RUNE is that method, automated. A runemaster that will not let you mistake reading the docs for
        understanding them.
      </p>
      <blockquote>
        "I cannot create what I do not understand." — R. Feynman
      </blockquote>
    </Card>

    <Card class="text-center">
      <h2 class="mb-4">
        Ready to inscribe?
      </h2>
      <p class="mb-6 text-parchment leading-[1.7]">
        The scroll is blank. The runemaster waits. The first sigil is yours to mark.
      </p>
      <div class="flex gap-3 flex-wrap justify-center">
        <Button to="/register" variant="primary">
          ≫ Begin Attunement
        </Button>
      </div>
    </Card>
  </div>
</template>

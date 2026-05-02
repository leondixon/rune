import tailwindcss from '@tailwindcss/vite'

export default defineNuxtConfig({
  compatibilityDate: '2026-05-02',
  devtools: { enabled: true },
  future: {
    compatibilityVersion: 4,
  },
  css: ['~/assets/css/main.css'],
  vite: {
    plugins: [tailwindcss()],
  },
  app: {
    head: {
      title: 'RUNE',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'AI-guided self-learning for developers. Feynman technique, interleaved practice, gamified loop.' },
      ],
    },
  },
})

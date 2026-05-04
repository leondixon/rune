import antfu from '@antfu/eslint-config'

export default antfu({
  vue: true,
  typescript: true,
  formatters: true,
  ignores: ['.nuxt/**', '.output/**', 'node_modules/**', '.harness/**', 'drizzle/**'],
  rules: {
    'unicorn/no-null': ['error', { checkStrictEquality: false }],
  },
})

import process from 'node:process'
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: '.',
  workers: 1,
  retries: 0,
  reporter: [['list']],
  use: {
    baseURL: process.env.BASE_URL,
    screenshot: 'off',
    trace: 'retain-on-failure',
  },
})

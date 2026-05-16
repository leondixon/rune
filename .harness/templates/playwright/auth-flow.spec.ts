import { mkdirSync } from 'node:fs'
import path from 'node:path'
import process from 'node:process'
import { expect, test } from '@playwright/test'

const SCREENSHOT_ROOT = process.env.SCREENSHOT_DIR
if (!SCREENSHOT_ROOT)
  throw new Error('SCREENSHOT_DIR env var required')

const SHOT_DIR = path.join(SCREENSHOT_ROOT, 'auth-flow')
mkdirSync(SHOT_DIR, { recursive: true })

const shot = (name: string) => path.join(SHOT_DIR, name)

test('register → cookie → me → logout → login → me → learn/new', async ({ page, context }) => {
  test.setTimeout(90_000)
  const stamp = Date.now()
  const email = `harness-${stamp}@example.test`
  const password = 'Harness-Test-1!'
  const firstName = 'Harness'
  const lastName = 'Runner'

  // 1. Render register page (visual proof) and pre-fill the form for the screenshot.
  await page.goto('/register')
  await page.waitForLoadState('networkidle')
  await page.locator('#firstName').fill(firstName)
  await page.locator('#lastName').fill(lastName)
  await page.locator('#email').fill(email)
  await page.locator('#password').fill(password)
  await page.screenshot({ path: shot('01-register-filled.png'), fullPage: true })

  // 2. Register via API. First request triggers seed; allow extra time.
  const registerRes = await page.request.post('/api/auth/register', {
    data: { firstName, lastName, email, password },
    timeout: 60_000,
  })
  expect(registerRes.status(), await registerRes.text()).toBe(200)
  const registerBody = await registerRes.json()
  expect(registerBody.user?.email).toBe(email)
  expect(registerBody.user?.firstName).toBe(firstName)

  // 3. Cookie set
  const cookiesAfterRegister = await context.cookies()
  expect(cookiesAfterRegister.find(c => c.name === 'rune_session')?.value).toBeTruthy()

  // 4. /api/auth/me reflects the user
  const meAfterRegister = await page.request.get('/api/auth/me')
  expect(meAfterRegister.ok()).toBeTruthy()
  expect((await meAfterRegister.json()).user?.email).toBe(email)

  // 5. Render the home page while logged in (visual proof).
  await page.goto('/')
  await page.screenshot({ path: shot('02-home-after-register.png'), fullPage: true })

  // 6. Logout
  const logoutRes = await page.request.post('/api/auth/logout')
  expect(logoutRes.ok()).toBeTruthy()
  await context.clearCookies()

  // 7. Render login page
  await page.goto('/login')
  await page.waitForLoadState('networkidle')
  await page.locator('#email').fill(email)
  await page.locator('#password').fill(password)
  await page.screenshot({ path: shot('03-login-filled.png'), fullPage: true })

  // 8. Login via API
  const loginRes = await page.request.post('/api/auth/login', {
    data: { email, password },
  })
  expect(loginRes.status(), await loginRes.text()).toBe(200)
  expect((await loginRes.json()).user?.email).toBe(email)

  const cookiesAfterLogin = await context.cookies()
  expect(cookiesAfterLogin.find(c => c.name === 'rune_session')?.value).toBeTruthy()

  // 9. /api/auth/me again
  const meAfterLogin = await page.request.get('/api/auth/me')
  expect(meAfterLogin.ok()).toBeTruthy()
  expect((await meAfterLogin.json()).user?.email).toBe(email)

  // 10. /api/learn/new returns seeded domains
  const learnRes = await page.request.get('/api/learn/new?limit=5')
  expect(learnRes.status(), await learnRes.text()).toBe(200)
  const learnBody = await learnRes.json()
  expect(Array.isArray(learnBody.items)).toBe(true)
  expect(learnBody.items.length).toBeGreaterThan(0)
  for (const item of learnBody.items) {
    expect(item.slug).toBeTruthy()
    expect(item.name).toBeTruthy()
  }
})

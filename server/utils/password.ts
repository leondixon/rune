import { Buffer } from 'node:buffer'
import { randomBytes, scryptSync, timingSafeEqual } from 'node:crypto'

const N = 1 << 15
const r = 8
const p = 1
const KEY_LEN = 64
const SALT_LEN = 16

export function hashPassword(plain: string): string {
  const salt = randomBytes(SALT_LEN)
  const hash = scryptSync(plain, salt, KEY_LEN, { N, r, p, maxmem: 64 * 1024 * 1024 })
  return `scrypt$${N}$${r}$${p}$${salt.toString('hex')}$${hash.toString('hex')}`
}

export function verifyPassword(plain: string, stored: string): boolean {
  const parts = stored.split('$')
  if (parts.length !== 6 || parts[0] !== 'scrypt')
    return false

  const [, nStr, rStr, pStr, saltHex, hashHex] = parts
  const storedN = Number(nStr)
  const storedR = Number(rStr)
  const storedP = Number(pStr)
  if (!Number.isFinite(storedN) || !Number.isFinite(storedR) || !Number.isFinite(storedP))
    return false

  const salt = Buffer.from(saltHex!, 'hex')
  const expected = Buffer.from(hashHex!, 'hex')
  const actual = scryptSync(plain, salt, expected.length, { N: storedN, r: storedR, p: storedP, maxmem: 64 * 1024 * 1024 })

  return actual.length === expected.length && timingSafeEqual(actual, expected)
}

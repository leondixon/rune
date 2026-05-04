import { z } from 'zod'

const strongPassword = z
  .string()
  .min(8, 'At least 8 characters')
  .max(128, 'At most 128 characters')
  .regex(/[a-z]/, 'Must include a lowercase letter')
  .regex(/[A-Z]/, 'Must include an uppercase letter')
  .regex(/\d/, 'Must include a digit')
  .regex(/[^A-Z0-9]/i, 'Must include a symbol')

const name = z
  .string()
  .trim()
  .min(1, 'Required')
  .max(64, 'At most 64 characters')
  .regex(/^[\p{L}'\- ]+$/u, 'Letters, spaces, hyphens, apostrophes only')

export const registerSchema = z.object({
  firstName: name,
  lastName: name,
  email: z.string().trim().toLowerCase().email('Invalid email').max(254),
  password: strongPassword,
})

export const loginSchema = z.object({
  email: z.string().trim().toLowerCase().email('Invalid email').max(254),
  password: z.string().min(1, 'Required').max(128),
})

export type RegisterInput = z.infer<typeof registerSchema>
export type LoginInput = z.infer<typeof loginSchema>

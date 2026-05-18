/**
 * payments.js — client-side helpers for Stripe and BlockCypher testnet.
 *
 * BlockCypher calls go through the Vite proxy (/blockcypher → api.blockcypher.com)
 * to avoid browser CORS restrictions in development.
 * In production, route these through the FastAPI backend.
 */

const BC = '/blockcypher/v1/btc/test3'

// Approximate EUR → BTC rate for demo/testing
export const EUR_TO_BTC = 0.0000145

/**
 * Generate a fresh Bitcoin testnet3 address via BlockCypher.
 * Returns the address string.
 */
export async function generateBtcAddress() {
  const res = await fetch(`${BC}/addrs`, { method: 'POST' })
  if (!res.ok) throw new Error(`BlockCypher error: ${res.status}`)
  const data = await res.json()
  return data.address
}

/**
 * Fetch the total received satoshis for a testnet address.
 * Returns 0 if the request fails (network / rate-limit).
 */
export async function getBtcReceived(address) {
  try {
    const res = await fetch(`${BC}/addrs/${address}/balance`)
    if (!res.ok) return 0
    const data = await res.json()
    return data.total_received ?? 0
  } catch {
    return 0
  }
}

/**
 * Luhn algorithm — validates a stripped card number string.
 */
export function luhn(num) {
  let sum = 0
  let odd = false
  for (let i = num.length - 1; i >= 0; i--) {
    let d = parseInt(num[i], 10)
    if (odd) { d *= 2; if (d > 9) d -= 9 }
    sum += d
    odd = !odd
  }
  return sum % 10 === 0
}

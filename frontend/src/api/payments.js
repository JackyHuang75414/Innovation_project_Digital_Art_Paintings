import { http } from './http'

// Approximate EUR → BTC rate for demo/testing
export const EUR_TO_BTC = 0.0000145

export const confirmDemoPayment = payload => http.post('/payments/demo/confirm', payload)
export const createBitcoinPayment = payload => http.post('/payments/bitcoin/address', payload)
export const getBitcoinPayment = paymentId => http.get(`/payments/bitcoin/${paymentId}`)

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

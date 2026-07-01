import { http } from './http'

export const chatWithAi = payload => http.post('/ai/chat', payload)

import { http } from './http'

export const createOrder = (payload) => http.post('/orders', payload)
export const getOrder = (id) => http.get(`/orders/${id}`)
export const getMyOrders = () => http.get('/orders/me')

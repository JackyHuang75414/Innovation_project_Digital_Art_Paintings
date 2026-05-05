import axios from 'axios'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
})

export const createOrder = (payload) => http.post('/orders', payload)
export const getOrder = (id) => http.get(`/orders/${id}`)
export const getMyOrders = () => http.get('/orders/me')

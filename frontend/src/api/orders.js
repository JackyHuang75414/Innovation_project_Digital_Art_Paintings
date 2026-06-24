import http from './http'

// Backend: POST /orders/create (requires JWT)
export const createOrder = (payload) => http.post('/orders/create', payload)

// Backend: GET /orders/detail?id= (requires JWT)
export const getOrder = (id) => http.get('/orders/detail', { params: { id } })

// Backend: GET /orders/me (requires JWT)
export const getMyOrders = () => http.get('/orders/me')

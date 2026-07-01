import axios from 'axios'

export const TOKEN_KEY = 'artex_token'

export const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
})

http.interceptors.request.use(config => {
  const token = localStorage.getItem(TOKEN_KEY)
  if (token) config.headers.Authorization = token
  return config
})

http.interceptors.response.use(response => {
  const body = response.data
  if (body && typeof body === 'object' && 'code' in body && 'data' in body) {
    if (body.code !== 0) {
      return Promise.reject(new Error(body.message || 'Request failed'))
    }
    response.data = body.data
  }
  return response
})

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
      const error = new Error(body.message || 'Request failed')
      error.response = response
      return Promise.reject(error)
    }
    response.data = body.data
  }
  return response
}, error => {
  const message = error.response?.data?.message
  if (message) error.message = message
  if (error.response?.status === 401) {
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem('artex_user')
  }
  return Promise.reject(error)
})

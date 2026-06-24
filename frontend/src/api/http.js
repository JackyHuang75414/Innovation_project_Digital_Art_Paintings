import axios from 'axios'

const http = axios.create({
  baseURL: '/api',
  timeout: 10000,
})

// Inject JWT token on every request
http.interceptors.request.use((config) => {
  const token = localStorage.getItem('artex_jwt')
  if (token) {
    config.headers['Authorization'] = token
  }
  return config
})

// Unwrap backend Result<T>: { code, message, data } → data
// Throws on code !== 0 so callers can catch errors uniformly
http.interceptors.response.use(
  (response) => {
    const result = response.data
    if (result && typeof result === 'object' && 'code' in result) {
      if (result.code !== 0) {
        return Promise.reject(new Error(result.message || 'API error'))
      }
      return result.data
    }
    return response.data
  },
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('artex_jwt')
    }
    // Attach a human-readable message for display
    const msg = error.response?.data?.message
      || error.response?.data?.error
      || error.message
    error.displayMessage = msg
    return Promise.reject(error)
  }
)

export default http

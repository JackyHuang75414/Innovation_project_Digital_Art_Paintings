import http from './http'

export const register = (name, email, password) => {
  const params = new URLSearchParams({ name, email, password })
  return http.post('/user/register', params, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  })
}

export const loginBackend = (name, password) => {
  const params = new URLSearchParams({ name, password })
  return http.post('/user/login', params, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  })
}

export const getMe = () => http.get('/user/me')

// Sends a password-reset email; backend: POST /user/forgot-password
export const forgotPassword = (email) =>
  http.post('/user/forgot-password', { email })

// Resets password using the token from the email link; backend: POST /user/reset-password
export const resetPassword = (token, newPassword) =>
  http.post('/user/reset-password', { token, newPassword })

// Verifies a Google ID token and returns an ArtEx JWT; backend: POST /user/google-login
export const googleLogin = (credential) =>
  http.post('/user/google-login', { credential })

// Permanently deletes the authenticated user's account; backend: DELETE /user/me
export const deleteAccount = () => http.delete('/user/me')

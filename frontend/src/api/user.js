import { http, TOKEN_KEY } from './http'

export async function loginUser(name, password) {
  const { data: token } = await http.post('/user/login', null, { params: { name, password } })
  localStorage.setItem(TOKEN_KEY, token)
  const { data: user } = await http.get('/user/me')
  return { token, user }
}

export async function registerUser(name, email, password) {
  const { data } = await http.post('/user/register', null, { params: { name, email, password } })
  return data
}

export async function getCurrentUser() {
  const { data } = await http.get('/user/me')
  return data
}

export function logoutUser() {
  localStorage.removeItem(TOKEN_KEY)
}

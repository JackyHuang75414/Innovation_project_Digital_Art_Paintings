import axios from 'axios'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
})

export const getArtworks = (params = {}) => http.get('/artworks', { params })
export const getArtwork = (id) => http.get(`/artworks/${id}`)
export const getRecommendations = (artworkId) => http.get(`/artworks/${artworkId}/recommendations`)
export const searchArtworks = (query) => http.get('/artworks/search', { params: { q: query } })

import { http } from './http'

export const getArtworks = (params = {}) => http.get('/artworks', { params })
export const getArtwork = (id) => http.get(`/artworks/${id}`)
export const getRecommendations = (artworkId) => http.get(`/artworks/${artworkId}/recommendations`)
export const searchArtworks = (query) => http.get('/artworks/search', { params: { q: query } })

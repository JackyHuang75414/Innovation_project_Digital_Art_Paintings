import http from './http'

// Backend: GET /artworks/list
export const getArtworks = (params = {}) => http.get('/artworks/list', { params })

// Backend: GET /artworks/detail?id=
export const getArtwork = (id) => http.get('/artworks/detail', { params: { id } })

// Backend: GET /artworks/recommendations?id=&limit=
export const getRecommendations = (artworkId, limit = 4) =>
  http.get('/artworks/recommendations', { params: { id: artworkId, limit } })

// Search is just list with q param
export const searchArtworks = (query) => http.get('/artworks/list', { params: { q: query } })

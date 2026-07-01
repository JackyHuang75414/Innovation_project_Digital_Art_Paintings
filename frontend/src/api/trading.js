import { http } from './http'

export const getMarketArtworks = () => http.get('/market/artworks')
export const getMarketArtwork = id => http.get(`/market/artworks/${id}`)
export const getOrderBook = id => http.get(`/market/artworks/${id}/order-book`)
export const getTrades = id => http.get(`/market/artworks/${id}/trades`)
export const getPriceHistory = id => http.get(`/market/artworks/${id}/price-history`)
export const getPortfolio = () => http.get('/account/portfolio')
export const executeSpot = payload => http.post('/trades/spot', payload)
export const openPerp = payload => http.post('/trades/perp/open', payload)
export const closePerp = posId => http.post(`/trades/perp/close/${posId}`)
export const setTpSl = payload => http.post('/account/tpsl', payload)
export const cancelTpSl = id => http.delete(`/account/tpsl/${id}`)

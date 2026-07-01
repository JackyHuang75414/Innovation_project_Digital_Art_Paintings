import { http } from './http'

export const addWishlist = artworkId => http.post('/wishlist', null, { params: { artworkId } })
export const removeWishlist = artworkId => http.delete('/wishlist', { params: { artworkId } })
export const getMyWishlist = () => http.get('/wishlist/me')

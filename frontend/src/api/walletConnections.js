import { http } from './http'

export const getWalletConnections = () => http.get('/account/wallet-connections')

export const connectWallet = payload => http.post('/account/wallet-connections', payload)

export const disconnectWallet = id => http.delete(`/account/wallet-connections/${id}`)

export const disconnectActiveWallet = () => http.delete('/account/wallet-connections/active')

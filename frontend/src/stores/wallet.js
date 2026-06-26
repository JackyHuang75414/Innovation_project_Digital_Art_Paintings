import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import {
  connectWallet,
  disconnectActiveWallet,
  disconnectWallet,
  getWalletConnections,
} from '@/api/walletConnections'

export const WALLETS = [
  {
    id: 'testwallet',
    name: 'Test Wallet',
    description: 'Instant demo wallet — no extension required',
    chain: 'TEST',
    installUrl: null,
    color: '#22c55e',
    isTest: true,
  },
  {
    id: 'metamask',
    name: 'MetaMask',
    description: 'The most popular Ethereum wallet',
    chain: 'ETH',
    installUrl: 'https://metamask.io/download/',
    color: '#f6851b',
  },
  {
    id: 'coinbase',
    name: 'Coinbase Wallet',
    description: 'Self-custody wallet by Coinbase',
    chain: 'ETH',
    installUrl: 'https://www.coinbase.com/wallet/downloads',
    color: '#0052ff',
  },
  {
    id: 'walletconnect',
    name: 'WalletConnect',
    description: 'Connect 300+ mobile wallets via QR',
    chain: 'Multi',
    installUrl: null,
    color: '#3b99fc',
  },
  {
    id: 'phantom',
    name: 'Phantom',
    description: 'The leading Solana wallet',
    chain: 'SOL',
    installUrl: 'https://phantom.app/',
    color: '#ab9ff2',
  },
]

export const useWalletStore = defineStore('wallet', () => {
  const connectionId = ref(null)
  const address     = ref(null)
  const balanceEth  = ref(null)  // ETH or SOL balance
  const chainId     = ref(null)
  const walletType  = ref(null)  // 'metamask' | 'coinbase' | 'phantom' | 'walletconnect'
  const isConnecting = ref(false)
  const connectError = ref(null)
  const isLoadingConnection = ref(false)

  const isConnected   = computed(() => !!address.value)
  const shortAddress  = computed(() =>
    address.value ? address.value.slice(0, 6) + '…' + address.value.slice(-4) : null
  )
  const activeWallet  = computed(() => WALLETS.find(w => w.id === walletType.value) ?? null)

  // ── Ethereum provider helpers ─────────────────────────────────────────────

  function _getEthProvider(walletId) {
    if (typeof window === 'undefined') return null
    if (walletId === 'coinbase' && window.coinbaseWalletExtension) return window.coinbaseWalletExtension
    if (window.ethereum) {
      // Multiple injected providers — find the right one
      if (window.ethereum.providers?.length) {
        const found = window.ethereum.providers.find(p =>
          walletId === 'metamask' ? p.isMetaMask && !p.isCoinbaseWallet
          : walletId === 'coinbase' ? p.isCoinbaseWallet
          : true
        )
        return found ?? window.ethereum.providers[0]
      }
      return window.ethereum
    }
    return null
  }

  function _isEthWalletInstalled(walletId) {
    if (walletId === 'metamask') {
      const p = _getEthProvider('metamask')
      return !!(p?.isMetaMask)
    }
    if (walletId === 'coinbase') {
      return !!(window.coinbaseWalletExtension || window.ethereum?.isCoinbaseWallet)
    }
    return false
  }

  // ── Connect ────────────────────────────────────────────────────────────────

  function applyConnection(connection) {
    connectionId.value = connection.id ?? null
    address.value = connection.address ?? null
    walletType.value = connection.walletType ?? null
    chainId.value = connection.chainId ?? null
    balanceEth.value = connection.balanceNative != null ? String(connection.balanceNative) : null
  }

  async function persistConnection() {
    const response = await connectWallet({
      walletType: walletType.value,
      address: address.value,
      chainId: chainId.value,
      balanceNative: balanceEth.value,
    })
    applyConnection(response.data)
  }

  async function loadConnection() {
    isLoadingConnection.value = true
    try {
      const response = await getWalletConnections()
      const connections = response.data ?? []
      if (connections.length > 0) {
        applyConnection(connections[0])
      } else {
        clearLocal()
      }
    } catch {
      clearLocal()
    } finally {
      isLoadingConnection.value = false
    }
  }

  async function connect(walletId) {
    connectError.value = null
    isConnecting.value = true

    // Test wallet: instant connection, no extension needed
    if (walletId === 'testwallet') {
      await new Promise(r => setTimeout(r, 600))  // brief animation
      address.value    = '0xTest4rtEx00DemoAcc0unt'
      walletType.value = 'testwallet'
      balanceEth.value = '10.0000'
      chainId.value    = 'test-1337'
      try {
        await persistConnection()
        return { ok: true }
      } catch (e) {
        clearLocal()
        connectError.value = 'backend_error'
        return { ok: false, code: 'backend_error', msg: e.message }
      } finally {
        isConnecting.value = false
      }
    }

    try {
      if (walletId === 'metamask' || walletId === 'coinbase') {
        const provider = _getEthProvider(walletId)
        if (!provider) {
          connectError.value = 'not_installed'
          return { ok: false, code: 'not_installed' }
        }

        const accounts = await provider.request({ method: 'eth_requestAccounts' })
        if (!accounts?.length) throw new Error('No accounts returned')

        address.value    = accounts[0]
        walletType.value = walletId

        // Fetch balance
        const balHex = await provider.request({ method: 'eth_getBalance', params: [accounts[0], 'latest'] })
        balanceEth.value = (parseInt(balHex, 16) / 1e18).toFixed(4)

        chainId.value = await provider.request({ method: 'eth_chainId' })

        // React to external account/chain changes
        provider.on?.('accountsChanged', accs => { address.value = accs[0] ?? null })
        provider.on?.('chainChanged',    id  => { chainId.value = id })

        await persistConnection()
        return { ok: true }
      }

      if (walletId === 'phantom') {
        if (!window.solana?.isPhantom) {
          connectError.value = 'not_installed'
          return { ok: false, code: 'not_installed' }
        }
        const resp = await window.solana.connect()
        address.value    = resp.publicKey.toString()
        walletType.value = 'phantom'
        balanceEth.value = null  // SOL balance would need an RPC call; omit for now
        chainId.value    = 'solana-mainnet'
        window.solana.on?.('disconnect', disconnect)
        await persistConnection()
        return { ok: true }
      }

      if (walletId === 'walletconnect') {
        // WalletConnect requires the SDK; return a signal to show QR UI
        return { ok: false, code: 'show_qr' }
      }

      return { ok: false, code: 'unknown_wallet' }
    } catch (e) {
      const code = e.code === 4001 ? 'rejected' : 'error'
      connectError.value = code
      return { ok: false, code, msg: e.message }
    } finally {
      isConnecting.value = false
    }
  }

  function clearLocal() {
    if (walletType.value === 'phantom') window.solana?.disconnect?.()
    connectionId.value = null
    address.value    = null
    balanceEth.value = null
    chainId.value    = null
    walletType.value = null
    connectError.value = null
  }

  async function disconnect() {
    const id = connectionId.value
    try {
      if (id) {
        await disconnectWallet(id)
      } else {
        await disconnectActiveWallet()
      }
    } catch {
      // Keep the UI responsive even if the active connection was already gone.
    } finally {
      clearLocal()
    }
  }

  function isInstalled(walletId) {
    if (walletId === 'metamask' || walletId === 'coinbase') return _isEthWalletInstalled(walletId)
    if (walletId === 'phantom') return !!(window.solana?.isPhantom)
    if (walletId === 'walletconnect') return true  // protocol, always "available"
    return false
  }

  return {
    connectionId, address, balanceEth, chainId, walletType,
    isConnecting, connectError, isLoadingConnection,
    isConnected, shortAddress, activeWallet,
    WALLETS,
    connect, disconnect, clearLocal, loadConnection, isInstalled,
  }
})

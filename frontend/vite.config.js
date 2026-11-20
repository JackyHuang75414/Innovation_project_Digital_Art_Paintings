import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')

  return {
    plugins: [vue(), tailwindcss()],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
      },
    },
    server: {
      proxy: {
        // Backend API
        '/api': 'http://localhost:8000',

        // DeepSeek LLM — API key injected server-side, never exposed to browser
        '/llm-api': {
          target: 'https://api.deepseek.com',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/llm-api/, ''),
          configure: (proxy) => {
            proxy.on('proxyReq', (proxyReq) => {
              proxyReq.setHeader('Authorization', `Bearer ${env.LLM_API_KEY}`)
            })
          },
        },

        // CoinGecko — live crypto prices (free, no key, bypasses CORS)
        '/coingecko': {
          target: 'https://api.coingecko.com',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/coingecko/, ''),
        },

        // BlockCypher testnet — bypasses browser CORS
        '/blockcypher': {
          target: 'https://api.blockcypher.com',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/blockcypher/, ''),
        },
      },
    },
  }
})

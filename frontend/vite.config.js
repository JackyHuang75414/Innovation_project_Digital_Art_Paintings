import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig(({ mode }) => {
  // Load ALL env vars (incl. those without VITE_ prefix) — server-side only
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

        // DeepSeek AI — Authorization header injected server-side; key never reaches browser
        '/llm-api': {
          target: 'https://api.deepseek.com',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/llm-api/, ''),
          headers: env.LLM_API_KEY
            ? { Authorization: `Bearer ${env.LLM_API_KEY}` }
            : {},
        },
      },
    },
  }
})

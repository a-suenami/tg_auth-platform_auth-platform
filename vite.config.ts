import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import * as path from 'path';

export default defineConfig({
  plugins: [
    RubyPlugin(),
  ],
  server: {
    hmr: {
      host: process.env.VITE_SERVER_HMR_HOST,
      clientPort: Number(process.env.VITE_SERVER_HMR_PORT),
    },
  },
  resolve: {
    alias: {
      '@app': path.resolve(__dirname, 'app/frontend'),
    },
  },
  define: {
    global: {}, // global is not defined が発生するため
  },
})


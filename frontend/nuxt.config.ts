// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },

  devServer: {
    port: 3001,
  },

  runtimeConfig: {
    // Server-only: used by SSR to reach the backend on the Docker internal network.
    // Override via API_BASE_INTERNAL env var in docker-compose.
    apiBaseInternal:
      process.env.API_BASE_INTERNAL ?? 'http://localhost:3000/api',

    public: {
      // Browser-side (and dev SSR): reaches backend through the exposed host port.
      // Override via NUXT_PUBLIC_API_BASE env var.
      apiBase: process.env.NUXT_PUBLIC_API_BASE ?? 'http://localhost:3000/api',
    },
  },
});

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },

  devServer: {
    port: 3001,
  },

  runtimeConfig: {
    public: {
      // Backend NestJS: http://localhost:3000/api
      apiBase: process.env.NUXT_PUBLIC_API_BASE ?? 'http://localhost:3000/api',
    },
  },
});

/**
 * Returns the correct API base URL for the current execution context.
 *
 * During SSR (server-side) we use the private `apiBaseInternal` config key
 * which points to the backend's Docker-internal hostname (e.g. http://backend:3000/api).
 *
 * In the browser we use `public.apiBase` which points to the host-exposed port
 * (e.g. http://localhost:3000/api) — the only address the browser can reach.
 *
 * This dual-URL pattern is required in any containerised Nuxt SSR setup where
 * the backend is on a private Docker network unreachable from the browser.
 */
export const useApiBase = (): string => {
  const config = useRuntimeConfig();
  return import.meta.server
    ? (config.apiBaseInternal as string)
    : config.public.apiBase;
};

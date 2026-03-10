/**
 * Persists a session ID in a cookie so that the same cart session
 * is kept across page loads and SSR requests.
 */
export const useSession = () => {
  return useCookie('shop_session_id', {
    default: () => crypto.randomUUID(),
    maxAge: 60 * 60 * 24 * 7, // 7 days
    sameSite: 'lax',
  });
};

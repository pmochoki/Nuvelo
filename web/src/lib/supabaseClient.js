import { createClient } from "@supabase/supabase-js";

const url = import.meta.env.VITE_SUPABASE_URL || "";
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || "";

export const isSupabaseConfigured = Boolean(
  typeof url === "string" && url.length > 0 && typeof anonKey === "string" && anonKey.length > 0
);

/**
 * OAuth + magic-link redirect. Production builds use https://nuvelo.one unless
 * VITE_AUTH_REDIRECT_URL is set. Local dev uses the current origin.
 */
export const getAuthRedirectUrl = () => {
  const explicit = import.meta.env.VITE_AUTH_REDIRECT_URL || import.meta.env.VITE_SITE_URL;
  if (explicit) {
    return explicit;
  }
  if (import.meta.env.DEV && typeof window !== "undefined") {
    return window.location.origin;
  }
  return "https://nuvelo.one";
};

export const supabase = isSupabaseConfigured
  ? createClient(url, anonKey, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
        flowType: "pkce",
        storage: typeof window !== "undefined" ? window.localStorage : undefined
      }
    })
  : null;

const { createClient } = require("@supabase/supabase-js");

let cached;

/**
 * Supabase client with service role (server-only). Bypasses RLS; use only in Vercel `/api/*`.
 * Returns null if URL/key env vars are missing (handlers may fall back to file store).
 */
function getSupabaseAdmin() {
  const url = process.env.SUPABASE_URL || process.env.NUVELO_SUPABASE_URL || "";
  const key =
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NUVELO_SUPABASE_SERVICE_ROLE_KEY || "";
  if (!url.trim() || !key.trim()) {
    return null;
  }
  if (!cached) {
    cached = createClient(url.trim(), key.trim(), {
      auth: { persistSession: false, autoRefreshToken: false }
    });
  }
  return cached;
}

function isListingsDbEnabled() {
  return Boolean(getSupabaseAdmin());
}

module.exports = { getSupabaseAdmin, isListingsDbEnabled };

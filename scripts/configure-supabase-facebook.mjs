#!/usr/bin/env node
/**
 * Enable Facebook OAuth on Nuvelo Supabase via Management API.
 *
 * 1. Meta app → Settings → Basic → App ID + App Secret
 * 2. Create token: https://supabase.com/dashboard/account/tokens
 * 3. Run:
 *    FACEBOOK_APP_ID=123 FACEBOOK_APP_SECRET=abc SUPABASE_ACCESS_TOKEN=sbp_xxx \
 *      node scripts/configure-supabase-facebook.mjs
 */

const PROJECT_REF = "ahiujuljjbozmfwoqtli";
const CALLBACK_URL = `https://${PROJECT_REF}.supabase.co/auth/v1/callback`;

async function api(method, token, body) {
  const res = await fetch(`https://api.supabase.com/v1/projects/${PROJECT_REF}/config/auth`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json"
    },
    body: body ? JSON.stringify(body) : undefined
  });
  const text = await res.text();
  let json = null;
  try {
    json = text ? JSON.parse(text) : null;
  } catch {
    json = { raw: text };
  }
  if (!res.ok) {
    throw new Error(`API ${res.status}: ${JSON.stringify(json)}`);
  }
  return json;
}

async function main() {
  const appId = String(process.env.FACEBOOK_APP_ID || "").trim();
  const appSecret = String(process.env.FACEBOOK_APP_SECRET || "").trim();
  const token = String(process.env.SUPABASE_ACCESS_TOKEN || "").trim();

  if (!appId || !appSecret) {
    console.log("\nMissing Meta credentials.");
    console.log("Get them from developers.facebook.com → Your App → Settings → Basic");
    console.log("\nThen run:");
    console.log("  FACEBOOK_APP_ID=... FACEBOOK_APP_SECRET=... SUPABASE_ACCESS_TOKEN=sbp_... \\");
    console.log("    node scripts/configure-supabase-facebook.mjs");
    console.log("\nMeta Valid OAuth Redirect URI must include:");
    console.log(" ", CALLBACK_URL);
    process.exit(1);
  }

  if (!token) {
    console.log("\nNo SUPABASE_ACCESS_TOKEN.");
    console.log("Create one: https://supabase.com/dashboard/account/tokens");
    console.log("\nOr paste manually in Supabase → Authentication → Providers → Facebook:");
    console.log("  Facebook client ID:", appId);
    console.log("  Facebook client secret:", "(App Secret from Meta)");
    process.exit(1);
  }

  const before = await api("GET", token);
  console.log("Before:");
  console.log("  external_facebook_enabled:", before.external_facebook_enabled);
  console.log("  external_facebook_client_id:", before.external_facebook_client_id || "(empty)");
  console.log("  external_facebook_secret set:", Boolean(before.external_facebook_secret));

  const after = await api("PATCH", token, {
    external_facebook_enabled: true,
    external_facebook_client_id: appId,
    external_facebook_secret: appSecret
  });

  console.log("\nAfter PATCH:");
  console.log("  external_facebook_enabled:", after.external_facebook_enabled);
  console.log("  external_facebook_client_id:", after.external_facebook_client_id);
  console.log("  external_facebook_secret set:", Boolean(after.external_facebook_secret));
  console.log("\nDone. Hard-refresh nuvelo.one → Continue with Facebook.");
  console.log("Meta app must list redirect URI:", CALLBACK_URL);
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});

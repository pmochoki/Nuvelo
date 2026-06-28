#!/usr/bin/env node
/**
 * Enable Apple OAuth on Nuvelo Supabase via Management API.
 * Fixes "invalid_client" / "Unable to exchange external code" when dashboard paste fails.
 *
 * 1. Create token: https://supabase.com/dashboard/account/tokens
 * 2. Run:
 *    SUPABASE_ACCESS_TOKEN=sbp_xxx node scripts/configure-supabase-apple.mjs
 *
 * Optional: --dry-run (generate JWT only, no API call)
 */

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

const PROJECT_REF = "ahiujuljjbozmfwoqtli";
const TEAM_ID = "H9JAV8HGW9";
const KEY_ID = "FX25BH5D5X";
const CLIENT_ID = "one.nuvelo.web";
const P8_PATH = path.join(process.env.HOME || "", "Desktop/AuthKey_FX25BH5D5X.p8");

function base64url(input) {
  return Buffer.from(input).toString("base64url");
}

function generateAppleSecret() {
  if (!fs.existsSync(P8_PATH)) {
    throw new Error(`Missing .p8 key: ${P8_PATH}`);
  }
  const privateKey = fs.readFileSync(P8_PATH, "utf8");
  const now = Math.floor(Date.now() / 1000);
  const exp = now + 60 * 60 * 24 * 180;
  const header = { alg: "ES256", kid: KEY_ID };
  const payload = {
    iss: TEAM_ID,
    iat: now,
    exp,
    aud: "https://appleid.apple.com",
    sub: CLIENT_ID
  };
  const unsigned = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(payload))}`;
  const sign = crypto.createSign("SHA256");
  sign.update(unsigned);
  sign.end();
  const signature = sign.sign(privateKey, "base64url");
  return `${unsigned}.${signature}`;
}

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
  const dryRun = process.argv.includes("--dry-run");
  const secret = generateAppleSecret();
  const exp = JSON.parse(Buffer.from(secret.split(".")[1], "base64url").toString()).exp;

  console.log("\nApple JWT generated (valid until", new Date(exp * 1000).toISOString().slice(0, 10) + ")");
  console.log("Services ID (Client ID):", CLIENT_ID);
  fs.writeFileSync(path.join(process.env.HOME || ".", "Desktop/nuvelo-apple-jwt.txt"), secret + "\n", "utf8");
  console.log("Saved to ~/Desktop/nuvelo-apple-jwt.txt\n");

  if (dryRun) {
    console.log("Dry run — not calling Supabase API.");
    return;
  }

  const token = process.env.SUPABASE_ACCESS_TOKEN || "";
  if (!token) {
    console.log("No SUPABASE_ACCESS_TOKEN — paste JWT manually:");
    console.log("  Supabase → Authentication → Providers → Apple");
    console.log("  Client IDs:", CLIENT_ID);
    console.log("  Secret Key: contents of ~/Desktop/nuvelo-apple-jwt.txt");
    console.log("\nOr re-run with your dashboard token:");
    console.log("  SUPABASE_ACCESS_TOKEN=sbp_... node scripts/configure-supabase-apple.mjs");
    process.exit(1);
  }

  const before = await api("GET", token);
  console.log("Before:");
  console.log("  external_apple_enabled:", before.external_apple_enabled);
  console.log("  external_apple_client_id:", before.external_apple_client_id || "(empty)");
  console.log("  external_apple_secret set:", Boolean(before.external_apple_secret));

  const after = await api("PATCH", token, {
    external_apple_enabled: true,
    external_apple_client_id: CLIENT_ID,
    external_apple_secret: secret
  });

  console.log("\nAfter PATCH:");
  console.log("  external_apple_enabled:", after.external_apple_enabled);
  console.log("  external_apple_client_id:", after.external_apple_client_id);
  console.log("  external_apple_secret set:", Boolean(after.external_apple_secret));
  console.log("\nDone. Wait 10s, hard-refresh nuvelo.one, try Continue with Apple.");
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});

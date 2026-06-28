#!/usr/bin/env node
/**
 * Generate the Apple OAuth client secret (JWT) for Supabase.
 *
 * Supabase → Authentication → Providers → Apple → Secret Key expects a JWT,
 * NOT the raw .p8 file contents.
 *
 * Usage:
 *   node scripts/generate-apple-client-secret.mjs \
 *     --team-id H9JAV8HGW9 \
 *     --key-id FX25BH5D5X \
 *     --client-id one.nuvelo.web \
 *     --p8 ~/Downloads/AuthKey_FX25BH5D5X.p8
 *
 * --client-id must be your Apple Services ID (web), not the app bundle ID.
 * Re-run every ~6 months and update Supabase (Apple JWT expires).
 */

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

function parseArgs(argv) {
  const out = {};
  for (let i = 2; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === "--team-id") out.teamId = argv[++i];
    else if (a === "--key-id") out.keyId = argv[++i];
    else if (a === "--client-id") out.clientId = argv[++i];
    else if (a === "--p8") out.p8Path = argv[++i];
    else if (a === "--help" || a === "-h") out.help = true;
  }
  return out;
}

function base64url(input) {
  return Buffer.from(input).toString("base64url");
}

function usage() {
  console.log(`Generate Apple Sign in with Apple client secret (JWT) for Supabase.

Required:
  --team-id     Apple Team ID (e.g. H9JAV8HGW9)
  --key-id      Key ID from Apple Developer → Keys (e.g. FX25BH5D5X)
  --client-id   Services ID for web OAuth (NOT bundle ID; e.g. one.nuvelo.web)
  --p8          Path to AuthKey_XXXXX.p8 downloaded from Apple (once)

Example:
  node scripts/generate-apple-client-secret.mjs \\
    --team-id H9JAV8HGW9 \\
    --key-id FX25BH5D5X \\
    --client-id one.nuvelo.web \\
    --p8 ~/Downloads/AuthKey_FX25BH5D5X.p8
`);
}

const args = parseArgs(process.argv);
if (args.help || !args.teamId || !args.keyId || !args.clientId || !args.p8Path) {
  usage();
  process.exit(args.help ? 0 : 1);
}

const p8Resolved = path.resolve(String(args.p8Path).replace(/^~/, process.env.HOME || ""));
if (!fs.existsSync(p8Resolved)) {
  console.error(`Error: .p8 file not found: ${p8Resolved}`);
  process.exit(1);
}

const privateKey = fs.readFileSync(p8Resolved, "utf8");
const now = Math.floor(Date.now() / 1000);
// Apple allows max ~6 months; use 180 days
const exp = now + 60 * 60 * 24 * 180;

const header = { alg: "ES256", kid: args.keyId };
const payload = {
  iss: args.teamId,
  iat: now,
  exp,
  aud: "https://appleid.apple.com",
  sub: args.clientId
};

const unsigned = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(payload))}`;
const sign = crypto.createSign("SHA256");
sign.update(unsigned);
sign.end();
const signature = sign.sign(privateKey, "base64url");
const jwt = `${unsigned}.${signature}`;

console.log("\n--- Paste this into Supabase → Apple → Secret Key ---\n");
console.log(jwt);
console.log("\n--- Client IDs field: use your Services ID ---\n");
console.log(args.clientId);
console.log(`\nExpires (approx): ${new Date(exp * 1000).toISOString().slice(0, 10)}`);
console.log("Set a calendar reminder to regenerate before then.\n");

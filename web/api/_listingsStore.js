/**
 * Ephemeral listings store for Vercel serverless (no DB yet).
 * Persists to /tmp on Vercel (survives warm invocations) or ./data locally.
 *
 * Fallback when SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY are unset. Production should use Postgres via `_listingsDb.js`.
 */

const fs = require("fs");
const path = require("path");

const DATA_PATH =
  process.env.VERCEL === "1"
    ? path.join("/tmp", "nuvelo-listings-store.json")
    : path.join(process.cwd(), "data", "nuvelo-listings-store.json");

let cache = null;

function ensureDir() {
  if (process.env.VERCEL === "1") {
    return;
  }
  try {
    fs.mkdirSync(path.dirname(DATA_PATH), { recursive: true });
  } catch (e) {
    console.error("[listingsStore] mkdir", e);
  }
}

function load() {
  if (cache) {
    return cache;
  }
  try {
    if (fs.existsSync(DATA_PATH)) {
      const raw = fs.readFileSync(DATA_PATH, "utf8");
      const parsed = JSON.parse(raw);
      cache = Array.isArray(parsed) ? parsed : [];
      return cache;
    }
  } catch (e) {
    console.error("[listingsStore] load", e);
  }
  cache = [];
  return cache;
}

function persist() {
  try {
    ensureDir();
    fs.writeFileSync(DATA_PATH, JSON.stringify(cache, null, 0), "utf8");
  } catch (e) {
    console.error("[listingsStore] persist", e);
  }
}

function addListing(row) {
  const listings = load();
  const id =
    row.id || `ls_${Date.now()}_${Math.random().toString(36).slice(2, 11)}`;
  const now = new Date().toISOString();
  const full = {
    ...row,
    id,
    status: row.status || "pending",
    createdAt: row.createdAt || now,
    updatedAt: now
  };
  listings.unshift(full);
  cache = listings;
  persist();
  return full;
}

function getAll() {
  return load().slice();
}

function getById(id) {
  return load().find((x) => String(x.id) === String(id)) || null;
}

module.exports = { addListing, getAll, getById };

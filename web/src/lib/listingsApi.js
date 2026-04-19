import { getDemoListingById, mergeListingsWithDemos } from "../data/demoListings.js";
import { DONATIONS_CATEGORY_ID } from "../data/donationConstants.js";

const DONATIONS_CLAIMED_KEY = "nuvelo_donations_claimed";
const LOCAL_LISTINGS_KEY = "nuvelo_local_listings_v1";

function readDonationClaimedStore() {
  try {
    const raw = localStorage.getItem(DONATIONS_CLAIMED_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch {
    return {};
  }
}

function applyDonationClaimed(listing) {
  if (!listing || listing.categoryId !== DONATIONS_CATEGORY_ID) {
    return listing;
  }
  const store = readDonationClaimedStore();
  const fromStore = store[listing.id];
  const claimed =
    typeof fromStore === "boolean" ? fromStore : Boolean(listing.categoryFields?.claimed);
  return {
    ...listing,
    categoryFields: {
      ...listing.categoryFields,
      claimed
    }
  };
}

/** Persisted claimed state for donor flow (demo + API listings). */
export function setDonationClaimed(listingId, claimed) {
  const store = readDonationClaimedStore();
  store[listingId] = Boolean(claimed);
  try {
    localStorage.setItem(DONATIONS_CLAIMED_KEY, JSON.stringify(store));
  } catch {
    /* ignore */
  }
}

/**
 * Browser API base for listings/auth.
 *
 * - `VITE_API_URL` unset or whitespace-only → same-origin `/api` (Vercel Functions in this repo).
 * - Set a full URL only if the API is on another origin (CORS must allow your site).
 *
 * Vercel (Production) — typical setup:
 * - Omit `VITE_API_URL` or set it empty so the app calls `/api` on the deployed domain.
 * - Set `VITE_DEMO_LISTINGS=false` so browse/detail/post do not mix in demo listings or offline fallbacks.
 * - Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` for auth (baked in at build time).
 */
function getApiBase() {
  const raw = import.meta.env.VITE_API_URL;
  if (raw == null || String(raw).trim() === "") {
    return "/api";
  }
  return String(raw).trim().replace(/\/+$/, "");
}

/**
 * Demo listings are opt-in in production builds so nuvelo.one never mixes fake ads with real ones.
 * Development: defaults on unless VITE_DEMO_LISTINGS=false.
 */
function demosEnabled() {
  if (import.meta.env.PROD) {
    return import.meta.env.VITE_DEMO_LISTINGS === "true";
  }
  return import.meta.env.VITE_DEMO_LISTINGS !== "false";
}

function readLocalListings() {
  try {
    const raw = localStorage.getItem(LOCAL_LISTINGS_KEY);
    if (!raw) {
      return [];
    }
    const p = JSON.parse(raw);
    return Array.isArray(p) ? p : [];
  } catch {
    return [];
  }
}

function saveLocalListings(rows) {
  localStorage.setItem(LOCAL_LISTINGS_KEY, JSON.stringify(rows.slice(0, 200)));
}

async function apiFetch(path, options = {}) {
  const base = getApiBase();
  const pathPart = path.startsWith("/") ? path : `/${path}`;
  const url = base.startsWith("http") ? `${base}${pathPart}` : `${base}${pathPart}`;

  let res;
  try {
    res = await fetch(url, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        ...(options.headers || {})
      }
    });
  } catch (err) {
    console.error("[Nuvelo] API network error", { url, baseEnv: import.meta.env.VITE_API_URL ?? "(same-origin /api)" }, err);
    throw new Error("Unable to reach the server. Please try again shortly.");
  }
  const text = await res.text();
  let payload = null;
  if (text) {
    try {
      payload = JSON.parse(text);
    } catch {
      payload = text;
    }
  }
  if (!res.ok) {
    const msg =
      payload?.error ||
      (Array.isArray(payload?.errors) ? payload.errors.join(", ") : "") ||
      `Request failed (${res.status})`;
    console.error("[Nuvelo] API HTTP error", { url, status: res.status, msg });
    throw new Error(msg);
  }
  return payload;
}

/** Reject invalid / negative prices from API; null means unspecified. */
function sanitizeListingPrice(raw) {
  if (raw == null || raw === "") {
    return null;
  }
  const n = Number(raw);
  if (!Number.isFinite(n) || n < 0) {
    return null;
  }
  return n;
}

export function normalizeListingRow(row) {
  if (!row) {
    return null;
  }
  const base = {
    id: row.id,
    userId: row.userId,
    categoryId: row.categoryId,
    title: row.title,
    description: row.description,
    price: sanitizeListingPrice(row.price),
    currency: row.currency || "HUF",
    condition: row.condition,
    location: row.location,
    images: Array.isArray(row.images) ? row.images : [],
    categoryFields:
      row.categoryFields && typeof row.categoryFields === "object"
        ? row.categoryFields
        : {},
    createdAt: row.createdAt,
    updatedAt: row.updatedAt || row.createdAt,
    featured: Boolean(row.featured),
    isFeatured: Boolean(row.featured),
    viewCount: Number(row.viewCount) || 0,
    views: Number(row.viewCount) || 0,
    sellerName: row.sellerName || "Seller",
    sellerVerified: Boolean(row.sellerVerified),
    enterprise: Boolean(row.enterprise),
    status: row.status
  };
  return applyDonationClaimed(base);
}

/**
 * @param {object} params
 * @param {string} [params.forUserId] — when set, includes this user's pending listings from API + offline queue
 */
export async function fetchListings(params = {}) {
  const { query: keyword, categoryId, location, minPrice, maxPrice, forUserId } = params;
  const qs = new URLSearchParams();
  if (keyword) {
    qs.set("query", String(keyword).trim());
  }
  if (categoryId) {
    qs.set("categoryId", String(categoryId));
  }
  if (location) {
    qs.set("location", String(location).trim());
  }
  if (minPrice != null && minPrice !== "" && !Number.isNaN(Number(minPrice))) {
    qs.set("minPrice", String(Number(minPrice)));
  }
  if (maxPrice != null && maxPrice !== "" && !Number.isNaN(Number(maxPrice))) {
    qs.set("maxPrice", String(Number(maxPrice)));
  }
  if (forUserId) {
    qs.set("userId", String(forUserId));
  }

  let real = [];
  const listingsUrl = `/listings${qs.toString() ? `?${qs}` : ""}`;
  try {
    const data = await apiFetch(listingsUrl);
    real = (Array.isArray(data) ? data : []).map(normalizeListingRow);
    const hasServerFilters = Boolean(
      keyword || categoryId || location || minPrice != null || maxPrice != null
    );
    if (real.length === 0 && hasServerFilters && !forUserId) {
      try {
        const rawUnfiltered = await apiFetch("/listings");
        const n = Array.isArray(rawUnfiltered) ? rawUnfiltered.length : 0;
        console.warn("[Nuvelo] Filtered listings empty; unfiltered API returned count:", n);
      } catch (e2) {
        console.error("[Nuvelo] Fallback unfiltered listings probe failed", e2);
      }
    }
    if (real.length === 0 && !forUserId) {
      console.warn("[Nuvelo] fetchListings returned 0 rows", {
        listingsUrl,
        params: { keyword, categoryId, location, minPrice, maxPrice }
      });
    }
  } catch (e) {
    console.error("[Nuvelo] fetchListings failed", { url: listingsUrl, message: e?.message }, e);
    if (forUserId) {
      if (!demosEnabled()) {
        throw e;
      }
    } else {
      /* Public browse / home: API down or error still shows “no listings” empty state, not outage copy. */
      real = [];
    }
  }

  const locals = readLocalListings().map(normalizeListingRow);
  let mergedLocals = [];
  if (forUserId) {
    mergedLocals = locals.filter((l) => String(l.userId) === String(forUserId));
  } else {
    mergedLocals = locals.filter((l) => {
      const st = String(l.status || "").toLowerCase();
      return st === "approved" || st === "active";
    });
  }

  const seen = new Set(real.map((r) => String(r.id)));
  const extra = mergedLocals.filter((l) => l?.id && !seen.has(String(l.id)));
  const combined = [...real, ...extra];

  if (!demosEnabled()) {
    return combined;
  }
  return mergeListingsWithDemos(combined, params).map((x) => normalizeListingRow(x));
}

export async function fetchListing(id) {
  try {
    const data = await apiFetch(`/listings/${encodeURIComponent(id)}`);
    if (data) {
      return normalizeListingRow(data);
    }
  } catch (e) {
    console.error(e);
    if (!demosEnabled()) {
      throw e;
    }
  }
  const local = readLocalListings().find((l) => String(l.id) === String(id));
  if (local) {
    return normalizeListingRow(local);
  }
  if (!demosEnabled()) {
    return null;
  }
  const demo = getDemoListingById(id);
  return demo ? normalizeListingRow(demo) : null;
}

function isValidationErrorMessage(msg) {
  return /required|invalid|must be|Price must|Listing rate|banned|errors/i.test(String(msg || ""));
}

function createListingLocalFallback(row) {
  const id = `local-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`;
  const now = new Date().toISOString();
  const listing = normalizeListingRow({
    ...row,
    id,
    userId: row.userId,
    status: "Pending",
    createdAt: now,
    updatedAt: now
  });
  const all = readLocalListings();
  all.unshift(listing);
  try {
    saveLocalListings(all);
  } catch (e) {
    console.error(e);
    throw new Error("Unable to submit your ad right now. Please try again in a moment.");
  }
  return listing;
}

export async function createListing(formPayload, userId) {
  const isDonation = formPayload.categoryId === DONATIONS_CATEGORY_ID;
  const rawCond = String(formPayload.condition || "other");
  const cond = isDonation
    ? "other"
    : rawCond === "new"
      ? "new"
      : rawCond === "used"
        ? "used"
        : rawCond === "good"
          ? "other"
          : "other";
  const images = (formPayload.images || []).filter(
    (u) => typeof u === "string" && /^https?:\/\//i.test(u)
  );
  let priceVal = null;
  if (isDonation) {
    priceVal = 0;
  } else if (formPayload.price != null && formPayload.price !== "") {
    const n = Number(formPayload.price);
    if (!Number.isFinite(n) || n < 0) {
      throw new Error("Price must be zero or a positive number.");
    }
    priceVal = n;
  }
  const row = {
    userId,
    title: formPayload.title,
    description: formPayload.description,
    categoryId: formPayload.categoryId,
    price: priceVal,
    currency: "HUF",
    condition: cond,
    location: formPayload.location,
    images,
    categoryFields: formPayload.categoryFields || {}
  };

  try {
    const data = await apiFetch("/listings", {
      method: "POST",
      body: JSON.stringify(row)
    });
    return normalizeListingRow(data);
  } catch (e) {
    const msg = String(e?.message || "");
    if (isValidationErrorMessage(msg)) {
      throw new Error(
        msg.length > 120 || /https?:\/\//i.test(msg)
          ? "Please check your listing details and try again."
          : msg
      );
    }
    if (!demosEnabled()) {
      console.error("[createListing] API error (no local fallback when VITE_DEMO_LISTINGS=false)", e);
      throw new Error(
        msg && msg.length < 200 && !/https?:\/\//i.test(msg)
          ? msg
          : "Unable to submit your ad — the server could not be reached. Please try again shortly."
      );
    }
    console.warn("[createListing] API unavailable, saving locally", e);
    try {
      return createListingLocalFallback({ ...row, userId });
    } catch (e2) {
      console.error(e2);
      throw new Error("Unable to submit your ad right now. Please try again in a moment.");
    }
  }
}

/**
 * Legacy sign-in: POST same-origin `/api/auth/login` → Vercel proxies to `LISTINGS_BACKEND_URL` /
 * `NUVELO_API_URL` (see `api/auth/login.js`). Used only when Supabase is not configured; production
 * builds disable this path unless `VITE_ALLOW_LEGACY_AUTH=true` (see `web/src/main.js`).
 */
export async function loginUser({ name, role, email, phone }) {
  const data = await apiFetch("/auth/login", {
    method: "POST",
    body: JSON.stringify({ name, role, email, phone })
  });
  return {
    id: data.id,
    name: data.name || "User",
    role: data.role || role || "buyer",
    email: data.email || email || "",
    phone: data.phone || phone || "",
    avatarUrl: data.avatar_url || data.avatarUrl || ""
  };
}

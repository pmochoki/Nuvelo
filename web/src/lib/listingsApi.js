import { getDemoListingById, mergeListingsWithDemos } from "../data/demoListings.js";
import { DONATIONS_CATEGORY_ID } from "../data/donationConstants.js";

const DONATIONS_CLAIMED_KEY = "nuvelo_donations_claimed";

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

const DEFAULT_API_URL = "https://nuvelo-backend.onrender.com";
const API_URL = (import.meta.env.VITE_API_URL || DEFAULT_API_URL).replace(/\/+$/, "");

/** Set VITE_DEMO_LISTINGS=false in Vercel to hide sample ads in production. */
function demosEnabled() {
  return import.meta.env.VITE_DEMO_LISTINGS !== "false";
}

async function apiFetch(path, options = {}) {
  const url = `${API_URL}${path.startsWith("/") ? path : `/${path}`}`;
  const res = await fetch(url, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(options.headers || {})
    }
  });
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
    enterprise: Boolean(row.enterprise)
  };
  return applyDonationClaimed(base);
}

export async function fetchListings(params = {}) {
  const { query: keyword, categoryId, location, minPrice, maxPrice } = params;
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
  let real = [];
  try {
    const data = await apiFetch(`/listings${qs.toString() ? `?${qs}` : ""}`);
    real = (Array.isArray(data) ? data : []).map(normalizeListingRow);
  } catch (e) {
    console.error(e);
    if (!demosEnabled()) {
      throw e;
    }
  }

  if (!demosEnabled()) {
    return real;
  }
  return mergeListingsWithDemos(real, params).map((x) => normalizeListingRow(x));
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
  if (!demosEnabled()) {
    return null;
  }
  const demo = getDemoListingById(id);
  return demo ? normalizeListingRow(demo) : null;
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
  const data = await apiFetch("/listings", {
    method: "POST",
    body: JSON.stringify(row)
  });
  return normalizeListingRow(data);
}

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

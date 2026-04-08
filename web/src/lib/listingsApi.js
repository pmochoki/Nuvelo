import { getDemoListingById, mergeListingsWithDemos } from "../data/demoListings.js";

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

export function normalizeListingRow(row) {
  if (!row) {
    return null;
  }
  return {
    id: row.id,
    userId: row.userId,
    categoryId: row.categoryId,
    title: row.title,
    description: row.description,
    price: row.price != null ? Number(row.price) : null,
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
    sellerVerified: false,
    enterprise: false
  };
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
  return mergeListingsWithDemos(real, params);
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
  return getDemoListingById(id);
}

export async function createListing(formPayload, userId) {
  const rawCond = String(formPayload.condition || "other");
  const cond =
    rawCond === "new"
      ? "new"
      : rawCond === "used"
        ? "used"
        : rawCond === "good"
          ? "other"
          : "other";
  const images = (formPayload.images || []).filter(
    (u) => typeof u === "string" && /^https?:\/\//i.test(u)
  );
  const row = {
    userId,
    title: formPayload.title,
    description: formPayload.description,
    categoryId: formPayload.categoryId,
    price: formPayload.price,
    currency: formPayload.currency || "HUF",
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
    phone: data.phone || phone || ""
  };
}

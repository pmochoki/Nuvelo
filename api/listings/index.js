const { applyCors } = require("../_cors");
const store = require("../_listingsStore");
const { isListingsDbEnabled } = require("../_supabaseAdmin");
const { listListings, insertListing } = require("../_listingsDb");
const { readJsonBody } = require("../_readJsonBody");

/**
 * GET /api/listings — all listings (filter: public = approved only; ?userId= = that user's rows incl. pending)
 * POST /api/listings — create listing (JSON body), returns created row with status pending
 *
 * Uses Supabase Postgres when SUPABASE_URL + SUPABASE_SERVICE_ROLE_KEY are set; otherwise ephemeral file store.
 */

function filterListings(listings, q) {
  const {
    query: keyword,
    categoryId,
    location,
    minPrice,
    maxPrice,
    userId,
    status: statusFilter
  } = q;

  return listings.filter((listing) => {
    if (userId) {
      if (String(listing.userId) !== String(userId)) {
        return false;
      }
    } else if (listing.status && listing.status !== "approved") {
      return false;
    }
    if (statusFilter && listing.status !== statusFilter) {
      return false;
    }
    if (categoryId && String(listing.categoryId) !== String(categoryId)) {
      return false;
    }
    if (location && listing.location) {
      if (!String(listing.location).toLowerCase().includes(String(location).toLowerCase())) {
        return false;
      }
    }
    if (keyword) {
      const text = `${listing.title || ""} ${listing.description || ""}`.toLowerCase();
      if (!text.includes(String(keyword).toLowerCase())) {
        return false;
      }
    }
    const p = listing.price;
    if (minPrice != null && minPrice !== "" && p != null && Number(p) < Number(minPrice)) {
      return false;
    }
    if (maxPrice != null && maxPrice !== "" && p != null && Number(p) > Number(maxPrice)) {
      return false;
    }
    return true;
  });
}

module.exports = async (req, res) => {
  applyCors(req, res);
  if (req.method === "OPTIONS") {
    res.statusCode = 204;
    return res.end();
  }

  if (req.method === "GET") {
    const q = { ...(req.query || {}) };
    delete q.path;
    delete q.slug;
    delete q.id;
    try {
      const rows = isListingsDbEnabled()
        ? await listListings(q)
        : filterListings(store.getAll(), q);
      res.statusCode = 200;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify(rows));
    } catch (e) {
      console.error("[api/listings] GET", e);
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify({ error: "Failed to load listings" }));
    }
  }

  if (req.method === "POST") {
    let payload;
    try {
      payload = await readJsonBody(req);
    } catch (e) {
      res.statusCode = 400;
      return res.end(JSON.stringify({ error: "Invalid JSON body" }));
    }
    if (!payload || typeof payload.title !== "string" || payload.title.length < 3) {
      res.statusCode = 400;
      return res.end(JSON.stringify({ error: "Title is required." }));
    }
    if (!payload.categoryId) {
      res.statusCode = 400;
      return res.end(JSON.stringify({ error: "categoryId is required." }));
    }
    try {
      const row = {
        title: payload.title,
        description: payload.description || "",
        categoryId: payload.categoryId,
        price: payload.price ?? null,
        currency: payload.currency || "HUF",
        condition: payload.condition || "other",
        location: payload.location || "Hungary",
        images: Array.isArray(payload.images) ? payload.images : [],
        categoryFields:
          payload.categoryFields && typeof payload.categoryFields === "object" ? payload.categoryFields : {},
        userId: payload.userId || "anonymous",
        status: "pending"
      };
      const created = isListingsDbEnabled() ? await insertListing(row) : store.addListing(row);
      res.statusCode = 201;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify(created));
    } catch (e) {
      console.error("[api/listings] POST", e);
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify({ error: "Failed to create listing" }));
    }
  }

  res.statusCode = 405;
  return res.end(JSON.stringify({ error: "Method not allowed" }));
};

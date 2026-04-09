const { applyCors } = require("../_cors");
const store = require("../_listingsStore");

/**
 * GET /api/listings — all listings (filter: public = approved only; ?userId= = that user's rows incl. pending)
 * POST /api/listings — create listing (JSON body), returns created row with status pending
 *
 * No longer proxies to Render; uses in-repo store. TODO: wire to a real database.
 */

async function readJsonBody(req) {
  if (req.body && typeof req.body === "object" && !Buffer.isBuffer(req.body)) {
    return req.body;
  }
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", (chunk) => {
      data += chunk;
    });
    req.on("end", () => {
      try {
        resolve(data ? JSON.parse(data) : {});
      } catch (e) {
        reject(e);
      }
    });
    req.on("error", reject);
  });
}

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
    const rows = filterListings(store.getAll(), q);
    res.statusCode = 200;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify(rows));
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
    const created = store.addListing({
      title: payload.title,
      description: payload.description || "",
      categoryId: payload.categoryId,
      price: payload.price ?? null,
      currency: payload.currency || "HUF",
      condition: payload.condition || "other",
      location: payload.location || "Hungary",
      images: Array.isArray(payload.images) ? payload.images : [],
      categoryFields: payload.categoryFields && typeof payload.categoryFields === "object" ? payload.categoryFields : {},
      userId: payload.userId || "anonymous",
      status: "pending"
    });
    res.statusCode = 201;
    res.setHeader("Content-Type", "application/json");
    return res.end(JSON.stringify(created));
  }

  res.statusCode = 405;
  return res.end(JSON.stringify({ error: "Method not allowed" }));
};

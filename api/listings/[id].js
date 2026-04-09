const { applyCors } = require("../_cors");
const store = require("../_listingsStore");
const { isListingsDbEnabled } = require("../_supabaseAdmin");
const { getById, updateListing } = require("../_listingsDb");
const { readJsonBody } = require("../_readJsonBody");

/** GET /api/listings/:id — single listing. PATCH — update (requires body.userId matching listing owner). */
module.exports = async (req, res) => {
  applyCors(req, res);
  if (req.method === "OPTIONS") {
    res.statusCode = 204;
    return res.end();
  }

  const id = req.query?.id;
  if (!id || typeof id !== "string") {
    res.statusCode = 400;
    return res.end(JSON.stringify({ error: "Missing listing id" }));
  }

  if (req.method === "GET") {
    try {
      const listing = isListingsDbEnabled() ? await getById(id) : store.getById(id);
      if (!listing) {
        res.statusCode = 404;
        return res.end(JSON.stringify({ error: "Listing not found" }));
      }
      res.statusCode = 200;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify(listing));
    } catch (e) {
      console.error("[api/listings/:id] GET", e);
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify({ error: "Failed to load listing" }));
    }
  }

  if (req.method === "PATCH") {
    let payload;
    try {
      payload = await readJsonBody(req);
    } catch (e) {
      res.statusCode = 400;
      return res.end(JSON.stringify({ error: "Invalid JSON body" }));
    }
    if (!payload || typeof payload.userId === "undefined") {
      res.statusCode = 400;
      return res.end(JSON.stringify({ error: "userId is required for updates." }));
    }
    if (!isListingsDbEnabled()) {
      res.statusCode = 503;
      return res.end(
        JSON.stringify({
          error: "Listing updates require database configuration (Supabase env vars)."
        })
      );
    }
    try {
      const result = await updateListing(id, payload, payload.userId);
      if (!result.ok) {
        res.statusCode = result.status;
        res.setHeader("Content-Type", "application/json");
        return res.end(JSON.stringify(result.body));
      }
      res.statusCode = 200;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify(result.listing));
    } catch (e) {
      console.error("[api/listings/:id] PATCH", e);
      res.statusCode = 500;
      res.setHeader("Content-Type", "application/json");
      return res.end(JSON.stringify({ error: "Failed to update listing" }));
    }
  }

  res.statusCode = 405;
  return res.end(JSON.stringify({ error: "Method not allowed" }));
};
